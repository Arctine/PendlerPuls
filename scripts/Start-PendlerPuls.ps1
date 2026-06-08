[CmdletBinding()]
param(
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$runtimeDirectory = Join-Path $projectRoot ".run"
$statePath = Join-Path $runtimeDirectory "processes.json"
$apiOutputPath = Join-Path $runtimeDirectory "api.out.log"
$apiErrorPath = Join-Path $runtimeDirectory "api.err.log"
$webOutputPath = Join-Path $runtimeDirectory "web.out.log"
$webErrorPath = Join-Path $runtimeDirectory "web.err.log"
$webDirectory = Join-Path $projectRoot "apps\web"
$solutionPath = Join-Path $projectRoot "PendlerPuls.sln"
$packageLockPath = Join-Path $webDirectory "package-lock.json"
$packageMarkerPath = Join-Path $runtimeDirectory "package-lock.sha256"
$appUrl = "http://127.0.0.1:5173"
$healthUrl = "http://127.0.0.1:5050/api/health"

function Get-ListeningProcessId {
    param([int]$Port)

    return Get-NetTCPConnection `
        -LocalPort $Port `
        -State Listen `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty OwningProcess
}

function Test-Url {
    param([string]$Url)

    try {
        $response = Invoke-WebRequest `
            -Uri $Url `
            -UseBasicParsing `
            -TimeoutSec 2
        return $response.StatusCode -ge 200 -and $response.StatusCode -lt 400
    }
    catch {
        return $false
    }
}

function Wait-ForUrl {
    param(
        [string]$Url,
        [int]$TimeoutSeconds = 30
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-Url -Url $Url) {
            return $true
        }

        Start-Sleep -Milliseconds 500
    }

    return $false
}

function Stop-StartedProcesses {
    param([System.Diagnostics.Process[]]$Processes)

    foreach ($process in $Processes) {
        if ($null -ne $process -and -not $process.HasExited) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
    }

    foreach ($port in @(5050, 5173)) {
        $processId = Get-ListeningProcessId -Port $port
        if ($processId) {
            Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        }
    }
}

function Show-LogTail {
    param(
        [string]$Label,
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        Write-Host ""
        Write-Host "$Label ($Path)" -ForegroundColor Yellow
        Get-Content -LiteralPath $Path -Tail 20
    }
}

try {
    Set-Location $projectRoot
    New-Item -ItemType Directory -Path $runtimeDirectory -Force | Out-Null

    $apiProcessId = Get-ListeningProcessId -Port 5050
    $webProcessId = Get-ListeningProcessId -Port 5173

    if ($apiProcessId -and $webProcessId -and (Test-Url $healthUrl) -and (Test-Url $appUrl)) {
        Write-Host "PendlerPuls is already running." -ForegroundColor Green
        Write-Host $appUrl

        if (-not $NoBrowser) {
            Start-Process $appUrl
        }

        exit 0
    }

    if ($apiProcessId -or $webProcessId) {
        throw "Port 5050 or 5173 is already in use. Run STOP-PENDLERPULS.cmd or close the program using that port."
    }

    foreach ($command in @("dotnet", "node", "npm")) {
        if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
            throw "Required command '$command' was not found. Install .NET 10 and Node.js 20 or newer."
        }
    }

    Write-Host "Preparing PendlerPuls..." -ForegroundColor Cyan

    & dotnet restore $solutionPath
    if ($LASTEXITCODE -ne 0) {
        throw "The .NET dependency restore failed."
    }

    $packageLockHash = (Get-FileHash -LiteralPath $packageLockPath -Algorithm SHA256).Hash
    $installedHash = if (Test-Path -LiteralPath $packageMarkerPath) {
        (Get-Content -LiteralPath $packageMarkerPath -Raw).Trim()
    }
    else {
        ""
    }

    $nodeModulesPath = Join-Path $webDirectory "node_modules"
    if (-not (Test-Path -LiteralPath $nodeModulesPath) -or $installedHash -ne $packageLockHash) {
        Write-Host "Installing frontend dependencies..." -ForegroundColor Cyan
        Push-Location $webDirectory
        try {
            & npm ci
            if ($LASTEXITCODE -ne 0) {
                throw "The frontend dependency installation failed."
            }
        }
        finally {
            Pop-Location
        }

        Set-Content `
            -LiteralPath $packageMarkerPath `
            -Value $packageLockHash `
            -Encoding ASCII
    }

    Remove-Item `
        -LiteralPath $apiOutputPath, $apiErrorPath, $webOutputPath, $webErrorPath `
        -Force `
        -ErrorAction SilentlyContinue

    Write-Host "Starting API and web client..." -ForegroundColor Cyan

    $apiProcess = Start-Process `
        -FilePath "dotnet" `
        -ArgumentList @(
            "run",
            "--no-restore",
            "--project",
            "apps/api/PendlerPuls.Api.csproj",
            "--urls",
            "http://127.0.0.1:5050"
        ) `
        -WorkingDirectory $projectRoot `
        -WindowStyle Hidden `
        -RedirectStandardOutput $apiOutputPath `
        -RedirectStandardError $apiErrorPath `
        -PassThru

    $webProcess = Start-Process `
        -FilePath "npm.cmd" `
        -ArgumentList @(
            "run",
            "dev",
            "--",
            "--host",
            "127.0.0.1",
            "--strictPort",
            "--port",
            "5173"
        ) `
        -WorkingDirectory $webDirectory `
        -WindowStyle Hidden `
        -RedirectStandardOutput $webOutputPath `
        -RedirectStandardError $webErrorPath `
        -PassThru

    if (-not (Wait-ForUrl -Url $healthUrl -TimeoutSeconds 35)) {
        Stop-StartedProcesses -Processes @($apiProcess, $webProcess)
        Show-LogTail -Label "API output" -Path $apiOutputPath
        Show-LogTail -Label "API errors" -Path $apiErrorPath
        throw "The PendlerPuls API did not become ready."
    }

    if (-not (Wait-ForUrl -Url $appUrl -TimeoutSeconds 35)) {
        Stop-StartedProcesses -Processes @($apiProcess, $webProcess)
        Show-LogTail -Label "Web output" -Path $webOutputPath
        Show-LogTail -Label "Web errors" -Path $webErrorPath
        throw "The PendlerPuls web client did not become ready."
    }

    $apiListenerId = Get-ListeningProcessId -Port 5050
    $webListenerId = Get-ListeningProcessId -Port 5173
    $apiListener = Get-Process -Id $apiListenerId
    $webListener = Get-Process -Id $webListenerId

    $state = [pscustomobject]@{
        root = $projectRoot
        startedAt = (Get-Date).ToString("o")
        api = [pscustomobject]@{
            processId = $apiListener.Id
            processStartTime = $apiListener.StartTime.ToString("o")
        }
        web = [pscustomobject]@{
            processId = $webListener.Id
            processStartTime = $webListener.StartTime.ToString("o")
        }
    }

    $state |
        ConvertTo-Json -Depth 4 |
        Set-Content -LiteralPath $statePath -Encoding UTF8

    Write-Host ""
    Write-Host "PendlerPuls is ready." -ForegroundColor Green
    Write-Host $appUrl
    Write-Host "Double-click STOP-PENDLERPULS.cmd when you are finished."

    if (-not $NoBrowser) {
        Start-Process $appUrl
    }
}
catch {
    Write-Host ""
    Write-Host "PendlerPuls could not start:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}


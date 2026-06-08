[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$runtimeDirectory = Join-Path $projectRoot ".run"
$statePath = Join-Path $runtimeDirectory "processes.json"

function Stop-TrackedProcess {
    param(
        [string]$Label,
        [pscustomobject]$ProcessState
    )

    if ($null -eq $ProcessState) {
        return
    }

    $process = Get-Process `
        -Id ([int]$ProcessState.processId) `
        -ErrorAction SilentlyContinue

    if ($null -eq $process) {
        return
    }

    $recordedStart = [DateTime]::Parse($ProcessState.processStartTime)
    $difference = [Math]::Abs(($process.StartTime - $recordedStart).TotalSeconds)
    if ($difference -gt 2) {
        Write-Host "Skipped $Label because its process ID has been reused." -ForegroundColor Yellow
        return
    }

    Stop-Process -Id $process.Id -Force
    Write-Host "Stopped $Label." -ForegroundColor Green
}

try {
    if (-not (Test-Path -LiteralPath $statePath)) {
        Write-Host "No launcher-managed PendlerPuls instance is running."
        exit 0
    }

    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    if ($state.root -ne $projectRoot) {
        throw "The runtime state belongs to another project folder."
    }

    Stop-TrackedProcess -Label "web client" -ProcessState $state.web
    Stop-TrackedProcess -Label "API" -ProcessState $state.api
    Remove-Item -LiteralPath $statePath -Force

    Write-Host "PendlerPuls is stopped." -ForegroundColor Green
}
catch {
    Write-Host "PendlerPuls could not be stopped safely:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}


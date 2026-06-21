using Microsoft.EntityFrameworkCore;
using Npgsql;
using PendlerPuls.Api.Data;
using PendlerPuls.Api.Endpoints;
using PendlerPuls.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();
builder.Services.AddProblemDetails();

var databaseProvider =
    builder.Configuration["DATABASE_PROVIDER"]
    ?? builder.Configuration["Database:Provider"]
    ?? "Sqlite";

builder.Services.AddDbContext<AppDbContext>(options =>
{
    if (databaseProvider.Equals("Postgres", StringComparison.OrdinalIgnoreCase))
    {
        options.UseNpgsql(ResolvePostgresConnectionString(builder.Configuration));
        return;
    }

    options.UseSqlite(builder.Configuration.GetConnectionString("Sqlite"));
});

builder.Services.Configure<EnturOptions>(builder.Configuration.GetSection("Entur"));
builder.Services.AddHttpClient<EnturClient>(client =>
{
    client.Timeout = TimeSpan.FromSeconds(12);
});
builder.Services.AddSingleton<PasswordService>();
builder.Services.AddSingleton<ObservationCsvExporter>();
builder.Services.AddScoped<SessionService>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("web", policy =>
    {
        policy
            .WithOrigins("http://localhost:5173", "http://127.0.0.1:5173")
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

var app = builder.Build();

app.UseExceptionHandler();
app.UseCors("web");

if (!app.Environment.IsDevelopment())
{
    app.UseDefaultFiles();
    app.UseStaticFiles();
}

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

await using (var scope = app.Services.CreateAsyncScope())
{
    var database = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await database.Database.EnsureCreatedAsync();
}

app.MapGet("/api/health", () => Results.Ok(new
{
    status = "ok",
    service = "PendlerPuls.Api",
    timeUtc = DateTimeOffset.UtcNow
}));

app.MapAuthEndpoints();
app.MapTransitEndpoints();
app.MapJourneyEndpoints();

if (!app.Environment.IsDevelopment())
{
    app.MapFallbackToFile("index.html");
}

app.Run();

static string ResolvePostgresConnectionString(IConfiguration configuration)
{
    var configured =
        configuration.GetConnectionString("Postgres")
        ?? configuration["DATABASE_URL"];

    if (string.IsNullOrWhiteSpace(configured))
    {
        throw new InvalidOperationException(
            "PostgreSQL was selected, but no Postgres connection string was configured.");
    }

    if (!Uri.TryCreate(configured, UriKind.Absolute, out var uri)
        || (uri.Scheme != "postgres" && uri.Scheme != "postgresql"))
    {
        return configured;
    }

    var credentials = uri.UserInfo.Split(':', 2);
    var builder = new NpgsqlConnectionStringBuilder
    {
        Host = uri.Host,
        Port = uri.Port > 0 ? uri.Port : 5432,
        Database = uri.AbsolutePath.TrimStart('/'),
        Username = credentials.Length > 0 ? Uri.UnescapeDataString(credentials[0]) : string.Empty,
        Password = credentials.Length > 1 ? Uri.UnescapeDataString(credentials[1]) : string.Empty
    };

    if (uri.Query.Contains("sslmode=require", StringComparison.OrdinalIgnoreCase))
    {
        builder.SslMode = SslMode.Require;
    }

    return builder.ConnectionString;
}

public partial class Program;

using Microsoft.EntityFrameworkCore;
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
        options.UseNpgsql(builder.Configuration.GetConnectionString("Postgres"));
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

app.Run();

public partial class Program;


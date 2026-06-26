using Microsoft.Extensions.Configuration;
using Npgsql;

namespace PendlerPuls.Api.Services;

public static class PostgresConnectionStringResolver
{
    public static string Resolve(IConfiguration configuration)
    {
        var configured =
            configuration["DATABASE_URL"]
            ?? configuration.GetConnectionString("Postgres");

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
}

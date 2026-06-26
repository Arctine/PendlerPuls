using Microsoft.Extensions.Configuration;
using PendlerPuls.Api.Services;

namespace PendlerPuls.Api.Tests;

public sealed class PostgresConnectionStringResolverTests
{
    [Fact]
    public void Resolve_PrefersDatabaseUrlOverAppSettingsConnectionString()
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:Postgres"] =
                    "Host=127.0.0.1;Port=5432;Database=pendlerpuls;Username=local;Password=local",
                ["DATABASE_URL"] =
                    "postgres://render_user:render_pass@render-host:5432/render_db?sslmode=require"
            })
            .Build();

        var resolved = PostgresConnectionStringResolver.Resolve(configuration);

        Assert.Contains("render-host", resolved);
        Assert.Contains("render_db", resolved);
        Assert.Contains("render_user", resolved);
        Assert.DoesNotContain("127.0.0.1", resolved);
    }

    [Fact]
    public void Resolve_UsesAppSettingsConnectionStringWhenDatabaseUrlIsMissing()
    {
        const string localConnectionString =
            "Host=127.0.0.1;Port=5432;Database=pendlerpuls;Username=local;Password=local";

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:Postgres"] = localConnectionString
            })
            .Build();

        Assert.Equal(
            localConnectionString,
            PostgresConnectionStringResolver.Resolve(configuration));
    }
}

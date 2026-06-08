using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using PendlerPuls.Api.Data;
using PendlerPuls.Api.Models;

namespace PendlerPuls.Api.Tests;

public sealed class JourneyPersistenceTests
{
    [Fact]
    public async Task Observation_CanBeAppendedWithSqlite()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();

        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlite(connection)
            .Options;

        var userId = Guid.NewGuid();
        var journeyId = Guid.NewGuid();

        await using (var setup = new AppDbContext(options))
        {
            await setup.Database.EnsureCreatedAsync();
            setup.Users.Add(new User
            {
                Id = userId,
                Email = "persistence@example.com",
                PasswordHash = "hash",
                PasswordSalt = "salt"
            });
            setup.SavedJourneys.Add(new SavedJourney
            {
                Id = journeyId,
                UserId = userId,
                Name = "University",
                FromName = "Oslo S",
                FromEnturId = "from",
                FromLatitude = 59.91,
                FromLongitude = 10.75,
                ToName = "Blindern",
                ToEnturId = "to",
                ToLatitude = 59.94,
                ToLongitude = 10.72
            });
            await setup.SaveChangesAsync();
        }

        await using (var update = new AppDbContext(options))
        {
            update.JourneyObservations.Add(new JourneyObservation
            {
                SavedJourneyId = journeyId,
                ExpectedStartTime = DateTimeOffset.UtcNow,
                ExpectedEndTime = DateTimeOffset.UtcNow.AddMinutes(15),
                DurationMinutes = 15,
                DelayMinutes = 2,
                LineSummary = "5"
            });

            await update.SaveChangesAsync();
        }

        await using var verify = new AppDbContext(options);
        Assert.Equal(
            1,
            await verify.JourneyObservations.CountAsync(
                item => item.SavedJourneyId == journeyId));
    }
}


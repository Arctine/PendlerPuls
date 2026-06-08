using Microsoft.EntityFrameworkCore;
using PendlerPuls.Api.Models;

namespace PendlerPuls.Api.Data;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options)
    : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Session> Sessions => Set<Session>();
    public DbSet<SavedJourney> SavedJourneys => Set<SavedJourney>();
    public DbSet<JourneyObservation> JourneyObservations => Set<JourneyObservation>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .HasIndex(user => user.Email)
            .IsUnique();

        modelBuilder.Entity<Session>()
            .HasIndex(session => session.TokenHash)
            .IsUnique();

        modelBuilder.Entity<Session>()
            .HasOne(session => session.User)
            .WithMany(user => user.Sessions)
            .HasForeignKey(session => session.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<SavedJourney>()
            .HasOne(journey => journey.User)
            .WithMany(user => user.SavedJourneys)
            .HasForeignKey(journey => journey.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<JourneyObservation>()
            .HasOne(observation => observation.SavedJourney)
            .WithMany(journey => journey.Observations)
            .HasForeignKey(observation => observation.SavedJourneyId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}


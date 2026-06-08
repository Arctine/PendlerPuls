namespace PendlerPuls.Api.Models;

public sealed class SavedJourney
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string Name { get; set; }
    public required string FromName { get; set; }
    public required string FromEnturId { get; set; }
    public double FromLatitude { get; set; }
    public double FromLongitude { get; set; }
    public required string ToName { get; set; }
    public required string ToEnturId { get; set; }
    public double ToLatitude { get; set; }
    public double ToLongitude { get; set; }
    public DateTimeOffset CreatedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public Guid UserId { get; set; }
    public User? User { get; set; }
    public List<JourneyObservation> Observations { get; set; } = [];
}


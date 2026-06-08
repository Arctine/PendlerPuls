namespace PendlerPuls.Api.Models;

public sealed class JourneyObservation
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid SavedJourneyId { get; set; }
    public SavedJourney? SavedJourney { get; set; }
    public DateTimeOffset CollectedAtUtc { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset ExpectedStartTime { get; set; }
    public DateTimeOffset ExpectedEndTime { get; set; }
    public int DurationMinutes { get; set; }
    public int DelayMinutes { get; set; }
    public required string LineSummary { get; set; }
}


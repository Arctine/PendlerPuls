namespace PendlerPuls.Api.Contracts;

public sealed record RegisterRequest(string Email, string Password);
public sealed record LoginRequest(string Email, string Password);
public sealed record UserResponse(Guid Id, string Email);

public sealed record LocationReference(
    string Id,
    string Name,
    string Label,
    double Latitude,
    double Longitude);

public sealed record TripPreviewRequest(
    LocationReference From,
    LocationReference To);

public sealed record TripPreviewResponse(
    string FromName,
    string ToName,
    DateTimeOffset ExpectedStartTime,
    DateTimeOffset ExpectedEndTime,
    int DurationMinutes,
    int DelayMinutes,
    IReadOnlyList<string> Modes,
    string LineSummary,
    string Attribution);

public sealed record SaveJourneyRequest(
    string Name,
    LocationReference From,
    LocationReference To);

public sealed record ObservationResponse(
    Guid Id,
    DateTimeOffset CollectedAtUtc,
    DateTimeOffset ExpectedStartTime,
    DateTimeOffset ExpectedEndTime,
    int DurationMinutes,
    int DelayMinutes,
    string LineSummary);

public sealed record SavedJourneyResponse(
    Guid Id,
    string Name,
    LocationReference From,
    LocationReference To,
    DateTimeOffset CreatedAtUtc,
    IReadOnlyList<ObservationResponse> Observations);


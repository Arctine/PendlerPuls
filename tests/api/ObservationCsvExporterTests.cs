using PendlerPuls.Api.Models;
using PendlerPuls.Api.Services;

namespace PendlerPuls.Api.Tests;

public sealed class ObservationCsvExporterTests
{
    [Fact]
    public void BuildCsv_OrdersRowsAndEscapesLineSummary()
    {
        var journey = new SavedJourney
        {
            Name = "Morning commute",
            FromName = "Oslo S",
            FromEnturId = "from",
            FromLatitude = 59.91,
            FromLongitude = 10.75,
            ToName = "Blindern",
            ToEnturId = "to",
            ToLatitude = 59.94,
            ToLongitude = 10.72
        };

        journey.Observations.AddRange([
            new JourneyObservation
            {
                CollectedAtUtc = new DateTimeOffset(2026, 6, 8, 8, 20, 0, TimeSpan.Zero),
                ExpectedStartTime = new DateTimeOffset(2026, 6, 8, 8, 21, 0, TimeSpan.Zero),
                ExpectedEndTime = new DateTimeOffset(2026, 6, 8, 8, 36, 0, TimeSpan.Zero),
                DurationMinutes = 15,
                DelayMinutes = 4,
                LineSummary = "5, Sognsvann"
            },
            new JourneyObservation
            {
                CollectedAtUtc = new DateTimeOffset(2026, 6, 8, 8, 10, 0, TimeSpan.Zero),
                ExpectedStartTime = new DateTimeOffset(2026, 6, 8, 8, 11, 0, TimeSpan.Zero),
                ExpectedEndTime = new DateTimeOffset(2026, 6, 8, 8, 26, 0, TimeSpan.Zero),
                DurationMinutes = 15,
                DelayMinutes = 1,
                LineSummary = "5"
            }
        ]);

        var csv = new ObservationCsvExporter().BuildCsv(journey);

        Assert.Contains("2026-06-08T08:10:00.0000000+00:00", csv);
        Assert.True(
            csv.IndexOf("2026-06-08T08:10:00.0000000+00:00", StringComparison.Ordinal)
            < csv.IndexOf("2026-06-08T08:20:00.0000000+00:00", StringComparison.Ordinal));
        Assert.Contains("\"5, Sognsvann\"", csv);
    }

    [Fact]
    public void BuildFileName_RemovesUnsafeCharacters()
    {
        var fileName = new ObservationCsvExporter()
            .BuildFileName("Oslo S -> Blindern / morning");

        Assert.Equal("pendlerpuls-oslo-s-blindern-morning-observations.csv", fileName);
    }
}

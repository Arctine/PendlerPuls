using System.Globalization;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Extensions.Options;
using PendlerPuls.Api.Contracts;

namespace PendlerPuls.Api.Services;

public sealed class EnturOptions
{
    public string ClientName { get; set; } = "arctine-pendlerpuls";
}

public sealed class EnturClient(
    HttpClient httpClient,
    IOptions<EnturOptions> options,
    ILogger<EnturClient> logger)
{
    private const string GeocoderUrl =
        "https://api.entur.io/geocoder/v1/autocomplete";

    private const string JourneyPlannerUrl =
        "https://api.entur.io/journey-planner/v3/graphql";

    public async Task<IReadOnlyList<LocationReference>> SearchLocationsAsync(
        string query,
        CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(
            HttpMethod.Get,
            $"{GeocoderUrl}?text={Uri.EscapeDataString(query)}&lang=en&size=6&layers=venue");
        AddClientName(request);

        using var response = await httpClient.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            throw new EnturUpstreamException(
                $"Entur geocoder returned {(int)response.StatusCode}.");
        }

        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var document = await JsonDocument.ParseAsync(
            stream,
            cancellationToken: cancellationToken);

        var locations = new List<LocationReference>();
        foreach (var feature in document.RootElement.GetProperty("features").EnumerateArray())
        {
            var properties = feature.GetProperty("properties");
            var coordinates = feature.GetProperty("geometry").GetProperty("coordinates");

            locations.Add(new LocationReference(
                properties.GetProperty("id").GetString() ?? string.Empty,
                properties.GetProperty("name").GetString() ?? "Unknown place",
                properties.GetProperty("label").GetString() ?? "Unknown place",
                coordinates[1].GetDouble(),
                coordinates[0].GetDouble()));
        }

        return locations;
    }

    public async Task<TripPreviewResponse> PreviewTripAsync(
        TripPreviewRequest request,
        CancellationToken cancellationToken)
    {
        var query = BuildJourneyQuery(request);
        using var message = new HttpRequestMessage(HttpMethod.Post, JourneyPlannerUrl)
        {
            Content = JsonContent.Create(new { query })
        };
        AddClientName(message);

        using var response = await httpClient.SendAsync(message, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            throw new EnturUpstreamException(
                $"Entur journey planner returned {(int)response.StatusCode}.");
        }

        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var document = await JsonDocument.ParseAsync(
            stream,
            cancellationToken: cancellationToken);

        if (document.RootElement.TryGetProperty("errors", out var errors))
        {
            logger.LogWarning("Entur GraphQL errors: {Errors}", errors.ToString());
            throw new EnturUpstreamException("Entur could not plan that journey.");
        }

        var patterns = document.RootElement
            .GetProperty("data")
            .GetProperty("trip")
            .GetProperty("tripPatterns");

        if (patterns.GetArrayLength() == 0)
        {
            throw new EnturUpstreamException("Entur returned no available journeys.");
        }

        var pattern = patterns[0];
        var legs = pattern.GetProperty("legs").EnumerateArray().ToList();
        var finalLeg = legs[^1];
        var delayLeg = legs.LastOrDefault(leg =>
            leg.TryGetProperty("line", out var line)
            && line.ValueKind != JsonValueKind.Null);

        if (delayLeg.ValueKind == JsonValueKind.Undefined)
        {
            delayLeg = finalLeg;
        }

        var aimedEnd = ParseDate(delayLeg.GetProperty("aimedEndTime"));
        var expectedEnd = ParseDate(delayLeg.GetProperty("expectedEndTime"));
        var lineNames = legs
            .Where(leg =>
                leg.TryGetProperty("line", out var line)
                && line.ValueKind != JsonValueKind.Null)
            .Select(leg =>
            {
                var line = leg.GetProperty("line");
                var code = line.GetProperty("publicCode").GetString();
                var name = line.GetProperty("name").GetString();
                return string.IsNullOrWhiteSpace(code) ? name : code;
            })
            .Where(value => !string.IsNullOrWhiteSpace(value))
            .Distinct()
            .Cast<string>()
            .ToList();

        var modes = legs
            .Select(leg => leg.GetProperty("mode").GetString() ?? "unknown")
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        return new TripPreviewResponse(
            request.From.Name,
            request.To.Name,
            ParseDate(pattern.GetProperty("expectedStartTime")),
            ParseDate(pattern.GetProperty("expectedEndTime")),
            (int)Math.Ceiling(pattern.GetProperty("duration").GetDouble() / 60),
            (int)Math.Round((expectedEnd - aimedEnd).TotalMinutes),
            modes,
            lineNames.Count == 0 ? "Walking" : string.Join(" + ", lineNames),
            "Data made available by Entur");
    }

    private void AddClientName(HttpRequestMessage request)
    {
        request.Headers.Add("ET-Client-Name", options.Value.ClientName);
    }

    private static DateTimeOffset ParseDate(JsonElement value)
    {
        return DateTimeOffset.Parse(
            value.GetString() ?? throw new EnturUpstreamException("Missing time value."),
            CultureInfo.InvariantCulture);
    }

    private static string BuildJourneyQuery(TripPreviewRequest request)
    {
        var fromName = JsonSerializer.Serialize(request.From.Name);
        var toName = JsonSerializer.Serialize(request.To.Name);
        var fromLatitude = request.From.Latitude.ToString(CultureInfo.InvariantCulture);
        var fromLongitude = request.From.Longitude.ToString(CultureInfo.InvariantCulture);
        var toLatitude = request.To.Latitude.ToString(CultureInfo.InvariantCulture);
        var toLongitude = request.To.Longitude.ToString(CultureInfo.InvariantCulture);

        return $$"""
            {
              trip(
                from: {
                  place: {{fromName}}
                  coordinates: {
                    latitude: {{fromLatitude}}
                    longitude: {{fromLongitude}}
                  }
                }
                to: {
                  place: {{toName}}
                  coordinates: {
                    latitude: {{toLatitude}}
                    longitude: {{toLongitude}}
                  }
                }
                numTripPatterns: 1
              ) {
                tripPatterns {
                  duration
                  expectedStartTime
                  expectedEndTime
                  legs {
                    mode
                    aimedEndTime
                    expectedEndTime
                    line {
                      publicCode
                      name
                    }
                  }
                }
              }
            }
            """;
    }
}

public sealed class EnturUpstreamException(string message) : Exception(message);


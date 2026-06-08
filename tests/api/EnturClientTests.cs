using System.Net;
using System.Text;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using PendlerPuls.Api.Contracts;
using PendlerPuls.Api.Services;

namespace PendlerPuls.Api.Tests;

public sealed class EnturClientTests
{
    [Fact]
    public async Task PreviewTripAsync_MapsTheProviderResponse()
    {
        const string json = """
            {
              "data": {
                "trip": {
                  "tripPatterns": [{
                    "duration": 900,
                    "expectedStartTime": "2026-06-08T08:00:00+02:00",
                    "expectedEndTime": "2026-06-08T08:15:00+02:00",
                    "legs": [{
                      "mode": "metro",
                      "aimedEndTime": "2026-06-08T08:13:00+02:00",
                      "expectedEndTime": "2026-06-08T08:15:00+02:00",
                      "line": {
                        "publicCode": "5",
                        "name": "Sognsvann - Vestli"
                      }
                    }]
                  }]
                }
              }
            }
            """;

        var handler = new StubHandler(json);
        var client = new EnturClient(
            new HttpClient(handler),
            Options.Create(new EnturOptions()),
            NullLogger<EnturClient>.Instance);

        var result = await client.PreviewTripAsync(
            new TripPreviewRequest(
                new LocationReference("from", "Oslo S", "Oslo S", 59.91, 10.75),
                new LocationReference("to", "Blindern", "Blindern", 59.94, 10.72)),
            CancellationToken.None);

        Assert.Equal(15, result.DurationMinutes);
        Assert.Equal(2, result.DelayMinutes);
        Assert.Equal("5", result.LineSummary);
        Assert.Contains("metro", result.Modes);
    }

    private sealed class StubHandler(string responseBody) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            Assert.True(request.Headers.Contains("ET-Client-Name"));

            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(
                    responseBody,
                    Encoding.UTF8,
                    "application/json")
            });
        }
    }
}


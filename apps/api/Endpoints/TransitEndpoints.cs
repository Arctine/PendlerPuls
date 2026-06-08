using PendlerPuls.Api.Contracts;
using PendlerPuls.Api.Services;

namespace PendlerPuls.Api.Endpoints;

public static class TransitEndpoints
{
    public static IEndpointRouteBuilder MapTransitEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/transit").WithTags("Transit");

        group.MapGet("/locations", SearchLocationsAsync);
        group.MapPost("/preview", PreviewTripAsync);

        return app;
    }

    private static async Task<IResult> SearchLocationsAsync(
        string query,
        EnturClient entur,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(query) || query.Trim().Length < 2)
        {
            return Results.BadRequest(new { message = "Enter at least two characters." });
        }

        try
        {
            var locations = await entur.SearchLocationsAsync(
                query.Trim(),
                cancellationToken);
            return Results.Ok(locations);
        }
        catch (EnturUpstreamException exception)
        {
            return Results.Problem(
                exception.Message,
                statusCode: StatusCodes.Status502BadGateway);
        }
    }

    private static async Task<IResult> PreviewTripAsync(
        TripPreviewRequest request,
        EnturClient entur,
        CancellationToken cancellationToken)
    {
        if (!IsValidLocation(request.From) || !IsValidLocation(request.To))
        {
            return Results.BadRequest(new { message = "Choose both locations from search." });
        }

        try
        {
            return Results.Ok(await entur.PreviewTripAsync(request, cancellationToken));
        }
        catch (EnturUpstreamException exception)
        {
            return Results.Problem(
                exception.Message,
                statusCode: StatusCodes.Status502BadGateway);
        }
    }

    private static bool IsValidLocation(LocationReference? location)
    {
        return location is not null
            && !string.IsNullOrWhiteSpace(location.Id)
            && !string.IsNullOrWhiteSpace(location.Name)
            && location.Latitude is >= -90 and <= 90
            && location.Longitude is >= -180 and <= 180;
    }
}

using Microsoft.EntityFrameworkCore;
using PendlerPuls.Api.Contracts;
using PendlerPuls.Api.Data;
using PendlerPuls.Api.Models;
using PendlerPuls.Api.Services;

namespace PendlerPuls.Api.Endpoints;

public static class JourneyEndpoints
{
    public static IEndpointRouteBuilder MapJourneyEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/journeys").WithTags("Saved journeys");

        group.MapGet("/", ListAsync);
        group.MapPost("/", SaveAsync);
        group.MapPost("/{id:guid}/refresh", RefreshAsync);
        group.MapDelete("/{id:guid}", DeleteAsync);

        return app;
    }

    private static async Task<IResult> ListAsync(
        AppDbContext database,
        SessionService sessions,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        var user = await sessions.GetCurrentUserAsync(context, cancellationToken);
        if (user is null)
        {
            return Results.Unauthorized();
        }

        var journeys = await database.SavedJourneys
            .AsNoTracking()
            .Where(journey => journey.UserId == user.Id)
            .Include(journey => journey.Observations)
            .ToListAsync(cancellationToken);

        return Results.Ok(journeys
            .OrderByDescending(journey => journey.CreatedAtUtc)
            .Select(ToResponse));
    }

    private static async Task<IResult> SaveAsync(
        SaveJourneyRequest request,
        AppDbContext database,
        SessionService sessions,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        var user = await sessions.GetCurrentUserAsync(context, cancellationToken);
        if (user is null)
        {
            return Results.Unauthorized();
        }

        if (!IsValidLocation(request.From) || !IsValidLocation(request.To))
        {
            return Results.BadRequest(new { message = "Choose two valid locations." });
        }

        var name = request.Name?.Trim() ?? string.Empty;
        if (name.Length is < 2 or > 80)
        {
            return Results.BadRequest(new
            {
                message = "Give the journey a name between 2 and 80 characters."
            });
        }

        var journey = new SavedJourney
        {
            Name = name,
            UserId = user.Id,
            FromName = request.From.Name,
            FromEnturId = request.From.Id,
            FromLatitude = request.From.Latitude,
            FromLongitude = request.From.Longitude,
            ToName = request.To.Name,
            ToEnturId = request.To.Id,
            ToLatitude = request.To.Latitude,
            ToLongitude = request.To.Longitude
        };

        database.SavedJourneys.Add(journey);
        await database.SaveChangesAsync(cancellationToken);

        return Results.Created($"/api/journeys/{journey.Id}", ToResponse(journey));
    }

    private static async Task<IResult> RefreshAsync(
        Guid id,
        AppDbContext database,
        SessionService sessions,
        EnturClient entur,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        var user = await sessions.GetCurrentUserAsync(context, cancellationToken);
        if (user is null)
        {
            return Results.Unauthorized();
        }

        var journey = await database.SavedJourneys
            .Include(item => item.Observations)
            .SingleOrDefaultAsync(
                item => item.Id == id && item.UserId == user.Id,
                cancellationToken);

        if (journey is null)
        {
            return Results.NotFound();
        }

        try
        {
            var preview = await entur.PreviewTripAsync(
                new TripPreviewRequest(ToFromLocation(journey), ToToLocation(journey)),
                cancellationToken);

            var observation = new JourneyObservation
            {
                SavedJourneyId = journey.Id,
                ExpectedStartTime = preview.ExpectedStartTime,
                ExpectedEndTime = preview.ExpectedEndTime,
                DurationMinutes = preview.DurationMinutes,
                DelayMinutes = preview.DelayMinutes,
                LineSummary = preview.LineSummary
            };

            database.JourneyObservations.Add(observation);
            await database.SaveChangesAsync(cancellationToken);
            return Results.Ok(ToResponse(journey));
        }
        catch (EnturUpstreamException exception)
        {
            return Results.Problem(
                exception.Message,
                statusCode: StatusCodes.Status502BadGateway);
        }
    }

    private static async Task<IResult> DeleteAsync(
        Guid id,
        AppDbContext database,
        SessionService sessions,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        var user = await sessions.GetCurrentUserAsync(context, cancellationToken);
        if (user is null)
        {
            return Results.Unauthorized();
        }

        var journey = await database.SavedJourneys.SingleOrDefaultAsync(
            item => item.Id == id && item.UserId == user.Id,
            cancellationToken);

        if (journey is null)
        {
            return Results.NotFound();
        }

        database.SavedJourneys.Remove(journey);
        await database.SaveChangesAsync(cancellationToken);
        return Results.NoContent();
    }

    private static SavedJourneyResponse ToResponse(SavedJourney journey)
    {
        return new SavedJourneyResponse(
            journey.Id,
            journey.Name,
            ToFromLocation(journey),
            ToToLocation(journey),
            journey.CreatedAtUtc,
            journey.Observations
                .OrderByDescending(item => item.CollectedAtUtc)
                .Take(12)
                .Select(item => new ObservationResponse(
                    item.Id,
                    item.CollectedAtUtc,
                    item.ExpectedStartTime,
                    item.ExpectedEndTime,
                    item.DurationMinutes,
                    item.DelayMinutes,
                    item.LineSummary))
                .ToList());
    }

    private static LocationReference ToFromLocation(SavedJourney journey)
    {
        return new LocationReference(
            journey.FromEnturId,
            journey.FromName,
            journey.FromName,
            journey.FromLatitude,
            journey.FromLongitude);
    }

    private static LocationReference ToToLocation(SavedJourney journey)
    {
        return new LocationReference(
            journey.ToEnturId,
            journey.ToName,
            journey.ToName,
            journey.ToLatitude,
            journey.ToLongitude);
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

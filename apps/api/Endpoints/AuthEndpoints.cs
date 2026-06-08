using Microsoft.EntityFrameworkCore;
using PendlerPuls.Api.Contracts;
using PendlerPuls.Api.Data;
using PendlerPuls.Api.Models;
using PendlerPuls.Api.Services;

namespace PendlerPuls.Api.Endpoints;

public static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth").WithTags("Authentication");

        group.MapPost("/register", RegisterAsync);
        group.MapPost("/login", LoginAsync);
        group.MapPost("/logout", LogoutAsync);
        group.MapGet("/me", MeAsync);

        return app;
    }

    private static async Task<IResult> RegisterAsync(
        RegisterRequest request,
        AppDbContext database,
        PasswordService passwords,
        SessionService sessions,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        var email = request.Email?.Trim().ToLowerInvariant() ?? string.Empty;
        var passwordValue = request.Password ?? string.Empty;
        if (!email.Contains('@') || email.Length > 200)
        {
            return Results.BadRequest(new { message = "Enter a valid email address." });
        }

        if (passwordValue.Length < 10 || passwordValue.Length > 200)
        {
            return Results.BadRequest(new
            {
                message = "Use a password between 10 and 200 characters."
            });
        }

        if (await database.Users.AnyAsync(user => user.Email == email, cancellationToken))
        {
            return Results.Conflict(new { message = "An account already uses that email." });
        }

        var password = passwords.Hash(passwordValue);
        var user = new User
        {
            Email = email,
            PasswordHash = password.Hash,
            PasswordSalt = password.Salt
        };

        database.Users.Add(user);
        await database.SaveChangesAsync(cancellationToken);
        await sessions.CreateAsync(user, context, cancellationToken);

        return Results.Created("/api/auth/me", new UserResponse(user.Id, user.Email));
    }

    private static async Task<IResult> LoginAsync(
        LoginRequest request,
        AppDbContext database,
        PasswordService passwords,
        SessionService sessions,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        var email = request.Email?.Trim().ToLowerInvariant() ?? string.Empty;
        var passwordValue = request.Password ?? string.Empty;
        var user = await database.Users.SingleOrDefaultAsync(
            item => item.Email == email,
            cancellationToken);

        if (user is null
            || !passwords.Verify(passwordValue, user.PasswordHash, user.PasswordSalt))
        {
            return Results.Unauthorized();
        }

        await sessions.CreateAsync(user, context, cancellationToken);
        return Results.Ok(new UserResponse(user.Id, user.Email));
    }

    private static async Task<IResult> LogoutAsync(
        SessionService sessions,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        await sessions.DeleteAsync(context, cancellationToken);
        return Results.NoContent();
    }

    private static async Task<IResult> MeAsync(
        SessionService sessions,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        var user = await sessions.GetCurrentUserAsync(context, cancellationToken);
        return user is null
            ? Results.Unauthorized()
            : Results.Ok(new UserResponse(user.Id, user.Email));
    }
}

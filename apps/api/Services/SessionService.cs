using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using PendlerPuls.Api.Data;
using PendlerPuls.Api.Models;

namespace PendlerPuls.Api.Services;

public sealed class SessionService(
    AppDbContext database,
    IWebHostEnvironment environment)
{
    public const string CookieName = "pendlerpuls_session";
    private static readonly TimeSpan SessionLifetime = TimeSpan.FromDays(14);

    public async Task<User?> GetCurrentUserAsync(
        HttpContext context,
        CancellationToken cancellationToken)
    {
        if (!context.Request.Cookies.TryGetValue(CookieName, out var token))
        {
            return null;
        }

        var tokenHash = HashToken(token);
        var session = await database.Sessions
            .Include(item => item.User)
            .SingleOrDefaultAsync(
                item => item.TokenHash == tokenHash,
                cancellationToken);

        if (session is null)
        {
            return null;
        }

        if (session.ExpiresAtUtc <= DateTimeOffset.UtcNow)
        {
            database.Sessions.Remove(session);
            await database.SaveChangesAsync(cancellationToken);
            return null;
        }

        return session.User;
    }

    public async Task CreateAsync(
        User user,
        HttpContext context,
        CancellationToken cancellationToken)
    {
        var token = Base64UrlEncode(RandomNumberGenerator.GetBytes(32));
        var session = new Session
        {
            UserId = user.Id,
            TokenHash = HashToken(token),
            ExpiresAtUtc = DateTimeOffset.UtcNow.Add(SessionLifetime)
        };

        database.Sessions.Add(session);
        await database.SaveChangesAsync(cancellationToken);

        context.Response.Cookies.Append(CookieName, token, new CookieOptions
        {
            HttpOnly = true,
            Secure = !environment.IsDevelopment(),
            SameSite = SameSiteMode.Lax,
            Expires = session.ExpiresAtUtc,
            IsEssential = true
        });
    }

    public async Task DeleteAsync(
        HttpContext context,
        CancellationToken cancellationToken)
    {
        if (context.Request.Cookies.TryGetValue(CookieName, out var token))
        {
            var tokenHash = HashToken(token);
            var session = await database.Sessions.SingleOrDefaultAsync(
                item => item.TokenHash == tokenHash,
                cancellationToken);

            if (session is not null)
            {
                database.Sessions.Remove(session);
                await database.SaveChangesAsync(cancellationToken);
            }
        }

        context.Response.Cookies.Delete(CookieName);
    }

    private static string HashToken(string token)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
        return Convert.ToHexString(bytes);
    }

    private static string Base64UrlEncode(byte[] value)
    {
        return Convert.ToBase64String(value)
            .TrimEnd('=')
            .Replace('+', '-')
            .Replace('/', '_');
    }
}


namespace PendlerPuls.Api.Models;

public sealed class Session
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string TokenHash { get; set; }
    public DateTimeOffset ExpiresAtUtc { get; set; }
    public Guid UserId { get; set; }
    public User? User { get; set; }
}


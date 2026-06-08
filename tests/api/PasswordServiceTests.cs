using PendlerPuls.Api.Services;

namespace PendlerPuls.Api.Tests;

public sealed class PasswordServiceTests
{
    private readonly PasswordService service = new();

    [Fact]
    public void HashAndVerify_AcceptsTheOriginalPassword()
    {
        var result = service.Hash("a sufficiently long password");

        Assert.True(service.Verify(
            "a sufficiently long password",
            result.Hash,
            result.Salt));
    }

    [Fact]
    public void HashAndVerify_RejectsAnotherPassword()
    {
        var result = service.Hash("a sufficiently long password");

        Assert.False(service.Verify(
            "this is the wrong password",
            result.Hash,
            result.Salt));
    }
}


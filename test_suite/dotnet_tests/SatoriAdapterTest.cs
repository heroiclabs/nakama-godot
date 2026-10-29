using System;
using System.Linq;
using System.Threading.Tasks;
using Godot;
using Satori;

// Runs the Satori .NET client through the addon's Godot adapter against the server in SATORI_HOST.
public partial class SatoriAdapterTest : Node
{
    // A fixed identity, so runs don't create a new one each time.
    private const string Identity = "6f1d2c5e-2b8a-4c7e-9a40-1f6b3d8e5c21";
    private const double TimeoutSec = 30;

    private bool _finished;

    public override async void _Ready()
    {
        var host = OS.GetEnvironment("SATORI_HOST");
        var apiKey = OS.GetEnvironment("SATORI_API_KEY");
        if (host == "" || apiKey == "")
        {
            GD.Print("======= INFO: SKIP: SatoriAdapterTest.cs: set SATORI_HOST and SATORI_API_KEY to run it");
            GD.Print("======= TESTS END");
            GetTree().Quit(0);
            return;
        }

        GetTree().CreateTimer(TimeoutSec).Timeout += () => Finish($"timed out after {TimeoutSec} s");
        try
        {
            await Run(host, apiKey);
            Finish(null);
        }
        catch (Exception e)
        {
            Finish(e.ToString());
        }
    }

    private async Task Run(string host, string apiKey)
    {
        var httpAdapter = new GodotSatoriHttpAdapter();
        AddChild(httpAdapter);
        var client = new Client("https", host, 443, apiKey, httpAdapter);
        client.Logger = new GodotSatoriLogger("Satori", GodotSatoriLogger.LogLevel.ERROR);

        var session = await client.AuthenticateAsync(Identity);
        Check(session.IdentityId == Identity, $"the session belongs to the identity, got {session.IdentityId}");

        var flags = await client.GetFlagsAsync(session, Array.Empty<string>(), Array.Empty<string>());
        Check(flags.Flags.Any(), "the server has at least one flag");

        // A call from a pause menu still completes.
        GetTree().Paused = true;
        try
        {
            await client.GetFlagsAsync(session, Array.Empty<string>(), Array.Empty<string>());
        }
        finally
        {
            GetTree().Paused = false;
        }

        await client.EventAsync(session, new Event("gameFinished", DateTime.UtcNow));

        // An error reply becomes an ApiResponseException with the server's codes.
        var badClient = new Client("https", host, 443, "wrongkey", httpAdapter);
        try
        {
            await badClient.AuthenticateAsync(Identity);
            Check(false, "a wrong API key is rejected");
        }
        catch (ApiResponseException e)
        {
            Check(e.StatusCode == 401 && e.GrpcStatusCode == 16, $"a wrong API key gives 401/16, got {e.StatusCode}/{e.GrpcStatusCode}");
        }

        await client.AuthenticateLogoutAsync(session);
    }

    private static void Check(bool condition, string what)
    {
        if (!condition)
        {
            throw new Exception("check failed: " + what);
        }
    }

    private void Finish(string failure)
    {
        if (_finished)
        {
            return;
        }
        _finished = true;
        GD.Print(failure == null ? "======= INFO: SUCCESS: SatoriAdapterTest.cs" : "======= INFO: !!!!!!!!!!!!!!!!!!! FAILURE: SatoriAdapterTest.cs: " + failure);
        GD.Print("======= TESTS END");
        GetTree().Quit(failure == null ? 0 : 1);
    }
}

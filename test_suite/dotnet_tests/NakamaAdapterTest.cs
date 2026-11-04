using System;
using System.Diagnostics;
using System.Linq;
using System.Net;
using TcpListener = System.Net.Sockets.TcpListener;
using System.Threading;
using System.Threading.Tasks;
using Godot;
using Nakama;

// Runs the Nakama .NET client through the addon's Godot adapters against the test server.
public partial class NakamaAdapterTest : Node
{
    private const string Host = "127.0.0.1";
    private const int Port = 7350;
    private const string ServerKey = "defaultkey";
    // A made-up key that must never show up in error messages or logs.
    private const string HttpKey = "secret-http-key";
    private const double TimeoutSec = 30;

    private bool _finished;

    public override async void _Ready()
    {
        GetTree().CreateTimer(TimeoutSec).Timeout += () => Finish($"timed out after {TimeoutSec} s");
        try
        {
            await Run();
            Finish(null);
        }
        catch (Exception e)
        {
            Finish(e.ToString());
        }
    }

    private async Task Run()
    {
        var httpAdapter = new GodotHttpAdapter();
        AddChild(httpAdapter);
        var client = new Client("http", Host, Port, ServerKey, httpAdapter);
        client.Logger = new GodotLogger("Nakama", GodotLogger.LogLevel.ERROR);

        var session = await client.AuthenticateDeviceAsync(Guid.NewGuid().ToString());
        var account = await client.GetAccountAsync(session);
        Check(account.User.Id == session.UserId, "the account belongs to the session's user");

        // Escaped characters in the query, such as a space, reach the server still escaped.
        var users = await client.GetUsersAsync(session, null, new[] { "no such user é" });
        Check(!users.Users.Any(), "a username with a space and an accent finds no user");

        // A call from a pause menu still completes.
        GetTree().Paused = true;
        try
        {
            await client.GetAccountAsync(session);
        }
        finally
        {
            GetTree().Paused = false;
        }

        // An error reply becomes an ApiResponseException with the server's codes.
        var badClient = new Client("http", Host, Port, "wrongkey", httpAdapter);
        try
        {
            await badClient.AuthenticateDeviceAsync(Guid.NewGuid().ToString());
            Check(false, "a wrong server key is rejected");
        }
        catch (ApiResponseException e)
        {
            Check(e.StatusCode == 401 && e.GrpcStatusCode == 16, $"a wrong server key gives 401/16, got {e.StatusCode}/{e.GrpcStatusCode}");
        }

        // A request Godot refuses to send, such as one with an unsupported scheme, fails at once.
        var ftpClient = new Client("ftp", Host, Port, ServerKey, httpAdapter);
        try
        {
            await ftpClient.RpcAsync(HttpKey, "any");
            Check(false, "a request Godot refuses to send fails");
        }
        catch (ApiResponseException e)
        {
            Check(e.StatusCode == 0 && e.GrpcStatusCode == 14, $"a refused request gives 0/14, got {e.StatusCode}/{e.GrpcStatusCode}");
            Check(!e.Message.Contains(HttpKey), $"a refused request's error hides the http_key, got: {e.Message}");
        }

        // No reply at all is transient, so the client retries it, then gives up with the adapter's error inside.
        var retries = 0;
        var downClient = new Client("http", Host, 1, ServerKey, httpAdapter);
        downClient.GlobalRetryConfiguration = new RetryConfiguration(10, 2, (numRetry, _) => retries = numRetry);
        try
        {
            await downClient.RpcAsync(HttpKey, "any");
            Check(false, "an unreachable server fails");
        }
        catch (TaskCanceledException e)
        {
            var status = (e.InnerException as ApiResponseException)?.StatusCode;
            Check(status == -1 && retries == 2, $"an unreachable server gives -1 after 2 retries, got {status} after {retries}");
            Check(!e.InnerException.Message.Contains(HttpKey), $"an unreachable server's error hides the http_key, got: {e.InnerException.Message}");
        }

        await CheckLogsHideCredentials();

        var socketAdapter = new GodotWebSocketAdapter();
        AddChild(socketAdapter);
        var socket = Socket.From(client, socketAdapter);
        var closed = new TaskCompletionSource<string>();
        socket.Closed += reason => closed.TrySetResult(reason);
        await socket.ConnectAsync(session);
        Check(socket.IsConnected, "the socket is connected");

        // The request and its reply both go through the adapter.
        var match = await socket.CreateMatchAsync();
        Check(!string.IsNullOrEmpty(match.Id), "the socket creates a match");

        // A socket call from a pause menu still completes.
        GetTree().Paused = true;
        try
        {
            await socket.CreateMatchAsync();
        }
        finally
        {
            GetTree().Paused = false;
        }

        await CheckServerMessages(client, socket, match.Id);

        await socket.CloseAsync();
        await closed.Task;
        Check(!socket.IsConnected, "the socket is closed");
        Check(socketAdapter.CloseAsync().IsCompleted, "closing a socket that is already closed finishes at once");

        // A second connect while the first is under way waits for it, and both succeed.
        var uri = new Uri($"ws://{Host}:{Port}/ws?lang=en&status=false&token={Uri.EscapeDataString(session.AuthToken)}");
        var first = socketAdapter.ConnectAsync(uri, 5);
        var second = socketAdapter.ConnectAsync(uri, 5);
        await Task.WhenAll(first, second);
        Check(socketAdapter.IsConnected, "two concurrent connects leave the socket connected");
        await socketAdapter.CloseAsync();

        // A connect to another URI while one is under way, e.g. a retry with a refreshed token, replaces the stale one.
        var stuck = new TcpListener(IPAddress.Loopback, 0);
        stuck.Start();
        try
        {
            var stale = socketAdapter.ConnectAsync(new Uri($"ws://{Host}:{((IPEndPoint)stuck.LocalEndpoint).Port}/ws"), 5);
            await socketAdapter.ConnectAsync(uri, 5);
            Check(socketAdapter.IsConnected, "a connect to a new URI connects there");
            try
            {
                await stale;
                Check(false, "the replaced connect fails");
            }
            catch (GodotWebSocketConnectionException)
            {
            }
        }
        finally
        {
            stuck.Stop();
        }
        await socketAdapter.CloseAsync();

        // A user handler that throws must not stop a connect or close from finishing.
        Action throwOnConnected = () => throw new Exception("Connected handler throws on purpose");
        Action<string> throwOnClosed = _ => throw new Exception("Closed handler throws on purpose");
        socketAdapter.Connected += throwOnConnected;
        socketAdapter.Closed += throwOnClosed;
        try
        {
            var connect = socketAdapter.ConnectAsync(uri, 5);
            Check(await Task.WhenAny(connect, Task.Delay(3000)) == connect, "a connect finishes when a Connected handler throws");
            var close = socketAdapter.CloseAsync();
            Check(await Task.WhenAny(close, Task.Delay(3000)) == close, "a close finishes when a Closed handler throws");
        }
        finally
        {
            socketAdapter.Connected -= throwOnConnected;
            socketAdapter.Closed -= throwOnClosed;
        }

        // A server that accepts connections but never replies.
        var silent = new TcpListener(IPAddress.Loopback, 0);
        silent.Start();
        try
        {
            var silentClient = new Client("http", Host, ((IPEndPoint)silent.LocalEndpoint).Port, ServerKey, httpAdapter);
            await CheckCancel(silentClient);
            await CheckConnectTimeout(silentClient, session);
        }
        finally
        {
            silent.Stop();
        }
    }

    // A second player joins and sends binary match state; the host's socket receives both from the server.
    private async Task CheckServerMessages(Client client, ISocket host, string matchId)
    {
        string guestId = null;
        var joined = new TaskCompletionSource();
        // Wait for the guest's join: the host may first hear of its own.
        host.ReceivedMatchPresence += e =>
        {
            if (guestId != null && e.Joins.Any(p => p.UserId == guestId))
            {
                joined.TrySetResult();
            }
        };
        var received = new TaskCompletionSource<IMatchState>();
        host.ReceivedMatchState += s => received.TrySetResult(s);

        var guestSession = await client.AuthenticateDeviceAsync(Guid.NewGuid().ToString());
        guestId = guestSession.UserId;
        var guestAdapter = new GodotWebSocketAdapter();
        AddChild(guestAdapter);
        var guest = Socket.From(client, guestAdapter);
        await guest.ConnectAsync(guestSession);
        await guest.JoinMatchAsync(matchId);

        await joined.Task;

        var payload = Enumerable.Range(0, 256).Select(i => (byte)i).ToArray();
        await guest.SendMatchStateAsync(matchId, 7, payload);
        var state = await received.Task;
        Check(state.OpCode == 7 && state.State.SequenceEqual(payload) && state.UserPresence.UserId == guestSession.UserId,
            $"the host gets the guest's match state, got op code {state.OpCode} and {state.State.Length} bytes");

        await guest.CloseAsync();
    }

    // Logging every message, as at INFO or DEBUG, must not write tokens or the http_key to the console or log files.
    private async Task CheckLogsHideCredentials()
    {
        var logged = new RecordingLogger();
        var adapter = new GodotHttpAdapter();
        AddChild(adapter);
        var logClient = new Client("http", Host, Port, ServerKey, adapter) { Logger = logged };
        var session = await logClient.AuthenticateDeviceAsync(Guid.NewGuid().ToString());
        var refreshed = await logClient.SessionRefreshAsync(session);
        await logClient.SessionLogoutAsync(refreshed);
        try
        {
            await logClient.RpcAsync(HttpKey, "no_such_rpc");
        }
        catch (ApiResponseException)
        {
        }
        var secrets = new[] { session.AuthToken, session.RefreshToken, refreshed.AuthToken, HttpKey };
        Check(logged.Messages.Count > 0, "the adapter logs its requests");
        var leak = logged.Messages.FirstOrDefault(m => secrets.Any(m.Contains));
        Check(leak == null, $"logs hide tokens and the http_key, got: {leak}");
    }

    private class RecordingLogger : ILogger
    {
        public readonly System.Collections.Generic.List<string> Messages = new();
        public void DebugFormat(string format, params object[] args) => Messages.Add(string.Format(format, args));
        public void ErrorFormat(string format, params object[] args) => Messages.Add(string.Format(format, args));
        public void InfoFormat(string format, params object[] args) => Messages.Add(string.Format(format, args));
        public void WarnFormat(string format, params object[] args) => Messages.Add(string.Format(format, args));
    }

    private static async Task CheckCancel(Client silentClient)
    {
        using var cancel = new CancellationTokenSource();
        cancel.CancelAfter(300);
        var clock = Stopwatch.StartNew();
        try
        {
            await silentClient.AuthenticateDeviceAsync(Guid.NewGuid().ToString(), canceller: cancel.Token);
            Check(false, "a cancelled request fails");
        }
        catch (OperationCanceledException)
        {
            Check(clock.Elapsed.TotalSeconds < 2, $"a cancelled request stops at once, took {clock.Elapsed.TotalSeconds:F1} s");
        }
    }

    private async Task CheckConnectTimeout(Client silentClient, ISession session)
    {
        var socketAdapter = new GodotWebSocketAdapter();
        AddChild(socketAdapter);
        var socket = Socket.From(silentClient, socketAdapter);
        var closedCount = 0;
        socket.Closed += _ => closedCount++;
        try
        {
            await socket.ConnectAsync(session, false, 1);
            Check(false, "a socket that gets no handshake times out");
        }
        catch (GodotWebSocketConnectionException)
        {
        }
        await ToSignal(GetTree().CreateTimer(0.5), SceneTreeTimer.SignalName.Timeout);
        Check(closedCount == 0, $"a socket that never opened is not reported closed, got {closedCount} Closed events");
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
        GD.Print(failure == null ? "======= INFO: SUCCESS: NakamaAdapterTest.cs" : "======= INFO: !!!!!!!!!!!!!!!!!!! FAILURE: NakamaAdapterTest.cs: " + failure);
        GD.Print("======= TESTS END");
        GetTree().Quit(failure == null ? 0 : 1);
    }
}

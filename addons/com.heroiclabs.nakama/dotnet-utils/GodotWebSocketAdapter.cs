// Copyright 2022 The Nakama Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using System;
using System.Threading;
using System.Threading.Tasks;
using Godot;

namespace Nakama
{
    /// <summary>
    /// An exception that is thrown when the WebSocket is unable to connect.
    /// </summary>
    public class GodotWebSocketConnectionException : Exception
    {
        /// <summary>
        /// Constructs a GodotWebSocketConnectionException.
        /// </summary>
        /// <param name="message">Why the WebSocket could not connect.</param>
        public GodotWebSocketConnectionException(string message = "Unable to connect over WebSocket")
            : base(message) { }
    }

    /// <summary>
    /// An exception that is thrown when the WebSocket is unable to send.
    /// </summary>
    public class GodotWebSocketSendException : Exception
    {
        /// <summary>
        /// Constructs a GodotWebSocketSendException.
        /// </summary>
        public GodotWebSocketSendException() : base("Unable to send over WebSocket") { }
    }

    /// <summary>
    /// A socket adapter for the Nakama .NET client that uses Godot's WebSocketPeer.
    /// </summary>
    public partial class GodotWebSocketAdapter : Node, ISocketAdapter
    {
        /// <inheritdoc cref="ISocketAdapter.Connected"/>
        public event Action Connected;

        /// <inheritdoc cref="ISocketAdapter.Closed"/>
        public event Action<string> Closed;

        /// <inheritdoc cref="ISocketAdapter.ReceivedError"/>
        public event Action<Exception> ReceivedError;

        /// <inheritdoc cref="ISocketAdapter.Received"/>
        public event Action<ArraySegment<byte>> Received;

        /// <inheritdoc cref="ISocketAdapter.IsConnected"/>
        public new bool IsConnected
        {
            get
            {
                return ws.GetReadyState() == WebSocketPeer.State.Open;
            }
        }

        /// <inheritdoc cref="ISocketAdapter.IsConnecting"/>
        public bool IsConnecting
        {
            get
            {
                return ws.GetReadyState() == WebSocketPeer.State.Connecting;
            }
        }

        private WebSocketPeer ws;
        private WebSocketPeer.State wsLastState = WebSocketPeer.State.Closed;
        private bool wasOpen;

        private TaskCompletionSource<bool> connectionSource;
        private TaskCompletionSource<bool> closeSource;
        private Uri connectionUri;
        private int connectionTimeout;
        private double connectionStart;

        /// <summary>
        /// Constructs a GodotWebSocketAdapter.
        /// </summary>
        public GodotWebSocketAdapter()
        {
            ws = new WebSocketPeer();
            // 256 KB, like the GDScript socket: the 64 KB default closes the socket on bigger server messages.
            ws.InboundBufferSize = 256 * 1024;
            // Keep polling while the game is paused, so calls from a pause menu finish and server pings get answered.
            ProcessMode = ProcessModeEnum.Always;
        }

        /// <inheritdoc cref="ISocketAdapter.CloseAsync"/>
        public Task CloseAsync()
        {
            // Already closed, e.g. dropped by the server, and _Process has seen it: no state change is coming.
            if (ws.GetReadyState() == WebSocketPeer.State.Closed && wsLastState == WebSocketPeer.State.Closed)
            {
                return Task.CompletedTask;
            }
            if (closeSource == null)
            {
                closeSource = new TaskCompletionSource<bool>();
            }
            ws.Close();
            return closeSource.Task;
        }

        /// <inheritdoc cref="ISocketAdapter.ConnectAsync"/>
        public Task ConnectAsync(Uri uri, int timeout)
        {
            TaskCompletionSource<bool> aborted = null;
            if (connectionSource != null)
            {
                // Already connecting there, e.g. a double-clicked connect button: wait for that attempt and share its outcome.
                if (uri.Equals(connectionUri))
                {
                    return connectionSource.Task;
                }
                // Elsewhere, e.g. a retry with a refreshed token: the stale attempt must not decide this one's outcome.
                aborted = connectionSource;
                connectionSource = null;
                // -1 closes at once, so the connect below finds the socket closed.
                ws.Close(-1);
            }

            try
            {
                return StartConnect(uri, timeout);
            }
            finally
            {
                // Last: SetException runs the stale attempt's continuations inline, and they must see the new
                // attempt fully set up, not a half-closed socket.
                aborted?.SetException(new GodotWebSocketConnectionException("Connection attempt aborted by a new connection attempt"));
            }
        }

        private Task StartConnect(Uri uri, int timeout)
        {
            if (ws.GetReadyState() != WebSocketPeer.State.Closed)
            {
                return Task.FromException(new GodotWebSocketConnectionException("Cannot connect until the current socket is closed"));
            }

            connectionUri = uri;
            connectionTimeout = timeout;
            connectionStart = Time.GetUnixTimeFromSystem();

            connectionSource = new TaskCompletionSource<bool>();

            var err = ws.ConnectToUrl(uri.ToString());
            if (err != Error.Ok)
            {
                connectionSource = null;
                return Task.FromException(new GodotWebSocketConnectionException($"Error connecting: {err}"));
            }

            wsLastState = WebSocketPeer.State.Closed;

            return connectionSource.Task;
        }

        /// <inheritdoc cref="ISocketAdapter.SendAsync"/>
        public Task SendAsync(ArraySegment<byte> buffer, bool reliable = true, CancellationToken canceller = default)
        {
            byte[] temp;

            if (buffer.Offset != 0 || buffer.Count != buffer.Array.Length)
            {
                temp = new byte[buffer.Count];
                Array.Copy(buffer.Array, buffer.Offset, temp, 0, buffer.Count);
            }
            else
            {
                temp = buffer.Array;
            }

            var err = ws.Send(temp, WebSocketPeer.WriteMode.Text);
            if (err == Error.Ok)
            {
                return Task.CompletedTask;
            }

            return Task.FromException(new GodotWebSocketSendException());
        }

        public override void _Process(double delta)
        {
            if (ws.GetReadyState() != WebSocketPeer.State.Closed)
            {
                ws.Poll();
            }

            // A user handler that throws must not leave ConnectAsync or CloseAsync waiting forever.
            var state = ws.GetReadyState();
            if (wsLastState != state)
            {
                wsLastState = state;

                if (state == WebSocketPeer.State.Open)
                {
                    wasOpen = true;
                    var connected = connectionSource;
                    connectionSource = null;
                    // Raise Connected before completing the task: SetResult runs awaiting continuations inline, and
                    // one calling CloseAsync would otherwise run the handlers with IsConnected already false.
                    try
                    {
                        Connected?.Invoke();
                    }
                    finally
                    {
                        connected.SetResult(true);
                    }
                }
                else if (state == WebSocketPeer.State.Closed)
                {
                    var failed = connectionSource;
                    connectionSource = null;
                    // Not after a timed-out connect, which already failed through ReceivedError.
                    var raiseClosed = failed == null && wasOpen;
                    wasOpen = false;
                    var closed = closeSource;
                    closeSource = null;

                    Exception e = new GodotWebSocketConnectionException("Failed to connect");
                    // Raise events before completing the tasks: a continuation run inline by SetResult could start
                    // a new connection and then see this one's Closed or ReceivedError.
                    try
                    {
                        if (failed != null)
                        {
                            ReceivedError?.Invoke(e);
                        }
                        else if (raiseClosed)
                        {
                            Closed?.Invoke(ws.GetCloseReason());
                        }
                    }
                    finally
                    {
                        failed?.SetException(e);
                        closed?.SetResult(true);
                    }
                }
            }

            if (ws.GetReadyState() == WebSocketPeer.State.Connecting)
            {
                if (connectionStart + (double)connectionTimeout < Time.GetUnixTimeFromSystem())
                {
                    ws.Close();

                    Exception e = new GodotWebSocketConnectionException("Connection timed out");
                    var timedOut = connectionSource;
                    connectionSource = null;
                    try
                    {
                        ReceivedError?.Invoke(e);
                    }
                    finally
                    {
                        timedOut.SetException(e);
                    }
                }
            }

            while (ws.GetReadyState() == WebSocketPeer.State.Open && ws.GetAvailablePacketCount() > 0)
            {
                Received?.Invoke(new ArraySegment<byte>(ws.GetPacket()));
            }
        }
    }
}

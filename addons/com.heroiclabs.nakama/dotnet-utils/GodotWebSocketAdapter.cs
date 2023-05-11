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
    public class GodotWebSocketConnectionException : Exception {
        public GodotWebSocketConnectionException(string message = "WebSocket unable to connect")
            : base(message) { }
    }

    /// <summary>
    /// An exception that is thrown when the WebSocket is unable to send.
    /// </summary>
    public class GodotWebSocketSendException : Exception {
        public GodotWebSocketSendException() : base("Unable to send over WebSocket") { }
    }

    /// <summary>
    /// A socket adapter which uses Godot's WebSocketPeer.
    /// </summary>
    public partial class GodotWebSocketAdapter : Node, ISocketAdapter
    {
        /// <inheritdoc cref="ISocketAdapter.Connected"/>
        public event Action Connected;

        /// <inheritdoc cref="ISocketAdapter.Closed"/>
        public event Action Closed;

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

        private TaskCompletionSource<bool> connectionSource;
        private TaskCompletionSource<bool> closeSource;
        private int connectionTimeout;
        private double connectionStart;

        /// <summary>
        /// Constructs a GodotWebSocketAdapter.
        /// </summary>
        public GodotWebSocketAdapter()
        {
            ws = new WebSocketPeer();
        }

        /// <inheritdoc cref="ISocketAdaptor.CloseAsync"/>
        public Task CloseAsync()
        {
            if (closeSource == null)
            {
                closeSource = new TaskCompletionSource<bool>();
            }
            ws.Close();
            return closeSource.Task;
        }

        /// <inheritdoc cref="ISocketAdaptor.ConnectAsync"/>
        public Task ConnectAsync(Uri uri, int timeout)
        {
            if (connectionSource != null)
            {
                connectionSource.SetException(new GodotWebSocketConnectionException("Connection attempt aborted due to new connection attempt"));
                connectionSource = null;
            }

            if (ws.GetReadyState() != WebSocketPeer.State.Closed)
            {
                return Task.FromException(new GodotWebSocketConnectionException("Cannot connect until current socket is closed"));
            }

            connectionTimeout = timeout;
            connectionStart = Time.GetUnixTimeFromSystem();

            connectionSource = new TaskCompletionSource<bool>();

            var err = ws.ConnectToUrl(uri.ToString());
            if (err != Error.Ok)
            {
                return Task.FromException(new GodotWebSocketConnectionException(String.Format("Error connecting: {0}", Enum.GetName(typeof(Error), err))));
            }

            wsLastState = WebSocketPeer.State.Closed;

            return connectionSource.Task;
        }

        /// <inheritdoc cref="ISocketAdaptor.SendAsync"/>
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

            var state = ws.GetReadyState();
            if (wsLastState != state)
            {
                wsLastState = state;

                if (state == WebSocketPeer.State.Open)
                {
                    Connected?.Invoke();
                    connectionSource.SetResult(true);
                    connectionSource = null;
                }
                else if (state == WebSocketPeer.State.Closed)
                {
                    if (connectionSource != null)
                    {
                        Exception e = new GodotWebSocketConnectionException("Failed to connect");
                        ReceivedError?.Invoke(e);
                        connectionSource.SetException(e);
                        connectionSource = null;
                    }
                    else
                    {
                        Closed?.Invoke();
                    }

                    if (closeSource != null)
                    {
                        closeSource.SetResult(true);
                        closeSource = null;
                    }
                }
            }

            if (ws.GetReadyState() == WebSocketPeer.State.Connecting) {
                if (connectionStart + (double)connectionTimeout < Time.GetUnixTimeFromSystem())
                {
                    ws.Close();

                    Exception e = new GodotWebSocketConnectionException("Connection timed out");
                    ReceivedError?.Invoke(e);
                    connectionSource.SetException(e);
                    connectionSource = null;
                }
            }

            while (ws.GetReadyState() == WebSocketPeer.State.Open && ws.GetAvailablePacketCount() > 0)
            {
                Received?.Invoke(new ArraySegment<byte>(ws.GetPacket()));
            }
        }
    }
}

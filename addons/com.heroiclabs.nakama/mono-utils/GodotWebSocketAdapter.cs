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
using Nakama;
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
    /// A socket adapter which uses Godot's WebSocketClient.
    /// </summary>
    public class GodotWebSocketAdapter : Node, ISocketAdapter
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
        public new bool IsConnected { get; private set; }

        /// <inheritdoc cref="ISocketAdapter.IsConnecting"/>
        public bool IsConnecting { get; private set; }

        private WebSocketClient ws;

        private TaskCompletionSource<bool> connectionSource;
        private int connectionTimeout;
        private ulong connectionStart;


        /// <summary>
        /// Constructs a GodotWebSocketAdapter.
        /// </summary>
        public GodotWebSocketAdapter() {
            IsConnected = false;
            IsConnecting = false;

            ws = new WebSocketClient();
            ws.Connect("data_received", this, "_socketReceived");
            ws.Connect("connection_established", this, "_socketConnected");
            ws.Connect("connection_error", this, "_socketError");
            ws.Connect("connection_closed", this, "_socketClosed");
        }

        /// <inheritdoc cref="ISocketAdaptor.CloseAsync"/>
        public Task CloseAsync() {
            ws.DisconnectFromHost();
            IsConnected = false;
            IsConnecting = false;
            return Task.CompletedTask;
        }

        /// <inheritdoc cref="ISocketAdaptor.ConnectAsync"/>
        public Task ConnectAsync(Uri uri, int timeout) {
            if (ws.GetConnectionStatus() != WebSocketClient.ConnectionStatus.Disconnected) {
                ws.DisconnectFromHost();
            }

            IsConnected = false;
            IsConnecting = true;

            connectionTimeout = timeout;
            connectionStart = OS.GetUnixTime();

            connectionSource = new TaskCompletionSource<bool>();

            var err = ws.ConnectToUrl(uri.ToString());
            if (err != Error.Ok) {
                return Task.FromException(new GodotWebSocketConnectionException());
            }

            return connectionSource.Task;
        }

        /// <inheritdoc cref="ISocketAdaptor.SendAsync"/>
        public Task SendAsync(ArraySegment<byte> buffer, bool reliable = true, CancellationToken canceller = default) {
            byte[] temp;

            if (buffer.Offset != 0 || buffer.Count != buffer.Array.Length) {
                temp = new byte[buffer.Count];
                Array.Copy(buffer.Array, buffer.Offset, temp, 0, buffer.Count);
            }
            else {
                temp = buffer.Array;
            }
            var err = ws.GetPeer(1).PutPacket(temp);
            if (err == Error.Ok) {
                return Task.CompletedTask;
            }

            return Task.FromException(new GodotWebSocketSendException());
        }

        public override void _Process(float delta) {
            if (ws.GetConnectionStatus() == WebSocketClient.ConnectionStatus.Connecting) {
                if (connectionStart + (ulong)connectionTimeout < OS.GetUnixTime()) {
                    ws.DisconnectFromHost();
                    IsConnecting = false;

                    Exception e = new GodotWebSocketConnectionException("WebSocket connection timed out");
                    ReceivedError?.Invoke(e);
                    connectionSource.SetException(e);
                    connectionSource = null;
                }
                else {
                    ws.Poll();
                }
            }
            else if (ws.GetConnectionStatus() != WebSocketClient.ConnectionStatus.Disconnected) {
                ws.Poll();
            }
        }

        public void _socketReceived() {
            Received?.Invoke(new ArraySegment<byte>(ws.GetPeer(1).GetPacket()));
        }

        public void _socketConnected(string protocol) {
            if (IsConnecting && connectionSource != null) {
                IsConnecting = false;
                IsConnected = true;

                ws.GetPeer(1).SetWriteMode(WebSocketPeer.WriteMode.Text);

                Connected?.Invoke();
                connectionSource.SetResult(true);
                connectionSource = null;
            }
        }

        public void _socketError() {
            if (IsConnecting && connectionSource != null) {
                IsConnecting = false;
                IsConnected = false;

                Exception e = new GodotWebSocketConnectionException();
                ReceivedError?.Invoke(e);
                connectionSource.SetException(e);
                connectionSource = null;
            }
        }

        public void _socketClosed(bool was_clean_close) {
            IsConnected = false;
            IsConnecting = false;
            Closed?.Invoke();
        }
    }
}

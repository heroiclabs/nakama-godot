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
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Nakama.TinyJson;
using Godot;

namespace Nakama
{
    /// <summary>
    /// An HTTP adapter that uses Godot's HttpRequest node.
    /// </summary>
    /// <remarks>
    /// Every request sends an 'Accept: application/json' header.
    /// </remarks>
    public partial class GodotHttpAdapter : Node, IHttpAdapter
    {
        /// <inheritdoc cref="IHttpAdapter.Logger"/>
        public ILogger Logger { get; set; }

        /// <inheritdoc cref="IHttpAdapter.TransientExceptionDelegate"/>
        public TransientExceptionDelegate TransientExceptionDelegate => IsTransientException;

        /// <inheritdoc cref="IHttpAdapter.SendAsync"/>
        public async Task<string> SendAsync(string method, Uri uri, IDictionary<string, string> headers,
            byte[] body, int timeout, CancellationToken? cancellationToken)
        {
            cancellationToken?.ThrowIfCancellationRequested();

            var req = new HttpRequest();
            req.Timeout = timeout;
            // No threads: in Godot 4.7 a threaded request to a peer that stops replying spins its thread, and then a
            // timeout or cancel freezes the game waiting for it. https://github.com/godotengine/godot/pull/117749
            req.UseThreads = false;
            // Calls from a pause menu must still finish.
            req.ProcessMode = ProcessModeEnum.Always;

            var godotMethod = HttpClient.Method.Get;
            if (method == "POST")
            {
                godotMethod = HttpClient.Method.Post;
            }
            else if (method == "PUT")
            {
                godotMethod = HttpClient.Method.Put;
            }
            else if (method == "DELETE")
            {
                godotMethod = HttpClient.Method.Delete;
            }
            else if (method == "HEAD")
            {
                godotMethod = HttpClient.Method.Head;
            }

            var headersArray = new string[headers.Count + 1];
            headersArray[0] = "Accept: application/json";
            var index = 1;
            foreach (var item in headers)
            {
                headersArray[index] = item.Key + ": " + item.Value;
                index++;
            }

            var bodyString = body != null ? System.Text.Encoding.UTF8.GetString(body) : "";

            AddChild(req);
            var err = req.Request(uri.ToString(), headersArray, godotMethod, bodyString);
            if (err != Error.Ok)
            {
                // A refused request never emits RequestCompleted. Status 0 is not retried, as in the GDScript client.
                req.QueueFree();
                throw new ApiResponseException(0, $"HTTP request to {uri} failed to send: {err}", 14);
            }

            Logger?.InfoFormat("Send: method='{0}', uri='{1}', body='{2}'", method, uri, bodyString);

            var completed = Await(ToSignal(req, HttpRequest.SignalName.RequestCompleted));
            if (cancellationToken.HasValue && cancellationToken.Value.CanBeCanceled)
            {
                var cancelled = new TaskCompletionSource();
                using (cancellationToken.Value.Register(() => cancelled.TrySetResult()))
                {
                    if (await Task.WhenAny(completed, cancelled.Task) == cancelled.Task)
                    {
                        // CancelRequest() does not emit RequestCompleted, so stop waiting for it here.
                        req.CancelRequest();
                        req.QueueFree();
                        cancellationToken.Value.ThrowIfCancellationRequested();
                    }
                }
            }

            var resultObjects = await completed;

            var result = (HttpRequest.Result)(long)resultObjects[0];
            var responseCode = (long)resultObjects[1];
            var responseBody = System.Text.Encoding.UTF8.GetString((byte[])resultObjects[3]);

            req.QueueFree();

            Logger?.InfoFormat("Received: result={0}, status={1}, contents='{2}'", result, responseCode, responseBody);

            if (result == HttpRequest.Result.Success && responseCode >= 200 && responseCode <= 299)
            {
                return responseBody;
            }

            // No reply, e.g. the server is unreachable: status -1 marks it transient, so it is retried.
            if (result != HttpRequest.Result.Success)
            {
                throw new ApiResponseException(-1, $"HTTP request to {uri} failed: {result}", -1);
            }

            var decoded = DecodeJsonObject(responseBody);
            if (decoded == null)
            {
                // Not an error body from Nakama, e.g. a proxy's HTML page, so pass it on as the message.
                throw new ApiResponseException(responseCode, responseBody, -1);
            }

            var message = decoded.ContainsKey("message") ? decoded["message"].ToString() : string.Empty;
            var grpcCode = decoded.ContainsKey("code") ? (int)decoded["code"] : -1;

            var exception = new ApiResponseException(responseCode, message, grpcCode);

            if (decoded.ContainsKey("error"))
            {
                IHttpAdapterUtil.CopyResponseError(this, decoded["error"], exception);
            }

            throw exception;
        }

        private static async Task<Variant[]> Await(SignalAwaiter signal)
        {
            return await signal;
        }

        // TinyJson throws on some invalid input, such as an empty string, and returns null on other input.
        private static Dictionary<string, object> DecodeJsonObject(string json)
        {
            try
            {
                return json.FromJson<Dictionary<string, object>>();
            }
            catch (Exception)
            {
                return null;
            }
        }

        private static bool IsTransientException(Exception e)
        {
            return e is ApiResponseException apiException && (apiException.StatusCode >= 500 || apiException.StatusCode == -1);
        }
    }
}

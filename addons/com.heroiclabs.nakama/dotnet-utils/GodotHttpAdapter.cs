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

namespace Nakama {

    /// <summary>
    /// An Http adapter which uses Godot's HttpRequest node.
    /// </summary>
    /// <remarks>
    /// Note Content-Type header is always set as 'application/json'.
    /// </remarks>
    public partial class GodotHttpAdapter : Node, IHttpAdapter {

        /// <inheritdoc cref="IHttpAdapter.Logger"/>
        public ILogger Logger { get; set; }

        /// <inheritdoc cref="IHttpAdapter.TransientExceptionDelegate"/>
        public TransientExceptionDelegate TransientExceptionDelegate => IsTransientException;

        /// <inheritdoc cref="IHttpAdapter"/>
        public async Task<string> SendAsync(string method, Uri uri, IDictionary<string, string> headers,
            byte[] body, int timeout, CancellationToken? cancellationToken)
        {
            var req = new HttpRequest();
            req.Timeout = timeout;

            if (OS.GetName() != "HTML5") {
                req.UseThreads = true;
            }

            var godot_method = HttpClient.Method.Get;
            if (method == "POST") {
                godot_method = HttpClient.Method.Post;
            }
            else if (method == "PUT") {
                godot_method = HttpClient.Method.Put;
            }
            else if (method == "DELETE") {
                godot_method = HttpClient.Method.Delete;
            }
            else if (method == "HEAD") {
                godot_method = HttpClient.Method.Head;
            }

            var headers_array = new String[headers.Count + 1];
            headers_array[0] = "Accept: application/json";
            int index = 1;
            foreach (var item in headers) {
                headers_array[index] = item.Key + ": " + item.Value;
                index++;
            }

            string body_string = body != null ? System.Text.Encoding.UTF8.GetString(body) : "";

            AddChild(req);
            req.Request(uri.ToString(), headers_array, godot_method, body_string);

            Logger?.InfoFormat("Send: method='{0}', uri='{1}', body='{2}'", method, uri, body_string);

            Variant[] resultObjects = await ToSignal(req, "request_completed");

            HttpRequest.Result result = (HttpRequest.Result)(long)resultObjects[0];
            long response_code = (long)resultObjects[1];
            string response_body = System.Text.Encoding.UTF8.GetString((byte[])resultObjects[3]);

            req.QueueFree();

            Logger?.InfoFormat("Received: status={0}, contents='{1}'", response_code, response_body);

            if (result == HttpRequest.Result.Success && response_code >= 200 && response_code <= 299) {
                return response_body;
            }

            var decoded = response_body.FromJson<Dictionary<string, object>>();
            string message = decoded.ContainsKey("message") ? decoded["message"].ToString() : string.Empty;
            int grpcCode = decoded.ContainsKey("code") ? (int) decoded["code"] : -1;

            var exception = new ApiResponseException(response_code, message, grpcCode);

            if (decoded.ContainsKey("error"))
            {
                IHttpAdapterUtil.CopyResponseError(this, decoded["error"], exception);
            }

            throw exception;
        }

        private static bool IsTransientException(Exception e) {
            return e is ApiResponseException apiException && (apiException.StatusCode >= 500 || apiException.StatusCode == -1);
        }

    }

}

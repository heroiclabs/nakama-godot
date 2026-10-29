# Copyright 2026 The Nakama Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class_name NakamaError
extends RefCounted
## Why a request failed: the server's rejection, a transport failure, a cancel, or a realtime socket
## error (the last three with http_status 0).

## gRPC status codes, as Nakama returns them in the error body.
const CANCELLED := 1
const UNKNOWN := 2
const INVALID_ARGUMENT := 3
const DEADLINE_EXCEEDED := 4
const NOT_FOUND := 5
const ALREADY_EXISTS := 6
const PERMISSION_DENIED := 7
const RESOURCE_EXHAUSTED := 8
const FAILED_PRECONDITION := 9
const ABORTED := 10
const OUT_OF_RANGE := 11
const UNIMPLEMENTED := 12
const INTERNAL := 13
const UNAVAILABLE := 14
const DATA_LOSS := 15
const UNAUTHENTICATED := 16

## HTTP status, or 0 when no response arrived (connect failure, timeout, cancel, socket error).
var http_status: int
var grpc_code: int
var message: String
## For errors the realtime socket reports: a NakamaRtTypes.ErrorCode; -1 otherwise.
var socket_code := -1


## Builds the error from a non-2xx response, whose body is {"code": <grpc>, "message": ...} from Nakama.
static func from_response(p_http_status: int, body: String) -> NakamaError:
	var json := JSON.new()
	var parsed: Variant = json.data if json.parse(body) == OK else null
	if parsed is Dictionary:
		var data: Dictionary = parsed
		if data.has("code"):
			var code: int = type_convert(data["code"], TYPE_INT)
			var text: String = data.get("message", "")
			return NakamaError.new(p_http_status, code, text)
	# Not a Nakama body, e.g. a load balancer page.
	return NakamaError.new(p_http_status, UNKNOWN, body)


## Builds the error from the realtime socket's {"code": <ErrorCode>, "message": ...} envelope field.
static func from_socket(error: Dictionary) -> NakamaError:
	var text: String = error.get("message", "")
	var code: int = type_convert(error.get("code", 0), TYPE_INT)
	return NakamaError.new(0, UNKNOWN, text, code)


func _init(p_http_status: int, p_grpc_code: int, p_message: String,
		p_socket_code: int = -1) -> void:
	http_status = p_http_status
	grpc_code = p_grpc_code
	message = p_message
	socket_code = p_socket_code


func _to_string() -> String:
	if socket_code >= 0:
		return "NakamaError(socket %d): %s" % [socket_code, message]
	return "NakamaError(http %d, grpc %d): %s" % [http_status, grpc_code, message]

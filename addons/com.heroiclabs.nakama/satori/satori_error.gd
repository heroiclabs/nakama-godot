# Copyright 2026 The Satori Authors
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

class_name SatoriError
extends RefCounted
## Why a request failed: the server's rejection, or a transport failure (http_status 0).

## gRPC status codes, as Satori returns them in the error body.
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

## HTTP status, or 0 when no response arrived (connect failure, timeout, cancel).
var http_status: int
var grpc_code: int
var message: String


## Builds the error from a non-2xx response, whose body is {"code": <grpc>, "message": ...} from Satori.
static func from_response(p_http_status: int, body: String) -> SatoriError:
	var json := JSON.new()
	var parsed: Variant = json.data if json.parse(body) == OK else null
	if parsed is Dictionary:
		var data: Dictionary = parsed
		if data.has("code"):
			var code: int = type_convert(data["code"], TYPE_INT)
			var text: String = data.get("message", "")
			return SatoriError.new(p_http_status, code, text)
	# Not a Satori body, e.g. a load balancer page.
	return SatoriError.new(p_http_status, UNKNOWN, body)


func _init(p_http_status: int, p_grpc_code: int, p_message: String) -> void:
	http_status = p_http_status
	grpc_code = p_grpc_code
	message = p_message


func _to_string() -> String:
	return "SatoriError(http %d, grpc %d): %s" % [http_status, grpc_code, message]

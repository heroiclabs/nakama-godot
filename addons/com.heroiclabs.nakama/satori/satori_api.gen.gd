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

# Code generated from the Satori protos. DO NOT EDIT.
class_name SatoriAPI
extends RefCounted


## Authenticate against the server.
static func authenticate(request: SatoriTypes.AuthenticateRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v1/authenticate", {}, request.to_json())


## Refresh an identity's session using a refresh token retrieved from a previous authentication request.
static func authenticate_refresh(
		request: SatoriTypes.AuthenticateRefreshRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v1/authenticate/refresh", {}, request.to_json())


## Get or list all available experiments for this identity.
static func get_experiments(names: Array[String] = [],
		labels: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v1/experiment", {
		"names": names,
		"labels": labels,
	})


## List all available flags and their value overrides for this identity.
static func get_flag_overrides(names: Array[String] = [],
		labels: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v1/flag/override", {
		"names": names,
		"labels": labels,
	})


## List all available flags for this identity.
static func get_flags(names: Array[String] = [], labels: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v1/flag", {
		"names": names,
		"labels": labels,
	})


## List available live events.
static func get_live_events(past_run_count: int = 0, future_run_count: int = 0,
		start_time_sec: int = 0, end_time_sec: int = 0, names: Array[String] = [],
		labels: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v1/live-event", {
		"past_run_count": past_run_count,
		"future_run_count": future_run_count,
		"start_time_sec": start_time_sec,
		"end_time_sec": end_time_sec,
		"names": names,
		"labels": labels,
	})


## Enrich/replace the current session with a new identifier.
static func identify(request: SatoriTypes.IdentifyRequest) -> ApiRequestModel:
	return ApiRequestModel.new("PUT", "/v1/identify", {}, request.to_json())


## Get the list of messages for the identity.
static func get_message_list(limit: int = 1, forward: bool = true, cursor: String = "",
		message_ids: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v1/message", {
		"limit": limit,
		"forward": forward,
		"cursor": cursor,
		"message_ids": message_ids,
	})


## Log out a session, invalidate a refresh token, or log out all sessions/refresh tokens for an identity.
static func authenticate_logout(request: SatoriTypes.AuthenticateLogoutRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v1/authenticate/logout", {}, request.to_json())


## Publish an event for this session.
static func event(request: SatoriTypes.EventRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v1/event", {}, request.to_json())


## Publish server events for multiple distinct identities.
static func server_event(request: SatoriTypes.EventRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v1/server-event", {}, request.to_json())


## Join an 'explicit join' live event.
static func join_live_event(id: String = "") -> ApiRequestModel:
	var url := "/v1/live-event/{id}/participation"
	url = url.replace("{id}", str(id).uri_encode())
	return ApiRequestModel.new("POST", url)


## Update identity properties.
static func update_properties(request: SatoriTypes.UpdatePropertiesRequest) -> ApiRequestModel:
	return ApiRequestModel.new("PUT", "/v1/properties", {}, request.to_json())


## Update a message for an identity.
static func update_message(request: SatoriTypes.UpdateMessageRequest) -> ApiRequestModel:
	var url := "/v1/message/{id}"
	url = url.replace("{id}", str(request.id).uri_encode())
	return ApiRequestModel.new("PUT", url, {}, request.to_json())


## Delete a message for an identity.
static func delete_message(id: String = "") -> ApiRequestModel:
	var url := "/v1/message/{id}"
	url = url.replace("{id}", str(id).uri_encode())
	return ApiRequestModel.new("DELETE", url)


## List properties associated with this identity.
static func list_properties() -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v1/properties")


## Delete the caller's identity and associated data.
static func delete_identity() -> ApiRequestModel:
	return ApiRequestModel.new("DELETE", "/v1/identity")


## A healthcheck which load balancers can use to check the service.
static func healthcheck() -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/healthcheck")


## A readycheck which load balancers can use to check the service.
static func readycheck() -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/readycheck")


## An HTTP request for the client to send.
class ApiRequestModel:
	var verb: String
	var url: String
	var body: String


	## p_query is appended to p_url, skipping nulls; arrays repeat the key.
	func _init(p_verb: String, p_url: String, p_query: Dictionary = {},
			p_body: String = "") -> void:
		verb = p_verb
		body = p_body
		var query := PackedStringArray()
		for key: String in p_query:
			var value: Variant = p_query[key]
			if value == null:
				continue
			for item: Variant in (value if value is Array else [value]):
				query.append("%s=%s" % [key, str(item).uri_encode()])
		url = p_url if query.is_empty() else p_url + "?" + "&".join(query)

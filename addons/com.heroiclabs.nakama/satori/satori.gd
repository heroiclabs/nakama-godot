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

class_name Satori
extends RefCounted
## Satori's HTTP API: a function per server call, plus auth, session refresh, retries, and timeouts.

## Emitted after a session's tokens are renewed in place, e.g. to save the new ones.
signal session_refreshed(session: SatoriSession)

enum LogLevel { NONE, ERROR, WARNING, INFO, DEBUG }

## Refresh within this many seconds of expiry, or half the token lifetime if shorter.
const REFRESH_MARGIN_SEC := 300
const TRANSIENT_CODES := [500, 502, 503, 504]

var auto_refresh_session: bool
## Retries on transient errors, exponential backoff with full jitter.
var retry_base_delay_ms := 500
var retry_max_attempts := 4
## Cap on a single retry wait, before jitter. 0: no cap.
var retry_max_delay_ms := 10_000
## 0: no total limit.
var retry_max_total_ms := 60_000
## Seconds per request, connecting included.
var timeout_sec := 10
var log_level := LogLevel.WARNING
var host: String
var _api_key: String
## Sessions being refreshed, so concurrent calls share one refresh.
var _refreshing: Dictionary


## A Timestamp field's value, e.g. for SatoriTypes.Event.timestamp: unix_time in RFC 3339 UTC with the Z
## the server requires.
static func timestamp(unix_time: float = Time.get_unix_time_from_system()) -> String:
	return Time.get_datetime_string_from_unix_time(int(unix_time)) + ".%06dZ" % int(fmod(unix_time, 1.0) * 1_000_000)


## Moves new_session's tokens and properties into session, so everyone holding session sees them.
static func _update_session(session: SatoriSession, new_session: SatoriSession) -> void:
	session.update(new_session.token, new_session.refresh_token)
	if new_session.properties != null:
		session.properties = new_session.properties


## Awaits done; if canceller cancels first, runs on_cancel, which must emit done so the wait ends.
static func _until(done: Signal, canceller: SatoriCanceller, on_cancel: Callable) -> Variant:
	if canceller == null:
		return await done
	canceller.cancelled.connect(on_cancel)
	if canceller.is_cancelled:
		on_cancel.call_deferred()  # deferred: done must be emitted after the await below starts
	var value: Variant = await done
	canceller.cancelled.disconnect(on_cancel)
	return value


## Satori is only hosted, so it is always reached over HTTPS on port 443.
func _init(p_api_key: String, p_host: String, p_timeout_sec: int = 10,
		p_auto_refresh_session: bool = true) -> void:
	_api_key = p_api_key
	host = p_host
	timeout_sec = p_timeout_sec
	auto_refresh_session = p_auto_refresh_session


## Authenticate against the server.
func authenticate_async(id: String, default: Dictionary = {}, custom: Dictionary = {},
		no_session: bool = false, canceller: SatoriCanceller = null) -> SatoriResult:
	var request := SatoriTypes.AuthenticateRequest.new(id, default, custom, no_session)
	var request_model := SatoriAPI.authenticate(request)
	var result: SatoriResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = SatoriSession.from_json(result.value)
	return result


func authenticate_logout_async(session: SatoriSession,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request := SatoriTypes.AuthenticateLogoutRequest.new(session.token, session.refresh_token)
	var request_model := SatoriAPI.authenticate_logout(request)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Renews session's tokens in place and emits session_refreshed; a rejected refresh token is cleared.
func authenticate_refresh_async(session: SatoriSession,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request := SatoriTypes.AuthenticateRefreshRequest.new(session.refresh_token)
	var request_model := SatoriAPI.authenticate_refresh(request)
	return _refreshed(session, await _send(request_model, canceller))


## Delete the caller's identity and associated data.
func delete_identity_async(session: SatoriSession,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.delete_identity()
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Delete a message for an identity.
func delete_message_async(session: SatoriSession, id: String,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.delete_message(id)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


func event_async(session: SatoriSession, event: SatoriTypes.Event,
		canceller: SatoriCanceller = null) -> SatoriResult:
	return await events_async(session, [event], canceller)


## Publish events for this session.
func events_async(session: SatoriSession, events: Array[SatoriTypes.Event],
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request := SatoriTypes.EventRequest.new(events)
	var request_model := SatoriAPI.event(request)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Get or list all available experiments for this identity.
func get_experiments_async(session: SatoriSession, names: Array[String] = [],
		labels: Array[String] = [], canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.get_experiments(names, labels)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = SatoriTypes.ExperimentList.from_json(result.value)
	return result


## One flag by name. When the call fails, e.g. offline, value is still a flag holding default and error says
## why, so a game can play on with the default; an unknown flag also gets default.
func get_flag_async(session: SatoriSession, name: String, default: String = "",
		canceller: SatoriCanceller = null) -> SatoriResult:
	return _flag(await get_flags_async(session, [name], [], canceller), name, default)


## Like get_flag_async with the API key instead of a session, e.g. before login.
func get_flag_default_async(name: String, default: String = "",
		canceller: SatoriCanceller = null) -> SatoriResult:
	return _flag(await get_flags_default_async([name], [], canceller), name, default)


## List all available flags and their value overrides for this identity.
func get_flag_overrides_async(session: SatoriSession, names: Array[String] = [],
		labels: Array[String] = [], canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.get_flag_overrides(names, labels)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = SatoriTypes.FlagOverrideList.from_json(result.value)
	return result


## Like get_flag_overrides_async with the API key instead of a session, e.g. defaults before login.
func get_flag_overrides_default_async(names: Array[String] = [], labels: Array[String] = [],
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.get_flag_overrides(names, labels)
	var result: SatoriResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = SatoriTypes.FlagOverrideList.from_json(result.value)
	return result


## List all available flags for this identity.
func get_flags_async(session: SatoriSession, names: Array[String] = [], labels: Array[String] = [],
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.get_flags(names, labels)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = SatoriTypes.FlagList.from_json(result.value)
	return result


## Like get_flags_async with the API key instead of a session, e.g. defaults before login.
func get_flags_default_async(names: Array[String] = [], labels: Array[String] = [],
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.get_flags(names, labels)
	var result: SatoriResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = SatoriTypes.FlagList.from_json(result.value)
	return result


## List available live events.
func get_live_events_async(session: SatoriSession, past_run_count: int = 0,
		future_run_count: int = 0, start_time_sec: int = 0, end_time_sec: int = 0,
		names: Array[String] = [], labels: Array[String] = [],
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.get_live_events(past_run_count, future_run_count, start_time_sec,
			end_time_sec, names, labels)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = SatoriTypes.LiveEventList.from_json(result.value)
	return result


## Get the list of messages for the identity.
func get_message_list_async(session: SatoriSession, limit: int = 1, forward: bool = true,
		cursor: String = "", message_ids: Array[String] = [],
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.get_message_list(limit, forward, cursor, message_ids)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = SatoriTypes.GetMessageListResponse.from_json(result.value)
	return result


## A healthcheck which load balancers can use to check the service.
func healthcheck_async(session: SatoriSession, canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.healthcheck()
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Enrich/replace the current session with a new identifier.
func identify_async(session: SatoriSession, id: String, default: Dictionary = {},
		custom: Dictionary = {}, canceller: SatoriCanceller = null) -> SatoriResult:
	var request := SatoriTypes.IdentifyRequest.new(id, default, custom)
	var request_model := SatoriAPI.identify(request)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	# Update session in place with the new tokens so its holders keep working.
	if result.error == null:
		_update_session(session, SatoriSession.from_json(result.value))
		result.value = session
	return result


## Join an 'explicit join' live event.
func join_live_event_async(session: SatoriSession, id: String,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.join_live_event(id)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## List properties associated with this identity.
func list_properties_async(session: SatoriSession,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.list_properties()
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = SatoriTypes.Properties.from_json(result.value)
	return result


## A readycheck which load balancers can use to check the service.
func readycheck_async(session: SatoriSession, canceller: SatoriCanceller = null) -> SatoriResult:
	var request_model := SatoriAPI.readycheck()
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Publish server events for multiple distinct identities.
func server_events_async(events: Array[SatoriTypes.Event],
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request := SatoriTypes.EventRequest.new(events)
	var request_model := SatoriAPI.server_event(request)
	var result: SatoriResult = await _send(request_model, canceller)
	result.value = null
	return result


## Update a message for an identity.
func update_message_async(session: SatoriSession, id: String, read_time: int = 0,
		consume_time: int = 0, canceller: SatoriCanceller = null) -> SatoriResult:
	var request := SatoriTypes.UpdateMessageRequest.new(id, read_time, consume_time)
	var request_model := SatoriAPI.update_message(request)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Update identity properties.
func update_properties_async(session: SatoriSession, default: Dictionary = {},
		custom: Dictionary = {}, recompute: Variant = null,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var request := SatoriTypes.UpdatePropertiesRequest.new(default, custom, recompute)
	var request_model := SatoriAPI.update_properties(request)
	var result: SatoriResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


func _log(level: LogLevel, message: String) -> void:
	if level > log_level:
		return
	match level:
		LogLevel.ERROR: push_error("Satori: " + message)
		LogLevel.WARNING: push_warning("Satori: " + message)
		_: print("Satori: " + message)


## Sends a request built by SatoriAPI with the API key, as authenticate calls do.
func _send(request: SatoriAPI.ApiRequestModel, canceller: SatoriCanceller = null) -> SatoriResult:
	return await _send_with_retry(request, "Basic " + Marshalls.utf8_to_base64(_api_key + ":"), canceller)


## Sends with session's token, refreshing it first when near expiry.
func _send_with_session(session: SatoriSession, request: SatoriAPI.ApiRequestModel,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var can_refresh := session.refresh_token != "" and not session.has_refresh_expired()
	var margin_sec := mini(REFRESH_MARGIN_SEC, int((session.expire_time - session.create_time) / 2.0))
	var expires_soon := session.has_expired(margin_sec)
	if auto_refresh_session and can_refresh and expires_soon:
		await _refresh_session(session, canceller)
	return await _send_with_retry(request, "Bearer " + session.token, canceller)


## Value is the parsed JSON reply; error after retrying transient failures.
func _send_with_retry(request: SatoriAPI.ApiRequestModel, auth: String,
		canceller: SatoriCanceller = null) -> SatoriResult:
	var start := Time.get_ticks_msec()
	var retries := 0
	var what := "%s %s" % [request.verb, request.url.get_slice("?", 0)]
	while true:
		if canceller and canceller.is_cancelled:
			return SatoriResult.new(null, SatoriError.new(0, SatoriError.CANCELLED, "%s cancelled" % what))
		var response: Dictionary = await _request(request, auth, canceller)
		var code: int = response["code"]
		var text: String = response["text"]
		_log(LogLevel.DEBUG, "%s: %d" % [what, code])
		if code >= 200 and code < 300:
			if text == "":
				return SatoriResult.new({})
			var json := JSON.new()
			if json.parse(text) == OK and json.data is Dictionary:
				return SatoriResult.new(json.data)
			# Not from Satori, e.g. a captive portal's login page.
			return SatoriResult.new(null, SatoriError.new(code, SatoriError.UNKNOWN, "%s %s: reply is not a JSON object: %s" % [
					request.verb, request.url.get_slice("?", 0), text.left(200)]))
		var error: SatoriError
		if code == 0:
			var grpc_code: int = response["grpc_code"]
			error = SatoriError.new(0, grpc_code, "%s %s %s" % [request.verb, request.url.get_slice("?", 0), text])
		else:
			error = SatoriError.from_response(code, text)
		var backoff_ms := pow(2, retries) * retry_base_delay_ms
		if retry_max_delay_ms > 0:
			backoff_ms = minf(backoff_ms, retry_max_delay_ms)
		var delay_ms := int(backoff_ms * randf())
		if code not in TRANSIENT_CODES or retries >= retry_max_attempts or (retry_max_total_ms > 0 and Time.get_ticks_msec() - start + delay_ms >= retry_max_total_ms):
			_log(LogLevel.INFO, "%s failed: %s" % [what, error])
			return SatoriResult.new(null, error)
		retries += 1
		_log(LogLevel.WARNING, "%s failed with %d, retry %d in %d ms" % [what, code, retries, delay_ms])
		var timer: SceneTreeTimer = (Engine.get_main_loop() as SceneTree).create_timer(delay_ms / 1000.0)
		await _until(timer.timeout, canceller, func() -> void: timer.timeout.emit())
	return null


## Waits for session's refresh, starting it unless another call has. A canceller ends the wait, not the refresh,
## which other calls may share.
func _refresh_session(session: SatoriSession, canceller: SatoriCanceller) -> void:
	if not _refreshing.has(session):
		# No await: finishes on its own, for the calls that share it
		_run_refresh(session)
	while _refreshing.has(session) and not (canceller and canceller.is_cancelled):
		await (Engine.get_main_loop() as SceneTree).process_frame


func _run_refresh(session: SatoriSession) -> void:
	_refreshing[session] = true
	# On failure the call proceeds with the old token and gets UNAUTHENTICATED.
	var refreshed: SatoriResult = await authenticate_refresh_async(session)
	if refreshed.error != null:
		_log(LogLevel.WARNING, "session refresh failed: %s" % refreshed.error)
	_refreshing.erase(session)


## Applies a refresh reply to session: new tokens in place and session_refreshed, or, if the refresh token
## is rejected, clears it so auto refresh stops retrying it on every call.
func _refreshed(session: SatoriSession, result: SatoriResult) -> SatoriResult:
	if result.error == null:
		var new_session := SatoriSession.from_json(result.value)
		_update_session(session, new_session)
		result.value = session
		session_refreshed.emit(session)
	elif result.error.grpc_code == SatoriError.UNAUTHENTICATED:
		session.refresh_token = ""
	return result


## {"code": HTTP status, or 0 plus "grpc_code" if no reply, "text": body or error}. One HTTPRequest per call.
func _request(request: SatoriAPI.ApiRequestModel, auth: String,
		canceller: SatoriCanceller = null) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = timeout_sec
	# No threads: in Godot 4.7 a threaded request to a peer that stops replying spins its thread, and then a timeout
	# or cancel freezes the game waiting for it. https://github.com/godotengine/godot/pull/117749
	http.use_threads = false
	http.process_mode = Node.PROCESS_MODE_ALWAYS  # calls from a pause menu must still finish
	# Deferred: the root rejects children while setting up a scene, e.g. from _ready().
	(Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(http)
	await http.ready
	var headers := PackedStringArray(["Content-Type: application/json", "Accept: application/json", "Authorization: " + auth])
	# Godot sends no Content-Length for an empty body, and some proxies answer 411 Length Required.
	if request.body.is_empty() and request.verb in ["POST", "PUT", "PATCH"]:
		headers.append("Content-Length: 0")
	var methods := {
		"GET": HTTPClient.METHOD_GET,
		"POST": HTTPClient.METHOD_POST,
		"PUT": HTTPClient.METHOD_PUT,
		"PATCH": HTTPClient.METHOD_PATCH,
		"DELETE": HTTPClient.METHOD_DELETE,
	}
	var url := "https://%s%s" % [host, request.url]
	var method: HTTPClient.Method = methods[request.verb]
	var err := http.request(url, headers, method, request.body)
	if err != OK:
		http.queue_free()
		return {"code": 0, "grpc_code": SatoriError.UNAVAILABLE, "text": "failed to send: %s" % error_string(err)}
	# Result -1 marks a cancel; HTTPRequest has no result code of its own for one.
	var completed: Array = await _until(http.request_completed, canceller, func() -> void:
		http.cancel_request()
		http.request_completed.emit(-1, 0, PackedStringArray(), PackedByteArray()))
	http.queue_free()
	var result: int = completed[0]
	if result == -1:
		return {"code": 0, "grpc_code": SatoriError.CANCELLED, "text": "cancelled"}
	if result == HTTPRequest.RESULT_TIMEOUT:
		return {"code": 0, "grpc_code": SatoriError.DEADLINE_EXCEEDED, "text": "timed out after %d s" % timeout_sec}
	if result != HTTPRequest.RESULT_SUCCESS:
		return {"code": 0, "grpc_code": SatoriError.UNAVAILABLE, "text": "failed, HTTPRequest result %d" % result}
	var body: PackedByteArray = completed[3]
	return {"code": completed[1], "text": body.get_string_from_utf8()}


func _flag(result: SatoriResult, name: String, default: String) -> SatoriResult:
	if result.error == null:
		for flag: SatoriTypes.Flag in result.value.flags:
			if flag.name == name:
				result.value = flag
				return result
	result.value = SatoriTypes.Flag.new(name, default)
	return result

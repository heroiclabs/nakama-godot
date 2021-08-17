tool
extends Node

# An adapter which implements the HTTP protocol.
class_name NakamaHTTPAdapter

# The logger to use with the adapter.
var logger : Reference = NakamaLogger.new()

# The timeout for requests
var timeout : int = 3
# If request should be automatically retried when a network error occurs.
var auto_retry : bool = true
# The maximum number of time a request will be retried when auto_retry is true
var auto_retry_count : int = 3
var auto_retry_backoff_base : int = 10

var _pending = {}
var id : int = 0

class AsyncRequest:
	var id : int
	var request : HTTPRequest
	var uri : String
	var method : int
	var headers : PoolStringArray
	var body : PoolByteArray
	var retry_count := 3
	var backoff_time := 10
	var logger : NakamaLogger

	var cancelled = false
	var result : int = HTTPRequest.RESULT_NO_RESPONSE
	var response_code : int = -1
	var response_body : PoolByteArray
	var timer : SceneTreeTimer = null
	var cur_try : int = 1
	var rng = RandomNumberGenerator.new()

	func _init(p_id : int, p_request : HTTPRequest, p_uri : String,
			p_method : int, p_headers : PoolStringArray, p_body : PoolByteArray,
			p_retry_count : int, p_backoff_time : int, p_logger : NakamaLogger):
		rng.seed = OS.get_ticks_usec()
		id = p_id
		request = p_request
		uri = p_uri
		method = p_method
		headers = p_headers
		body = p_body
		retry_count = p_retry_count
		backoff_time = p_backoff_time
		logger = p_logger

	func should_retry():
		return cur_try < retry_count and not cancelled

	func retry():
		var time = pow(backoff_time, cur_try) * rng.randf_range(0.5, 1)
		logger.debug("Retrying request %d. Tries left: %d. Backoff: %d ms" % [
			id, retry_count - cur_try, time
		])
		cur_try += 1
		yield(backoff(time), "completed")
		if cancelled:
			return
		return yield(make_request(), "completed")

	func make_request():
		var err = request.request(uri, headers, true, method, body.get_string_from_utf8())
		if err != OK:
			yield(request.get_tree(), "idle_frame")
			result = HTTPRequest.RESULT_CANT_CONNECT
			logger.debug("Request %d failed to start, error: %d" % [id, err])
			return

		var args = yield(request, "request_completed")
		result = args[0]
		response_code = args[1]
		response_body = args[3]

	func backoff(p_time : int):
		timer = request.get_tree().create_timer(p_time / 1000)
		yield(timer, "timeout")
		timer = null

	func cancel():
		cancelled = true
		request.cancel_request()
		if timer:
			timer.time_left = 0
		else:
			request.call_deferred("emit_signal", "request_completed", HTTPRequest.RESULT_REQUEST_FAILED, 0, [], [])

	func parse_result():
		if cancelled:
			return NakamaException.new("Request cancelled", -1, -1, true)
		elif result != HTTPRequest.RESULT_SUCCESS:
			return NakamaException.new("HTTPRequest failed!", result)

		var json : JSONParseResult = JSON.parse(response_body.get_string_from_utf8())
		if json.error != OK:
			logger.debug("Unable to parse request %d response. JSON error: %d, response code: %d" % [
				id, json.error, response_code
			])
			return NakamaException.new("Failed to decode JSON response", response_code)

		if response_code != HTTPClient.RESPONSE_OK:
			var error = ""
			var code = -1
			if typeof(json.result) == TYPE_DICTIONARY:
				if "message" in json.result:
					error = json.result["message"]
				elif "error" in json.result:
					error = json.result["error"]
				else:
					error = str(json.result)
				code = json.result["code"] if "code" in json.result else -1
			else:
				error = str(json.result)
			if typeof(error) == TYPE_DICTIONARY:
				error = JSON.print(error)
			logger.debug("Request %d returned response code: %d, RPC code: %d, error: %s" % [
				id, response_code, code, error
			])
			return NakamaException.new(error, response_code, code)

		return json.result


# Send a HTTP request.
# @param method - HTTP method to use for this request.
# @param uri - The fully qualified URI to use.
# @param headers - Request headers to set.
# @param body - Request content body to set.
# @param timeoutSec - Request timeout.
# Returns a task which resolves to the contents of the response.
func send_async(p_method : String, p_uri : String, p_headers : Dictionary, p_body : PoolByteArray):
	var req = HTTPRequest.new()
	req.timeout = timeout
	if OS.get_name() != 'HTML5':
		req.use_threads = true # Threads not available nor needed on the web.

	# Parse method
	var method = HTTPClient.METHOD_GET
	if p_method == "POST":
		method = HTTPClient.METHOD_POST
	elif p_method == "PUT":
		method = HTTPClient.METHOD_PUT
	elif p_method == "DELETE":
		method = HTTPClient.METHOD_DELETE
	elif p_method == "HEAD":
		method = HTTPClient.METHOD_HEAD
	var headers = PoolStringArray()

	# Parse headers
	headers.append("Accept: application/json")
	for k in p_headers:
		headers.append("%s: %s" % [k, p_headers[k]])

	id += 1
	var retry = auto_retry_count if auto_retry else 0
	var backoff = auto_retry_backoff_base
	_pending[id] = AsyncRequest.new(id, req, p_uri, method, headers, p_body, retry, backoff, logger)

	logger.debug("Sending request [ID: %d, Method: %s, Uri: %s, Headers: %s, Body: %s, Timeout: %d, Retries: %d, Backoff base: %d ms]" % [
		id, p_method, p_uri, p_headers, p_body.get_string_from_utf8(), timeout, retry, backoff
	])

	add_child(req)

	return _send_async(id, _pending)

func get_last_token():
	return id

func cancel_request(p_token):
	if _pending.has(p_token):
		_pending[p_token].cancel()

static func _clear_request(p_request : AsyncRequest, p_pending : Dictionary, p_id : int):
	if not p_request.request.is_queued_for_deletion():
		p_request.logger.debug("Freeing request %d" % p_id)
		p_request.request.queue_free()
		p_pending.erase(p_id)

static func _send_async(p_id : int, p_pending : Dictionary):

	var req : AsyncRequest = p_pending[p_id]
	yield(req.make_request(), "completed")

	while req.result != HTTPRequest.RESULT_SUCCESS:
		req.logger.debug("Request %d failed with result: %d, response code: %d" % [
			p_id, req.result, req.response_code
		])
		if not req.should_retry():
			break
		yield(req.retry(), "completed")

	_clear_request(req, p_pending, p_id)
	return req.parse_result()

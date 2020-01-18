tool
extends Node

### <summary>
### An adapter which implements the HTTP protocol.
### </summary>
class_name NakamaHTTPAdapter

### <summary>
### The logger to use with the adapter.
### </summary>
var logger : Reference = null

var _pending = {}
var id : int = 0

### <summary>
### Send a HTTP request.
### </summary>
### <param name="method">HTTP method to use for this request.</param>
### <param name="uri">The fully qualified URI to use.</param>
### <param name="headers">Request headers to set.</param>
### <param name="body">Request content body to set.</param>
### <param name="timeoutSec">Request timeout.</param>
### <returns>A task which resolves to the contents of the response.</returns>
func send_async(p_method : String, p_uri : String, p_headers : Dictionary, p_body : PoolByteArray, p_timeout : int = 3):
	var req = HTTPRequest.new()
	req.use_threads = true

	# Not supported in 3.1
	#req.timeout = p_timeout

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

	# Handle timeout for 3.1 compatibility
	id += 1
	_pending[id] = [req, OS.get_ticks_msec() + (p_timeout * 1000)]

	add_child(req)
	return _send_async(req, p_uri, headers, method, p_body, id, _pending)

func _process(delta):
	# Handle timeout for 3.1 compatibility
	var ids = _pending.keys()
	for id in ids:
		var p = _pending[id]
		if p[0].is_queued_for_deletion():
			_pending.erase(id)
			continue
		if p[1] < OS.get_ticks_msec():
			p[0].cancel_request()
			_pending.erase(id)
			p[0].emit_signal("request_completed", HTTPRequest.RESULT_REQUEST_FAILED, 0, PoolStringArray(), PoolByteArray())

static func _send_async(request : HTTPRequest, p_uri : String, p_headers : PoolStringArray,
		p_method : int, p_body : PoolByteArray, p_id : int, p_pending : Dictionary):

	if request.request(p_uri, p_headers, true, p_method, p_body.get_string_from_utf8()) != OK:
		yield(request.get_tree(), "idle_frame")
		request.queue_free()
		return NakamaAPI.ResponseException.new()

	var args = yield(request, "request_completed")
	var result = args[0]
	var response_code = args[1]
	var _headers = args[2]
	var body = args[3]

	# Will be deleted next frame
	if not request.is_queued_for_deletion():
		request.queue_free()
		p_pending.erase(p_id)

	if result != HTTPRequest.RESULT_SUCCESS:
		return NakamaException.new("HTTPRequest failed!", result)

	var json : JSONParseResult = JSON.parse(body.get_string_from_utf8())
	if json.error != OK:
		return NakamaException.new("Failed to decode JSON response", response_code)

	if response_code != HTTPClient.RESPONSE_OK:
		return NakamaException.new(json.result["error"], response_code, json.result["code"])

	return json.result

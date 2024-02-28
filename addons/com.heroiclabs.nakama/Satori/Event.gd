extends SatoriAsyncResult

class_name Event

# The name of the event.
var name: String

# The time when the event was triggered.
var timestamp: String

# Optional value.
var value: String

# Event metadata, if any.
var metadata: Dictionary

# Optional event ID assigned by the client, used to de-duplicate in retransmission scenarios.
# If not supplied the server will assign a randomly generated unique event identifier.
var id: String

# The event constructor.
 # Initializes a new Event object.
 #
 # @param name The name of the event.
 # @param timestamp The timestamp of the event.
 # @param value The value associated with the event (optional).
 # @param metadata The metadata associated with the event (optional).
 # @param id The ID of the event (optional).
func _init(name: String, timestamp: float, value: String = "", metadata: Dictionary = {}, id: String = "", p_exception = null):
	super(p_exception)
	
	self.name = name
	self.timestamp = unix_to_protobuf_timestamp_format(timestamp)
	self.value = value
	self.metadata = metadata
	self.id = id

func to_api_event_dict() -> Dictionary:
	return {
		"name": self.name,
		"timestamp": self.timestamp,
		"value": self.value,
		"metadata": self.metadata,
		"id": self.id
	}

func unix_to_protobuf_timestamp_format(unix_time: float) -> String:
	# Extract microseconds precision from unix time
	var microseconds = int(fmod(unix_time, 1.0) * 1_000_000)
	
	# Convert seconds to datetime structure
	var datetime = Time.get_datetime_dict_from_unix_time(int(unix_time))
	
	var year = datetime.year
	var month = str(datetime.month).pad_zeros(2)
	var day = str(datetime.day).pad_zeros(2)
	var hour = str(datetime.hour).pad_zeros(2)
	var minute = str(datetime.minute).pad_zeros(2)
	var second = str(datetime.second).pad_zeros(2)
	var microsecond = str(microseconds).pad_zeros(6)

	# Construct the protobuf timestamp format string
	var timestamp_str = "%s-%s-%sT%s:%s:%s.%sZ" % [year, month, day, hour, minute, second, microsecond]
	
	return timestamp_str
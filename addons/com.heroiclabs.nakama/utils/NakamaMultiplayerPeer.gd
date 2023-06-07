extends MultiplayerPeerExtension
class_name NakamaMultiplayerPeer

const MAX_PACKET_SIZE := 1 << 24

var _self_id := 0
var _connection_status: ConnectionStatus = CONNECTION_DISCONNECTED
var _refusing_new_connections := false
var _target_id := 0

class Packet extends RefCounted:
	var data: PackedByteArray
	var from: int

	func _init(p_data: PackedByteArray, p_from: int) -> void:
		data = p_data
		from = p_from

var _incoming_packets := []

signal packet_generated (peer_id, buffer)

func _get_packet_script() -> PackedByteArray:
	if _incoming_packets.size() == 0:
		return PackedByteArray()
	return _incoming_packets.pop_front().data

func _get_packet_mode() -> TransferMode:
	return TRANSFER_MODE_RELIABLE

func _get_packet_channel() -> int:
	return 0

func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	packet_generated.emit(_target_id, p_buffer)
	return OK

func _get_available_packet_count() -> int:
	return _incoming_packets.size()

func _get_max_packet_size() -> int:
	return MAX_PACKET_SIZE

func _set_transfer_channel(p_channel) -> void:
	pass

func _get_transfer_channel() -> int:
	return 0

func _set_transfer_mode(p_mode: TransferMode) -> void:
	pass

func _get_transfer_mode() -> TransferMode:
	return TRANSFER_MODE_RELIABLE

func _set_target_peer(p_peer_id: int) -> void:
	_target_id = p_peer_id

func _get_packet_peer() -> int:
	if _connection_status != CONNECTION_CONNECTED:
		return 1
	if _incoming_packets.size() == 0:
		return 1

	return _incoming_packets[0].from

func _is_server() -> bool:
	return _self_id == 1

func _poll() -> void:
	pass

func _get_unique_id() -> int:
	return _self_id

func _set_refuse_new_connections(p_enable: bool) -> void:
	_refusing_new_connections = p_enable

func _is_refusing_new_connections() -> bool:
	return _refusing_new_connections

func _get_connection_status() -> ConnectionStatus:
	return _connection_status

func initialize(p_self_id: int) -> void:
	if _connection_status != CONNECTION_CONNECTING:
		return
	_self_id = p_self_id
	if _self_id == 1:
		_connection_status = CONNECTION_CONNECTED

func set_connection_status(p_connection_status: int) -> void:
	_connection_status = p_connection_status

func deliver_packet(p_data: PackedByteArray, p_from_peer_id: int) -> void:
	var packet = Packet.new(p_data, p_from_peer_id);
	_incoming_packets.push_back(packet)

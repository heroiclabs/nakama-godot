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

class_name NakamaMultiplayerPeer
extends MultiplayerPeerExtension
## The MultiplayerPeer of a NakamaMultiplayerBridge: hands Godot's packets to the bridge, which carries
## them as match state. Use NakamaMultiplayerBridge.multiplayer_peer rather than making one.

## Emitted for each packet Godot sends; peer_id is the target: 0 for all, negative for all but -peer_id.
signal packet_generated(peer_id: int, buffer: PackedByteArray)

const MAX_PACKET_SIZE := 1 << 24

var _self_id := 0
var _connection_status := CONNECTION_DISCONNECTED
var _refusing_new_connections := false
var _target_id := 0
## Received packets, oldest first, as [data: PackedByteArray, from: int].
var _incoming_packets: Array = []


func _init() -> void:
	peer_disconnected.connect(_drop_packets_from)


func _get_packet_script() -> PackedByteArray:
	if _incoming_packets.is_empty():
		return PackedByteArray()
	return _incoming_packets.pop_front()[0]


func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	packet_generated.emit(_target_id, p_buffer)
	return OK


func _get_available_packet_count() -> int:
	return _incoming_packets.size()


func _get_max_packet_size() -> int:
	return MAX_PACKET_SIZE


func _get_packet_mode() -> TransferMode:
	return TRANSFER_MODE_RELIABLE


func _get_packet_channel() -> int:
	return 0


# Match state over the socket is always reliable and ordered, so channels and modes are ignored.
func _set_transfer_channel(_p_channel: int) -> void:
	pass


func _get_transfer_channel() -> int:
	return 0


func _set_transfer_mode(_p_mode: TransferMode) -> void:
	pass


func _get_transfer_mode() -> TransferMode:
	return TRANSFER_MODE_RELIABLE


func _set_target_peer(p_peer_id: int) -> void:
	_target_id = p_peer_id


func _get_packet_peer() -> int:
	if _connection_status != CONNECTION_CONNECTED or _incoming_packets.is_empty():
		return 1
	return _incoming_packets[0][1]


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


## Takes p_self_id as this peer's ID; the host (ID 1) is connected at once. Only while connecting.
func initialize(p_self_id: int) -> void:
	if _connection_status != CONNECTION_CONNECTING:
		return
	_self_id = p_self_id
	if _self_id == 1:
		_connection_status = CONNECTION_CONNECTED


func set_connection_status(p_connection_status: ConnectionStatus) -> void:
	_connection_status = p_connection_status


func deliver_packet(p_data: PackedByteArray, p_from_peer_id: int) -> void:
	_incoming_packets.append([p_data, p_from_peer_id])


# Godot rejects packets from a peer it no longer knows, so drop the ones still queued.
func _drop_packets_from(peer_id: int) -> void:
	_incoming_packets = _incoming_packets.filter(func(packet: Array) -> bool: return packet[1] != peer_id)

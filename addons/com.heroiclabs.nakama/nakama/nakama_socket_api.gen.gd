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

# Code generated from the NakamaSocket protos. DO NOT EDIT.
class_name NakamaSocketAPI
extends RefCounted


## Join the matchmaker pool and search for opponents on the server.
static func add_matchmaker(request: NakamaRtTypes.MatchmakerAdd) -> SocketRequestModel:
	return SocketRequestModel.new("matchmaker_add", request.to_json())


## Begin matchmaking as a party.
static func add_matchmaker_party(request: NakamaRtTypes.PartyMatchmakerAdd) -> SocketRequestModel:
	return SocketRequestModel.new("party_matchmaker_add", request.to_json())


## Create a multiplayer match on the server.
static func create_match(request: NakamaRtTypes.MatchCreate) -> SocketRequestModel:
	return SocketRequestModel.new("match_create", request.to_json())


## Create a party.
static func create_party(request: NakamaRtTypes.PartyCreate) -> SocketRequestModel:
	return SocketRequestModel.new("party_create", request.to_json())


## Subscribe to one or more users for their status updates.
static func follow_users(request: NakamaRtTypes.StatusFollow) -> SocketRequestModel:
	return SocketRequestModel.new("status_follow", request.to_json())


## Join a chat channel on the server.
static func join_chat(request: NakamaRtTypes.ChannelJoin) -> SocketRequestModel:
	return SocketRequestModel.new("channel_join", request.to_json())


## Join a multiplayer match by its ID or a matchmaker token.
static func join_match(request: NakamaRtTypes.MatchJoin) -> SocketRequestModel:
	return SocketRequestModel.new("match_join", request.to_json())


## Request a list of pending join requests for a party.
static func list_party_join_requests(
		request: NakamaRtTypes.PartyJoinRequestList) -> SocketRequestModel:
	return SocketRequestModel.new("party_join_request_list", request.to_json())


## Remove a chat message from a chat channel on the server.
static func remove_chat_message(request: NakamaRtTypes.ChannelMessageRemove) -> SocketRequestModel:
	return SocketRequestModel.new("channel_message_remove", request.to_json())


## Execute an RPC function on the server.
static func rpc(request: NakamaTypes.Rpc) -> SocketRequestModel:
	return SocketRequestModel.new("rpc", request.to_json())


## Update a chat message on a chat channel on the server.
static func update_chat_message(request: NakamaRtTypes.ChannelMessageUpdate) -> SocketRequestModel:
	return SocketRequestModel.new("channel_message_update", request.to_json())


## Update the party label and whether it's open or closed.
static func update_party(request: NakamaRtTypes.PartyUpdate) -> SocketRequestModel:
	return SocketRequestModel.new("party_update", request.to_json())


## Send a chat message to a chat channel on the server.
static func write_chat_message(request: NakamaRtTypes.ChannelMessageSend) -> SocketRequestModel:
	return SocketRequestModel.new("channel_message_send", request.to_json())


## Accept a party member's request to join the party.
static func accept_party_member(request: NakamaRtTypes.PartyAccept) -> SocketRequestModel:
	return SocketRequestModel.new("party_accept", request.to_json())


## End a party, kicking all party members and closing it.
static func close_party(request: NakamaRtTypes.PartyClose) -> SocketRequestModel:
	return SocketRequestModel.new("party_close", request.to_json())


## Join a party, or request to join if the party is not open.
static func join_party(request: NakamaRtTypes.PartyJoin) -> SocketRequestModel:
	return SocketRequestModel.new("party_join", request.to_json())


## Leave a chat channel on the server.
static func leave_chat(request: NakamaRtTypes.ChannelLeave) -> SocketRequestModel:
	return SocketRequestModel.new("channel_leave", request.to_json())


## Leave a multiplayer match on the server.
static func leave_match(request: NakamaRtTypes.MatchLeave) -> SocketRequestModel:
	return SocketRequestModel.new("match_leave", request.to_json())


## Leave the party.
static func leave_party(request: NakamaRtTypes.PartyLeave) -> SocketRequestModel:
	return SocketRequestModel.new("party_leave", request.to_json())


## Promote a new party leader.
static func promote_party_member(request: NakamaRtTypes.PartyPromote) -> SocketRequestModel:
	return SocketRequestModel.new("party_promote", request.to_json())


## Leave the matchmaker pool using a ticket.
static func remove_matchmaker(request: NakamaRtTypes.MatchmakerRemove) -> SocketRequestModel:
	return SocketRequestModel.new("matchmaker_remove", request.to_json())


## Cancel a party matchmaking process using a ticket.
static func remove_matchmaker_party(
		request: NakamaRtTypes.PartyMatchmakerRemove) -> SocketRequestModel:
	return SocketRequestModel.new("party_matchmaker_remove", request.to_json())


## Kick a party member, or decline a request to join.
static func remove_party_member(request: NakamaRtTypes.PartyRemove) -> SocketRequestModel:
	return SocketRequestModel.new("party_remove", request.to_json())


## Send input to a multiplayer match on the server. The server sends no reply.
static func send_match_state(request: NakamaRtTypes.MatchDataSend) -> SocketRequestModel:
	return SocketRequestModel.new("match_data_send", request.to_json(), false)


## Send data to a party.
static func send_party_data(request: NakamaRtTypes.PartyDataSend) -> SocketRequestModel:
	return SocketRequestModel.new("party_data_send", request.to_json())


## Unsubscribe from one or more users' status updates.
static func unfollow_users(request: NakamaRtTypes.StatusUnfollow) -> SocketRequestModel:
	return SocketRequestModel.new("status_unfollow", request.to_json())


## Update the current user's online status.
static func update_status(request: NakamaRtTypes.StatusUpdate) -> SocketRequestModel:
	return SocketRequestModel.new("status_update", request.to_json())


## One message to send, wrapped in an envelope under key.
class SocketRequestModel:
	var key: String
	var body: String
	var expects_reply: bool


	func _init(p_key: String, p_body: String, p_expects_reply: bool = true) -> void:
		key = p_key
		body = p_body
		expects_reply = p_expects_reply

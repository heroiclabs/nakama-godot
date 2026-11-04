extends Node
## The node each player calls RPCs on in multiplayer_bridge_test; the same name under every player's multiplayer root.

var received: Array = []

@rpc("any_peer")
func ping(text: String) -> void:
	received.append([text, multiplayer.get_remote_sender_id()])

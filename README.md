Nakama Godot
============

> Godot addon for Nakama and Satori, written in GDScript.

[Nakama](https://github.com/heroiclabs/nakama) is an open-source game server for user accounts, chat, social features, matchmaking, realtime multiplayer, and [more](https://heroiclabs.com). [Satori](https://heroiclabs.com/satori/) is a LiveOps server for events, segmentation, A/B tests, feature flags, and live events.

This addon covers Nakama's full API and realtime socket, and Satori's client API. It needs Godot 4.4 or later. For the full documentation, see [heroiclabs.com/docs](https://heroiclabs.com/docs).

## Getting started

1. Run a Nakama server. The quickest way is [Docker](https://heroiclabs.com/docs/nakama/getting-started/install/docker/). For other options, see the [server documentation](https://github.com/heroiclabs/nakama#getting-started).

2. Download the addon from the [releases page](https://github.com/heroiclabs/nakama-godot/releases), and copy its `addons/com.heroiclabs.nakama` folder into your project.

3. Create a client. These values connect to a local Docker server:

	```gdscript
	extends Node

	func _ready():
		var client := Nakama.new("defaultkey", "127.0.0.1", 7350, "http")
	```

## Usage

The `Nakama` client has a function for each server API, such as `authenticate_email_async` or `get_account_async`. Each one is a coroutine, so call it with `await`. It returns a `NakamaResult`: `value` holds the reply, and `error` holds a `NakamaError` when the call fails.

### Authenticate

Authenticate players with a device ID, email and password, custom ID, or an Apple, Facebook, Game Center, Google, or Steam account. Authenticating creates the account if it doesn't exist. To only log in, pass `false` for the `create` argument. For details, see [Authentication](https://heroiclabs.com/docs/nakama/concepts/authentication/).

```gdscript
	var result: NakamaResult = await client.authenticate_email_async("super@heroes.com", "batsignal")
	if result.error:
		print("Could not authenticate: %s" % result.error)
		return
	var session: NakamaSession = result.value
```

### Sessions

Every other call takes the `NakamaSession` that authenticating returns, and the client refreshes it before it expires. To keep the player logged in across restarts, save its tokens and restore them. Save the device ID too: it's the player's account, so a new one logs in as a new player.

```gdscript
extends Node

const SAVE_PATH := "user://nakama.cfg"

var client := Nakama.new("defaultkey")
var session: NakamaSession
var config := ConfigFile.new()


func _ready():
	# Save the new tokens whenever the client refreshes them.
	client.session_refreshed.connect(save_session)
	config.load(SAVE_PATH)

	# Restore the last session, unless it can no longer be refreshed.
	if config.has_section("session"):
		session = NakamaSession.restore(config.get_value("session", "token"), config.get_value("session", "refresh_token"))
	if session == null or session.has_refresh_expired():
		var device_id: String = config.get_value("device", "id", Nakama.generate_device_id())
		config.set_value("device", "id", device_id)
		var result: NakamaResult = await client.authenticate_device_async(device_id)
		if result.error:
			print("Could not log in: %s" % result.error)
			return
		session = result.value
		save_session(session)

	var account: NakamaResult = await client.get_account_async(session)
	if account.error == null:
		print("Logged in as %s" % account.value.user.username)


func save_session(current: NakamaSession):
	config.set_value("session", "token", current.token)
	config.set_value("session", "refresh_token", current.refresh_token)
	config.save(SAVE_PATH)
```

To log out, call `session_logout_async(session)`. It invalidates the session's tokens on the server.

### Requests

Some functions take objects, such as storage writes. Build each object with its constructor, which takes the object's fields in the server API's order:

```gdscript
	var save := NakamaTypes.WriteStorageObject.new("saves", "slot1", {"level": 3})
	var written: NakamaResult = await client.write_storage_objects_async(session, [save])
```

List arguments are typed arrays, such as `Array[String]`. A list written in the call works as is. A list kept in a variable needs its element type, or Godot stops with a script error:

```gdscript
	var saves: Array[NakamaTypes.WriteStorageObject] = [save]
```

Names that are GDScript keywords or built-in classes get a trailing underscore, such as `NakamaRtTypes.Match.self_` and `NakamaRtTypes.Error_`.
Call your server's [custom RPCs](https://heroiclabs.com/docs/nakama/server-framework/introduction/#rpc-functions) with `rpc_async`:

```gdscript
	var reply: NakamaResult = await client.rpc_async(session, "my_rpc", {"level": 3})
	if reply.error == null:
		print(reply.value.payload)
```

Server tools call RPCs without a session through `rpc_with_key_async` and the server's runtime HTTP key. Never ship the HTTP key in a game client.

### Errors

Compare `error.grpc_code` with the constants on `NakamaError`:

```gdscript
	var result: NakamaResult = await client.get_account_async(session)
	if result.error and result.error.grpc_code == NakamaError.UNAUTHENTICATED:
		print("Authenticate again")
```

When no reply arrives, `http_status` is 0 and `grpc_code` is `UNAVAILABLE` for a connection failure or `DEADLINE_EXCEEDED` for a timeout. The client retries temporary server errors (HTTP 500, 502, 503, and 504) with exponential backoff. Tune it with `timeout_sec`, `retry_max_attempts`, `retry_base_delay_ms`, `retry_max_delay_ms`, and `retry_max_total_ms`.

To give up on calls, pass a `NakamaCanceller`. One canceller can stop many calls, such as all of a scene's calls when it closes:

```gdscript
	var canceller := NakamaCanceller.new()
	get_tree().create_timer(5.0).timeout.connect(canceller.cancel)
	var result: NakamaResult = await client.get_account_async(session, canceller)
```

The client prints warnings for retries and failed refreshes. For more or less output, set `client.log_level` to a `Nakama.LogLevel` value. It never prints tokens.

### Socket

A socket carries the realtime features: chat, matches, parties, the matchmaker, notifications, and status. Create it from the client, and connect it with the session:

```gdscript
	var socket := NakamaSocket.from(client)
	socket.closed.connect(_on_socket_closed)
	socket.received_channel_message.connect(_on_channel_message)
	var error: NakamaError = await socket.connect_async(session)
	if error:
		print("Could not connect: %s" % error)
		return

	var joined: NakamaResult = await socket.join_chat_async("lobby", NakamaRtTypes.ChannelJoinType.ROOM)
	if joined.error == null:
		await socket.write_chat_message_async(joined.value.id, {"text": "Hello!"})


func _on_socket_closed(code: int, reason: String):
	print("Socket closed: %d %s" % [code, reason])


func _on_channel_message(message: NakamaTypes.ChannelMessage):
	print(message.content)
```

Server messages arrive as `received_*` signals, such as `received_match_state`, `received_matchmaker_matched`, and `received_notification`. The socket doesn't reconnect by itself. When it emits `closed`, call `connect_async` again.

## Godot's high-level multiplayer

`NakamaMultiplayerBridge` runs Godot's [high-level multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) over a Nakama match, so `@rpc` functions, peer signals, and multiplayer authority work as they do with ENet or WebRTC:

```gdscript
var multiplayer_bridge: NakamaMultiplayerBridge

func _ready():
	# socket is a connected NakamaSocket.
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(_on_match_join_error)
	multiplayer_bridge.match_joined.connect(_on_match_joined)
	multiplayer.multiplayer_peer = multiplayer_bridge.multiplayer_peer
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_match_join_error(error: NakamaError):
	print("Could not join the match: %s" % error)

func _on_match_joined():
	print("Joined match %s as peer %d" % [multiplayer_bridge.match_id, multiplayer.get_unique_id()])

func _on_peer_connected(peer_id: int):
	print("Peer %d joined" % peer_id)
```

Then join a match in one of these ways:

- **Create a match** with this player as the host: `multiplayer_bridge.create_match()`
- **Join a match** by its ID: `multiplayer_bridge.join_match(match_id)`
- **Join by name**, creating the match if it's empty: `multiplayer_bridge.join_named_match(match_name)`
- **Use the matchmaker**:

    ```gdscript
    	var ticket: NakamaResult = await socket.add_matchmaker_async(2, 4)
    	if ticket.error == null:
    		multiplayer_bridge.start_matchmaking(ticket.value)
    ```

Once the bridge emits `match_joined`, use `rpc()` and the rest of the multiplayer API. To find a peer's Nakama user, call `get_user_presence_for_peer(peer_id)`. To leave the match or the matchmaker, call `leave()`.

### Matches without a host

By default, one player is the host: peer 1, who gives everyone else their peer ID. When the host leaves, nobody else can join. An [authoritative match](https://heroiclabs.com/docs/nakama/concepts/multiplayer/authoritative/) can give out the IDs instead, so every player is equal. Join it with `join_match(match_id)`, and the bridge sets `server_assigned`. The server's match handler must:

- **Assign IDs**: give each player who joins the next peer ID, starting at 2. Send the newcomer its own ID first, then everyone else's, and send everyone else the newcomer's. Send each from the match itself on op code 9001: `{"type": 1, "session_id": ..., "peer_id": ..., "user_id": ..., "username": ...}`.
- **Route packets**: each op code 9002 message starts with the target peer ID as a little-endian int32: positive for that peer, negative for everyone but that peer, and 0 for everyone. Strip those 4 bytes and forward the rest with the original sender.
- **Drop player meta messages**: ignore op code 9001 from players, so nobody can fake a peer ID.

## Satori

Create a client with your Satori deployment's host and API key. To find them, see [Connecting your game client](https://heroiclabs.com/docs/heroic-cloud/concepts/titles/satori-deployments/#connecting-your-game-client). The client always uses HTTPS. For the full documentation, see [Satori Godot client](https://heroiclabs.com/docs/satori/client-libraries/godot/index.html).

```gdscript
extends Node

func _ready():
	var client := Satori.new("your-api-key", "your-satori-host")
	var result: SatoriResult = await client.authenticate_async("your-player-id")
	if result.error:
		print("Could not authenticate: %s" % result.error)
		return
	var session: SatoriSession = result.value
```

Satori calls return a `SatoriResult`, and the client refreshes sessions, as the Nakama client does.

Read the player's experiments and feature flags. `get_flag_async` falls back to your default when the flag is unknown or Satori can't be reached. Before login, `get_flag_default_async` reads a flag with the API key:

```gdscript
	var experiments: SatoriResult = await client.get_experiments_async(session)
	var flag: SatoriResult = await client.get_flag_async(session, "FlagName", "default value")
	print(flag.value.value)
```

Send events that are defined in Satori. Each event is stamped with the time you create it:

```gdscript
	await client.event_async(session, SatoriTypes.Event.new("gameFinished"))
```

Other calls cover identities, properties, live events, and messages, such as `identify_async`, `update_properties_async`, `get_live_events_async`, and `get_message_list_async`.

## .NET and C#

With the .NET version of Godot, you can use the [Nakama .NET client](https://github.com/heroiclabs/nakama-dotnet) instead. Install it from NuGet:

```
dotnet add package NakamaClient
```

The addon's `dotnet-utils/nakama` folder has C# classes that connect the .NET client to Godot:

- `GodotHttpAdapter`: an HTTP adapter that uses Godot's `HttpRequest` node.
- `GodotWebSocketAdapter`: a socket adapter that uses Godot's `WebSocketPeer`.
- `GodotLogger`: a logger that prints to the Godot console.

They need the `NakamaClient` package, so if your C# project doesn't use the Nakama .NET client, delete `dotnet-utils/nakama`, or the project won't build. Both adapters are nodes, so add them to the scene tree, for example in an autoload, so they stay alive:

```csharp
	var httpAdapter = new GodotHttpAdapter();
	AddChild(httpAdapter);
	var client = new Client("http", "127.0.0.1", 7350, "defaultkey", httpAdapter);
	client.Logger = new GodotLogger("Nakama", GodotLogger.LogLevel.DEBUG);

	ISession session;
	try
	{
		session = await client.AuthenticateDeviceAsync(OS.GetUniqueId());
	}
	catch (ApiResponseException e)
	{
		GD.PrintErr(e.ToString());
		return;
	}

	var socketAdapter = new GodotWebSocketAdapter();
	AddChild(socketAdapter);
	var socket = Socket.From(client, socketAdapter);
```

For the [Satori .NET client](https://github.com/heroiclabs/nakama-dotnet/tree/master/Satori) (`dotnet add package SatoriClient`), `dotnet-utils/satori` has `GodotSatoriHttpAdapter` and `GodotSatoriLogger`, which work the same way. They need the `SatoriClient` package, so if you don't use Satori, delete `dotnet-utils/satori`.

```csharp
	var satoriAdapter = new GodotSatoriHttpAdapter();
	AddChild(satoriAdapter);
	var satori = new Satori.Client("https", "your-satori-host", 443, "your-api-key", satoriAdapter);
	var satoriSession = await satori.AuthenticateAsync("your-player-id");
```

## Contribute

The roadmap lives in GitHub issues, and pull requests are welcome. Before a big change, open an issue or post in the [community forum](https://forum.heroiclabs.com). To make a release, see [RELEASEINST.md](./RELEASEINST.md).

### Run tests

The tests run against real servers. You need [Docker](https://www.docker.com), [Task](https://taskfile.dev), and Godot 4.7. If Godot isn't at `/Applications/Godot.app/Contents/MacOS/Godot`, set `GODOT` to its path.

```shell
task run-server   # Nakama, PostgreSQL, and the test plugin in test_suite/server
task test-nakama   # Nakama tests in test_suite/nakama_tests
task test-dotnet   # C# adapter tests in test_suite/dotnet_tests; the Satori one runs only with SATORI_HOST and SATORI_API_KEY set
task stop-server
SATORI_HOST=... SATORI_API_KEY=... task test-satori   # Satori tests in test_suite/satori_tests
```

The Satori tests have no default server: set `SATORI_HOST`, or `HOST` in `test_suite/satori_tests/settings.json`. Pass the API key through `SATORI_API_KEY`, never the tracked file. The server needs the `appLaunched` and `gameFinished` events and at least one flag.

`test-dotnet` needs the [.NET SDK](https://dotnet.microsoft.com/download) and the .NET version of Godot 4.7. If it isn't at `/Applications/Godot_mono.app/Contents/MacOS/Godot`, set `GODOT_MONO` to its path.

Each GDScript task copies `addons` into its test project; `test-dotnet` builds the adapters from `addons` directly. To open a test project in the Godot editor, run its task first.

### License

This project is licensed under the [Apache 2.0 License](https://github.com/heroiclabs/nakama-godot/blob/master/LICENSE).

Nakama Godot
===========

> Godot client for Nakama server written in GDScript.

[Nakama](https://github.com/heroiclabs/nakama) is an open-source server designed to power modern games and apps. Features include user accounts, chat, social, matchmaker, realtime multiplayer, and much [more](https://heroiclabs.com).

This client implements the full API and socket options with the server. It's written in GDScript to support Godot Engine `4.0+`.

Full documentation is online - https://heroiclabs.com/docs

## Godot 3 & 4

You're currently looking at the Godot 4 version of the Nakama client for Godot.

If you are using Godot 3, you need to use the ['godot-3'
branch](https://github.com/heroiclabs/nakama-godot/tree/godot-3) on GitHub.

## Getting Started

You'll need to setup the server and database before you can connect with the client. The simplest way is to use Docker but have a look at the [server documentation](https://github.com/heroiclabs/nakama#getting-started) for other options.

1. Install and run the servers. Follow these [instructions](https://heroiclabs.com/docs/nakama/getting-started/install/docker/).

2. Download the client from the [releases page](https://github.com/heroiclabs/nakama-godot/releases) and import it into your project. You can also [download it from the asset repository](#asset-repository).

3. Add the `Nakama.gd` singleton (in `addons/com.heroiclabs.nakama/`) as an [autoload in Godot](https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html).

4. Use the connection credentials to build a client object using the singleton.

    ```gdscript
    extends Node

    func _ready():
    	var scheme = "http"
    	var host = "127.0.0.1"
    	var port = 7350
    	var server_key = "defaultkey"
    	var client := Nakama.create_client(server_key, host, port, scheme)
    ```

## Usage

The client object has many methods to execute various features in the server or open realtime socket connections with the server.

### Authenticate

There's a variety of ways to [authenticate](https://heroiclabs.com/docs/nakama/concepts/authentication/) with the server. Authentication can create a user if they don't already exist with those credentials. It's also easy to authenticate with a social profile from Google Play Games, Facebook, Game Center, etc.

```gdscript
	var email = "super@heroes.com"
	var password = "batsignal"
	# Use 'await' to wait for the request to complete.
	var session : NakamaSession = await client.authenticate_email_async(email, password)
	print(session)
```

### Sessions

When authenticated the server responds with an auth token (JWT) which contains useful properties and gets deserialized into a `NakamaSession` object.

```gdscript
	print(session.token) # raw JWT token
	print(session.user_id)
	print(session.username)
	print("Session has expired: %s" % session.expired)
	print("Session expires at: %s" % session.expire_time)
```

It is recommended to store the auth token from the session and check at startup if it has expired. If the token has expired you must reauthenticate. The expiry time of the token can be changed as a setting in the server.

```gdscript
	var authtoken = "restored from somewhere"
	var session2 = NakamaClient.restore_session(authtoken)
	if session2.expired:
		print("Session has expired. Must reauthenticate!")
```

NOTE: The length of the lifetime of a session can be changed on the server with the `--session.token_expiry_sec` command flag argument.

### Requests

The client includes lots of builtin APIs for various features of the game server. These can be accessed with the async methods. It can also call custom logic in RPC functions on the server. These can also be executed with a socket object.

All requests are sent with a session object which authorizes the client.

```gdscript
	var account = await client.get_account_async(session)
	print(account.user.id)
	print(account.user.username)
	print(account.wallet)
```

### Exceptions

Since Godot Engine does not support exceptions, whenever you make an async request via the client or socket, you can check if an error occurred via the `is_exception()` method.

```gdscript
	var an_invalid_session = NakamaSession.new() # An empty session, which will cause and error when we use it.
	var account2 = await client.get_account_async(an_invalid_session)
	print(account2) # This will print the exception
	if account2.is_exception():
		print("We got an exception")
```

### Socket

The client can create one or more sockets with the server. Each socket can have it's own event listeners registered for responses received from the server.

```gdscript
	var socket = Nakama.create_socket_from(client)
	socket.connected.connect(self._on_socket_connected)
	socket.closed.connect(self._on_socket_closed)
	socket.received_error.connect(self._on_socket_error)
	await socket.connect_async(session)
	print("Done")

func _on_socket_connected():
	print("Socket connected.")

func _on_socket_closed():
	print("Socket closed.")

func _on_socket_error(err):
	printerr("Socket error %s" % err)
```

## Integration with Godot's High-level Multiplayer API

Godot provides a [High-level Multiplayer
API](https://docs.godotengine.org/en/latest/tutorials/networking/high_level_multiplayer.html),
allowing developers to make RPCs, calling functions that run on other peers in
a multiplayer match.

For example:

```gdscript
func _process(delta):
	if not is_multiplayer_authority():
		return

	var input_vector = get_input_vector()

	# Move the player locally.
	velocity = input_vector * SPEED
	move_and_slide()

	# Then update the player's position on all other connected clients.
	update_remote_position.rpc(position)

@rpc(any_peer)
func update_remote_position(new_position):
	position = new_position
```

Godot provides a number of built-in backends for sending the RPCs, including:
ENet, WebSockets, and WebRTC.

However, you can also use the Nakama client as a backend! This can allow you to
continue using Godot's familiar High-level Multiplayer API, but with the RPCs
transparently sent over a realtime Nakama match.

To do that, you need to use the `NakamaMultiplayerBridge` class:

```gdscript
var multiplayer_bridge

func _ready():
	# [...]
	# You must have a working 'socket', created as described above.

	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(self._on_match_join_error)
	multiplayer_bridge.match_joined.connect(self._on_match_joined)
	get_tree().get_multiplayer().set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)

func _on_match_join_error(error):
	print ("Unable to join match: ", error.message)

func _on_match_join() -> void:
	print ("Joined match with id: ", multiplayer_bridge.match_id)
```

You can also connect to any of the usual signals on `MultiplayerAPI`, for
example:

```gdscript
	get_tree().get_multiplayer().peer_connected.connect(self._on_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(self._on_peer_disconnected)

func _on_peer_connected(peer_id):
	print ("Peer joined match: ", peer_id)

func _on_peer_disconnected(peer_id):
	print ("Peer left match: ", peer_id)
```

Then you need to join a match, using one of the following methods:

- Create a new private match, with your client as the host.
  ```gdscript
  multiplayer_bridge.create_match()
  ```

- Join a private match.
  ```gdscript
  multiplayer_bridge.join_match(match_id)
  ```

- Create or join a private match with the given name.
  ```gdscript
  multiplayer_bridge.join_named_match(match_name)
  ```

- Use the matchmaker to find and join a public match.
  ```gdscript
  var ticket = await socket.add_matchmaker_async()
  if ticket.is_exception():
	print ("Error joining matchmaking pool: ", ticket.get_exception().message)
	return

  multiplayer_bridge.start_matchmaking(ticket)
  ```

After the the "match_joined" signal is emitted, you can start sending RPCs as
usual with the `rpc()` function, and calling any other functions associated with
the High-level Multiplayer API, such as `get_tree().get_multiplayer().get_unique_id()`
and `node.set_network_authority(peer_id)` and `node.is_network_authority()`.

## .NET / C#

If you're using the .NET version of Godot with C# support, you can use the
[Nakama .NET client](https://github.com/heroiclabs/nakama-dotnet/), which can be
installed via NuGet:

```
dotnet add package NakamaClient
```

This addon includes some C# classes for use with the .NET client, to provide deeper
integration with Godot:

- `GodotLogger`: A logger which prints to the Godot console.
- `GodotHttpAdapter`: An HTTP adapter which uses Godot's HTTPRequest node.
- `GodotWebSocketAdapter`: A socket adapter which uses Godot's WebSocketClient.

Here's an example of how to use them:

```csharp
	var http_adapter = new GodotHttpAdapter();
	// It's a Node, so it needs to be added to the scene tree.
	// Consider putting this in an autoload singleton so it won't go away unexpectedly.
	AddChild(http_adapter);

	const string scheme = "http";
	const string host = "127.0.0.1";
	const int port = 7350;
	const string serverKey = "defaultkey";

	// Pass in the 'http_adapter' as the last argument.
	var client = new Client(scheme, host, port, serverKey, http_adapter);

	// To log DEBUG messages to the Godot console.
	client.Logger = new GodotLogger("Nakama", GodotLogger.LogLevel.DEBUG);

	ISession session;
	try {
		session = await client.AuthenticateDeviceAsync(OS.GetUniqueId(), "TestUser", true);
	}
	catch (ApiResponseException e) {
		GD.PrintErr(e.ToString());
		return;
	}

	var websocket_adapter = new GodotWebSocketAdapter();
	// Like the HTTP adapter, it's a Node, so it needs to be added to the scene tree.
	// Consider putting this in an autoload singleton so it won't go away unexpectedly.
	AddChild(websocket_adapter);

	// Pass in the 'websocket_adapter' as the last argument.
	var socket = Socket.From(client, websocket_adapter);
```

**Note:** _The out-of-the-box Nakama .NET client will work fine with desktop builds of your game! However, it won't work with HTML5 builds, unless you use the `GodotHttpAdapter` and `GodotWebSocketAdapter` classes._

# Satori

Satori is a liveops server for games that powers actionable analytics, A/B testing and remote configuration. Use the Satori Godot Client to communicate with Satori from within your Godot game.

Satori is only compatible with Godot 4.

Full documentation is online - https://heroiclabs.com/docs/satori/client-libraries/godot/index.html

## Getting Started

Add the `Satori.gd` singleton (in `addons/com.heroiclabs.nakama/`) as an [autoload in Godot](https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html).

Create a client object that accepts the API key you were given as a Satori customer.

```gdscript
extends Node

func ready():
	var scheme = "http"
	var host = "127.0.0.1"
	var port: Int = 7450
	var apiKey = "apiKey"
	var client := Satori.create_client(apiKey, host, port, scheme)
```

Then authenticate with the server to obtain your session.

```gdscript
// Authenticate with the Satori server.
var session = await _client.authenticate_async("your-id")
if session.is_exception():
	print("Error authenticating: " + session.get_exception()._message)
else:
	print("Authenticated successfully.")
```

Using the client you can get any experiments or feature flags, the user belongs to.

```gdscript
var experiments = await _client.get_experiments_async(session, ["experiment1", "Experiment2"])
var flag = await _client.get_flag_async(session, "FlagName")
```

You can also send arbitrary events to the server:

```gdscript
var _event = Event.new("gameFinished", Time.get_unix_time_from_system())
await _client.event_async(session, _event)
```

## Contribute

The development roadmap is managed as GitHub issues and pull requests are welcome. If you're interested to improve the code please open an issue to discuss the changes or drop in and discuss it in the [community forum](https://forum.heroiclabs.com).

### Run Tests

To run tests you will need to run the server and database. Most tests are written as integration tests which execute against the server. A quick approach we use with our test workflow is to use the Docker compose file described in the [documentation](https://heroiclabs.com/docs/nakama/getting-started/install/docker/).

Additionally, you will need to copy (or symlink) the `addons` folder inside the `test_suite` folder. You can now run the `test_suite` project from the Godot Editor.

To run the tests on a headless machine (without a GPU) you can download a copy of [Godot Headless](https://godotengine.org/download/server) and run it from the command line.

To automate this procedure, move the headless binary to `test_suite/bin/godot.elf`, and run the tests via the `test_suite/run_tests.sh` shell script (exit code will report test failure/success).

```shell
cd nakama
docker-compose -f ./docker-compose-postgres.yml up
cd ..
cd nakama-godot
sh test_suite/run_tests.sh
```

### Make a new release

To make a new release ready for distribution, simply zip the addons folder recursively (possibly adding `CHANGELOG`, `LICENSE`, and `README.md` too).

On unix systems, you can run the following command (replacing `$VERSION` with the desired version number). Remember to update the `CHANGELOG` file first.

```shell
zip -r nakama-$VERSION.zip addons/ LICENSE CHANGELOG.md README.md
```

### License

This project is licensed under the [Apache-2 License](https://github.com/heroiclabs/nakama-godot/blob/master/LICENSE).

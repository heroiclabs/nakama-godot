Nakama Godot
===========

> Godot client for Nakama server written in GDScript.

[Nakama](https://github.com/heroiclabs/nakama) is an open-source server designed to power modern games and apps. Features include user accounts, chat, social, matchmaker, realtime multiplayer, and much [more](https://heroiclabs.com).

This client implements the full API and socket options with the server. It's written in GDScript to support Godot Engine `3.1+`.

Full documentation is online - https://heroiclabs.com/docs

## Getting Started

You'll need to setup the server and database before you can connect with the client. The simplest way is to use Docker but have a look at the [server documentation](https://github.com/heroiclabs/nakama#getting-started) for other options.

1. Install and run the servers. Follow these [instructions](https://heroiclabs.com/docs/install-docker-quickstart).

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

There's a variety of ways to [authenticate](https://heroiclabs.com/docs/authentication) with the server. Authentication can create a user if they don't already exist with those credentials. It's also easy to authenticate with a social profile from Google Play Games, Facebook, Game Center, etc.

```gdscript
	var email = "super@heroes.com"
	var password = "batsignal"
	# Use yield(client.function(), "completed") to wait for the request to complete.
	var session : NakamaSession = yield(client.authenticate_email_async(email, password), "completed")
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
	var account = yield(client.get_account_async(session), "completed")
	print(account.user.id)
	print(account.user.username)
	print(account.wallet)
```

### Exceptions

Since Godot Engine does not support exceptions, whenever you make an async request via the client or socket, you can check if an error occurred via the `is_exception()` method.

```gdscript
	var an_invalid_session = NakamaSession.new() # An empty session, which will cause and error when we use it.
	var account2 = yield(client.get_account_async(an_invalid_session), "completed")
	print(account2) # This will print the exception
	if account2.is_exception():
		print("We got an exception")
```

### Socket

The client can create one or more sockets with the server. Each socket can have it's own event listeners registered for responses received from the server.

```gdscript
	var socket = Nakama.create_socket_from(client)
	socket.connect("connected", self, "_on_socket_connected")
	socket.connect("closed", self, "_on_socket_closed")
	socket.connect("received_error", self, "_on_socket_error")
	yield(socket.connect_async(session), "completed")
	print("Done")

func _on_socket_connected():
	print("Socket connected.")

func _on_socket_closed():
	print("Socket closed.")

func _on_socket_error(err):
	printerr("Socket error %s" % err)
```

## Contribute

The development roadmap is managed as GitHub issues and pull requests are welcome. If you're interested to improve the code please open an issue to discuss the changes or drop in and discuss it in the [community forum](https://forum.heroiclabs.com).

### Run Tests

To run tests you will need to run the server and database. Most tests are written as integration tests which execute against the server. A quick approach we use with our test workflow is to use the Docker compose file described in the [documentation](https://heroiclabs.com/docs/install-docker-quickstart).

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

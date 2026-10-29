# Change Log
All notable changes to this project are documented below.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

A rewrite of the client, generated from the Nakama and Satori protocol definitions. It breaks the API: see the README for the new usage. It needs Godot 4.4 or later.

### Added
- Nakama: Every server API, including ones the old client lacked, such as `list_friends_of_friends_async`, `list_parties_async`, `ban_group_users_async`, `delete_tournament_record_async`, the generic `authenticate_async`, `link_async`, and `unlink_async`, and Samsung and Facebook Instant purchase validation.
- Nakama: `rpc_with_key_async` calls an RPC with the server's HTTP key instead of a session.
- Nakama: RPC payloads can be a String, a PackedByteArray, or any value `JSON.stringify` accepts.
- Nakama: `NakamaCanceller` cancels requests in flight and retry waits.
- Nakama: Request and reply classes take their fields as optional constructor arguments in proto order, such as `NakamaTypes.ReadStorageObjectId.new(collection, key, user_id)`.
- Nakama: Sessions refresh automatically before they expire, and `session_refreshed` reports the new tokens.
- Nakama: `NakamaMultiplayerBridge` works with authoritative matches that assign the peer IDs, so no player is the host.
- Nakama: `Nakama.timestamp()` formats a time for timestamp fields.
- C# adapters: `GodotSatoriHttpAdapter` and `GodotSatoriLogger` in `dotnet-utils/satori` connect the Satori .NET client to Godot.
- Satori: Messages, flag overrides, live event joins, and server events.
- Satori: `get_flag_async` falls back to a default value, and `get_flag_default_async` reads a flag before login.
- Satori: `SatoriTypes.Event.new(name)` stamps the event with the current time.

### Changed
- Nakama and Satori: Required arguments, such as tokens, IDs, and credentials, have no defaults, so leaving one out is a parse error instead of a server error. `list_storage_objects_async` takes `collection` before `user_id`.
- Nakama: `Nakama.generate_device_id()` replaces the autoload's `get_device_id()`. It only makes a new ID and no longer saves it, so save it with the session, as the README shows.
- Install by copying `addons/com.heroiclabs.nakama`. The `Nakama` and `Satori` autoloads are gone; those names are now the client classes, replacing `NakamaClient` and `SatoriClient`: create clients with `Nakama.new(server_key, host, port, scheme)` and `Satori.new(api_key, host)`, which always uses HTTPS on port 443, and sockets with `NakamaSocket.from(client)`.
- Nakama and Satori: Methods return a `NakamaResult` or `SatoriResult`, and its `error` replaces `is_exception()`. Arguments follow the server API. Requests and replies are typed classes in `NakamaTypes`, `NakamaRtTypes`, and `SatoriTypes`.
- Nakama: List arguments are typed arrays, such as `Array[String]`. Declare list variables with their element type.
- Nakama: Renamed `rpc_async_with_key` to `rpc_with_key_async`, `list_users_storage_objects_async` to `list_storage_objects_async` (pass the user ID), and `write_tournament_record2_async` to `write_tournament_record_async`. On the socket, renamed `is_connected_to_host` to `is_open`, `is_connecting_to_host` to `is_connecting`, and `promote_party_member` to `promote_party_member_async`. On `NakamaMultiplayerBridge`, renamed `match_state` and `MatchState` to `connection_state` and `ConnectionState`.
- Nakama: `send_match_state_async` and `send_party_data_async` take a String or a PackedByteArray, replacing the `_raw_` variants.
- Nakama: Socket signals carry typed messages, and `closed` reports the close code and reason.
- Nakama: Renamed `auto_refresh` to `auto_refresh_session` and `timeout` to `timeout_sec`, with a default of 10 seconds instead of 3. `retry_max_attempts`, `retry_base_delay_ms`, `retry_max_delay_ms`, and `retry_max_total_ms` replace `auto_retry`, `auto_retry_count`, and `auto_retry_backoff_base`. Removed `auto_refresh_seconds` and the `get_*` and `set_*` methods.
- Nakama: Only temporary server errors (HTTP 500, 502, 503, and 504) are retried.
- Nakama: `log_level` and `Nakama.LogLevel` replace `NakamaLogger`, and the default level is `WARNING` instead of `DEBUG`.
- Nakama: HTTP requests no longer use threads, so a timeout or cancel cannot freeze the game when the server stops replying.
- Nakama: `NakamaCanceller` replaces `cancel_request` and `get_last_cancel_token`.
- C# adapters: Moved from `dotnet-utils` to `dotnet-utils/nakama`, next to the new `dotnet-utils/satori`. Delete the old addon folder before copying the new one, or the old copies cause duplicate class errors.
- C# adapters: `GodotLogger`'s constructor arguments are named `module` and `level` instead of `p_module` and `p_level`, and warnings print as `WARNING` instead of `WARN`.
- Satori: Renamed `get_all_experiments_async` to `get_experiments_async` and `session_refresh_async` to `authenticate_refresh_async`.
- Tests run with `task test-nakama` against the Nakama server in `test_suite/docker-compose.yml`, `task test-satori` against a hosted Satori, and `task test-dotnet` against both through the C# adapters.

### Removed
- Nakama: Swappable HTTP and socket adapters, and the injectable logger. To capture the client's messages, register a Godot `Logger` with `OS.add_logger()` (Godot 4.5 or later).

### Fixed
- C# adapters: `GodotWebSocketAdapter` builds with Nakama .NET client 3.18.0 or later, whose socket `Closed` event passes the close reason.
- C# adapters: `GodotHttpAdapter` throws `ApiResponseException` instead of `IndexOutOfRangeException` when a request gets no reply (which the .NET client now retries) or a reply that isn't JSON.
- C# adapters: `GodotHttpAdapter` no longer uses threaded requests, which in Godot 4.7 freeze the game when a server stops replying.
- C# adapters: `GodotHttpAdapter` stops a request when its cancellation token is cancelled.
- C# adapters: `GodotHttpAdapter` requests finish while the game is paused, so calls from a pause menu work.
- C# adapters: `GodotHttpAdapter` throws `ApiResponseException` when Godot refuses to send a request, such as one with an unsupported URI scheme, instead of waiting forever.
- C# adapters: `GodotWebSocketAdapter` no longer emits `Closed` after a connection attempt times out.

## [3.4.0] - 2024-03-19

### Added
- Satori: Adds the Satori Godot SDK for Godot 4. Satori is our LiveOps server for game studios. Read more about it in the [documentation](https://heroiclabs.com/docs/satori/concepts/introduction/).

### Fixed
- Nakama: Fixed code that caused Godot 3 to report memory leaks.
- Nakama: Fixed links to Nakama server documentation.
- Nakama: Fixed naming of `HttpRequest` to match Godot's new naming.
- Nakama: Fixed number of arguments passed to `HttpRequest.Request`.
- Nakama: Fixed JSON `json_error` typo in `NakamaHTTPAdapter`.
- Nakama: Removed some leftover Godot 3 code from master.

### Changed
- Nakama: Godot 4 support is now on master. Godot 3 support can now be found on the `godot-3` branch.
- Nakama: Changed return type from `int` to `TransferMode` in `_get_packet_mode` of the `NakamaMultiplayerPeer`.

## [3.3.1] - 2023-04-17

### Fixed

- Fix arguments for HTTPRequest.request() for beta17
- Fix typehints for enums in Godot 4.0-rc1
- Fix type check and typehint for Godot 4.0-rc3
- Fix null byte array error in GodotHttpAdapter for C#

## [3.3.0] - 2023-01-30

### Added

- Add support for subscription validation APIs that were added in Nakama v3.13.0
- Add support for sending events
- Allow disabling threads for making HTTP requests
- Add support for delete_account_async() and other API changes that were added in Nakama v3.15.0

## [3.2.0] - 2022-08-30

### Fixed

- Fix NakamaSocket.add_matchmaker_party_async() and the tests for it
- Fix MatchData.op_code type in schema to TYPE_INT
- Fix circular reference in Nakama singleton to itself

### Added

- Add support for receiving binary data in "NakamaRTAPI.MatchState"
- Add support for sending and receiving binary data in "NakamaRTAPI.PartyData"
- Add NakamaMultiplayerBridge to integrate with Godot's High-Level Multiplayer API

## [3.1.0] - 2022-04-28

### Added

- Expose the "seen_before" property on "NakamaAPI.ApiValidatedPurchase"
- Add support for creating match by name
- Add support for "count_multiple" on "NakamaSocket.add_matchmaker_async()" and "NakamaSocket.add_matchmaker_party_async()"
- Add C# support classes to better integrate the .NET client with the Mono version of Godot, allowing HTML5 exports to work

### Fixed

- Fix receiving "NakamaRTAPI.PartyClose" message
- Fix sending and receiving of PartyData

## [3.0.0] - 2022-03-28

### Added

- Add realtime party support.
- Add purchase validation functions.
- Add Apple authentication functions.
- Add "demote_group_users_async" function.
- A session can be refreshed on demand with "session_refresh_async" method.
- Session and/or refresh tokens can now be invalidated with a client logout.
- The client now supports session auto-refresh using refresh tokens. This is enabled by default.
- The client now supports auto-retrying failed requests due to network errors. This is enabled by default.
- The client now supports cancelling requests in-flight via "client.cancel_request".

### Fixed

- Fix Dictionary serialization (e.g. "NakamaSocket.add_matchmaker_async" "p_string_props" and "p_numeric_props").
- Pass join metadata onwards into match join message.
- Don't stop processing messages when the game is paused.
- Fix "rpc_async", "rpc_async_with_key". Now uses GET request only if no payload is passed.
- Fix parsing of client errors in Nakama 3.x
- Make it possible to omit the label and query on NakamaClient.list_matches_async().

### Backwards incompatible changes

- The "received_error" signal on "NakamaSocket" is now emitted with a "NakamaRTAPI.Error" object received from the server.
  Previously, it was emitted with an integer error code when the socket failed to connect.
  If you have old code using the "received_error" signal, you can switch to the new "connection_error" signal, which was added to replace it.

## [2.1.0] - 2020-08-01

### Added

- Add an optional log level parameter to "Nakama.create_client".

### Changed

- Update variable definitions to new GDScript variable controls.

### Fixed

- Fix "add_friends_async" so its "id" field is optional.
- Fix "add_matchmaker_async" and "MatchmakerAdd" parameter assignment.
- Fix missing "presence" property in NakamaRTAPI.MatchData.
- Fix NakamaSocket not emitting "received_error" correctly.
- Fix "DEFAULT_LOG_LEVEL" in Nakama.gd not doing anything.

## [2.0.0] - 2020-04-02

### Added

- Decode base64 data in "MatchData". (breaks compat)
- Add "FacebookInstantGame" endpoints (link/unlink/authenticate).
- GDScript-style comments (removing all XML tags).
- Add "list_storage_objects_async" "p_user_id" parameter to allow listing other users' objects.

### Fixed

- Fix encoding of "op_code" in "MatchDataSend" and marshalling of "NakamaSocket.send_match_state_[raw_]async".
- Fix parsing of "MatchmakerMatched" messages when no token is specified.
- Disable "HTTPRequest.use_threads" in HTML5 exports.
- "NakamaSession.is_expired" returned reversed result.
- Fix "NakamaClient.update_account_async" to allow updating account without username change.
- Fix "NakamaClient.update_group_async" to allow updating group without name change.
- Fix "HTTPAdapter._send_async" error catching for some edge cases.
- Fix "NakamaClient.send_rpc_async" with empty payload (will send empty string now).
- Fix "NakamaRTAPI.Status" parsing.
- Fix "NakamaClient" "list_leaderboard_records_around_owner_async" and "list_leaderboard_records_async" parameter order. (breaks compat)
- Rename "NakamaClient.JoinTournamentAsync" to "join_tournament_async" for consistent naming.
- Update all "p_limit" parameters default in "NakamaClient" to "10".
- Fix "NakamaRTAPI.Stream" parsing.

## [1.0.0] - 2020-01-28
### Added
- Initial public release.
- Client API implementation.
- Realtime Socket implementation.
- Helper singleton.
- Setup instructions.

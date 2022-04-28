# Change Log
All notable changes to this project are documented below.

The format is based on [keep a changelog](http://keepachangelog.com/) and this project uses [semantic versioning](http://semver.org/).

## [3.1.0] - 2022-04-28

### Added

- Expose the "seen_before" property on "NakamaAPI.ApiValidatedPurchase"
- Add support for creating match by name
- Add support for "count_multple" on "NakamaSocket.add_matchmaker_async()" and "NakamaSocket.add_matchmaker_party_async()"
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
- The client now supports auto-retrying failed request due to network error. This is enabled by defulut.
- The client now support cancelling requests in-flight via "client.cancel_request".

### Fixed

- Fix Dictionary serialization (e.g. "NakamaSocket.add_matchmaker_async" "p_string_props" and "p_numeric_props").
- Pass join metadata onwards into match join message.
- Don't stop processing messages when the game is paused.
- Fix "rpc_async", "rpc_async_with_key". Now uses GET request only if no payload is passed.
- Fix client errors parsing in Nakama 3.x
- Make it possible to omit the label and query on NakamaClient.list_matches_async().

### Backwards incompatible changes

- The "received_error" signal on "NakamaSocket" is now emited with an "NakamaRTAPI.Error" object received from the server.
  Previously, it was emitted with an integer error code when the socket failed to connect.
  If you have old code using the "received_error" signal, you can switch to the new "connection_error" signal, which was added to replace it.

## [2.1.0] - 2020-08-01

### Added

- Add an optional log level parameter to "Nakama.create_client".

### Changed

- Update variable definitions to new gdscript variable controls.

### Fixed

- Fix "add_friends_async" should have its "id" field input as optional.
- Fix "add_matchmaker_async" and "MatchmakerAdd" parameter assignment.
- Fix missing "presence" property in NakamaRTAPI.MatchData.
- Fix NakamaSocket not emitting "received_error" correctly.
- Fix "DEFAULT_LOG_LEVEL" in Nakama.gd not doing anything.

## [2.0.0] - 2020-04-02

### Added

- Decode base64 data in "MatchData". (breaks compat)
- Add "FacebookInstantGame" endpoints (link/unlink/authenticate).
- GDScript-style comments (removing all XML tags).
- Add "list_storage_objects_async" "p_user_id" parameter to allow listing user(s) objects.

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

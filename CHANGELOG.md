# Change Log
All notable changes to this project are documented below.

The format is based on [keep a changelog](http://keepachangelog.com/) and this project uses [semantic versioning](http://semver.org/).

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

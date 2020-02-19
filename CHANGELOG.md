# Change Log
All notable changes to this project are documented below.

The format is based on [keep a changelog](http://keepachangelog.com/) and this project uses [semantic versioning](http://semver.org/).

## [Unreleased]

### Added
- Decode base64 data in `MatchData`. (breaks compat)

### Fixed

- Fix encoding of `op_code` in `MatchDataSend` and marshalling of `NakamaSocket.send_match_state_[raw_]async`.
- Fix parsing of `MatchmakerMatched` messages when no token is specified.
- Disable `HTTPRequest.use_threads` in HTML5 exports.
- `NakamaSession.is_expired` returned reversed result.

## [1.0.0] - 2020-01-28
### Added
- Initial public release.
- Client API implementation.
- Realtime Socket implementation.
- Helper singleton.
- Setup instructions.

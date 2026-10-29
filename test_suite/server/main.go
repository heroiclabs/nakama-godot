// A Nakama plugin for the tests in test_suite/nakama_tests/: an authoritative match that gives out
// NakamaMultiplayerBridge peer ids, so the bridge's server_assigned mode can be tested, and an RPC that always fails
// with HTTP 500 for the retry tests.
package main

import (
	"context"
	"database/sql"
	"encoding/binary"
	"encoding/json"

	"github.com/heroiclabs/nakama-common/runtime"
)

const (
	matchModule    = "bridge_match"
	rpcCreateMatch = "create_bridge_match"
	rpcFail500     = "fail_500"
	matchTickRate  = 10
	// Ends 10 s after the last player leaves, or after creation if nobody joins.
	matchEmptyTicksMax = 10 * matchTickRate

	// NakamaMultiplayerBridge's default op codes and its ASSIGN_PEER_ID meta message type.
	godotMetaOpCode   = 9001
	godotRPCOpCode    = 9002
	godotAssignPeerID = 1
	// 1 is Godot's server, which this match is not: it only assigns ids and routes.
	godotFirstPeerID    = 2
	godotTargetByteSize = 4
)

//goland:noinspection GoUnusedExportedFunction
func InitModule(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, initializer runtime.Initializer) error {
	if err := initializer.RegisterMatch(matchModule, newBridgeMatch); err != nil {
		return err
	}
	if err := initializer.RegisterMatchmakerMatched(matchmakerMatched); err != nil {
		return err
	}
	if err := initializer.RegisterRpc(rpcFail500, rpcFail500Fn); err != nil {
		return err
	}
	return initializer.RegisterRpc(rpcCreateMatch, rpcCreateMatchFn)
}

// matchmakerMatched puts players whose tickets carry the string property bridge=server in a bridge match;
// everyone else gets a relayed match, as without the hook.
func matchmakerMatched(ctx context.Context, _ runtime.Logger, _ *sql.DB, nk runtime.NakamaModule, entries []runtime.MatchmakerEntry) (string, error) {
	if len(entries) == 0 || entries[0].GetProperties()["bridge"] != "server" {
		return "", nil
	}
	return nk.MatchCreate(ctx, matchModule, nil)
}

// rpcFail500Fn always fails with INTERNAL, which Nakama sends as HTTP 500, so clients retry it.
func rpcFail500Fn(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, _ string) (string, error) {
	return "", runtime.NewError("fail_500 always fails", 13)
}

// rpcCreateMatchFn creates a bridge match and replies with {"match_id": ...}.
func rpcCreateMatchFn(ctx context.Context, _ runtime.Logger, _ *sql.DB, nk runtime.NakamaModule, _ string) (string, error) {
	matchID, err := nk.MatchCreate(ctx, matchModule, nil)
	if err != nil {
		return "", err
	}
	reply, err := json.Marshal(map[string]string{"match_id": matchID})
	return string(reply), err
}

type matchState struct {
	presences  map[string]runtime.Presence // by session id
	peerIDs    map[string]int32            // by session id
	nextPeerID int32
	emptyTicks int
}

// godotAssign is the bridge's ASSIGN_PEER_ID meta message. It also names the user, since it can arrive
// before the presence event of the player it is about.
type godotAssign struct {
	Type      int    `json:"type"`
	SessionID string `json:"session_id"`
	PeerID    int32  `json:"peer_id"`
	UserID    string `json:"user_id"`
	Username  string `json:"username"`
}

type bridgeMatch struct{}

func newBridgeMatch(context.Context, runtime.Logger, *sql.DB, runtime.NakamaModule) (runtime.Match, error) {
	return &bridgeMatch{}, nil
}

func (m *bridgeMatch) MatchInit(context.Context, runtime.Logger, *sql.DB, runtime.NakamaModule, map[string]any) (any, int, string) {
	return &matchState{
		presences:  map[string]runtime.Presence{},
		peerIDs:    map[string]int32{},
		nextPeerID: godotFirstPeerID,
	}, matchTickRate, ""
}

func (m *bridgeMatch) MatchJoinAttempt(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, _ runtime.MatchDispatcher, _ int64, state any, _ runtime.Presence, _ map[string]string) (any, bool, string) {
	return state, true, ""
}

func (m *bridgeMatch) MatchJoin(_ context.Context, logger runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, dispatcher runtime.MatchDispatcher, _ int64, state any, presences []runtime.Presence) any {
	s := state.(*matchState)
	for _, p := range presences {
		s.presences[p.GetSessionId()] = p
		s.assignPeerID(logger, dispatcher, p)
	}
	return s
}

// assignPeerID gives the newcomer the next peer id, then tells it its own id followed by everyone else's,
// and everyone else the newcomer's.
func (s *matchState) assignPeerID(logger runtime.Logger, dispatcher runtime.MatchDispatcher, newcomer runtime.Presence) {
	s.peerIDs[newcomer.GetSessionId()] = s.nextPeerID
	s.nextPeerID++
	send := func(about runtime.Presence, to []runtime.Presence) {
		data, _ := json.Marshal(godotAssign{godotAssignPeerID, about.GetSessionId(), s.peerIDs[about.GetSessionId()], about.GetUserId(), about.GetUsername()})
		if err := dispatcher.BroadcastMessage(godotMetaOpCode, data, to, nil, true); err != nil {
			logger.Warn("peer id not sent: %v", err)
		}
	}
	send(newcomer, []runtime.Presence{newcomer})
	others := make([]runtime.Presence, 0, len(s.presences))
	for sessionID, p := range s.presences {
		if sessionID != newcomer.GetSessionId() {
			send(p, []runtime.Presence{newcomer})
			others = append(others, p)
		}
	}
	if len(others) > 0 {
		send(newcomer, others)
	}
}

func (m *bridgeMatch) MatchLeave(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, _ runtime.MatchDispatcher, _ int64, state any, presences []runtime.Presence) any {
	s := state.(*matchState)
	for _, p := range presences {
		delete(s.presences, p.GetSessionId())
		delete(s.peerIDs, p.GetSessionId())
	}
	return s
}

// MatchLoop routes each RPC packet to the peers its target names, with the sender's presence; returning nil ends the match.
func (m *bridgeMatch) MatchLoop(_ context.Context, logger runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, dispatcher runtime.MatchDispatcher, _ int64, state any, messages []runtime.MatchData) any {
	s := state.(*matchState)
	if len(s.presences) == 0 {
		s.emptyTicks++
		if s.emptyTicks > matchEmptyTicksMax {
			return nil
		}
	} else {
		s.emptyTicks = 0
	}
	for _, message := range messages {
		// Peer ids come from this match only, so players' meta messages are dropped.
		data := message.GetData()
		if message.GetOpCode() != godotRPCOpCode || len(data) < godotTargetByteSize {
			continue
		}
		// The bridge puts the target peer id first: positive for one peer, negative for all but one, 0 for all.
		target, data := int32(binary.LittleEndian.Uint32(data)), data[godotTargetByteSize:]
		to := make([]runtime.Presence, 0, len(s.presences))
		for sessionID, p := range s.presences {
			peerID := s.peerIDs[sessionID]
			if sessionID != message.GetSessionId() && (target == 0 || target == peerID || (target < 0 && -target != peerID)) {
				to = append(to, p)
			}
		}
		if len(to) == 0 {
			continue
		}
		if err := dispatcher.BroadcastMessage(godotRPCOpCode, data, to, message, message.GetReliable()); err != nil {
			logger.Warn("match relay failed: %v", err)
		}
	}
	return s
}

func (m *bridgeMatch) MatchTerminate(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, _ runtime.MatchDispatcher, _ int64, state any, _ int) any {
	return state
}

func (m *bridgeMatch) MatchSignal(_ context.Context, _ runtime.Logger, _ *sql.DB, _ runtime.NakamaModule, _ runtime.MatchDispatcher, _ int64, state any, data string) (any, string) {
	return state, data
}

ARG NAKAMA_VERSION=3.41.0

FROM docker.io/heroiclabs/nakama-pluginbuilder:${NAKAMA_VERSION} AS builder

ENV GO111MODULE=on
ENV CGO_ENABLED=1

WORKDIR /backend
COPY . .

RUN --mount=type=cache,target=/root/.cache/go-build/ go build --trimpath --buildmode=plugin -o ./backend.so

FROM docker.io/heroiclabs/nakama:${NAKAMA_VERSION}

COPY --from=builder /backend/backend.so /nakama/data/modules

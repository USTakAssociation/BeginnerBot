# Installation

Install Golang (1.18+ recommended).

Place the contents of this package in a folder that is neither in the `GOROOT` or `GOPATH`.

Install the `golang.org/x/net/context` package if your toolchain requires it.

# Programs

There are several commands included under the `cmd` directory. All commands accept `-help` to list flags; common binaries are `cmd/playtak`, `cmd/taktician`, `cmd/taklogger`, and `cmd/analyzetak`.

Below are quick examples for building, running, and containerizing the bot, and how to provide credentials and a PlayTak server URL.

## Build and run locally (`cmd/playtak`)

Build the `playtak` runner and run a match with different players:

```bash
go build -o bin/playtak ./cmd/playtak
./bin/playtak -white=minimax:5 -black=rand -size=5
```

You can also run directly with `go run`:

```bash
go run ./cmd/playtak -white=mcts:2s -black=minimax:3 -size=6
```

Player string syntax examples:
- `minimax:5` — minimax search with depth 5
- `mcts:2s` — MCTS search with a 2-second limit
- `rand` — random player

Use `-size` to set board size, and `-debug` or `-limit` where available for verbose output or time limits.

## Analyze PTN positions (`cmd/analyzetak`)

Analyze PTN files on the command line:

```bash
go build -o bin/analyzetak ./cmd/analyzetak
./bin/analyzetak FILE.ptn
```

## Connect to PlayTak / Run as a bot (`cmd/taktician`, `cmd/taklogger`)

Some binaries accept server and credential flags to connect to a PlayTak server. Common flags:

- `-server` : PlayTak server URL (e.g. `https://playtak.com`)
- `-user` : bot username
- `-pass` : bot password

Example: run `taktician` with a bot account and depth 4 minimax:

```bash
go build -o bin/taktician ./cmd/taktician
./bin/taktician -server=https://playtak.com -user=mybot -pass=secret -depth=4
```

Example: run `taklogger` pointing at a custom server and write PTN output:

```bash
go build -o bin/taklogger ./cmd/taklogger
./bin/taklogger -server=https://playtak.com -out=/data/games.ptn
```

Check each binary with `-help` for additional available flags (for example `-limit`, `-sort`, or `-table` may be supported).

## Containerization (Podman / Docker)

Example multi-stage `Dockerfile` to build `playtak` and produce a small runtime image:

```dockerfile
FROM golang:1.26.5 AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/playtak ./cmd/playtak

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
COPY --from=builder /out/playtak /usr/local/bin/playtak
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/playtak"]
```

Build and run with Podman:

```bash
podman build -t tak-bot:local .
podman run --rm -it tak-bot:local -white=minimax:5 -black=rand -size=5
```

To persist PTN output or provide data files, mount a host directory into the container:

```bash
podman run --rm -it -v $(pwd)/data:/data tak-bot:local -white=minimax:5 -black=rand -size=5 -out /data/game.ptn
```

## Notes and tips

- All CLI entrypoints accept `-help` to list supported flags. Use that to discover per-binary options such as `-depth`, `-limit`, `-debug`, etc.
- Strength is controlled via the player string (`minimax:DEPTH`, `mcts:DURATION`). You can tune additional AI behavior by editing `ai/minimax.go` and `ai/mcts/mcts.go`.
- The `-server`, `-user`, and `-pass` flags are used by the PlayTak-facing binaries (for example `cmd/taktician` and `cmd/taklogger`) to connect to the remote server. If you use a custom PlayTak instance, pass its URL via `-server`.

[tak]: http://cheapass.com/node/215

# Installation

Install Golang (1.26+ recommended).

# Programs

There are several commands included under the `cmd` directory. All commands accept `-help` to list flags; common binaries are `cmd/playtak`, `cmd/taktician`, `cmd/taklogger`, and `cmd/analyzetak`.

Below are quick examples for building, running, and containerizing the bot, and how to provide credentials and a PlayTak server address.

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

- `-server` : PlayTak server address in `host:port` form (e.g. `playtak.com:10000`)
- `-user` : bot username
- `-pass` : bot password

Note: `-pass` takes the password as a plain command-line argument, so it will be visible in your shell history and to other users via process listings (e.g. `ps`). There is currently no alternate input method (env var, prompt, or file); avoid using this flag with real credentials on shared or untrusted machines.

Example: run `taktician` with a bot account and depth 4 minimax:

```bash
go build -o bin/taktician ./cmd/taktician
./bin/taktician -server=playtak.com:10000 -user=mybot -pass=secret -depth=4
```

Example: run `taklogger` pointing at a custom server and write PTN output:

```bash
go build -o bin/taklogger ./cmd/taklogger
./bin/taklogger -server=playtak.com:10000 -out=/data/ptn
```

Check each binary with `-help` for additional available flags (for example `-limit`, `-sort`, or `-table` may be supported).

## Containerization (Podman / Docker)

The checked-in `Dockerfile` builds `taktician` and sets it as the image entrypoint:

```dockerfile
FROM golang:1.26.5 AS builder
WORKDIR /src
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/taktician ./cmd/taktician

FROM scratch
COPY --from=builder /out/taktician /usr/local/bin/taktician
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/taktician"]
```

Build and run with Podman, passing `taktician`'s own flags (not `playtak`'s):

```bash
podman build -t tak-bot:local .
podman run --rm -it tak-bot:local -server=playtak.com:10000 -user=mybot -pass=secret -depth=4
```

`taktician` connects to a PlayTak server and doesn't write files itself, so there's no PTN output to persist for this image. To build and run `playtak` or `taklogger` (which does support `-out`) in a container instead, write a separate Dockerfile targeting that command's `./cmd/...` path.

## Notes and tips

- All CLI entrypoints accept `-help` to list supported flags. Use that to discover per-binary options such as `-depth`, `-limit`, `-debug`, etc.
- Strength is controlled via the player string (`minimax:DEPTH`, `mcts:DURATION`). You can tune additional AI behavior by editing `ai/minimax.go` and `ai/mcts/mcts.go`.
- The `-server`, `-user`, and `-pass` flags are used by the PlayTak-facing binaries (for example `cmd/taktician` and `cmd/taklogger`) to connect to the remote server. If you use a custom PlayTak instance, pass its `host:port` address via `-server`.

[tak]: http://cheapass.com/node/215

FROM golang:1.26.5 AS builder
WORKDIR /src
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/playtak ./cmd/playtak

FROM scratch
COPY --from=builder /out/playtak /usr/local/bin/playtak
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/playtak"]
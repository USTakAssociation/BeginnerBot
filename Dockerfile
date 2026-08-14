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
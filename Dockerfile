FROM golang:1.23 AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

ADD . .

RUN go build -v -o builder-playground .

FROM debian:latest
WORKDIR /app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/builder-playground /app/builder-playground
ENTRYPOINT [ "/app/builder-playground" ]
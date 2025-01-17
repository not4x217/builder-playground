FROM golang:1.23 AS builder-playground
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
ADD . .
RUN go build -v -o builder-playground .

FROM golang:1.23 AS eigenlayer-cli 
WORKDIR /build
RUN git clone https://github.com/not4x217/eigenlayer-cli.git
RUN cd eigenlayer-cli && make build 

FROM debian:latest
RUN apt-get update && apt-get install -y git curl bash

RUN curl -L https://foundry.paradigm.xyz | bash
RUN bash -c 'source /root/.profile && foundryup'
RUN cp -r /root/.foundry/bin/* /usr/local/bin/
RUN adduser --uid 1000 foundry

WORKDIR /app
COPY --from=builder-playground /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder-playground /build/builder-playground /usr/local/bin/builder-playground
COPY --from=eigenlayer-cli /build/eigenlayer-cli/bin/eigenlayer /usr/local/bin/eigenlayer-cli

ENTRYPOINT [ "/bin/sh", "-c" ]
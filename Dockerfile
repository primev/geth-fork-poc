FROM golang:1.22-alpine AS builder

RUN apk add --no-cache gcc musl-dev linux-headers git make

RUN git clone https://github.com/primev/mev-commit-geth.git /go-ethereum
WORKDIR /go-ethereum

RUN git checkout shutdown-at-upgrade
RUN make geth

FROM alpine:latest

RUN apk add --no-cache jq

COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

COPY genesis.json /genesis.json

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8545

ENTRYPOINT ["/entrypoint.sh"]

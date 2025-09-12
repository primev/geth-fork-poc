#!/bin/sh
set -eu

echo "13373d9a0257983ad150392d7ddb2f9172c9396b4c450e26af469d123c7aaa5c" > /jwt.hex

echo "initializing erigon"
erigon init --datadir /erigon-data /genesis.json

echo "starting erigon"
exec erigon \
  --datadir /erigon-data \
  --externalcl \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.jwtsecret /jwt.hex \
  --authrpc.vhosts "*" \
  --networkid 17864 \
  --bootnodes "" \
  --nodiscover \
  --http \
  --http.api "eth,engine,erigon,web3,txpool" \
  --http.port 8545 \
  --http.addr 0.0.0.0 \
  --http.vhosts "*" \
  --ws=false \
  --verbosity info \

#!/bin/sh
set -eu

echo "13373d9a0257983ad150392d7ddb2f9172c9396b4c450e26af469d123c7aaa5c" > /jwt.hex

UPGRADE_TIMESTAMP_MS=$(cat /data/upgrade_timestamp_ms.txt)

jq ".config.shanghaiTime = $UPGRADE_TIMESTAMP_MS" /genesis.json > /genesis.json.tmp && mv /genesis.json.tmp /genesis.json
jq ".config.cancunTime = $UPGRADE_TIMESTAMP_MS" /genesis.json > /genesis.json.tmp && mv /genesis.json.tmp /genesis.json
jq ".config.pragueTime = $UPGRADE_TIMESTAMP_MS" /genesis.json > /genesis.json.tmp && mv /genesis.json.tmp /genesis.json

echo "initializing erigon"
erigon init --datadir /erigon-data /genesis.json

echo "importing chain.rlp"
erigon import --datadir /erigon-data /data/chain.rlp

echo "starting erigon"
exec erigon \
  --datadir /erigon-data \
  --externalcl \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.jwtsecret /jwt.hex \
  --networkid 17864 \
  --bootnodes "" \
  --nodiscover \
  --http \
  --http.api "eth,engine,erigon,web3" \
  --http.port 8545 \
  --http.addr 0.0.0.0 \
  --private-api.addr=localhost:9090 \
  --ws=false \
  --verbosity info \

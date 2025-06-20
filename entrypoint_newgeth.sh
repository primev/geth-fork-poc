#!/bin/sh
set -eu

echo "13373d9a0257983ad150392d7ddb2f9172c9396b4c450e26af469d123c7aaa5c" > /jwt.hex

UPGRADE_TIMESTAMP_MS=$(cat /data/upgrade_timestamp_ms.txt)

jq ".config.shanghaiTime = $UPGRADE_TIMESTAMP_MS" /genesis.json > /genesis.json.tmp && mv /genesis.json.tmp /genesis.json
jq ".config.cancunTime = $UPGRADE_TIMESTAMP_MS" /genesis.json > /genesis.json.tmp && mv /genesis.json.tmp /genesis.json
jq ".config.pragueTime = $UPGRADE_TIMESTAMP_MS" /genesis.json > /genesis.json.tmp && mv /genesis.json.tmp /genesis.json

echo "initializing newgeth"
geth init --datadir /newgeth-data /genesis.json

echo "importing chain.rlp"
# Note we may want to do this import with multiple rlp files in case of failures
geth import --datadir /newgeth-data /data/chain.rlp

echo "starting newgeth"
exec geth --verbosity 5 \
  --datadir /newgeth-data \
  --nodiscover \
  --http \
  --http.port 8545 \
  --http.addr 0.0.0.0 \
  --http.api "admin,eth,net,web3,engine" \
  --http.vhosts "*" \
  --port 30303 \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.vhosts "*" \
  --authrpc.jwtsecret /jwt.hex \
  --networkid 17864 \
  --syncmode full \
  --miner.recommit 900ms 

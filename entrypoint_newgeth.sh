#!/bin/sh
set -eu

echo "13373d9a0257983ad150392d7ddb2f9172c9396b4c450e26af469d123c7aaa5c" > /jwt.hex

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
  --port 30303 \
  --authrpc.jwtsecret /jwt.hex \
  --authrpc.port 8551 \
  --networkid 17864 \
  --syncmode full \
  --miner.recommit 900ms 

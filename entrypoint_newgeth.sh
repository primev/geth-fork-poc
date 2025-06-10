#!/bin/sh
set -eu

while nc -zv node1 8545; do
  echo "Waiting for oldgeth to exit..."
  sleep 5
done

exec geth --verbosity 5 \
  --datadir /data \
  --nodiscover \
  --http \
  --http.port 8545 \
  --port 30303 \
  --authrpc.jwtsecret ./geth-setup/jwt.hex \
  --authrpc.port 8551 \
  --networkid 141414 \
  --http.api "admin,eth,net,web3,engine" \
  --syncmode full \
  --miner.recommit 900ms

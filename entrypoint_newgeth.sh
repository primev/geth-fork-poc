#!/bin/sh
set -eu

# TODO: Init chain, then import chain.rlp

echo "done"
exit 0

exec geth --verbosity 5 \
  --datadir /data \
  --nodiscover \
  --http \
  --http.port 8545 \
  --port 30303 \
  --authrpc.jwtsecret ./geth-setup/jwt.hex \
  --authrpc.port 8551 \
  --networkid 17864 \
  --http.api "admin,eth,net,web3,engine" \
  --syncmode full \
  --miner.recommit 900ms 

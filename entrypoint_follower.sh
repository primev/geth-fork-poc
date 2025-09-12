#!/bin/sh
set -eu

exec snode follower \
  --instance-id "follower1" \
  --eth-client-url "http://erigon-follower:8551" \
  --jwt-secret "13373d9a0257983ad150392d7ddb2f9172c9396b4c450e26af469d123c7aaa5c" \
  --postgres-dsn "postgres://mevcommit:password123@postgres:5432/mevcommit?sslmode=disable" \
  --log-level "debug" \

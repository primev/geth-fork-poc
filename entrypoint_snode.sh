#!/bin/sh
set -eu

exec snode leader \
  --instance-id "leader1" \
  --eth-client-url "http://newgeth:8545" \
  --jwt-secret "13373d9a0257983ad150392d7ddb2f9172c9396b4c450e26af469d123c7aaa5c" \
  --priority-fee-recipient "0xfA0B0f5d298d28EFE4d35641724141ef19C05684" \
  --postgres-dsn "postgres://mevcommit:password123@postgres:5432/mevcommit?sslmode=disable" \
  --evm-build-delay "100ms" \
  --evm-build-delay-empty-block "2s" \
  --api-addr ":9090" \
  --log-level "info"

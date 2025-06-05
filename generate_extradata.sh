#!/bin/bash

# See: https://geth.ethereum.org/docs/fundamentals/private-network's extradata section.

extradata="0x$(printf '0%.0s' {1..64})"

for addr in "$@"; do
  addr="${addr#0x}"
  extradata+="$addr"
done

extradata+=$(printf '0%.0s' {1..130})

echo "$extradata"

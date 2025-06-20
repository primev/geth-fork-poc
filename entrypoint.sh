#!/bin/sh
set -eu

GENESIS_L1_PATH="/genesis.json"
VERBOSITY=3
GETH_DATA_DIR=/data
GETH_CHAINDATA_DIR="$GETH_DATA_DIR/geth/chaindata"
GETH_KEYSTORE_DIR="$GETH_DATA_DIR/keystore"
CHAIN_ID=$(cat "$GENESIS_L1_PATH" | jq -r .config.chainId)
RPC_PORT="${RPC_PORT:-8545}"
WS_PORT="${WS_PORT:-8546}"

# Generate signer key if needed
if [ ! -d "$GETH_KEYSTORE_DIR" ] && [ "$GETH_NODE_TYPE" = "signer" ]; then

	echo "$GETH_KEYSTORE_DIR missing, running account import"
	echo -n "pwd" > "$GETH_DATA_DIR"/password
	echo -n "$BLOCK_SIGNER_PRIVATE_KEY" | sed 's/0x//' > "$GETH_DATA_DIR"/block-signer-key
	geth --verbosity="$VERBOSITY" \
		--nousb \
		account import \
		--datadir="$GETH_DATA_DIR" \
		--password="$GETH_DATA_DIR"/password \
		"$GETH_DATA_DIR"/block-signer-key
else
	echo "$GETH_KEYSTORE_DIR exists."
fi

# Init geth if needed
if [ ! -d "$GETH_CHAINDATA_DIR" ]; then
	echo "$GETH_CHAINDATA_DIR missing, running init"
	echo "Initializing genesis."
	geth --verbosity="$VERBOSITY" \
		--nousb \
		--datadir="$GETH_DATA_DIR" init \
		"$GENESIS_L1_PATH"
else
	echo "$GETH_CHAINDATA_DIR exists."
fi

# Obtain assigned container IP for p2p
NODE_IP=$(hostname -i)

if [ "$GETH_NODE_TYPE" = "bootnode" ]; then
	echo "Starting bootnode"

	# Generate boot.key
	echo "$BOOT_KEY" > $GETH_DATA_DIR/boot.key

	exec geth \
		--verbosity="$VERBOSITY" \
		--datadir="$GETH_DATA_DIR" \
		--port 30301 \
		--http \
		--http.corsdomain="*" \
		--http.vhosts="*" \
		--http.addr=0.0.0.0 \
		--http.port="$RPC_PORT" \
		--http.api=web3,debug,eth,txpool,net,engine \
		--ws \
		--ws.addr=0.0.0.0 \
		--ws.port="$WS_PORT" \
		--ws.origins="*" \
		--ws.api=debug,eth,txpool,net,engine \
		--syncmode=full \
		--gcmode=archive \
		--networkid=$CHAIN_ID \
		--nousb \
		--metrics \
		--metrics.addr=0.0.0.0 \
		--metrics.port=6060 \
		--nodekey $GETH_DATA_DIR/boot.key \
		--netrestrict 172.13.0.0/24 \
		--nat extip:$NODE_IP

elif [ "$GETH_NODE_TYPE" = "signer" ]; then
	echo "Starting signer node"

	# Set upgrade timestamp to 30 seconds from now, in unix milliseconds
	UPGRADE_TIMESTAMP_MS=$(( $(date +%s) * 1000 + 30000 ))

	geth \
		--verbosity="$VERBOSITY" \
		--datadir="$GETH_DATA_DIR" \
		--port 30311 \
		--syncmode=full \
		--gcmode=full \
		--http \
		--http.corsdomain="*" \
		--http.vhosts="*" \
		--http.addr=0.0.0.0 \
		--http.port="$RPC_PORT" \
		--http.api=web3,debug,eth,txpool,net,engine \
		--bootnodes enode://34a2a388ad31ca37f127bb9ffe93758ee711c5c2277dff6aff2e359bcf2c9509ea55034196788dbd59ed70861f523c1c03d54f1eabb2b4a5c1c129d966fe1e65@172.13.0.100:30301 \
		--networkid=$CHAIN_ID \
		--unlock=$BLOCK_SIGNER_ADDRESS \
		--password="$GETH_DATA_DIR"/password \
		--mine \
		--miner.etherbase=$BLOCK_SIGNER_ADDRESS \
		--allow-insecure-unlock \
		--nousb \
		--netrestrict 172.13.0.0/24 \
		--ws \
		--ws.addr=0.0.0.0 \
		--ws.port="$WS_PORT" \
		--ws.origins="*" \
		--ws.api=debug,eth,txpool,net,engine \
		--rpc.allow-unprotected-txs \
		--authrpc.addr="0.0.0.0" \
		--authrpc.port="8551" \
		--authrpc.vhosts="*" \
		--nat extip:$NODE_IP \
		--upgrade-timestamp-ms $UPGRADE_TIMESTAMP_MS

	geth export --datadir $GETH_DATA_DIR "$GETH_DATA_DIR/chain.rlp"

	# Shouldn't be necessary, but to be defensive..
	sync

	touch $GETH_DATA_DIR/export_complete

	echo $UPGRADE_TIMESTAMP_MS > $GETH_DATA_DIR/upgrade_timestamp_ms.txt

	# Keep container running for health check
	tail -f /dev/null
else
	echo "Invalid GETH_NODE_TYPE specified"
fi

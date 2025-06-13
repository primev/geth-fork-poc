# geth-fork-poc

## Upgrade to recent geth

This repo currently implements a POC for upgrading our current clique-based geth chain from a v13 fork of geth to the most recent version of geth. Post-upgrade, the new geth chain uses engine-api and a simple single-node consensus engine.

Relies on:

* https://github.com/primev/mev-commit-geth/pull/59
* https://github.com/primev/mev-commit-go-ethereum/pull/3

### TODOs for this POC path

* Change how header.time is set in new geth after the upgrade. Find the spot where setting header.time happens and change it to ms, or if this is set in consensus layer then change it there. See https://github.com/primev/mev-commit/blob/main/cl/blockbuilder/blockbuilder.go#L150. 
* Deploy our protocol contracts and confirm state is maintained before/after the upgrade. 
* Stress test starting/stopping the post upgrade chain.
* Consider temporarily rejecting incoming RPC traffic to the eth node for 10 seconds before the upgrade (important client receives an error response and the request isn't just dropped)
* Confirm whether `TxPoolJournalFlag` needs to be enabled if we're already exporting chaindata. Does geth export handle mempool persistence implicitly? Or Do we need to manually copy over the mempool.rlp file between old and new geth?
* Stress test that "zero fee txes" work before and after the upgrade
* Add tx spam container, and associated monitoring, detects and visualizes if any txes are dropped before during and after the upgrade.
* Benchmark the import/export process for geth, how long it’ll take to import / export on different machines. Measure performance for varying num of blocks.

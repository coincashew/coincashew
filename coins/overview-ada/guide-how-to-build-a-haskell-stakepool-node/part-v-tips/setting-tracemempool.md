# Setting TraceMempool

If you are not satisfied with the performance of an instance of Cardano Node, then subjectively you may notice improvement in memory usage, CPU usage and/or the number of missed slot leader checks if you set the `TraceMempool` key to the value `false` in the file `mainnet-config.json`

**Side effects of TraceMempool = false**

* gLiveView will show 0 for transactions processed
* If your block producer is configured this way, troubleshooting topology / firewall / transaction processing issues may be harder to diagnose and identify. For block producer nodes, it is considered [best practice](https://github.com/input-output-hk/cardano-node/issues/2350) to keep TraceMempool as true.
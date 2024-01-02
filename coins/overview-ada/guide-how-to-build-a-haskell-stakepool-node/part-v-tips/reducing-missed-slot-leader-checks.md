# Reducing Missed Slot Leader Checks

{% hint style="success" %}
:ledger:Technical writing by [Change Pool (ticker CHG)](https://change.paradoxicalsphere.com)
{% endhint %}

By design, a Cardano Node instance checks whether to mint a block—whether to act as the leader for a slot—every second. When the computer hosting Cardano Node is busy, then Cardano Node may miss slot leader checks. If the Cardano Node instance misses a slot leader check when elected to mint a block, then the node may miss the opportunity to mint the block.

In general, investigate potential configuration changes to reduce missed slot leader checks if the [gLiveView](../part-iii-operation/starting-the-nodes.md#gliveview) dashboard reports that the Cardano Node instance misses more than approximately 0.1 percent of slot leader checks, after running for a few days.

To reduce the number of slot leader checks that a Cardano Node instance misses, consider the following configurations changes:

- Increase the speed of the disk drive that the computer uses.
- To force the Cardano Node instance to use all processor cores available on the computer, configure runtime system options to include the `-N` option. For details, see [Configuring Glasgow Haskell Compiler Runtime System Options](./configuring-runtime-options.md).
- By default, Cardano Node takes a snapshot of the ledger on the disk every 72 minutes. To customize the amount of time between snapshots, add a key named `SnapshotInterval` in the `config.json` file that the Cardano Node instance uses, and then set the value to a duration in seconds. For example, to take a snapshot every 24 hours, set the value to `86400` <!-- Source: https://cardano.stackexchange.com/questions/4532/missed-slot-leader-checks -->
- In the `config.json` configuration file that the Cardano Node instance uses, consider setting the `TraceMempool` key to the value `false` to disable mempool tracing. When you disable mempool tracing, the Cardano Node instance continues processes transactions as usual. However, the gLiveView dashboard displays 0 for statistics related to transaction processing. Therefore, you may find troubleshooting issues related to topology, firewall or transaction processing more challenging when mempool tracing is disabled. Always enabling mempool tracing on a block-producing node may be considered [best practice](https://github.com/input-output-hk/cardano-node/issues/2350).


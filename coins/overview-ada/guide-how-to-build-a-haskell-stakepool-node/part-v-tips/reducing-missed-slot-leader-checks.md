# Reducing Missed Slot Leader Checks and Improving Cardano Node Performance

{% hint style="success" %}
:ledger:Technical writing by [Change Pool (ticker CHG)](https://change.paradoxicalsphere.com)
{% endhint %}

By design, a Cardano block-producing node checks whether to mint a block—whether to act as the leader for a slot—every second. When the computer hosting the block producer is busy, then the block producer may miss slot leader checks. If the block producer misses a slot leader check when elected to mint a block, then the block producer may miss the opportunity to mint the block.

In general, investigate potential configuration changes to reduce missed slot leader checks if the [gLiveView](../part-iii-operation/starting-the-nodes.md#gliveview) dashboard reports that your block-producing node misses more than approximately 0.1 percent of slot leader checks, after running for a few days.

Configuration changes that reduce the number of missed slot leader checks when implemented on a block-producing node may also improve node performance when implemented on a relay node.

To reduce the number of missed slot leader checks on a block-producing node or improve the general performance of a relay node, consider the following configurations changes:

- Increase the speed of the disk drive that the computer hosting the Cardano Node uses.
- To force the Cardano Node instance to use all processor cores available on the computer, configure runtime system options to include the `-N` option. For details, see [Configuring Glasgow Haskell Compiler Runtime System Options](./configuring-runtime-options.md).
- By default, Cardano Node takes a snapshot of the ledger on the disk every 72 minutes. To customize the amount of time between snapshots, add a key named `SnapshotInterval` in the `config.json` file that the Cardano Node instance uses, and then set the value to a duration in seconds. For example, to take a snapshot every 24 hours, set the value to `86400` Increasing the amount of time between snapshots may slightly increase the time required to start the Cardano Node instance. <!-- Source: https://cardano.stackexchange.com/questions/4532/missed-slot-leader-checks -->
- In the `config.json` configuration file that the Cardano Node instance uses, consider setting the `TraceMempool` key to the value `false` to disable mempool tracing. When you disable mempool tracing, the Cardano Node instance continues processing transactions as usual. However, the gLiveView dashboard displays 0 for statistics related to transaction processing. Therefore, you may find troubleshooting issues related to topology, firewall or transaction processing more challenging when mempool tracing is disabled. Always enabling mempool tracing on a block-producing node may be considered [best practice](https://github.com/input-output-hk/cardano-node/issues/2350).


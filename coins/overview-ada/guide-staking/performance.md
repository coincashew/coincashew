---
description: >-
  The higher, the better
---

# :zap:Performance

To judge stake pool performance, evaluate the ratio of blocks assigned for the stake pool to mint, to blocks forged. Expect a ratio less than 100 percent. Stake pools may miss a certain number of blocks as orphans and due to **factors beyond the control of the operator**. However, generally a pool should forge all assigned blocks.

{% hint style="info" %}
Early iterations of Cardano Node released with bugs causing pools to miss blocks for various reasons. Cardano Node development is ongoing. Expect lower overall performance from pools existing since the Shelley era than from pools registered more recently.
{% endhint %}

Performance is most difficult to judge because only an attentive stake pool operator knows actual performance and few SPOs report statistics. Some stake pool operators report actual performance voluntarily using [Cardano PoolTool](https://pooltool.io/).

Some Web sites calculate the **luck** of a stake pool as the ratio of the number of blocks assigned for the pool to mint or forge, to the number of blocks expected to be assigned based on the size of stake. The luck metric is only useful for finding pools underperforming drastically. You can guarantee that a pool having greater than 100 percent luck has been elected to mint more blocks than expected. However, a current high value of luck does not indicate that the pool has outperformed other pools over the longer term. Conversely, a pool currently having less than 100 percent luck may have been assigned fewer blocks to mint than expected, or may be underperforming by missing scheduled blocks.

You can find pool parameters including and not limited to **pledge**, **margin**, **fixed fee** and **saturation** using [PoolTool](https://pooltool.io/), [Cardanoscan](https://cardanoscan.io/) or another Cardano blockchain explorer.

In addition to considering reward rates, also evaluate the infrastructure of a stake pool. At a minimum, a pool should have a block-producing node and two relay nodes. Relays connect with other relays on the network, transmitting blocks and transactions throughout the network. The more relays in a stake pool configuration, the better. The pool should have some redundancy in place that responds automatically to failures within the system. For example, if the block-producing node fails, then another node should replace the failing node quickly. All of the nodes should be distributed geographically.
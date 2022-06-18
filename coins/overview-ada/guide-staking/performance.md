---
description: >-
  The higher, the better
---

# :zap:Performance

To judge stake pool performance, you may evaluate the ratio of blocks assigned for the stake pool to mint, to blocks forged. Expect a ratio less than 100 percent. Stake pools may miss a certain number of blocks as orphans and due to **factors beyond the control of the operator**. However, generally a pool should forge all assigned blocks.

{% hint style="info" %}
Early versions of Cardano Node released with bugs causing pools to miss blocks for various reasons. Cardano Node development is ongoing. Expect lower overall performance from pools existing since the Shelley era than from pools registered more recently.
{% endhint %}

Performance is most difficult to judge because only an attentive stake pool operator knows actual performance. Few SPOs report statistics. Some stake pool operators report actual performance using [Cardano PoolTool](https://pooltool.io/).

The **luck** of a stake pool may be calculated as the ratio of the number of blocks assigned by the blockchain protocol for the pool to mint or forge, to the number of blocks expected to be assigned based on the size of stake. The luck metric is only useful for finding pools underperforming drastically. A pool having greater than 100 percent luck has been elected to mint more blocks than expected in the current epoch. However, a current high value of luck does not indicate that the pool has outperformed other pools over the longer term. Conversely, a pool currently having less than 100 percent luck may have been assigned fewer blocks to mint than expected in the current epoch, or the pool may be underperforming by missing scheduled blocks.

You can find pool parameters including and not limited to **pledge**, **margin**, **fixed fee** and **saturation** using [PoolTool](https://pooltool.io/), [Cardanoscan](https://cardanoscan.io/) or other Cardano blockchain explorers.

In addition to considering reward rates, also evaluate the infrastructure of a stake pool. Relays connect with other relays on the network, transmitting blocks and transactions throughout the network. More relay nodes in a stake pool configuration help improve transmission times for blockchain data throughout the network. Cardano stake pools may also distribute nodes geographically to help improve block propogation times. Some redundancy can help a stake pool respond automatically if a system failure occurs. For example, implementing a backup block-producing node may reduce the risk of a pool missing forging one or more blocks due to downtime.
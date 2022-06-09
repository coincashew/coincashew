# :cake: Checking Stake Pool Rewards

After the epoch is over and assuming you successfully minted blocks, check with this:

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query stake-address-info \
 --address $(cat stake.addr) \
 --mainnet
```
{% endtab %}
{% endtabs %}

Or simply lookup your pool on

* [ADApools](https://adapools.org)
* [PoolTool](https://pooltool.io)

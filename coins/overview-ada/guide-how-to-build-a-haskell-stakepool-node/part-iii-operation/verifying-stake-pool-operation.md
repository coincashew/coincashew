# Verifying Stake Pool Operation

Your stake pool ID can be computed with:

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway stake-pool id --cold-verification-key-file $HOME/cold-keys/node.vkey --output-format hex > stakepoolid.txt
cat stakepoolid.txt
```
{% endtab %}
{% endtabs %}

Copy **stakepoolid.txt** to your **hot environment.**

Now that you have your stake pool ID, verify it's included in the blockchain.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway query stake-snapshot --stake-pool-id $(cat stakepoolid.txt) --mainnet 
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
A non-empty string return means you're registered! :clap:
{% endhint %}

With your stake pool ID, now you can find your data on block explorers such as [https://pooltool.io/](https://pooltool.io)

{% hint style="success" %}
Congratulations! Your stake pool is included in the Cardano network and ready to produce blocks.
{% endhint %}

Currently, Input Output recommends the following stake pool configuration:

- At least two relay nodes that are registered on the blockchain
- One relay node that is NOT registered on the blockchain

When you finish testing that your stake pool successfully produces blocks, consider [future-proofing](../part-i-installation/prerequisites.md#futureproof) your stake pool.
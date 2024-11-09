# Verifying Stake Pool Operation

If you can successfully complete the following tasks, then your stake pool is registered on the blockchain:

- [Retrieving the Pool ID](#poolid)
- [Querying Stakes](#stakes)
- [Finding Your Pool Using a Block Explorer](#explorer)

## Retrieving the Pool ID<a href="#poolid" id="poolid"></a>

Compute your stake pool ID using the following command:

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway stake-pool id --cold-verification-key-file $HOME/cold-keys/node.vkey --output-format hex > stakepoolid.txt
cat stakepoolid.txt
```
{% endtab %}
{% endtabs %}

Copy **stakepoolid.txt** to your **hot environment.**

## Querying Stakes<a href="#stakes" id="stakes"></a>

Using your stake pool ID, at any time you can query the blockchain to display the stakes delegated to your pool using the following command:

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway query stake-snapshot --stake-pool-id $(cat stakepoolid.txt) --mainnet 
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
If the query returns results, then your stake pool is registered! :clap:
{% endhint %}

In the `pools` object in the JSON-formatted query results, the following keys display the stakes delegated to your pool, in Lovelace:

- `stakeGo` displays the stakes delegated to your pool in the previous epoch
- `stakeSet` displays the stakes delegated to your pool in the current epoch
- `stakeMark` displays the stakes currently delegated to your pool in the next epoch

## Finding Your Pool Using a Block Explorer<a href="#explorer" id="explorer"></a>

Using your stake pool ID, you can also find data for your pool on block explorers such as [https://pooltool.io/](https://pooltool.io)

## Conclusion

{% hint style="success" %}
Congratulations! Your stake pool is included in the Cardano network and is ready to produce blocks.
{% endhint %}

Currently, Input Output recommends the following stake pool configuration:

- At least two relay nodes that are registered on the blockchain
- One relay node that is NOT registered on the blockchain

When you finish testing that your stake pool successfully produces blocks, consider [future-proofing](../part-i-installation/prerequisites.md#futureproof) your stake pool.
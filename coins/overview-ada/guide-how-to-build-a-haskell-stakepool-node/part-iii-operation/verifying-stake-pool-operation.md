# :hatching\_chick: Verifying Stake Pool Operation

Your stake pool ID can be computed with:

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-pool id --cold-verification-key-file $HOME/cold-keys/node.vkey --output-format hex > stakepoolid.txt
cat stakepoolid.txt
```
{% endtab %}
{% endtabs %}

Copy **stakepoolid.txt **to your **hot environment.**

Now that you have your stake pool ID,  verify it's included in the blockchain.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query stake-snapshot --stake-pool-id $(cat stakepoolid.txt) --mainnet 
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
A non-empty string return means you're registered! :clap:&#x20;
{% endhint %}

With your stake pool ID, now you can find your data on block explorers such as [https://pooltool.io/](https://pooltool.io)
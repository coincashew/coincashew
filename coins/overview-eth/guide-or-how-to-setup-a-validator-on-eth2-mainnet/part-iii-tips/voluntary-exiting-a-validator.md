---
description: Remove a validator from staking duties.
---

# Voluntary Exiting a Validator

{% hint style="info" %}
Use this command to signal your intentions to stop validating with your validator. This means you no longer want to stake with your validator and want to turn off your node.

* **Timeline**: Voluntary exiting takes a minimum of 2048 epochs (or \~9days). There is a queue to exit and a delay before your validator is finally exited.
* **Consequences**: Once a validator is in exited state, it's non-reversible. You would need to re-key, or generate new validator keys to start staking again.
* **ETH Deposit**: In order to re-claim your 32ETH validator deposit and perform a full withdrawal, you must set the [0x01 withdrawal address.](../../update-withdrawal-keys-for-ethereum-validator-bls-to-execution-change-or-0x00-to-0x01-with-ethdo.md)
* **Responsibilities**: After your validator leaves the exit queue and is truly exited, it is safe to turn off your beacon node and validator.
{% endhint %}

{% tabs %}
{% tab title="Lighthouse" %}
```bash
lighthouse account validator exit \
--keystore $HOME/.lighthouse/mainnet/validators/<0x validator>/<keystore.json file> \
--beacon-node http://localhost:5052 \
--network mainnet
```
{% endtab %}

{% tab title="Teku" %}
```bash
teku voluntary-exit \
--epoch=<epoch number to exit> \
--beacon-node-api-endpoint=http://127.0.0.1:5051 \
--validator-keys=<path to keystore.json>:<path to password.txt file>
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
build/nimbus_beacon_node deposits exit --validator=<VALIDATOR_PUBLIC_KEY> --data-dir=/var/lib/nimbus
```
{% endtab %}

{% tab title="Prysm" %}
```bash
$HOME/prysm/prysm.sh validator accounts voluntary-exit --wallet-dir=$HOME/.eth2validators/prysm-wallet-v2
```
{% endtab %}

{% tab title="Lodestar" %}
Stop Lodestar validator

```
sudo systemctl stop validator
```



Run the voluntary exit command

<pre class="language-bash"><code class="lang-bash"><strong># change directories to binary folder
</strong><strong>cd $HOME/git/lodestar
</strong><strong>
</strong># the voluntary exit command
./lodestar validator voluntary-exit
</code></pre>



Restart validator

```
sudo systemctl restart validator
```
{% endtab %}
{% endtabs %}

#### Official reference documentation from each team can be found below:

* [Exiting a Teku validator](https://docs.teku.consensys.net/Reference/CLI/Subcommands/Voluntary-Exit)
* [Exiting a Prysm validator](https://docs.prylabs.network/docs/wallet/exiting-a-validator)
* [Exiting a Nimbus validator](https://nimbus.guide/voluntary-exit.html)
* [Exiting a Lodestar validator](https://chainsafe.github.io/lodestar/reference/cli/#validator-voluntary-exit)
* [Exiting a Lighthouse validator](https://lighthouse-book.sigmaprime.io/voluntary-exit.html)

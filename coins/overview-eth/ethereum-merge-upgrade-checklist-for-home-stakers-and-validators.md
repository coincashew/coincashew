---
description: Quick to-do list before the merge arrives.
---

# Ethereum Merge Upgrade Checklist for Home Stakers and Validators

{% hint style="success" %}
​:confetti\_ball: **Support us on Gitcoin Grants:** [We improve this guide with your support!](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew)🙏
{% endhint %}

{% hint style="info" %}
The following steps align with our [mainnet guide](guide-or-how-to-setup-a-validator-on-eth2-mainnet/). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

## Wen merge?&#x20;

* All testnets passed and the [Merge is a go on mainnet](https://blog.ethereum.org/2022/08/24/mainnet-merge-announcement/) officially as of August 24, 2022!&#x20;
* [Mainnet merge occurs in two sequential upgrades. ](https://blog.ethereum.org/2022/08/12/finalized-no-36/)
  * _**`[2022/09/06 11:34:47am UTC]`**_ – Bellatrix Mainnet upgrade
  * _**`[Estimated: 2022/9/15]`**_ – Paris Mainnet Merge transition
* Paris Mainnet merge transition is estimated to arrive on [Sept 15 2022 with TTD 58750000000000000000000](https://twitter.com/TimBeiko/status/1557747656507633665).

{% hint style="danger" %}
All stakers _**must**_ upgrade to EL+CL Merge-ready nodes before September 6th!
{% endhint %}

## What's merge?

![Enough said](../../.gitbook/assets/meme-merge.jpg)

## How to merge?

**Prerequisite:** Before beginning, there is a mandatory requirement to run your own Execution Layer (EL) client (i.e. besu, geth, nethermind, erigon).

{% hint style="warning" %}
Outsourcing EL/eth1 to Infura is no longer possible post merge. Run your own.
{% endhint %}

#### In order to transition through the merge successfully, your validator node must:

1\) Update to latest EL / CL node software

2\) Create a jwtsecret file

3\) Update startup commands with the following:

* Set your suggested fee recipient address
* Enable the authenticated port to the new Engine API

### 1) Update to latest EL / CL node software

First start by updating your system.

```
sudo apt -y update && sudo apt -y upgrade
```

Next, follow the instructions for [updating EL](guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/updating-your-execution-client.md) or [updating CL](guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/updating-your-consensus-client.md), or your node's official documentation.

Here are the Merge-Ready versions you require:

**Consensus Layer**

| Name       | Version | Link                                                                      |
| ---------- | ------- | ------------------------------------------------------------------------- |
| Lighthouse | v3.1.0  | [Download](https://github.com/sigp/lighthouse/releases/tag/v3.1.0)        |
| Lodestar   | v1.0.0  | [Download](https://github.com/ChainSafe/lodestar/releases/tag/v1.0.0)     |
| Nimbus     | v22.9.0 | [Download](https://github.com/status-im/nimbus-eth2/releases/tag/v22.9.0) |
| Prysm      | v3.1.0  | [Download](https://github.com/prysmaticlabs/prysm/releases/tag/v3.1.0)    |
| Teku       | 22.9.0  | [Download](https://github.com/ConsenSys/teku/releases/tag/22.9.0)         |

**Execution Layer**

| Name               | Version           | Link                                                                        |
| ------------------ | ----------------- | --------------------------------------------------------------------------- |
| Besu               | 22.7.2            | [Download](https://github.com/hyperledger/besu/releases/tag/22.7.2)         |
| Erigon             | v2022.09.01-alpha | [Download](https://github.com/ledgerwatch/erigon/releases/tag/v2022.09.01)  |
| go-ethereum (geth) | v1.10.23          | [Download](https://github.com/ethereum/go-ethereum/releases/tag/v1.10.23)   |
| Nethermind         | v1.14.1           | [Download](https://github.com/NethermindEth/nethermind/releases/tag/1.14.1) |

### 2) Create a jwtsecret file

{% hint style="info" %}
This new jwtsecret file contains a hexadecimal string that is passed to both Execution Layer client and Consensus Layer clients, and is used to ensure authenticated communications between both clients.
{% endhint %}

```bash
#store the jwtsecret file at /secrets
sudo mkdir -p /secrets

#create the jwtsecret file
openssl rand -hex 32 | tr -d "\n" | sudo tee /secrets/jwtsecret

#enable read access
sudo chmod 644 /secrets/jwtsecret
```

### 3) Update startup commands

Updates to your systemd file for the consensus layer, execution layer, or validator will be required to support the following new merge options:

* Set your suggested fee recipient address
* Enable the authenticated port to the new Engine API

Ensure you add/append the changes to the **END** of the `ExecStart` line.

To exit and save from the `nano` editor, press `Ctrl` + `X`, then `Y`, then`Enter`.

{% hint style="info" %}
The fee recipient address receives block proposal priority fees (aka mining tips) and is an ETH address you designate as your rewards address. These rewards are immediately spendable, unlike the validator's attestation and block proposal rewards.
{% endhint %}

{% hint style="danger" %}
Change **0x\_CHANGE\_THIS\_TO\_MY\_ETH\_FEE\_RECIPIENT\_ADDRESS**, your fee recipient address to an ETH address you control.
{% endhint %}

{% hint style="warning" %}
For advanced fee recipient configurations, i.e. you want a unique ETH address per validator for privacy reasons, refer to the official documents at: [Teku](https://docs.teku.consensys.net/en/latest/HowTo/Prepare-for-The-Merge/#configure-the-fee-recipient) | [Lighthouse](https://lighthouse-book.sigmaprime.io/suggested-fee-recipient.html) | [Nimbus](https://nimbus.guide/suggested-fee-recipient.html) | [Prysm](https://docs.prylabs.network/docs/execution-node/fee-recipient) | [Lodestar](https://chainsafe.github.io/lodestar/usage/validator-management/#configuring-the-fee-recipient-address)
{% endhint %}

#### Location of system service files to update

{% tabs %}
{% tab title="CoinCashew" %}
```
# Consensus Client:
sudo nano /etc/systemd/system/beacon-chain.service

# Validator Client:
sudo nano /etc/systemd/system/validator.service

# Execution Client:
sudo nano /etc/systemd/system/eth1.service
```
{% endtab %}

{% tab title="SomerEsat" %}
{% hint style="info" %}
For reference purposes only. Recommend refer to the official SomerEsat Merge Updates when available.
{% endhint %}

```
# Nimbus
sudo nano /etc/systemd/system/nimbus.service

# Prysm
sudo nano /etc/systemd/system/prysmvalidator.service
sudo nano /etc/systemd/system/prysmbeacon.service

# Lighthouse
sudo nano /etc/systemd/system/lighthousevalidator.service
sudo nano /etc/systemd/system/lighthousebeacon.service

# Teku
sudo nano /etc/systemd/system/teku.service

# Geth EL
sudo nano /etc/systemd/system/geth.service
```
{% endtab %}
{% endtabs %}

**Consensus Client Layer Changes (beacon chain)**

{% tabs %}
{% tab title="Lighthouse" %}
```
--execution-endpoint http://127.0.0.1:8551 --execution-jwt /secrets/jwtsecret
```
{% endtab %}

{% tab title="Teku" %}
If your Teku client is configured by passing in a **TOML file (i.e. teku.yaml),** edit `teku.yaml` with nano.

```
sudo nano /etc/teku/teku.yaml
```



Add the following lines to the yaml file:

```
# execution engine
ee-endpoint: http://localhost:8551
ee-jwt-secret-file: "/secrets/jwtsecret"

# fee recipient
validators-proposer-default-fee-recipient: "<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>"
```



Alternatively, if your Teku client is configured by --parameters in the **systemd service file,** add the following changes.

```
--ee-endpoint http://localhost:8551 --ee-jwt-secret-file "/secrets/jwtsecret" --validators-proposer-default-fee-recipient 0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS
```



{% hint style="info" %}
Use one configuration or the other but not both!
{% endhint %}
{% endtab %}

{% tab title="Lodestar" %}
```
--jwt-secret /secrets/jwtsecret --execution.urls http://127.0.0.1:8551 --suggestedFeeRecipient 0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS
```
{% endtab %}

{% tab title="Nimbus" %}
```
--web3-url=ws://127.0.0.1:8551 --jwt-secret="/secrets/jwtsecret" --suggested-fee-recipient=0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS
```
{% endtab %}

{% tab title="Prysm" %}
```
--execution-endpoint=http://localhost:8551 --jwt-secret=/secrets/jwtsecret --suggested-fee-recipient=0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS
```
{% endtab %}
{% endtabs %}

**Validator Client Changes**

{% tabs %}
{% tab title="Lighthouse" %}
```
--suggested-fee-recipient 0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS
```
{% endtab %}

{% tab title="Teku" %}
Only if running in validator in a separate client

```
--validators-proposer-default-fee-recipient=0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS
```
{% endtab %}

{% tab title="Lodestar" %}
```
--suggestedFeeRecipient 0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS
```
{% endtab %}

{% tab title="Nimbus" %}
Runs in consensus client, not needed.
{% endtab %}

{% tab title="Prysm" %}
```
--suggested-fee-recipient 0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS
```
{% endtab %}
{% endtabs %}

**Execution Client Layer Changes (eth1)**

{% tabs %}
{% tab title="Besu" %}
If your Besu client is configured by --parameters in the **systemd service file,** add the following changes.

```
--engine-jwt-secret=/secrets/jwtsecret
```



Alternatively, if your Besu client is configured by passing a **TOML file (i.e. besu.yaml),** edit `besu.yaml` with nano.

```
sudo nano /etc/besu/besu.yaml
```



Add the following line:

```
engine-jwt-secret="/secrets/jwtsecret"
```



{% hint style="info" %}
Use one configuration or the other, but not both!
{% endhint %}
{% endtab %}

{% tab title="Geth" %}
```
--authrpc.jwtsecret=/secrets/jwtsecret
```
{% endtab %}

{% tab title="Erigon" %}
```
--authrpc.jwtsecret=/secrets/jwtsecret
```
{% endtab %}

{% tab title="Nethermind" %}
```
--JsonRpc.Host=127.0.0.1 --JsonRpc.JwtSecretFile=/secrets/jwtsecret
```
{% endtab %}
{% endtabs %}

After adding the above startup commands, reload and restart your services.

```
sudo systemctl daemon-reload
sudo systemctl restart eth1 beacon-chain validator
```

Verify your logs look error-free and show use of the new configurations.

```
journalctl -fu eth1
journalctl -fu beacon-chain
journalctl -fu validator
```

Verify your validator is still attesting properly by checking an public block explorer such as beaconcha.in

{% hint style="success" %}
Congrats! Your node should be merge ready now. Stay tuned to the latest news.
{% endhint %}

## Post-Merge Cleanup and To-Dos

We've made it to a post-merge era! Consider the following changes to your startup commands.

* Remove `--eth1-endpoints` , as the execution engine endpoint is now in use. Not removing this may cause extra chatter in logs.
* Remove any Infura or backup beacon-chain CL references.
* If your EL and CL are on separate machines, update your firewall. Port 8551 is now used instead of 8545.

## Optional - Extra #TestingTheMerge

Can't get your mind off the merge? Here's some additional ideas and nice to haves.

\[:white\_check\_mark:] Test your merge configurations on Goerli testnet

\[:white\_check\_mark:] Improve [Client Diversity](https://clientdiversity.org/)

* Switch to a minority EL - suggestion: Use besu as "minority client". Besu features auto pruning.&#x20;
* Switch to a minority CL

\[:white\_check\_mark:] Configure MetaMask to use your own node. Bye Infura outages.

\[:white\_check\_mark:] Upgrade node storage to 2TB+&#x20;

\[:white\_check\_mark:] Prune your EL node

\[:white\_check\_mark:] Upgrade Grafana reporting with [samc's ethereum metrics exporter](https://github.com/samcm/ethereum-metrics-exporter)

\[:white\_check\_mark:] Test / dev / deploy code on the testnets

\[:white\_check\_mark:] Learn and earn more rewards with [MEV-boost](https://github.com/flashbots/mev-boost)


---
description: >-
  Empowered, inspired, home staker. Free. Open source. Public goods for
  Ethereum. ARM64 and AMD64 support. Lido CSM Compatible. Jumpstart your ETH
  solo-staking / Lido CSM journey.
---

# 🛡️ EthPillar: one-liner setup tool and node management TUI

{% hint style="danger" %}
DOCUMENTATION HAS MOVED TO > [https://docs.coincashew.com/ethpillar](https://docs.coincashew.com/ethpillar)

Below is for historical reference purposes only.
{% endhint %}











<figure><img src="../../.gitbook/assets/EthPillar.final.png" alt=""><figcaption></figcaption></figure>

{% hint style="success" %}
#### Do you like this software? Star the project and become a [⭐ Stargazer](https://github.com/coincashew/ethpillar/stargazers)
{% endhint %}

## :arrow\_forward: Quickstart: Ubuntu One-liner Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/coincashew/EthPillar/main/install.sh)"
```

{% hint style="success" %}
**Important Safety Best Practice:** Avoid downloading untrusted scripts. Unverified code may pose security risks. Double-check the script or ask someone trusted for verification. Only install after confirming its authenticity.
{% endhint %}

## :new: What is EthPillar?

:smile: **Friendly Node Installer**: Helps you deploy a systemd installation with minority clients Nimbus-Nethermind or Teku-Besu stack in just minutes. MEVboost included.

:floppy\_disk: **Ease of use**: No more remembering CLI commands required. Access common node operations via a simple text user interface (TUI).

:owl: **Fast Updates**: Quickly find and download the latest consensus/execution release. Less downtime!

:tada:**Compatibility**: Behind the scenes, node commands and file structure are identical to V2 staking setups.&#x20;

{% hint style="warning" %}
Already a running a Validator? EthPillar is compatible with [a Coincashew V2 Staking Setup.](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet)&#x20;
{% endhint %}

## :fire: Features

:chains: **Hoodi and Ephemery Testnet Support**: Quickest and easiest way run a node now, risk free. Learn and practice here before moving to mainnet.

:droplet: **Lido CSM Integration**: Deploys in minutes and start staking via [Lido's CSM with as little as 2.4 ETH](https://csm.testnet.fi/?ref=ethpillar).

:tools: **Plugins and Tools**: Node-checker, eth-validator-cli, Dora the lightweight block explorer, contributoor, Ethdo, client-stats, csm-sentinel and eth-duties Integration helps stakers with every day common tasks.

:bacon: **Grafana and Ethereum-Metrics-Exporter Integration:** Monitoring and dashboards has never been easier.

:mag\_right:  **Built-in Troubleshooting:** Find common issues preventing your node from it's peak performance. Discover EthPillar's built-in Node Checker which checks for common system issues.

:tada: **Multiple deployment configurations:** Deploy a Solo Staking Node, Full Node Only, Lido CSM Staking Node, Validator Client Only or Failover Staking Node.

## :sunglasses: Preview

<figure><img src="../../.gitbook/assets/1menu.png" alt=""><figcaption><p>Main Menu</p></figcaption></figure>



<div><figure><img src="../../.gitbook/assets/2ec.png" alt=""><figcaption><p>Execution Client</p></figcaption></figure> <figure><img src="../../.gitbook/assets/3cl.png" alt=""><figcaption><p>Consensus Client</p></figcaption></figure> <figure><img src="../../.gitbook/assets/4vc.png" alt=""><figcaption><p>Validator</p></figcaption></figure></div>

<figure><img src="../../.gitbook/assets/6tool.png" alt=""><figcaption><p>Tools</p></figcaption></figure>



<div><figure><img src="../../.gitbook/assets/7plug.png" alt=""><figcaption><p>Plugins</p></figcaption></figure> <figure><img src="../../.gitbook/assets/8mev.png" alt=""><figcaption><p>Mevboost</p></figcaption></figure> <figure><img src="../../.gitbook/assets/5sa.png" alt=""><figcaption><p>System Administration</p></figcaption></figure></div>



## :tada: Speedrun Demo by Stakesaurus

{% embed url="https://www.youtube.com/watch?v=aZLPACj2oPI" %}

## :whale: Prerequisites

* Study [Ethstaker's Staking for Beginners](https://www.reddit.com/r/ethstaker/wiki/staking_for_beginners/)
* [Review how staking works and the hardware requirements](guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/prerequisites.md)
* A Linux [Ubuntu](https://ubuntu.com/download) installation.&#x20;
  * Tested with [Ubuntu 24.04 LTS](https://ubuntu.com/download) Server
  * Also appears compatible with [armbian](https://www.armbian.com/download/), [Linux Mint](https://www.linuxmint.com/), [Debian 12](https://www.debian.org/distrib/netinst)
  * Support for **AMD64 and ARM64** architecture
  * Recommend at least 16GB RAM for **ARM64** sbc

## :triangular\_ruler: Option 1: Automated One-Liner Install

Open a terminal window from anywhere by typing `Ctrl+Alt+T`.&#x20;

To install, paste the following:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/coincashew/EthPillar/main/install.sh)"
```

## :handshake: Option 2: Manual Install

**Install updates and packages:**

```bash
sudo apt-get update && sudo apt-get install git curl ccze bc tmux jq nano btop whiptail ufw
```

**Clone the ethpillar repo and install:**

```bash
mkdir -p ~/git/ethpillar
git clone https://github.com/coincashew/ethpillar.git ~/git/ethpillar
sudo ln -s ~/git/ethpillar/ethpillar.sh /usr/local/bin/ethpillar
```

#### Run ethpillar:

```bash
ethpillar
```

## :tada:Next Steps

{% hint style="success" %}
Congrats on installing a EthPillar, making nodes and home staking easier!
{% endhint %}

<details>

<summary>All types of node operators: Solo staking, Full node, CSM Staking Node</summary>

**Step 1: Configure your network, port forwarding and firewall.**&#x20;

* With EthPillar, configuration can be changed at:
  * **Tools > UFW Firewall > Enable firewall with default settings**
  * Port forwarding is [manually configured](guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/step-2-configuring-node.md#configure-port-forwarding), depending on your router.
  * Confirm port forwarding is working with **Tools** > **Port Checker**
* Alternatively configure manually per the manual guide. [Click here for detailed network configuration.](guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/step-2-configuring-node.md#network-configuration)

**Step 2: Configure your BIOS to auto power on after power loss**

Actual steps vary depending on your computer's BIOS. General idea here: [https://www.wintips.org/setup-computer-to-auto-power-on-after-power-outage/](https://www.wintips.org/setup-computer-to-auto-power-on-after-power-outage/)

**Step 3: Enable Monitoring and Alerts (Optional)**

Found under:

* **Tools** > **Monitoring**

**Step 4: Benchmark your node (Optional)**

Ensure your node has sufficient CPU/disk/network performance.

* **Tools** > **Yet-Another-Bench-Script**

</details>

<details>

<summary>Lido CSM Staking Node Operators</summary>

**Step 1: Generate Validator Keys:**

* Generate new CSM validator keys for the Lido withdrawal vault
* `Ethpillar > Validator Client > Generate / Import Validator Keys`

**Step 2: Upload JSON Deposit Data:**

* Upload the newly generated deposit data file for your CSM keystores to the Lido CSM Widget. [CSM Holesky](https://csm.testnet.fi/?ref=ethpillar) or [CSM Mainnet](https://csm.lido.fi/?ref=ethpillar)
* Provide the required bond amount in ETH/stETH/wstETH.

**Step 3: Monitor Validator Key Deposit:**

* Wait for your CSM validator keys to be deposited by Lido.&#x20;
* Ensure your node remains online during the process.

</details>

<details>

<summary>Additional steps for Solo Stakers</summary>

**Step 1: Setup Validator Keys**

* Familarize yourself with the main guide's section on [setting up your validator keys.](guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/step-5-installing-validator/setting-up-validator-keys.md)
* When ready to generate your keys, go to **EthPillar > Validator Client > Generate / Import Validator Keys**

**Step 2: Upload deposit\_data.json to Launchpad**

* To begin staking on Ethereum as a validator, you need to submit to the Launchpad your  deposit\_data.json file, which includes crucial withdrawal address details, and pay the required deposit of 32ETH per validator.

**Step 3: Congrats!**&#x20;

* Now you're waiting in the Entry Queue [https://www.validatorqueue.com](https://www.validatorqueue.com/)

- Check out the [next steps from the main guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/step-5-installing-validator/next-steps) for further knowledge. Especially the FAQ's "Wen staking rewards?"

</details>

## :question: FAQ

<details>

<summary>Change Networks: How to switch between testnet and mainnet with EthPillar ?</summary>

To switch to mainnet, there are two recommended methods.

* **Cleanest and most problem-free option**: Reformat Ubuntu OS and re-install EthPillar.&#x20;

- **Use EthPillar:** Navigate to **System Administration > Change Network**

</details>

<details>

<summary>Exit Validator: How do I exit a validator?</summary>

If you already have VEMs created, skip to step 2.

Step 1: Navigate to EthPillar > Validator > Generate Voluntary Exit Message

Step 2: Broadcast Voluntary Exit Message

</details>

<details>

<summary>Add Validators: I already have validators running. I want to add one more validator. How do I do that?</summary>

Navigate to,

**EthPillar > Validator Client > Generate / Import Validator Keys**

From there you will pick 1 of 2 options.

* Import validator keys from offline key generation or backup
* Add new or regenerate existing validator keys from Secret Recovery Phrase

</details>

<details>

<summary>Node Types: What is a failover staking node?</summary>

**Purpose**: To provide high availability, you would run TWO (or more) failover staking nodes on separate machines. Point your validator client to your two failover staking nodes.

**What**: A failover staking node is made up of an execution client, consensus client and mevboost.

**How to**: To configure for nimbus validator client, edit your validator client configuration. [https://nimbus.guide/validator-client-options.html#multiple-beacon-nodes](https://nimbus.guide/validator-client-options.html#multiple-beacon-nodes)

Exposing the consensus client RPC port will also be required. You will need to adjust your firewall to allow traffic from your validator client's IP address as well.

**Benefit**: Running multiple failover staking nodes (or beacon nodes as nimbus refers to it) would allow you to perform maintenance or have an outage on 1 failover staking node.

</details>

<details>

<summary>Withdrawal Address: Can I have different withdraw addresses per validator or only 1 per setup?</summary>

Different withdrawal addresses per validator are possible if you run the ./deposit tool separately for each validator.

</details>

<details>

<summary>Generating Keystores: Can I generate 10 validator keystores and activate them one by one at the launchpad?</summary>

You can but it would require manual editing as you'll need to change the deposit\_data json.

</details>

<details>

<summary>Migrate or Upgrade Staking Setup: How to switch to EthPillar from a V1 Staking setup or other staking tool</summary>

To migrate from a different staking setup, find your most applicable situation:

**Cleanest and most problem-free option**:&#x20;

* 1\) Reformat Ubuntu Operating System
* 2\) Install EthPillar
* 3\) Import validator keys

**Existing V1 Staking Setup:** OGs and genesis stakers :saluting\_face:

* 1\) [Uninstall V1 Staking Setup](archived-guides/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/uninstalling-v1-staking-node.md)
* 2\) Install EthPillar
* 3\) Import validator keys

**Other staking automation tools or cloud hosted setups:**&#x20;

* 1\) Uninstall / cancel / existing tool or service provider
* 2\) Install EthPillar
* 3\) Import validator keys

:white\_check\_mark: **To avoid slashing penalties**, ensure your validator keys are deleted from existing staking setups.

</details>

## :telephone: Get in touch

Have questions? Chat with other home stakers on [Discord](https://discord.gg/dEpAVWgFNB) or open PRs/issues on [Github](https://github.com/coincashew/ethpillar).&#x20;

Open source source code available here: [https://github.com/coincashew/EthPillar](https://github.com/coincashew/EthPillar)

## :heart: Donations

If you'd like to support this public goods project, find us on the next Gitcoin Grants.

Our donation address is [0xCF83d0c22dd54475cC0C52721B0ef07d9756E8C0](https://etherscan.io/address/0xCF83d0c22dd54475cC0C52721B0ef07d9756E8C0) or coincashew.eth

## :ballot\_box\_with\_check: How to Update

{% tabs %}
{% tab title="TUI Update" %}
Upon opening EthPillar,

* Navigate to **System Administration > Update EthPillar** and then quit and relaunch.
{% endtab %}

{% tab title="Manual Update" %}
From a terminal, pull the latest updates from git.

```bash
cd ~/git/ethpillar
git pull
```
{% endtab %}
{% endtabs %}

## :star2:Contribute

We appreciate any help! To join in:

* Star the project on [GitHub](https://github.com/coincashew/EthPillar).
* Share the project on X or reddit. Talk about your experiences with solo staking.
* Provide feedback on [Github](https://github.com/coincashew/EthPillar/issues).
* [Submit PRs](https://github.com/coincashew/EthPillar/pulls) to improve the code.

## :tada: Credits

Shout out to [accidental-green](https://github.com/accidental-green/validator-install) for their pioneering work in Python validator tools, which has unintentionally ignited the inspiration and direction for this project. We are building upon their innovative foundations by forking their validator-install code. A heartfelt thanks to accidental-green for their game-changing contributions to the open-source Ethereum ecosystem!

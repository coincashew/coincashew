# Step 1: Prerequisites

## :woman\_technologist:Skills for operating an staking node

As a validator for Ethereum, you will typically have the following abilities:

* operational knowledge of how to set up, run and maintain a Ethereum consensus client, execution client and validator continuously
* a long term commitment to maintain your validator 24/7/365
* basic operating system skills

## :man\_technologist: Experience required to be a successful ETH Staker

* have learned the essentials by watching ['Intro to Eth2 & Staking for Beginners' by Superphiz](https://www.youtube.com/watch?v=tpkpW031RCI)
* have passed or is actively enrolled in the [Eth2 Study Master course](https://ethereumstudymaster.com)
* and have read the [8 Things Every Eth2 validator should know.](https://medium.com/chainsafe-systems/8-things-every-eth2-validator-should-know-before-staking-94df41701487)

## :reminder\_ribbon: **Minimum Node Setup Requirements**

* **Operating system:** 64-bit Linux (i.e. Ubuntu 22.04.1 LTS Server or Desktop)
* **Processor:** Dual core CPU, Intel Core i5–760 or AMD FX-8100 or better
* **Memory:** 16GB RAM
* **Storage:** 1TB SSD for testnet
* **Internet:** Stable broadband internet connection with speeds at least 5 Mbps upload and download.
* **Internet Data Plan**: At least 2 TB per month.
* **Power:** Reliable electrical power. Mitigate with a [Uninterruptible Power Supply (UPS)](https://www.lifewire.com/best-uninterrupted-power-supplies-4142625).
* **ETH balance:** at least 32 ETH and some ETH for deposit transaction fees
* **Wallet**: Metamask installed

## :man\_lifting\_weights: Recommended Node Setup Requirements

{% hint style="info" %}
Once done with testnet staking, this hardware configuration would be suitable for a mainnet staking node.
{% endhint %}

* **Operating system:** 64-bit Linux (i.e. Ubuntu 22.04.1 LTS Server or Desktop)
* **Processor:** Quad core CPU, Intel Core i7–4770 or AMD FX-8310 or better
* **Memory:** 32GB RAM
* **Storage:** 2TB NVME
* **Internet:** Stable broadband internet connections with speeds at least 10 Mbps without data limit.
* **Data Plan**: At least 2 TB per month. Ideally, no data cap or unlimited data plan.
* **Power:** Reliable electrical power with a [Uninterruptible Power Supply (UPS)](https://www.lifewire.com/best-uninterrupted-power-supplies-4142625).
* **ETH balance:** at least 32 ETH and some ETH for deposit transaction fees
* **Wallet**: Metamask installed

{% hint style="info" %}
:bulb: For examples of actual staking hardware builds, check out [RocketPool's hardware guide](https://github.com/rocket-pool/docs.rocketpool.net/blob/main/src/guides/node/local/hardware.md).
{% endhint %}

{% hint style="success" %}
:sparkles: **Pro Validator Tip**: Highly recommend you begin with a brand new instance of an OS, VM, and/or machine. Avoid headaches by NOT reusing testnet keys, wallets, or databases for your validator.
{% endhint %}

## :desktop: Local Node vs Remote Node

**Decision**: Do I run my Ethereum staking node locally at home or rent a VPS cloud server remotely? Here's a list of criteria to help you decide.

|       Criteria       | Local Node                                                                                                                                         | Remote Node                                                                                                                                          |
| :------------------: | -------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Ongoing Costs    | Plus - No fees, besides internet bill and electricity.                                                                                             | Minus - Monthly or Annual reoccurring rental fees.                                                                                                   |
| Hardware Maintenance | Minus - Do it yourself if hardware issues.                                                                                                         | Plus - Included, covered by hosting provider.                                                                                                        |
|       Internet       | Minus - Can slow down home internet and use up data plan (if not unlimited) Budget for at least 2TB per month data plan.                           | Plus - Often plans are generous and more than sufficient for an ETH node.                                                                            |
|      Reliability     | Minus - Do it yourself with UPS, redundant internet connections, computer issues                                                                   | Plus - Hosted in a data center with multiple power/internet backups.                                                                                 |
|   Barrier to Entry   | <p>Plus - Can re-use or re-purpose existing hardware<br><br>Minus - Initial cost to purchase new computer equipment</p>                            | Plus - Renting a VPS might require a lower initial investment as you can pay monthly.                                                                |
|   Decentralization   | Plus - Home staking is the **gold standard** for Ethereum decentralization, nothing bets it!                                                       | Minus - VPS cloud hosts like [Netcup](https://www.netcup.eu/bestellen/produkt.php?produkt=3026) or AmazonWebServices are by nature more centralized. |
|     Customization    | Plus - More fine control over hardware configuration                                                                                               | Minus - May be limited choices and hardware can be shared. For example, a common issue is insufficient disk storage I/O speeds (IOPS).               |
|       Security       | Plus - As secure as your home and personal [OPSEC](https://en.wikipedia.org/wiki/Operations\_security)                                             | Minus - Not your hardware, not your node. It's possible the hosting provide can view your node's contents.                                           |
|        Freedom       | <p>Plus - Do whatever you want. Plan your own upgrades.<br><br>Minus - With great freedom and power, you are solely responsible for your node.</p> | <p>Plus - Professional managed.</p><p><br>Minus - At the mercy of the host's actions, data center outages are possible.</p>                          |

## :tools: Setup Ubuntu

With your local or remote node, now you need to install an Operating System. This guide is designed for Ubuntu 22.04.1 LTS.

* To install **Ubuntu Server**, refer to [this guide.](https://ubuntu.com/tutorials/install-ubuntu-server#1-overview)
* To install **Ubuntu Desktop**, refer to [this guide.](https://www.coincashew.com/coins/overview-xtz/guide-how-to-setup-a-baker/install-ubuntu)

{% hint style="info" %}
**Recommendation**: A headless (no monitor) install of **Ubuntu Server** on a **dedicated** NUC/laptop/desktop/VPS is best for ease of reliability and security.  :fire: Do not use this system for email/browsing web/gaming/socials. :fire:
{% endhint %}

{% hint style="warning" %}
**Tip**: When installing Ubuntu Server, ensure you are selecting “**Use an entire disk**” on the **Guided storage configuration** screen. Next screen will be the **Storage configuration** screen, ensure your settings are using all available disk storage. A [common issue](../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-iii-tips/using-all-available-lvm-disk-space.md) is that Ubuntu server defaults to using only 200GB.
{% endhint %}

## :performing\_arts: Setup Metamask

When the time comes to make your validator's 32ETH deposit(s), you'll need a wallet to transfer funds to the beacon chain deposit contract.

* To install Metamask, refer to [this guide.](https://www.coincashew.com/wallets/browser-wallets/metamask-ethereum)

## :jigsaw: High Level Validator Node Overview

{% hint style="info" %}
At the end of this guide, you will build a staking validator node that hosts three main components in two layers: consensus layer consists of a consensus client, also known as a validator client with a beacon chain client. The execution layer consists of a execution client, formerly a eth1 node.

**Validator client** - Responsible for producing new blocks and attestations in the beacon chain and shard chains.

**Beacon chain client** - Responsible for managing the state of the beacon chain, validator shuffling, and more.

**Execution client (aka Eth1 node)** - Supplies incoming validator deposits from the eth mainnet chain to the beacon chain client.
{% endhint %}

![How eth2 fits together featuring Leslie the eth2 Rhino, the mascot named after American computer scientist Leslie Lamport](../../../.gitbook/assets/eth2network.png)

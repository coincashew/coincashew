# Prerequisites

## :man\_mage: Mandatory skills for stake pool operators

As a stake pool operator for Cardano, you must be competent with the following abilities:

* Operational knowledge of how to set up, run and maintain a Cardano node continuously
* A commitment to maintain your node 24/7/365
* System operation skills including general knowledge of using [Bash scripts](https://linuxconfig.org/bash-scripting-tutorial-for-beginners), [cron jobs](https://itsfoss.com/cron-job/) and [systemd](https://systemd.io/) services
* Server administration skills (operational and maintenance)

## :mage: Mandatory experience for stake pool operators

* Experience of development and operations (DevOps)
* Experience on how to [harden ](https://www.lifewire.com/harden-ubuntu-server-security-4178243)and [secure a server](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3).
* In the [Cardano Developer Portal](https://developers.cardano.org/docs/get-started/), successfully complete the section [Operate a Stake Pool](https://developers.cardano.org/docs/operate-a-stake-pool/) including the [Stake Pool Course](https://developers.cardano.org/docs/stake-pool-course/) 

{% hint style="danger" %}
:octagonal\_sign: **Before continuing this guide, you must satisfy the above requirements**. :construction:
{% endhint %}

## :reminder\_ribbon: Minimum Stake Pool Hardware Requirements

* **Two separate servers**: 1 for block producer node, 1 for relay node
* **One air-gapped offline machine (cold environment)**
* **Operating system**: 64-bit Linux (i.e. Ubuntu Server 20.04 LTS)
* **Processor:** An Intel or AMD x86 processor with two or more cores, at 2GHz or faster
* **Memory:** 12GB of RAM
* **Storage:** 50GB of free storage
* **Internet:** Broadband internet connection with speeds at least 10 Mbps.
* **Data Plan**: at least 1GB per hour. 720GB per month.
* **Power:** Reliable electrical power
* **ADA balance:** at least 505 ADA for pool deposit and transaction fees

## :man\_lifting\_weights: Recommended Future-proof Stake Pool Hardware Setup

* **Three separate servers**: 1 for block producer node, 2 for relay nodes
* **One air-gapped offline machine (cold environment)**
* **Operating system**: 64-bit Linux (i.e. Ubuntu 20.04 LTS)
* **Processor:** 4 core or higher CPU
* **Memory**: 16GB+ of RAM
* **Storage**: 256GB+ SSD
* **Internet**: Broadband internet connections with speeds at least 100 Mbps
* **Data Plan**: Unlimited
* **Power:** Reliable electrical power with UPS
* **ADA balance**: more pledge is better, to be determined by **a0**, the pledge influence factor

## :unlock: Recommended Stake Pool Security

If you need ideas on how to harden your stake pool's nodes, refer to [this guide](hardening-an-ubuntu-server.md).

## :tools: Setup Ubuntu

If you need to install **Ubuntu Server**, refer [to this guide.](https://ubuntu.com/tutorials/install-ubuntu-server#1-overview)

For instructions on installing **Ubuntu Desktop**, refer [to this guide.](https://www.coincashew.com/coins/overview-xtz/guide-how-to-setup-a-baker/install-ubuntu)

## :bricks: Rebuilding Nodes

If you are rebuilding or reusing an existing `cardano-node` installation, refer to the section [Resetting an Installation](../part-v-tips/resetting-an-installation.md).

# Prerequisites

Operating a stake pool in a Cardano [Testnet Environment](https://docs.cardano.org/cardano-testnets/environments) prior to registering a stake pool in the Mainnet production environment offers a risk-free approach to start learning practically about the technical skills, commitment, responsibilities and benefits of operating a Cardano stake pool.

When operating a stake pool on Mainnet, using a Testnet environment to test configuration changes and upgrades as well as troubleshoot any issues that may arise without impacting the production environment is very helpful.

While explaining how to implement a stake pool on Mainnet, The _How to Set Up a Cardano Stake Pool_ guide also includes instructions throughout describing how to configure a stake pool to operate in a Testnet environment.

## :man\_mage: Mandatory Skills for Stake Pool Operators

As a Stake Pool Operator (SPO) for Cardano, you need:

* Operational knowledge of how to set up, run and maintain a Cardano node continuously
* A commitment to maintain your node 24/7/365
* System operation skills including general knowledge of [Linux](https://linuxjourney.com/), [Bash scripting](https://linuxconfig.org/bash-scripting-tutorial-for-beginners), [JavaScript Object Notation (JSON) format](https://attacomsian.com/blog/what-is-json?msclkid=0445ae34ce4d11ec84216d09187b5112), [systemd services](https://linuxconfig.org/how-to-create-systemd-service-unit-in-linux) and [cron jobs](https://itsfoss.com/cron-job/)
* Server administration skills (operational and maintenance)
* Fundamental understanding of [networking](https://www.ibm.com/cloud/learn/networking-a-complete-guide)

## :mage: Mandatory Experience for Stake Pool Operators

* Experience of development and operations (DevOps)
* Experience in how to [harden ](https://www.lifewire.com/harden-ubuntu-server-security-4178243)and [secure a server](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3).
* In the [Cardano Developer Portal](https://developers.cardano.org/docs/get-started/), successfully complete the section [Operate a Stake Pool](https://developers.cardano.org/docs/operate-a-stake-pool/)

{% hint style="danger" %}
:octagonal\_sign: **Before continuing this guide, you must satisfy the above requirements**. :construction:
{% endhint %}

## :reminder\_ribbon: Minimum Mainnet Stake Pool Hardware and Operating Requirements

* **Two separate servers**: 1 block producer node, 1 registered relay node
* **One air-gapped offline computer (cold environment)**
* **Operating system**: 64-bit Linux (i.e. Ubuntu 22.04 LTS)
* **Processor:** An Intel or AMD x86 processor with two or more cores, at 2GHz or faster
* **Memory:** 24GB RAM (including swap space)
* **Storage:** 300GB free storage
* **Internet:** Static IP address and a broadband connection supporting speeds at least 10 Mbps
* **Data Plan**: At least 1GB per day (30GB per month)
* **Power:** Reliable electrical power
* **ADA balance:** At least 505 ADA for pool deposit and transaction fees

## :man\_lifting\_weights: Recommended Future-proof Mainnet Stake Pool Hardware and Operating Requirements <a href="#futureproof" id="futureproof"></a>

* **Four separate servers**: 1 block producer node, 3 relay nodes (2 registered relays and 1 unregistered relay) located in at least two different physical locations around the world
* **One air-gapped offline machine (cold environment)**
* **Operating system**: 64-bit Linux (i.e. Ubuntu 22.04 LTS)
* **Processor:** An Intel or AMD x86 processor with four or more cores, at 2GHz or faster
* **Memory**: 24GB+ RAM
* **Storage**: 350GB+ free storage
* **Internet**: Static IP addresses and broadband connections supporting speeds of at least 100 Mbps
* **Data Plan**: Unlimited
* **Power:** Reliable electrical power with an Uninterruptible Power Supply (UPS) or other backup power source
* **ADA balance**: More pledge and stake is better, to be determined by **a0**, the pledge influence factor

## :hammer: Example Testnet Stake Pool Hardware and Operating Requirements

* **One server**: 1 block producer node
* **Operating system**: 64-bit Linux (i.e. Ubuntu 22.04 LTS)
* **Processor:** An Intel or AMD x86 processor with two or more cores, at 2GHz or faster
* **Memory:** 8GB RAM
* **Storage:** 50GB free storage
* **Internet:** Static IP address and a broadband connection supporting speeds at least 10 Mbps
* **Data Plan**: At least 1GB per day (30GB per month)
* **Power:** Reliable electrical power
* **ADA balance:** 0 ADA (Request tokens and stake pool delegations using the [Testnets Faucet](https://docs.cardano.org/cardano-testnets/tools/faucet))

## :unlock: Recommended Stake Pool Security

If you need ideas on how to harden your stake pool's nodes, see the topic [Hardening an Ubuntu Server](hardening-an-ubuntu-server.md).

## :tools: Setup Ubuntu

Refer to the respective guide to [Install Ubuntu Server](https://ubuntu.com/tutorials/install-ubuntu-server) or [Install Ubuntu Desktop](https://ubuntu.com/tutorials/install-ubuntu-desktop).

## :bricks: Rebuilding Nodes

If you are rebuilding or reusing an existing Cardano Node installation, see the topic [Resetting an Installation](../part-v-tips/resetting-an-installation.md).

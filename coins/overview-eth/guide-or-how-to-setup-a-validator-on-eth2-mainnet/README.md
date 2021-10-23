---
description: >-
  Become a validator, start staking and help secure Ethereum, a proof-of-stake
  blockchain. Anyone with 32 ETH can join.
---

# Guide | How to setup a validator for Ethereum staking on mainnet

## :new:Announcements

{% hint style="info" %}
The ETH Foundation would like to hear from you.

Fill out this survey [https://ethstaker.cc/survey/#Z7ZpSghg](https://ethstaker.cc/survey/#Z7ZpSghg)
{% endhint %}

{% hint style="info" %}
:confetti\_ball: **2021-09 Gitcoin Grant Round 11:** We improve this guide with your support!

[Help fund us and earn a **POAP NFT**](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew). Appreciate your support!🙏
{% endhint %}

{% hint style="success" %}
As of October 23 2021, this is **guide version 3.5.0** and written for **Ethereum mainnet**:grin:
{% endhint %}

{% hint style="info" %}
:sparkles:\*\* [**PRATER testnet guide**](../guide-or-how-to-setup-a-validator-on-eth2-testnet-prater.md). Always test and practice on testnet.\*\*
{% endhint %}

### :page\_facing\_up: Changelog - **Update Notes -** **October 23 2021**

* Updated with consensus layer (CL), the execution layer (EL), formerly known as eth2 and eth1.
* Added erigon build dependencies.
* Added Teku and Lodestar Checkpoint Sync feature, the quickest way to sync a Ethereum beacon chain client.
* geth + erigon pruning / Altair hard fork changes / nimbus eth1 fallback
* lighthouse + prysm doppelganger protection enabled. Doppelganger protection intentionally misses an epoch on startup and listens for attestations to make sure your keys are not still running on the old validator client.
* OpenEthereum will no longer be supported post London hard fork. Gnosis, maintainers of OpenEthereum, suggest users migrate to their new \*\*Erigon \*\*Ethererum client. Added setup instructions for **Erigon** under eth1 node section.
* Added [Mobile App Node Monitoring by beaconcha.in](./#6-5-mobile-app-node-monitoring-by-beaconcha-in)
* Updated [eth2.0-deposit-cli to v.1.2.0](https://github.com/ethereum/eth2.0-deposit-cli/releases/tag/v1.2.0) and added section on eth1 withdrawal address
* Added generating mnemonic seeds on **Tails OS** by [punggolzenith](https://github.com/punggolzenith)
* Iancoleman.io BLS12-381 Key Generation Tool [how-to added](./#8-12-eip2333-key-generator-by-iancoleman-io)
* Testnet guide forked for [Prater testnet](../guide-or-how-to-setup-a-validator-on-eth2-testnet-prater.md) staking
* [Geth pruning guide](how-to-free-up-eth1-node-disk-space.md) created
* Major changes to Lodestar guide
* Additional [Grafana Dashboards](./#6-2-setting-up-grafana-dashboards) for Prysm, Lighthouse and Nimbus
* [Validator Security Best Practices added](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md)
* Translations now available for Japanese, Chinese and Spanish (access by changing site language)
* Generate keystore files on [Ledger Nano X, Nano S and Trezor Model T](./#2-signup-to-be-a-validator-at-the-launchpad) with tool from [allnodes.com](https://twitter.com/Allnodes/status/1390020240541618177?s=20)
* [Batch deposit tool](./#2-signup-to-be-a-validator-at-the-launchpad) by [abyss.finance](https://twitter.com/AbyssFinance/status/1379732382044069888) now added

### :page\_facing\_up: Latest Essential Ethereum Staking Reading

* [Modelling the Impact of Altair by pintail.xyz](https://pintail.xyz/posts/modelling-the-impact-of-altair/)
* [Update on the Merge after the Amphora Interop by Consensys.net](https://consensys.net/blog/ethereum-2-0/an-update-on-the-merge-after-the-amphora-interop-event-in-greece/)

## :checkered\_flag: 0. Prerequisites

### :woman\_technologist:Skills for operating a eth validator and beacon node

As a validator for eth, you will typically have the following abilities:

* operational knowledge of how to set up, run and maintain a eth beacon node and validator continuously
* a long term commitment to maintain your validator 24/7/365
* basic operating system skills

### :man\_technologist: Experience required to be a successful validator

* have learned the essentials by watching ['Intro to Eth2 & Staking for Beginners' by Superphiz](https://www.youtube.com/watch?v=tpkpW031RCI)
* have passed or is actively enrolled in the [Eth2 Study Master course](https://ethereumstudymaster.com)
* and have read the [8 Things Every Eth2 validator should know.](https://medium.com/chainsafe-systems/8-things-every-eth2-validator-should-know-before-staking-94df41701487)

### :reminder\_ribbon: **Minimum Setup Requirements**

* **Operating system:** 64-bit Linux (i.e. Ubuntu 20.04 LTS Server or Desktop)
* **Processor:** Dual core CPU, Intel Core i5–760 or AMD FX-8100 or better
* **Memory:** 8GB RAM
* **Storage:** 128GB SSD
* **Internet:** Broadband internet connection with speeds at least 1 Mbps.
* **Power:** Reliable electrical power.
* **ETH balance:** at least 32 ETH and some ETH for deposit transaction fees
* **Wallet**: Metamask installed

### :man\_lifting\_weights: Recommended Hardware Setup

* **Operating system:** 64-bit Linux (i.e. Ubuntu 20.04 LTS Server or Desktop)
* **Processor:** Quad core CPU, Intel Core i7–4770 or AMD FX-8310 or better
* **Memory:** 16GB RAM or more
* **Storage:** 2TB SSD or more
* **Internet:** Broadband internet connections with speeds at least 10 Mbps without data limit.
* **Power:** Reliable electrical power with uninterruptible power supply (UPS)
* **ETH balance:** at least 32 ETH and some ETH for deposit transaction fees
* **Wallet**: Metamask installed

{% hint style="info" %}
:bulb: For examples of actual staking hardware builds, check out [RocketPool's hardware guide](https://github.com/rocket-pool/docs.rocketpool.net/blob/main/src/guides/node/local/hardware.md).
{% endhint %}

{% hint style="success" %}
:sparkles: **Pro Validator Tip**: Highly recommend you begin with a brand new instance of an OS, VM, and/or machine. Avoid headaches by NOT reusing testnet keys, wallets, or databases for your validator.
{% endhint %}

### :unlock: Recommended eth validator Security Best Practices

If you need ideas or a reminder on how to secure your validator, refer to the [security best practices guide](https://www.coincashew.com/coins/overview-eth/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node).

### :tools: Setup Ubuntu

If you need to install Ubuntu Server, refer to [this guide.](https://ubuntu.com/tutorials/install-ubuntu-server#1-overview)

Or Ubuntu Desktop, refer to [this guide.](https://www.coincashew.com/coins/overview-xtz/guide-how-to-setup-a-baker/install-ubuntu)

### :performing\_arts: Setup Metamask

If you need to install Metamask, refer to [this guide.](https://www.coincashew.com/wallets/browser-wallets/metamask-ethereum)

### :jigsaw: High Level Validator Node Overview

{% hint style="info" %}
At the end of this guide, you will build a node that hosts three main components in two layers: consensus layer consists of a consensus client, also known as a validator client with a beacon chain client. The execution layer consists of a execution client, formerly a eth1 node.

**Validator client** - Responsible for producing new blocks and attestations in the beacon chain and shard chains.

**Beacon chain client** - Responsible for managing the state of the beacon chain, validator shuffling, and more.

**Execution client (aka Eth1 node)** - Supplies incoming validator deposits from the eth mainnet chain to the beacon chain client.

Note: Teku and Nimbus combines both clients into one process.
{% endhint %}

![How eth2 fits together featuring Leslie the eth2 Rhino, the mascot named after American computer scientist Leslie Lamport](../../../.gitbook/assets/eth2network.png)

## :seedling: 1. Buy/exchange or consolidate ETH

{% hint style="info" %}
Every 32 ETH you own allows you to make 1 validator. You can run thousands of validators with your beacon node.
{% endhint %}

Your ETH (or multiples of 32 ETH) should be consolidated into a single address accessible with Metamask.

If you need to buy/exchange or top up your ETH to a multiple of 32, check out [How to buy ETH guide.](https://www.coincashew.com/coins/overview-eth/guide-how-to-buy-eth)

## :woman\_technologist: 2. Signup to be a validator at the Launchpad

1. Install dependencies, the ethereum foundation deposit tool and generate your two sets of key pairs.

{% hint style="info" %}
Each validator will have two sets of key pairs. A **signing key** and a **withdrawal key.** These keys are derived from a single mnemonic phrase. [Learn more about keys.](https://blog.ethereum.org/2020/05/21/keys/)
{% endhint %}

You have the choice of downloading the pre-built [ethereum foundation deposit tool](https://github.com/ethereum/eth2.0-deposit-cli) or building it from source. Alternatively, if you have a **Ledger Nano X/S or Trezor Model T**, you're able to generate deposit files with keys managed by a hardware wallet.

{% tabs %}
{% tab title="Hardware Wallet - Most Secure" %}
#### How to generate validator keys with Ledger Nano X/S and Trezor Model T

{% hint style="info" %}
[Allnodes ](https://help.allnodes.com/en/articles/4664440-how-to-setup-ethereum-2-0-validator-node-on-allnodes)has created an easy to use tool to connect a Ledger Nano X/S and Trezor Model T and generate the deposit json files such that the withdrawal credentials remain secured by the hardware wallet. This tool can be used by any validator or staker.
{% endhint %}

1. Connect your hardware wallet to your PC/laptop
2. If using a Ledger Nano X/S, open the "ETHEREUM" ledger app (if missing, install from Ledger Live)
3. Visit [AllNode's Deposit Generator Tool.](https://wallet.allnodes.com/eth2/generate)
4. Select network > Mainnet
5. Select your wallet > then CONTINUE

![](../../../.gitbook/assets/allnodes-menu.png)

6\. From the dropdown, select your eth address with at least 32 ETH to fund your validators

7\. On your hardware wallet, sign the ETH signature message to login to allnodes.com

8\. Again on your hardware wallet, sign another message to verify your eth2 withdrawal credentials

{% hint style="info" %}
Double check that your generated deposit data file contains the same string as in withdrawal credentials and that this string includes your Ethereum address (starting after 0x)
{% endhint %}

![](../../../.gitbook/assets/allnodes-3.png)

9\. Enter the amount of nodes (or validators you want)

10\. Finally, enter a **KEYSTORE password** to encrypt the deposit json files. Keep this password safe and **offline**.

11\. Confirm password and click **GENERATE**
{% endtab %}

{% tab title="Build from source code" %}
Install dependencies.

```
sudo apt update
sudo apt install python3-pip git -y
```

Download source code and install.

```
cd $HOME
git clone https://github.com/ethereum/eth2.0-deposit-cli.git eth2deposit-cli
cd eth2deposit-cli
sudo ./deposit.sh install
```

Make a new mnemonic.

```
./deposit.sh new-mnemonic --chain mainnet
```

{% hint style="info" %}
**Advanced option**: Custom eth1 withdrawal address, often used for 3rd party staking.

```bash
# Add the following
--eth1_withdrawal_address <eth1 address hex string>
# Example
./deposit.sh new-mnemonic --chain mainnet --eth1_withdrawal_address 0x1...x
```

If this field is set and valid, the given Eth1 address will be used to create the withdrawal credentials. Otherwise, it will generate withdrawal credentials with the mnemonic-derived withdrawal public key in [EIP-2334 format](https://eips.ethereum.org/EIPS/eip-2334#eth2-specific-parameters).
{% endhint %}
{% endtab %}

{% tab title="Pre-built eth2deposit-cli" %}
Download eth2deposit-cli.

```bash
cd $HOME
wget https://github.com/ethereum/eth2.0-deposit-cli/releases/download/v1.2.0/eth2deposit-cli-256ea21-linux-amd64.tar.gz
```

Verify the SHA256 Checksum matches the checksum on the [releases page](https://github.com/ethereum/eth2.0-deposit-cli/releases/tag/v1.0.0).

```bash
echo "825035b6d6c06c0c85a38f78e8bf3e9df93dfd16bf7b72753b6888ae8c4cb30a *eth2deposit-cli-ed5a6d3-linux-amd64.tar.gz" | shasum -a 256 --check
```

Example valid output:

> eth2deposit-cli-256ea21-linux-amd64.tar.gz: OK

{% hint style="danger" %}
Only proceed if the sha256 check passes with **OK**!
{% endhint %}

Extract the archive.

```
tar -xvf eth2deposit-cli-256ea21-linux-amd64.tar.gz
mv eth2deposit-cli-256ea21-linux-amd64 eth2deposit-cli
rm eth2deposit-cli-256ea21-linux-amd64.tar.gz
cd eth2deposit-cli
```

Make a new mnemonic.

```
./deposit new-mnemonic --chain mainnet
```

{% hint style="info" %}
**Advanced option**: Custom eth1 withdrawal address, often used for 3rd party staking.

```bash
# Add the following
--eth1_withdrawal_address <eth1 address hex string>
# Example
./deposit.sh new-mnemonic --chain mainnet --eth1_withdrawal_address 0x1...x
```

If this field is set and valid, the given Eth1 address will be used to create the withdrawal credentials. Otherwise, it will generate withdrawal credentials with the mnemonic-derived withdrawal public key in [EIP-2334 format](https://eips.ethereum.org/EIPS/eip-2334#eth2-specific-parameters).
{% endhint %}
{% endtab %}

{% tab title="Advanced - Most Secure" %}
{% hint style="warning" %}
:fire:**\[ Optional ] Pro Security Tip**: Run the \*\*eth2deposit-cli tool \*\*and generate your **mnemonic seed** for your validator keys on an **air-gapped offline machine booted from usb**.
{% endhint %}

You will learn how to boot up a windows PC into an airgapped [Tails operating system](https://tails.boum.org/index.en.html).

The Tails OS is an _amnesic_ operating system, meaning it will save nothing and _leave no tracks behind_ each time you boot it.

#### Part 0 - Prerequisites

You need:

* 2 storage mediums (can be USB stick, SD cards or external hard drives)
* One of them must be > 8GB
* Windows or Mac computer
* 30 minutes or longer depending on your download speed

#### Part 1 - Download Tails OS

Download the official image from the [Tails website](https://tails.boum.org/install/index.en.html). Might take a while, go grab a coffee.

Make sure you follow the guide on the Tails website to verify your download of Tails.

#### Part 2 - Download and install the software to transfer your Tails image on your USB stick

For Windows, use one of

* [Etcher](https://tails.boum.org/etcher/Etcher-Portable.exe)
* [Win32 Disk Imager](https://win32diskimager.org/#download)
* [Rufus](https://rufus.ie/en\_US/)

For Mac, download [Etcher](https://tails.boum.org/etcher/Etcher.dmg)

#### Part 3 - Making your bootable USB stick

Run the above software. This is an example how it looks like on Mac OS with etcher, but other software should be similar.

![](../../../.gitbook/assets/etcher\_in\_mac.png)

Select the Tails OS image that you downloaded as the image. Then select the USB stick (the larger one).

Then flash the image to the larger USB stick.

#### Part 4 - Download and verify the eth2-deposit-cli

You can refer to the other tab on this guide on how to download and verify the eth2-deposit-cli.

Copy the file to the other USB stick.

#### Part 5 - Reboot your computer and into Tails OS

After you have done all the above, you can reboot. If you are connected by a LAN cable to the internet, you can disconnect it manually.

Plug in the USB stick that has your Tails OS.

On Mac, press and hold the Option key immediately upon hearing the startup chime. Release the key after Startup Manager appears.

On Windows, it depends on your computer manufacturer. Usually it is by pressing F1 or F12. If it doesn't work, try googling "Enter boot options menu on \[Insert your PC brand]"

Choose the USB stick that you loaded up with Tails OS to boot into Tails.

#### Part 6 - Welcome to Tails OS

![](../../../.gitbook/assets/grub.png)

You can boot with all the default settings.

#### Part 7 - Run the eth2-deposit-cli

Plug in your other USB stick with the `eth2-deposit-cli` file.

You can then open your command line and navigate into the directory containing the file. Then you can continue the guide from the other tab.

Make a new mnemonic.

```
./deposit.sh new-mnemonic --chain mainnet
```

If you ran this command directly from your non-Tails USB stick, the validator keys should stay on it. If it hasn't, copy the directory over to your non-Tails USB stick.

{% hint style="warning" %}
\*\*\*\*:fire: **Make sure you have saved your validator keys directory in your other USB stick (non Tails OS) before you shutdown Tails. Tails will delete everything saved on it after you shutdown.**.
{% endhint %}

{% hint style="success" %}
:tada: Congrats on learning how to use Tails OS to make an air gapped system. As a bonus, you can reboot into Tails OS again and connect to internet to surf the dark web or clear net safely!
{% endhint %}

Alternatively, follow this [ethstaker.cc](https://ethstaker.cc) exclusive for the low down on making a bootable usb.

**Part 1 - Create a Ubuntu 20.04 USB Bootable Drive**

Video link: [https://www.youtube.com/watch?v=DTR3PzRRtYU](https://www.youtube.com/watch?v=DTR3PzRRtYU)

**Part 2 - Install Ubuntu 20.04 from the USB Drive**

Video link: [https://www.youtube.com/watch?v=C97\_6MrufCE](https://www.youtube.com/watch?v=C97\_6MrufCE)

You can copy via USB key the pre-built eth2deposit-cli binaries from an online machine to an air-gapped offline machine booted from usb. Make sure to disconnect the ethernet cable and/or WIFI.
{% endtab %}
{% endtabs %}

2\. If using **eth2deposit-cli**, follow the prompts and pick a **KEYSTORE password**. This password encrypts your keystore files. Write down your mnemonic and keep this safe and **offline**.

{% hint style="warning" %}
**Caution**: Only deposit the 32 ETH per validator if you are confident your execution client (ETH1 node) and consensus client (ETH2 validator) will be fully synched and ready to perform validator duties. You can return later to launchpad with your deposit-data to finish the next steps.
{% endhint %}

3\. Follow the steps at [https://launchpad.ethereum.org/](https://launchpad.ethereum.org) while skipping over the steps you already just completed. Study the eth2 phase 0 overview material. Understanding eth staking is the key to success!

{% hint style="info" %}
:whale: **Batch Depositing Tip**: If you have many deposits to make for many validators, consider using [Abyss.finance's eth2depositor tool.](https://abyss.finance/eth2depositor) This greatly improves the deposit experience as multiple deposits can be batched into one transaction, thereby saving gas fees and saving your fingers by minimizing Metamask clicking.

Source: [https://twitter.com/AbyssFinance/status/1379732382044069888](https://twitter.com/AbyssFinance/status/1379732382044069888)
{% endhint %}

4\. Back on the launchpad website, upload your`deposit_data-#########.json` found in the `validator_keys` directory.

5\. Connect to the launchpad with your Metamask wallet, review and accept terms.

6\. Confirm the transaction(s). There's one deposit transaction of 32 ETH for each validator.

{% hint style="info" %}
For instance, if you want to run 3 validators you will need to have (32 x 3) = 96 goerli ETH plus some extra to cover the gas fees.
{% endhint %}

{% hint style="info" %}
Your transaction is sending and depositing your ETH to the [official ETH2 deposit contract address.](https://blog.ethereum.org/2020/11/04/eth2-quick-update-no-19/)

**Check**, _double-check_, _**triple-check**_ that the official Eth2 deposit contract address is correct.[`0x00000000219ab540356cBB839Cbe05303d7705Fa`](https://etherscan.io/address/0x00000000219ab540356cbb839cbe05303d7705fa)
{% endhint %}

{% hint style="danger" %}
\*\*\*\*:fire: **Critical Crypto Reminder:** \*\*Keep your mnemonic, keep your ETH. \*\*:rocket:

* Write down your mnemonic seed **offline**. _Not email. Not cloud._
* Multiple copies are better. Best stored in a \_[_metal seed._](https://jlopp.github.io/metal-bitcoin-storage-reviews/)
* The withdrawal keys will be generated from this mnemonic in the future.
* Make **offline backups**, such as to a USB key, of your **`validator_keys`** directory.
{% endhint %}

## :flying\_saucer: 3. Install execution client (ETH1 node)

{% hint style="info" %}
Ethereum 2.0 requires a connection to Ethereum 1.0 in order to monitor for 32 ETH validator deposits. Hosting your own Ethereum 1.0 node is the best way to maximize decentralization and minimize dependency on third parties such as Infura.
{% endhint %}

{% hint style="warning" %}
The subsequent steps assume you have completed the [best practices security guide.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md)

:octagonal\_sign: Do not run your processes as **ROOT** user. :scream:
{% endhint %}

Your choice of either [**Geth**](https://geth.ethereum.org)**,** [**Besu**](https://besu.hyperledger.org)**, **[**Nethermind**](https://www.nethermind.io)**, **[**Erigon**](https://github.com/ledgerwatch/erigon)** or **[**Infura**](https://infura.io)**.**

{% tabs %}
{% tab title="Geth" %}
{% hint style="info" %}
\*\*Geth \*\*- Go Ethereum is one of the three original implementations (along with C++ and Python) of the Ethereum protocol. It is written in **Go**, fully open source and licensed under the GNU LGPL v3.
{% endhint %}

Review the latest release notes at [https://github.com/ethereum/go-ethereum/releases](https://github.com/ethereum/go-ethereum/releases)

:dna:\*\* Install from the repository\*\*

```
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update -y
sudo apt dist-upgrade -y
sudo apt-get install ethereum -y
```

:gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = geth execution client service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
ExecStart       = /usr/bin/geth --http --metrics --pprof
Restart         = on-failure
RestartSec      = 3
TimeoutSec      = 300

[Install]
WantedBy    = multi-user.target
EOF
```

{% hint style="info" %}
**Nimbus Specific Configuration**: Add the following flag to the \*\*ExecStart \*\*line.

```bash
--ws
```
{% endhint %}

Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
```

Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1
```

:chains:\*\* Start geth\*\*

```
sudo systemctl start eth1
```

{% hint style="info" %}
**Geth Tip**: When is my geth node synched?

1. Attach to the geth console with:`geth attach `[`http://127.0.0.1:8545`](http://127.0.0.1:8545)\`\`
2. Type the following:`eth.syncing`
3. If it returns false, your geth node is synched.
{% endhint %}
{% endtab %}

{% tab title="Besu" %}
{% hint style="info" %}
**Hyperledger Besu** is an open-source Ethereum client designed for demanding enterprise applications requiring secure, high-performance transaction processing in a private network. It's developed under the Apache 2.0 license and written in **Java**.
{% endhint %}

:dna:\*\* Install java dependency\*\*

```
sudo apt update
sudo apt install openjdk-11-jdk -y
```

:last\_quarter\_moon\_with\_face:\*\* Download and unzip Besu\*\*

Review the latest release at [https://github.com/hyperledger/besu/releases](https://github.com/hyperledger/besu/releases)

File can be downloaded from [https://dl.bintray.com/hyperledger-org/besu-repo](https://dl.bintray.com/hyperledger-org/besu-repo)

```
cd
wget -O besu.tar.gz https://dl.bintray.com/hyperledger-org/besu-repo/besu-20.10.1.tar.gz
tar -xvf besu.tar.gz
rm besu.tar.gz
mv besu* besu
```

:gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = besu eth1 service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
ExecStart       = $(echo $HOME)/besu/bin/besu --metrics-enabled --rpc-http-enabled --data-path="$HOME/.besu"
Restart         = on-failure
RestartSec      = 3

[Install]
WantedBy    = multi-user.target
EOF
```

Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
```

Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1
```

:chains:\*\* Start besu\*\*

```
sudo systemctl start eth1
```
{% endtab %}

{% tab title="Nethermind" %}
{% hint style="info" %}
\*\*Nethermind \*\*is a flagship Ethereum client all about performance and flexibility. Built on **.NET** core, a widespread, enterprise-friendly platform, Nethermind makes integration with existing infrastructures simple, without losing sight of stability, reliability, data integrity, and security.
{% endhint %}

:gear:\*\* Install dependencies\*\*

```
sudo apt-get update
sudo apt-get install curl libsnappy-dev libc6-dev jq libc6 unzip -y
```

:last\_quarter\_moon\_with\_face:\*\* Download and unzip Nethermind\*\*

Review the latest release at [https://github.com/NethermindEth/nethermind/releases](https://github.com/NethermindEth/nethermind/releases)

Automatically download the latest linux release, un-zip and cleanup.

```bash
mkdir $HOME/nethermind
chmod 775 $HOME/nethermind
cd $HOME/nethermind
curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux-amd64  | xargs wget -q --show-progress
unzip -o nethermind*.zip
rm nethermind*linux*.zip
```

:gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = nethermind eth1 service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
ExecStart       = $(echo $HOME)/nethermind/Nethermind.Runner --baseDbPath $HOME/.nethermind --Metrics.Enabled true --JsonRpc.Enabled true --Sync.DownloadBodiesInFastSync true --Sync.DownloadReceiptsInFastSync true --Sync.AncientBodiesBarrier 11052984 --Sync.AncientReceiptsBarrier 11052984
Restart         = on-failure
RestartSec      = 3

[Install]
WantedBy    = multi-user.target
EOF
```

Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
```

Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1
```

:chains:\*\* Start Nethermind\*\*

```
sudo systemctl start eth1
```

{% hint style="info" %}
**Note about Metric Error messages**: You will see these until prometheus pushergateway is setup in section 6. `Error in MetricPusher: System.Net.Http.HttpRequestException: Connection refused`
{% endhint %}
{% endtab %}

{% tab title="Erigon" %}
{% hint style="info" %}
\*\*Erigon \*\*- Successor to OpenEthereum, Erigon is an implementation of Ethereum (aka "Ethereum client"), on the efficiency frontier, written in Go.
{% endhint %}

:gear:\*\* Install Go dependencies\*\*

```
wget -O go.tar.gz https://golang.org/dl/go1.16.5.linux-amd64.tar.gz
```

```bash
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz
```

```bash
echo export PATH=$PATH:/usr/local/go/bin>> $HOME/.bashrc
source $HOME/.bashrc
```

Verify Go is properly installed and cleanup files.

```bash
go version
rm go.tar.gz
```

:robot:\*\* Build and install Erigon\*\*

Install build dependencies.

```bash
sudo apt-get update
sudo apt install build-essential git
```

Review the latest release at [https://github.com/ledgerwatch/erigon/releases](https://github.com/ledgerwatch/erigon/releases)

```bash
cd $HOME
git clone --recurse-submodules -j8 https://github.com/ledgerwatch/erigon.git
cd erigon
make erigon && make rpcdaemon
```

​ Make data directory and update directory ownership.

```bash
sudo mkdir -p /var/lib/erigon
sudo chown $USER:$USER /var/lib/erigon
```

​ :gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = erigon eth1 service
Wants           = network-online.target
After           = network-online.target 
Requires        = eth1-erigon.service

[Service]
Type            = simple
User            = $USER
ExecStart       = $HOME/erigon/build/bin/erigon --datadir /var/lib/erigon --chain mainnet --private.api.addr=localhost:9089 --metrics --pprof --prune htc
Restart         = on-failure
RestartSec      = 3
KillSignal      = SIGINT
TimeoutStopSec  = 5

[Install]
WantedBy    = multi-user.target
EOF
```

{% hint style="info" %}
By default with Erigon, `--prune` deletes data older than 90K blocks from the tip of the chain (aka, for if tip block is no. 12'000'000, only the data between 11'910'000-12'000'000 will be kept).
{% endhint %}

```bash
cat > $HOME/eth1-erigon.service << EOF 
[Unit]
Description     = erigon rpcdaemon service
BindsTo	        = eth1.service
After           = eth1.service

[Service]
Type            = simple
User            = $USER
ExecStartPre	  = /bin/sleep 3
ExecStart       = $HOME/erigon/build/bin/rpcdaemon --private.api.addr=localhost:9089 --datadir /var/lib/erigon --http.api=eth,erigon,web3,net,debug,trace,txpool,shh
Restart         = on-failure
RestartSec      = 3
KillSignal      = SIGINT
TimeoutStopSec  = 5

[Install]
WantedBy    = eth1.service
EOF
```

Move the unit files to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
sudo mv $HOME/eth1-erigon.service /etc/systemd/system/eth1-erigon.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
sudo chmod 644 /etc/systemd/system/eth1-erigon.service
```

Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1 eth1-erigon
```

:chains:\*\* Start Erigon\*\*

```
sudo systemctl start eth1
```
{% endtab %}

{% tab title="OpenEthereum (Retired)" %}
{% hint style="danger" %}
OpenEthereum will no longer be supported post London hard fork. Gnosis, maintainers of OpenEthereum, suggest users migrate to their new \*\*Erigon \*\*Ethererum client.
{% endhint %}

{% hint style="info" %}
\*\*OpenEthereum **- It's** \*\*goal is to be the fastest, lightest, and most secure Ethereum client using the **Rust programming language**. OpenEthereum is licensed under the GPLv3 and can be used for all your Ethereum needs.
{% endhint %}

:gear:\*\* Install dependencies\*\*

```
sudo apt-get update
sudo apt-get install curl jq unzip -y
```

:robot:\*\* Install OpenEthereum\*\*

Review the latest release at [https://github.com/openethereum/openethereum/releases](https://github.com/openethereum/openethereum/releases)

Automatically download the latest linux release, un-zip, add execute permissions and cleanup.

```bash
mkdir $HOME/openethereum
cd $HOME/openethereum
curl -s https://api.github.com/repos/openethereum/openethereum/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux | xargs wget -q --show-progress
unzip -o openethereum*.zip
chmod +x openethereum
rm openethereum*.zip
```

​ :gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = openethereum eth1 service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
ExecStart       = $(echo $HOME)/openethereum/openethereum --metrics --metrics-port=6060
Restart         = on-failure
RestartSec      = 3

[Install]
WantedBy    = multi-user.target
EOF
```

{% hint style="info" %}
**Nimbus Specific Configuration**: Add the following flag to the \*\*ExecStart \*\*line.

```bash
--ws-origins=all
```
{% endhint %}

Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
```

Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1
```

:chains:\*\* Start OpenEthereum\*\*

```
sudo systemctl start eth1
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Syncing an execution client can take up to 1 week. On high-end machines with gigabit internet, expect syncing to take less than a day.
{% endhint %}

{% hint style="success" %}
Your execution client is fully sync'd when these events occur.

* **`OpenEthereum:`** `Imported #<block number>`
* **`Geth:`** `Imported new chain segment`
* **`Besu:`** `Imported #<block number>`
* **`Nethermind:`** `No longer syncing Old Headers`
{% endhint %}

#### :tools: Helpful eth1.service commands

​​ :notepad\_spiral: **To view and follow eth1 logs**

```
journalctl -fu eth1
```

:notepad\_spiral: **To stop eth1 service**

```
sudo systemctl stop eth1
```

## :last\_quarter\_moon\_with\_face: 4. Configure consensus client (beacon chain and validator)

Your choice of [Lighthouse](https://github.com/sigp/lighthouse), [Nimbus](https://github.com/status-im/nimbus-eth2), [Teku](https://consensys.net/knowledge-base/ethereum-2/teku/), [Prysm](https://github.com/prysmaticlabs/prysm) or [Lodestar](https://lodestar.chainsafe.io).

{% tabs %}
{% tab title="Lighthouse" %}
{% hint style="info" %}
[Lighthouse](https://github.com/sigp/lighthouse) is an Eth client with a heavy focus on speed and security. The team behind it, [Sigma Prime](https://sigmaprime.io), is an information security and software engineering firm who have funded Lighthouse along with the Ethereum Foundation, Consensys, and private individuals. Lighthouse is built in Rust and offered under an Apache 2.0 License.
{% endhint %}

#### :gear: 4.1. Install rust dependency

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Enter '1' to proceed with the default install.

Update your environment variables.

```bash
echo export PATH="$HOME/.cargo/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

Install rust dependencies.

```
sudo apt-get update
sudo apt install -y git gcc g++ make cmake pkg-config libssl-dev
```

#### :bulb: 4.2. Build Lighthouse from source

```bash
mkdir ~/git
cd ~/git
git clone https://github.com/sigp/lighthouse.git
cd lighthouse
git fetch --all && git checkout stable && git pull
make
```

{% hint style="info" %}
In case of compilation errors, run the following sequence.

```
rustup update
cargo clean
make
```
{% endhint %}

{% hint style="info" %}
This build process may take a few minutes.
{% endhint %}

Verify lighthouse was installed properly by checking the version number.

```
lighthouse --version
```

#### :tophat: 4.3. Import validator key

{% hint style="info" %}
When you import your keys into Lighthouse, your validator signing key(s) are stored in the `$HOME/.lighthouse/mainnet/validators` folder.
{% endhint %}

Run the following command to import your validator keys from the eth2deposit-cli tool directory.

Enter your **keystore password** to import accounts.

```bash
lighthouse account validator import --network mainnet --directory=$HOME/eth2deposit-cli/validator_keys
```

Verify the accounts were imported successfully.

```bash
lighthouse account_manager validator list --network mainnet
```

{% hint style="danger" %}
**WARNING**: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

#### :fire: 4.4. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, [ensure your validator's firewall ports are open and reachable.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall)

* **Lighthouse consensus client** requires port 9000 for tcp and udp
* execution client requires port 30303 for tcp and udp

{% hint style="info" %}
:sparkles: **Port Forwarding Tip:** You'll need to forward and open ports to your validator. Verify it's working with [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) or [https://canyouseeme.org/](https://canyouseeme.org) .
{% endhint %}

#### :chains: 4.5. Start the beacon chain

:cake:\*\* Benefits of using systemd for your beacon chain\*\*

1. Auto-start your beacon chain when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed beacon chain processes.
3. Maximize your beacon chain up-time and performance.

:tools:\*\* Setup Instructions for Systemd\*\*

Run the following to create a **unit file** to define your`beacon-chain.service` configuration. Simply copy and paste.

```bash
cat > $HOME/beacon-chain.service << EOF 
# The eth beacon chain service (part of systemd)
# file: /etc/systemd/system/beacon-chain.service 

[Unit]
Description     = eth beacon chain service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $USER
ExecStart       = $(which lighthouse) bn --staking --validator-monitor-auto --metrics --network mainnet
Restart         = on-failure

[Install]
WantedBy    = multi-user.target
EOF
```

{% hint style="info" %}
\*\*\*\*:fire: \*\*Lighthouse Pro Tip: \*\*On the \*\*ExecStart \*\*line, adding the `--eth1-endpoints` flag allows for redundant execution clients. Separate with comma. Make sure the endpoint does not end with a trailing slash or`/` Remove it.

```bash
# Example:
--eth1-endpoints http://localhost:8545,https://nodes.mewapi.io/rpc/eth,https://mainnet.eth.cloud.ava.do,https://mainnet.infura.io/v3/xxx
```

:money\_with\_wings: Find free ethereum fallback nodes at [https://ethereumnodes.com/](https://ethereumnodes.com)
{% endhint %}

Move the unit file to `/etc/systemd/system`

```bash
sudo mv $HOME/beacon-chain.service /etc/systemd/system/beacon-chain.service
```

Update file permissions.

```bash
sudo chmod 644 /etc/systemd/system/beacon-chain.service
```

Run the following to enable auto-start at boot time and then start your beacon node service.

```
sudo systemctl daemon-reload
sudo systemctl enable beacon-chain
sudo systemctl start beacon-chain
```

{% hint style="info" %}
**Troubleshooting common issues**:

_The beacon chain couldn't connect to the :8545 service?_

* In the beacon chain unit file under \[Service], add, "`ExecStartPre = /bin/sleep 30`" so that it waits 30 seconds for execution client to startup before connecting.

_CRIT Invalid eth1 chain id. Please switch to correct chain id._

* Allow your execution client to fully sync to mainnet.
{% endhint %}

{% hint style="success" %}
Nice work. Your beacon chain is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

:tools:** Some helpful systemd commands**

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl --unit=beacon-chain -f
```

```bash
#view log since yesterday
journalctl --unit=beacon-chain --since=yesterday
```

```bash
#view log since today
journalctl --unit=beacon-chain --since=today
```

```bash
#view log between a date
journalctl --unit=beacon-chain --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

:white\_check\_mark:\*\* Check whether the beacon chain is active\*\*

```
sudo systemctl is-active beacon-chain
```

:mag\_right:\*\* View the status of the beacon chain\*\*

```
sudo systemctl status beacon-chain
```

:arrows\_counterclockwise:\*\* Restarting the beacon chain\*\*

```
sudo systemctl reload-or-restart beacon-chain
```

:octagonal\_sign:\*\* Stopping the beacon chain\*\*

```
sudo systemctl stop beacon-chain
```

#### :dna: 4.6. Start the validator

:rocket:\*\* Setup Graffiti\*\*

Setup your `graffiti`, a custom message included in blocks your validator successfully proposes. Add optional graffiti between the single quotes.

```bash
MY_GRAFFITI=''
# Examples
# MY_GRAFFITI='poapAAAAACGatUA1bLuDnL4FMD13BfoD'
# MY_GRAFFITI='eth rulez!'
```

:cake:\*\* Benefits of using systemd for your validator\*\*

1. Auto-start your validator when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed validator processes.
3. Maximize your validator up-time and performance.

:tools:\*\* Setup Instructions for Systemd\*\*

Run the following to create a **unit file** to define your`validator.service` configuration. Simply copy and paste.

```bash
cat > $HOME/validator.service << EOF 
# The eth validator service (part of systemd)
# file: /etc/systemd/system/validator.service 

[Unit]
Description     = eth validator service
Wants           = network-online.target beacon-chain.service
After           = network-online.target 

[Service]
User            = $USER
ExecStart       = $(which lighthouse) vc --network mainnet --graffiti "${MY_GRAFFITI}" --metrics --enable-doppelganger-protection 
Restart         = on-failure

[Install]
WantedBy    = multi-user.target
EOF
```

Move the unit file to `/etc/systemd/system`

```bash
sudo mv $HOME/validator.service /etc/systemd/system/validator.service
```

Update file permissions.

```bash
sudo chmod 644 /etc/systemd/system/validator.service
```

Run the following to enable auto-start at boot time and then start your validator.

```
sudo systemctl daemon-reload
sudo systemctl enable validator
sudo systemctl start validator
```

{% hint style="success" %}
Nice work. Your validator is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

**🛠 Some helpful systemd commands**

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl --unit=validator -f
```

```bash
#view log since yesterday
journalctl --unit=validator --since=yesterday
```

```bash
#view log since today
journalctl --unit=validator --since=today
```

```bash
#view log between a date
journalctl --unit=validator --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

**✅ Check whether the validator is active**

```
sudo systemctl is-active validator
```

**🔎 View the status of the validator**

```
sudo systemctl status validator
```

**🔄 Restarting the validator**

```
sudo systemctl reload-or-restart validator
```

**🛑 Stopping the validator**

```
sudo systemctl stop validator
```
{% endtab %}

{% tab title="Nimbus" %}
{% hint style="info" %}
[Nimbus](https://our.status.im/tag/nimbus/) is a research project and a client implementation for Ethereum 2.0 designed to perform well on embedded systems and personal mobile devices, including older smartphones with resource-restricted hardware. The Nimbus team are from [Status](https://status.im/about/) the company best known for [their messaging app/wallet/Web3 browser](https://status.im) by the same name. Nimbus (Apache 2) is written in Nim, a language with Python-like syntax that compiles to C.
{% endhint %}

{% hint style="info" %}
:bulb: **Noteworthy**: binaries for all the usual platforms as well as dockers for x86 and arm can be found below:

[https://github.com/status-im/nimbus-eth2/releases/](https://github.com/status-im/nimbus-eth2/releases/)\
[https://hub.docker.com/r/statusim/nimbus-eth2](https://hub.docker.com/r/statusim/nimbus-eth2)
{% endhint %}

#### :gear: 4.1. Build Nimbus from source

Install dependencies.

```
sudo apt-get update
sudo apt-get install curl build-essential git -y
```

Install and build Nimbus.

```bash
mkdir ~/git 
cd ~/git
git clone https://github.com/status-im/nimbus-eth2
cd nimbus-eth2
make nimbus_beacon_node
```

{% hint style="info" %}
The build process may take a few minutes.
{% endhint %}

Verify Nimbus was installed properly by displaying the help.

```bash
cd $HOME/git/nimbus-eth2/build
./nimbus_beacon_node --help
```

Copy the binary file to `/usr/bin`

```bash
sudo cp $HOME/git/nimbus-eth2/build/nimbus_beacon_node /usr/bin
```

#### :tophat: 4.2. Import validator key <a href="6-import-validator-key" id="6-import-validator-key"></a>

Create a directory structure to store nimbus data.

```bash
sudo mkdir -p /var/lib/nimbus
```

Take ownership of this directory and set the correct permission level.

```bash
sudo chown $(whoami):$(whoami) /var/lib/nimbus
sudo chmod 700 /var/lib/nimbus
```

The following command will import your validator keys.

Enter your **keystore password** to import accounts.

```bash
cd $HOME/git/nimbus-eth2
build/nimbus_beacon_node deposits import --data-dir=/var/lib/nimbus $HOME/eth2deposit-cli/validator_keys
```

Now you can verify the accounts were imported successfully by doing a directory listing.

```bash
ll /var/lib/nimbus/validators
```

You should see a folder named for each of your validator's pubkey.

{% hint style="info" %}
When you import your keys into Nimbus, your validator signing key(s) are stored in the `/var/lib/nimbus` folder, under `secrets` and `validators.`

The `secrets` folder contains the common secret that gives you access to all your validator keys.

The `validators` folder contains your signing keystore(s) (encrypted keys). Keystores are used by validators as a method for exchanging keys.

For more on keys and keystores, see [here](https://blog.ethereum.org/2020/05/21/keys/).
{% endhint %}

{% hint style="danger" %}
**WARNING**: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

#### :fire: 4.3. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, [ensure your validator's firewall ports are open and reachable.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall)

* **Nimbus beacon chain node** will use port 9000 for tcp and udp
* **eth1** node requires port 30303 for tcp and udp

{% hint style="info" %}
:sparkles: **Port Forwarding Tip:** You'll need to forward and open ports to your validator. Verify it's working with [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) or [https://canyouseeme.org/](https://canyouseeme.org) .
{% endhint %}

#### :snowboarder: 4.4. Start the beacon chain and validator

{% hint style="info" %}
Nimbus combines both the beacon chain and validator into one process.
{% endhint %}

:rocket:\*\* Setup Graffiti and POAP\*\*

Setup your `graffiti`, a custom message included in blocks your validator successfully proposes, and earn a POAP token. [Generate your POAP string by supplying an Ethereum 1.0 address here.](https://beaconcha.in/poap)

Run the following command to set the `MY_GRAFFITI` variable. Replace `<my POAP string or message>` between the single quotes.

```bash
MY_GRAFFITI='<my POAP string or message>'
# Examples
# MY_GRAFFITI='poapAAAAACGatUA1bLuDnL4FMD13BfoD'
# MY_GRAFFITI='eth2 rulez!'
```

{% hint style="info" %}
Learn more about [POAP - The Proof of Attendance token.](https://www.poap.xyz)
{% endhint %}

**🍰 Benefits of using systemd for your beacon chain and validator**

1. Auto-start your beacon chain when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed beacon chain processes.
3. Maximize your beacon chain up-time and performance.

**🛠 Setup Instructions**

Run the following to create a **unit file** to define your`beacon-chain.service` configuration. Simply copy and paste.

```bash
cat > $HOME/beacon-chain.service << EOF 
# The eth2 beacon chain service (part of systemd)
# file: /etc/systemd/system/beacon-chain.service 

[Unit]
Description     = eth2 beacon chain service
Wants           = network-online.target
After           = network-online.target 

[Service]
Type            = simple
User            = $(whoami)
WorkingDirectory= /var/lib/nimbus
ExecStart       = /bin/bash -c '/usr/bin/nimbus_beacon_node --network=mainnet --graffiti="${MY_GRAFFITI}" --data-dir=/var/lib/nimbus --web3-url=ws://127.0.0.1:8546 --metrics --metrics-port=8008 --rpc --rpc-port=9091 --validators-dir=/var/lib/nimbus/validators --secrets-dir=/var/lib/nimbus/secrets --log-file=/var/lib/nimbus/beacon.log'
Restart         = on-failure

[Install]
WantedBy    = multi-user.target
EOF
```

{% hint style="warning" %}
Nimbus only supports websocket connections ("ws://" and "wss://") for the ETH1 node. Geth, OpenEthereum and Infura ETH1 nodes are verified compatible.
{% endhint %}

Move the unit file to `/etc/systemd/system`

```bash
sudo mv $HOME/beacon-chain.service /etc/systemd/system/beacon-chain.service
```

Update file permissions.

```bash
sudo chmod 644 /etc/systemd/system/beacon-chain.service
```

Run the following to enable auto-start at boot time and then start your beacon node service.

```
sudo systemctl daemon-reload
sudo systemctl enable beacon-chain
sudo systemctl start beacon-chain
```

{% hint style="success" %}
Nice work. Your beacon chain is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

:tools:** Some helpful systemd commands**

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl --unit=beacon-chain -f
```

```bash
#view log since yesterday
journalctl --unit=beacon-chain --since=yesterday
```

```bash
#view log since today
journalctl --unit=beacon-chain --since=today
```

```bash
#view log between a date
journalctl --unit=beacon-chain --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

:white\_check\_mark:\*\* Check whether the beacon chain is active\*\*

```
sudo systemctl is-active beacon-chain
```

:mag\_right:\*\* View the status of the beacon chain\*\*

```
sudo systemctl status beacon-chain
```

:arrows\_counterclockwise:\*\* Restarting the beacon chain\*\*

```
sudo systemctl reload-or-restart beacon-chain
```

:octagonal\_sign:\*\* Stopping the beacon chain\*\*

```
sudo systemctl stop beacon-chain
```
{% endtab %}

{% tab title="Teku" %}
{% hint style="info" %}
[PegaSys Teku](https://consensys.net/knowledge-base/ethereum-2/teku/) (formerly known as Artemis) is a Java-based Ethereum 2.0 client designed & built to meet institutional needs and security requirements. PegaSys is an arm of [ConsenSys](https://consensys.net) dedicated to building enterprise-ready clients and tools for interacting with the core Ethereum platform. Teku is Apache 2 licensed and written in Java, a language notable for its materity & ubiquity.
{% endhint %}

#### :gear: 4.1 Build Teku from source

Install git.

```
sudo apt-get install git -y
```

Install Java 11.

For **Ubuntu 20.x**, use the following

```
sudo apt update
sudo apt install openjdk-11-jdk -y
```

Verify Java 11+ is installed.

```bash
java --version
```

Install and build Teku.

```bash
mkdir ~/git
cd ~/git
git clone https://github.com/ConsenSys/teku.git
cd teku
./gradlew distTar installDist
```

{% hint style="info" %}
This build process may take a few minutes.
{% endhint %}

Verify Teku was installed properly by displaying the version.

```bash
cd $HOME/git/teku/build/install/teku/bin
./teku --version
```

Copy the teku binary file to `/usr/bin/teku`

```bash
sudo cp -r $HOME/git/teku/build/install/teku /usr/bin/teku
```

#### :fire: 4.2. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, [ensure your validator's firewall ports are open and reachable.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall)

* **Teku beacon chain node** will use port 9000 for tcp and udp
* \*\*eth1 \*\*node requires port 30303 for tcp and udp

{% hint style="info" %}
\*\*\*\*:sparkles: \*\*Port Forwarding Tip: \*\*You'll need to forward and open ports to your validator. Verify it's working with [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) or [https://canyouseeme.org/](https://canyouseeme.org) .
{% endhint %}

#### :snowboarder: 4.3. Configure the beacon chain and validator

{% hint style="info" %}
Teku combines both the beacon chain and validator into one process.
{% endhint %}

Setup a directory structure for Teku.

```bash
sudo mkdir -p /var/lib/teku
sudo mkdir -p /etc/teku
sudo chown $(whoami):$(whoami) /var/lib/teku
```

Copy your `validator_files` directory to the data directory we created above and remove the extra deposit\_data file.

```bash
cp -r $HOME/eth2deposit-cli/validator_keys /var/lib/teku
rm /var/lib/teku/validator_keys/deposit_data*
```

{% hint style="danger" %}
**WARNING**: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

Storing your **keystore password** in a text file is required so that Teku can decrypt and load your validators automatically.

Update `my_keystore_password_goes_here` with your **keystore password** between the single quotation marks and then run the command to save it to validators-password.txt

```bash
echo 'my_keystore_password_goes_here' > $HOME/validators-password.txt
```

Confirm that your **keystore password** is correct.

```bash
cat $HOME/validators-password.txt
```

Move the password file and make it read-only.

```bash
sudo mv $HOME/validators-password.txt /etc/teku/validators-password.txt
sudo chmod 600 /etc/teku/validators-password.txt
```

Clear the bash history in order to remove traces of keystore password.

```bash
shred -u ~/.bash_history && touch ~/.bash_history
```

:rocket:\*\* Setup Graffiti and POAP\*\*

Setup your `graffiti`, a custom message included in blocks your validator successfully proposes.

Run the following command to set the `MY_GRAFFITI` variable. Replace `<my POAP string or message>` between the single quotes.

```bash
MY_GRAFFITI='<my POAP string or message>'
```

```bash
# Examples
# MY_GRAFFITI='poapAAAAACGatUA1bLuDnL4FMD13BfoD'
# MY_GRAFFITI='eth2 rulez!'
```

{% hint style="info" %}
Learn more about [POAP - The Proof of Attendance token.](https://www.poap.xyz)
{% endhint %}

:fast\_forward: **Setup Teku Checkpoint Sync**

{% hint style="info" %}
Teku's Checkpoint Sync utilizes Infura to create the fastest syncing Ethereum beacon chain.
{% endhint %}

1\. Sign up for [a free infura account](https://infura.io/register).

2\. Create a project.

![](../../../.gitbook/assets/inf1.png)

3\. Add a project name and save changes.

4\. Copy your Project's ENDPOINT. Ensure the correct Network is selected with the dropdown box.

![](../../../.gitbook/assets/inf2.png)

Replace `<my infura Project's ENDPOINT>` with your Infura endpoint and then run the following command to set the `INFURA_PROJECT_ENDPOINT` variable.

```bash
INFURA_PROJECT_ENDPOINT=<my Infura Project's ENDPOINT>
```

```bash
# Example
# INFURA_PROJECT_ENDPOINT=https://1Rjimg6q8hxGaRfxmEf9vxyBEk5n:c42acfe90bcae227f9ec19b22e733550@eth2-beacon-mainnet.infura.io
```

Confirm that your Infura Project Endpoint looks correct.

```bash
echo $INFURA_PROJECT_ENDPOINT
```

Generate your Teku Config file. Simply copy and paste.

```bash
cat > $HOME/teku.yaml << EOF
# network
network: "mainnet"
initial-state: "${INFURA_PROJECT_ENDPOINT}/eth/v1/debug/beacon/states/finalized" 

# p2p
p2p-enabled: true
p2p-port: 9000

# validators
validator-keys: "/var/lib/teku/validator_keys:/var/lib/teku/validator_keys"
validators-graffiti: "${MY_GRAFFITI}"

# Eth 1
eth1-endpoint: "http://localhost:8545"

# metrics
metrics-enabled: true
metrics-port: 8008

# database
data-path: "/var/lib/teku"
data-storage-mode: "archive"

# rest api
rest-api-port: 5051
rest-api-docs-enabled: true
rest-api-enabled: true

# logging
log-include-validator-duties-enabled: true
log-destination: CONSOLE
EOF
```

Move the config file to `/etc/teku`

```bash
sudo mv $HOME/teku.yaml /etc/teku/teku.yaml
```

#### :tophat: 4.4 Import validator key

{% hint style="info" %}
When specifying directories for your validator-keys, Teku expects to find identically named keystore and password files.

For example `keystore-m_12221_3600_1_0_0-11222333.json `and `keystore-m_12221_3600_1_0_0-11222333.txt`
{% endhint %}

Create a corresponding password file for every one of your validators.

```bash
for f in /var/lib/teku/validator_keys/keystore*.json; do cp /etc/teku/validators-password.txt /var/lib/teku/validator_keys/$(basename $f .json).txt; done
```

Verify that your validator's keystore and validator's passwords are present by checking the following directory.

```bash
ll /var/lib/teku/validator_keys
```

#### :checkered\_flag: 4.5. Start the beacon chain and validator

Use \*\*systemd \*\*to manage starting and stopping teku.

**🍰 Benefits of using systemd for your beacon chain and validator**

1. Auto-start your beacon chain when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed beacon chain processes.
3. Maximize your beacon chain up-time and performance.

:tools:\*\* Setup Instructions\*\*

Run the following to create a **unit file** to define your`beacon-chain.service` configuration.

```bash
cat > $HOME/beacon-chain.service << EOF
# The eth2 beacon chain service (part of systemd)
# file: /etc/systemd/system/beacon-chain.service 

[Unit]
Description     = eth2 beacon chain service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
ExecStart       = /usr/bin/teku/bin/teku -c /etc/teku/teku.yaml
Restart         = on-failure
Environment     = JAVA_OPTS=-Xmx5g

[Install]
WantedBy	= multi-user.target
EOF
```

Move the unit file to `/etc/systemd/system`

```bash
sudo mv $HOME/beacon-chain.service /etc/systemd/system/beacon-chain.service
```

Update file permissions.

```bash
sudo chmod 644 /etc/systemd/system/beacon-chain.service
```

Run the following to enable auto-start at boot time and then start your beacon node service.

```
sudo systemctl daemon-reload
sudo systemctl enable beacon-chain
sudo systemctl start beacon-chain
```

{% hint style="success" %}
Nice work. Your beacon chain is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

:tools:** Some helpful systemd commands**

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl --unit=beacon-chain -f
```

```bash
#view log since yesterday
journalctl --unit=beacon-chain --since=yesterday
```

```bash
#view log since today
journalctl --unit=beacon-chain --since=today
```

```bash
#view log between a date
journalctl --unit=beacon-chain --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

:white\_check\_mark:\*\* Check whether the beacon chain is active\*\*

```
sudo systemctl is-active beacon-chain
```

:mag\_right:\*\* View the status of the beacon chain\*\*

```
sudo systemctl status beacon-chain
```

:arrows\_counterclockwise:\*\* Restarting the beacon chain\*\*

```
sudo systemctl reload-or-restart beacon-chain
```

:octagonal\_sign:\*\* Stopping the beacon chain\*\*

```
sudo systemctl stop beacon-chain
```
{% endtab %}

{% tab title="Prysm" %}
{% hint style="info" %}
[Prysm](https://github.com/prysmaticlabs/prysm) is a Go implementation of Ethereum 2.0 protocol with a focus on usability, security, and reliability. Prysm is developed by [Prysmatic Labs](https://prysmaticlabs.com), a company with the sole focus on the development of their client. Prysm is written in Go and released under a GPL-3.0 license.
{% endhint %}

#### :gear: 4.1. Install Prysm

```bash
mkdir ~/prysm && cd ~/prysm 
curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh 
```

#### :fire: 4.2. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, [ensure your validator's firewall ports are open and reachable.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall)

* **Prysm beacon chain node** will use port 12000 for udp and port 13000 for tcp
* **eth1** node requires port 30303 for tcp and udp

{% hint style="info" %}
:sparkles: **Port Forwarding Tip:** You'll need to forward and open ports to your validator. Verify it's working with [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) or [https://canyouseeme.org/](https://canyouseeme.org) .
{% endhint %}

#### :tophat: 4.3. Import validator key

Accept terms of use, accept default wallet location, enter a new **prysm-only password** to encrypt your local prysm wallet files and enter the **keystore password** for your imported accounts.

{% hint style="info" %}
If you wish, you can use the same password for the \*\*keystore \*\*and **prysm-only**.
{% endhint %}

```bash
$HOME/prysm/prysm.sh validator accounts import --mainnet --keys-dir=$HOME/eth2deposit-cli/validator_keys
```

Verify your validators imported successfully.

```bash
$HOME/prysm/prysm.sh validator accounts list --mainnet
```

Confirm your validator's pubkeys are listed.

> \#Example output:
>
> Showing 1 validator account View the eth1 deposit transaction data for your accounts by running \`validator accounts list --show-deposit-data
>
> Account 0 | pens-brother-heat\
> \[validating public key] 0x2374.....7121

{% hint style="danger" %}
**WARNING**: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

#### :snowboarder: 4.4. Start the beacon chain

:cake:\*\* Benefits of using systemd for your beacon chain and validator\*\*

1. Auto-start your beacon chain when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed beacon chain processes.
3. Maximize your beacon chain up-time and performance.

:tools:\*\* Setup Instructions\*\*

Run the following to create a **unit file** to define your`beacon-chain.service` configuration. Simply copy and paste.

```bash
cat > $HOME/beacon-chain.service << EOF 
# The eth2 beacon chain service (part of systemd)
# file: /etc/systemd/system/beacon-chain.service 

[Unit]
Description     = eth2 beacon chain service
Wants           = network-online.target
After           = network-online.target 

[Service]
Type            = simple
User            = $(whoami)
ExecStart       = $(echo $HOME)/prysm/prysm.sh beacon-chain --mainnet --p2p-max-peers=45 --http-web3provider=http://127.0.0.1:8545 --accept-terms-of-use 
Restart         = on-failure

[Install]
WantedBy    = multi-user.target
EOF
```

{% hint style="info" %}
\*\*\*\*:fire: \*\*Prysm Pro Tip: \*\*On the \*\*ExecStart \*\*line, adding the `--fallback-web3provider` flag allows for a backup eth1 node. May use flag multiple times. Make sure the endpoint does not end with a trailing slash or`/` Remove it.

```bash
--fallback-web3provider=<http://<alternate eth1 provider one> --fallback-web3provider=<http://<alternate eth1 provider two>
# Example
# --fallback-web3provider=https://nodes.mewapi.io/rpc/eth --fallback-web3provider=https://mainnet.infura.io/v3/YOUR-PROJECT-ID
```

:money\_with\_wings: Find free ethereum fallback nodes at [https://ethereumnodes.com/](https://ethereumnodes.com)
{% endhint %}

Move the unit file to `/etc/systemd/system`

```bash
sudo mv $HOME/beacon-chain.service /etc/systemd/system/beacon-chain.service
```

Update file permissions.

```bash
sudo chmod 644 /etc/systemd/system/beacon-chain.service
```

Run the following to enable auto-start at boot time and then start your beacon node service.

```
sudo systemctl daemon-reload
sudo systemctl enable beacon-chain
sudo systemctl start beacon-chain
```

{% hint style="success" %}
Nice work. Your beacon chain is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

:tools:** Some helpful systemd commands**

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl --unit=beacon-chain -f
```

```bash
#view log since yesterday
journalctl --unit=beacon-chain --since=yesterday
```

```bash
#view log since today
journalctl --unit=beacon-chain --since=today
```

```bash
#view log between a date
journalctl --unit=beacon-chain --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

:white\_check\_mark:\*\* Check whether the beacon chain is active\*\*

```
sudo systemctl is-active beacon-chain
```

:mag\_right:\*\* View the status of the beacon chain\*\*

```
sudo systemctl status beacon-chain
```

:arrows\_counterclockwise:\*\* Restarting the beacon chain\*\*

```
sudo systemctl reload-or-restart beacon-chain
```

:octagonal\_sign:\*\* Stopping the beacon chain\*\*

```
sudo systemctl stop beacon-chain
```

#### :dna: 4.5. Start the validator <a href="9-start-the-validator" id="9-start-the-validator"></a>

Store your **prysm-only password** in a file and make it read-only. This is required so that Prysm can decrypt and load your validators.

```bash
echo 'my_password_goes_here' > $HOME/.eth2validators/validators-password.txt
sudo chmod 600 $HOME/.eth2validators/validators-password.txt
```

Clear the bash history in order to remove traces of your **prysm-only password.**

```bash
shred -u ~/.bash_history && touch ~/.bash_history
```

:rocket:\*\* Setup Graffiti and POAP\*\*

Setup your `graffiti`, a custom message included in blocks your validator successfully proposes, and earn a POAP token. [Generate your POAP string by supplying an Ethereum 1.0 address here.](https://beaconcha.in/poap)

Run the following command to set the `MY_GRAFFITI` variable. Replace `<my POAP string or message>` between the single quotes.

```bash
MY_GRAFFITI='<my POAP string or message>'
# Examples
# MY_GRAFFITI='poapAAAAACGatUA1bLuDnL4FMD13BfoD'
# MY_GRAFFITI='eth2 rulez!'
```

{% hint style="info" %}
Learn more about [POAP - The Proof of Attendance token.](https://www.poap.xyz)
{% endhint %}

Your choice of running a validator manually from command line or automatically with systemd.

:cake:\*\* Benefits of using systemd for your validator\*\*

1. Auto-start your validator when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed validator processes.
3. Maximize your validator up-time and performance.

:tools:\*\* Setup Instructions for systemd\*\*

Run the following to create a **unit file** to define your`validator.service` configuration. Simply copy and paste.

```bash
cat > $HOME/validator.service << EOF 
# The eth2 validator service (part of systemd)
# file: /etc/systemd/system/validator.service 

[Unit]
Description     = eth2 validator service
Wants           = network-online.target beacon-chain.service
After           = network-online.target 

[Service]
User            = $(whoami)
ExecStart       = $(echo $HOME)/prysm/prysm.sh validator --mainnet --graffiti "${MY_GRAFFITI}" --accept-terms-of-use --wallet-password-file $(echo $HOME)/.eth2validators/validators-password.txt --enable-doppelganger
Restart         = on-failure

[Install]
WantedBy	= multi-user.target
EOF
```

Move the unit file to `/etc/systemd/system`

```bash
sudo mv $HOME/validator.service /etc/systemd/system/validator.service
```

Update file permissions.

```bash
sudo chmod 644 /etc/systemd/system/validator.service
```

Run the following to enable auto-start at boot time and then start your validator.

```
sudo systemctl daemon-reload
sudo systemctl enable validator
sudo systemctl start validator
```

:tools:** Some helpful systemd commands**

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl --unit=validator -f
```

```bash
#view log since yesterday
journalctl --unit=validator --since=yesterday
```

```bash
#view log since today
journalctl --unit=validator --since=today
```

```bash
#view log between a date
journalctl --unit=validator --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

:white\_check\_mark:\*\* Check whether the validator is active\*\*

```
sudo systemctl is-active validator
```

:mag\_right:\*\* View the status of the validator\*\*

```
sudo systemctl status validator
```

:arrows\_counterclockwise:\*\* Restarting the validator\*\*

```
sudo systemctl reload-or-restart validator
```

:octagonal\_sign:\*\* Stopping the validator\*\*

```
sudo systemctl stop validator
```

Verify that your **validator public key** appears in the logs.

```bash
journalctl --unit=validator --since=today
# Example below
# INFO Enabled validator       voting_pubkey: 0x2374.....7121
```
{% endtab %}

{% tab title="Lodestar" %}
{% hint style="info" %}
\*\*\*\*[\*\*Lodestar \*\*](https://lodestar.chainsafe.io)**is a Typescript implementation** of the official [Ethereum 2.0 specification](https://github.com/ethereum/eth2.0-specs) by the [ChainSafe.io](https://lodestar.chainsafe.io) team. In addition to the beacon chain client, the team is also working on 22 packages and libraries. A complete list can be found [here](https://hackmd.io/CcsWTnvRS\_eiLUajr3gi9g). Finally, the Lodestar team is leading the Eth2 space in light client research and development and has received funding from the EF and Moloch DAO for this purpose.
{% endhint %}

#### :gear: 4.1 Build Lodestar from source

Install curl and git.

```bash
sudo apt-get install gcc g++ make git curl -y
```

Install yarn.

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install yarn -y
```

Confirm yarn is installed properly.

```bash
yarn --version
# Should output version >= 1.22.4
```

Install nodejs.

```
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Confirm nodejs is installed properly.

```bash
nodejs -v
# Should output version >= v12.18.3
```

Install and build Lodestar.

```bash
mkdir ~/git
cd ~/git
git clone https://github.com/chainsafe/lodestar.git
cd lodestar
yarn install --ignore-optional
yarn run build
```

{% hint style="info" %}
This build process may take a few minutes.
{% endhint %}

Verify Lodestar was installed properly by displaying the help menu.

```
./lodestar --help
```

#### :fire: 4.2. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, [ensure your validator's firewall ports are open and reachable.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall)

* **Lodestar beacon chain node** will use port 30607 for tcp and port 9000 for udp peer discovery.
* \*\*eth1 \*\*node requires port 30303 for tcp and udp

{% hint style="info" %}
\*\*\*\*:sparkles: \*\*Port Forwarding Tip: \*\*You'll need to forward and open ports to your validator. Verify it's working with [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) or [https://canyouseeme.org/](https://canyouseeme.org) .
{% endhint %}

#### :tophat: 4.3. Import validator key

```bash
./lodestar account validator import \
  --network mainnet \
  --directory $HOME/eth2deposit-cli/validator_keys
```

Enter your **keystore password** to import accounts.

Confirm your keys were imported properly.

```
./lodestar account validator list --network mainnet
```

{% hint style="danger" %}
**WARNING**: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

#### :snowboarder: 4.4. Start the beacon chain and validator

Run the beacon chain automatically with systemd.

**🍰 Benefits of using systemd for your beacon chain**

1. Auto-start your beacon chain when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed beacon chain processes.
3. Maximize your beacon chain up-time and performance.

:tools:\*\* Setup Instructions\*\*

Run the following to create a **unit file** to define your`beacon-chain.service` configuration. Simply copy and paste.

```bash
cat > $HOME/beacon-chain.service << EOF 
# The eth2 beacon chain service (part of systemd)
# file: /etc/systemd/system/beacon-chain.service 

[Unit]
Description     = eth2 beacon chain service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
WorkingDirectory= $(echo $HOME)/git/lodestar
ExecStart       = $(echo $HOME)/git/lodestar/lodestar beacon --network mainnet --eth1.providerUrl http://localhost:8545 --weakSubjectivitySyncLatest true --metrics.enabled true --metrics.serverPort 8008
Restart         = on-failure

[Install]
WantedBy	= multi-user.target
EOF
```

Move the unit file to `/etc/systemd/system`

```bash
sudo mv $HOME/beacon-chain.service /etc/systemd/system/beacon-chain.service
```

Update file permissions.

```bash
sudo chmod 644 /etc/systemd/system/beacon-chain.service
```

Run the following to enable auto-start at boot time and then start your beacon node service.

```
sudo systemctl daemon-reload
sudo systemctl enable beacon-chain
sudo systemctl start beacon-chain
```

{% hint style="success" %}
Nice work. Your beacon chain is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

:tools:** Some helpful systemd commands**

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl --unit=beacon-chain -f
```

```bash
#view log since yesterday
journalctl --unit=beacon-chain --since=yesterday
```

```bash
#view log since today
journalctl --unit=beacon-chain --since=today
```

```bash
#view log between a date
journalctl --unit=beacon-chain --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

:white\_check\_mark:\*\* Check whether the beacon chain is active\*\*

```
sudo systemctl is-active beacon-chain
```

:mag\_right:\*\* View the status of the beacon chain\*\*

```
sudo systemctl status beacon-chain
```

:arrows\_counterclockwise:\*\* Restarting the beacon chain\*\*

```
sudo systemctl reload-or-restart beacon-chain
```

:octagonal\_sign:\*\* Stopping the beacon chain\*\*

```
sudo systemctl stop beacon-chain
```

#### :dna: 4.5. Start the validator

:rocket:\*\* Setup Graffiti and POAP\*\*

Setup your `graffiti`, a custom message included in blocks your validator successfully proposes, and earn a POAP token. [Generate your POAP string by supplying an Ethereum 1.0 address here.](https://beaconcha.in/poap)

Run the following command to set the `MY_GRAFFITI` variable. Replace `<my POAP string or message>` between the single quotes.

```bash
MY_GRAFFITI='<my POAP string or message>'
# Examples
# MY_GRAFFITI='poapAAAAACGatUA1bLuDnL4FMD13BfoD'
# MY_GRAFFITI='eth2 rulez!'
```

{% hint style="info" %}
Learn more about [POAP - The Proof of Attendance token.](https://www.poap.xyz)
{% endhint %}

Run the validator automatically with systemd.

**🍰 Benefits of using systemd for your validator**

1. Auto-start your validator when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed validator processes.
3. Maximize your validator up-time and performance.

:tools:\*\* Setup Instructions\*\*

Run the following to create a **unit file** to define your`validator.service` configuration. Simply copy and paste.

```bash
cat > $HOME/validator.service << EOF 
# The eth2 validator service (part of systemd)
# file: /etc/systemd/system/validator.service 

[Unit]
Description     = eth2 validator service
Wants           = network-online.target beacon-chain.service
After           = network-online.target 

[Service]
User            = $(whoami)
WorkingDirectory= $(echo $HOME)/git/lodestar
ExecStart       = $(echo $HOME)/git/lodestar/lodestar validator --network mainnet --graffiti "${MY_GRAFFITI}"
Restart         = on-failure

[Install]
WantedBy	= multi-user.target
EOF
```

Move the unit file to `/etc/systemd/system`

```bash
sudo mv $HOME/validator.service /etc/systemd/system/validator.service
```

Update file permissions.

```bash
sudo chmod 644 /etc/systemd/system/validator.service
```

Run the following to enable auto-start at boot time and then start your validator.

```
sudo systemctl daemon-reload
sudo systemctl enable validator
sudo systemctl start validator
```

{% hint style="success" %}
Nice work. Your validator is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

:tools:** Some helpful systemd commands**

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl --unit=validator -f
```

```bash
#view log since yesterday
journalctl --unit=validator --since=yesterday
```

```bash
#view log since today
journalctl --unit=validator --since=today
```

```bash
#view log between a date
journalctl --unit=validator --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

:white\_check\_mark:\*\* Check whether the validator is active\*\*

```
sudo systemctl is-active validator
```

:mag\_right:\*\* View the status of the validator\*\*

```
sudo systemctl status validator
```

:arrows\_counterclockwise:\*\* Restarting the validator\*\*

```
sudo systemctl reload-or-restart validator
```

:octagonal\_sign:\*\* Stopping the validator\*\*

```
sudo systemctl stop validator
```
{% endtab %}
{% endtabs %}

## :clock3:5. Time Synchronization

{% hint style="info" %}
Because beacon chain relies on accurate times to perform attestations and produce blocks, your computer's time must be accurate to real NTP or NTS time within 0.5 seconds.
{% endhint %}

Setup **Chrony** with [this guide.](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-setup-chrony)

{% hint style="info" %}
chrony is an implementation of the Network Time Protocol and helps to keep your computer's time synchronized with NTP.
{% endhint %}

{% hint style="warning" %}
Running multiple time synchronization services is known to cause issues. Ensure only either Chrony or only 1 NTP service is running.
{% endhint %}

## :mag\_right:6. Monitoring your validator with Grafana and Prometheus

Refer to [this monitoring guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/monitoring-your-validator-with-grafana-and-prometheus).

## :man\_mage:7. Update your consensus client (ETH2 client)

Refer to [this quick guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/how-to-update-your-eth2-client).

## :fire:8. Additional Useful Tips

Refer to [this quick guide.](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/additional-useful-eth-staking-tips)

## :city\_sunset: 9. Join the community on Discord and Reddit

### :mobile\_phone: Discord

* Lighthouse: [https://discord.com/invite/cyAszAh](https://discord.com/invite/cyAszAh)
* Nimbus: [https://discord.com/invite/XRxWahP](https://discord.com/invite/XRxWahP)
* Teku: [https://discord.com/invite/7hPv2T6](https://discord.com/invite/7hPv2T6)
* Prysm: [https://discord.com/invite/XkyZSSk4My](https://discord.com/invite/XkyZSSk4My)
* Lodestar: [https://discord.com/invite/aMxzVcr](https://discord.com/invite/aMxzVcr)

### :earth\_africa: Reddit r/ethStaker

* [https://www.reddit.com/r/ethstaker/](https://www.reddit.com/r/ethstaker/)

## :jigsaw:10. Reference Material

Appreciate the hard work done by the fine folks at the following links which served as a foundation for creating this guide.

* [https://launchpad.ethereum.org/en/](https://launchpad.ethereum.org/en/)
* [https://consensys.net/knowledge-base/ethereum-2/teku/](https://consensys.net/knowledge-base/ethereum-2/teku/)
* [https://docs.teku.pegasys.tech/en/latest/HowTo/Get-Started/Installation-Options/Build-From-Source/](https://docs.teku.pegasys.tech/en/latest/HowTo/Get-Started/Installation-Options/Build-From-Source/)
* [https://lighthouse-book.sigmaprime.io/intro.html](https://lighthouse-book.sigmaprime.io/intro.html)
* [https://nimbus.guide/intro.html](https://nimbus.guide/intro.html)
* [https://docs.prylabs.network/docs/getting-started/](https://docs.prylabs.network/docs/getting-started/)
* [https://chainsafe.github.io/lodestar/installation/](https://chainsafe.github.io/lodestar/installation/)

## :tada:11. Bonus links

### :bricks: ETH Block Explorers

* [https://beaconcha.in/](https://beaconcha.in)
* [https://beaconscan.com/](https://beaconscan.com)

### :notepad\_spiral: Latest Eth Info

* [https://hackmd.io/@benjaminion/eth2\_news](https://hackmd.io/@benjaminion/eth2\_news)
* [https://www.reddit.com/r/ethstaker](https://www.reddit.com/r/ethstaker)
* [https://blog.ethereum.org/](https://blog.ethereum.org)

### :family\_mwgb: Additional ETH Community Guides

* [https://someresat.medium.com/](https://someresat.medium.com)
* [https://github.com/metanull-operator/eth2-ubuntu](https://github.com/metanull-operator/eth2-ubuntu)
* [https://agstakingco.gitbook.io/eth-2-0-staking-guide-prater-lighthouse/](https://agstakingco.gitbook.io/eth-2-0-staking-guide-prater-lighthouse/)
* [https://www.reddit.com/r/ethstaker/comments/j3mlup/a\_slightly\_updated\_look\_at\_hardware\_for\_staking/](https://www.reddit.com/r/ethstaker/comments/j3mlup/a\_slightly\_updated\_look\_at\_hardware\_for\_staking/)
* [https://raymonddurk.medium.com/how-to-stake-for-ethereum-2-0-with-dappnode-231fa7689c02](https://raymonddurk.medium.com/how-to-stake-for-ethereum-2-0-with-dappnode-231fa7689c02)
* [https://kb.beaconcha.in/](https://kb.beaconcha.in)

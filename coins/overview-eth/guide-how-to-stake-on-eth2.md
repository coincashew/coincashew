---
description: >-
  The Medalla Testnet is a public multi-client network. It implements the
  Ethereum 2.0 Phase 0 protocol for a proof-of-stake blockchain, enabling anyone
  holding Goerli test ETH to join.
---

# Guide: How to stake on ETH2 Medalla Testnet with Prysm on Ubuntu

{% hint style="success" %}
[Prysm](https://github.com/prysmaticlabs/prysm) is a Go implementation of Ethereum 2.0 protocol with a focus on usability, security, and reliability. Prysm is developed by [Prysmatic Labs](https://prysmaticlabs.com/), a company with the sole focus on the development of their client. Prysm is written in Go and released under a GPL-3.0 license.
{% endhint %}

## 🏁 0. Prerequisites

### 👩💻 Skills for operating a eth2 validator and beacon node

As a validator for eth2, you will typically have the following abilities:

* operational knowledge of how to set up, run and maintain a eth2 beacon node and validator continuously
* a commitment to maintain your validator 24/7/365
* basic operating system skills

### \*\*\*\*🎗 **Minimum Setup Requirements**

* **Operating system:** 64-bit Linux \(i.e. Ubuntu 18.04.4 LTS\)
* **Processor:** Dual core CPU
* **Memory:** 4GB RAM
* **Storage:** 20GB SSD
* **Internet:** 24/7 broadband internet connection with speeds at least 1 Mbps.
* **Power:** 24/7 electrical power
* **ETH balance:** at least 32 Goerli ETH
* **Wallet**: Metamask installed

### 🏋♀ Recommended Futureproof Hardware Setup

* **Operating system:** 64-bit Linux \(i.e. Ubuntu 18.04.4 LTS\)
* **Processor:** Octa core CPU
* **Memory:** 32GB RAM
* **Storage:** 2 TB SSD
* **Internet:** Multiple 24/7 broadband internet connections with speeds at least 100 Mbps \(i.e. fiber + cellular 4G\)
* **Power:** Redundant 24/7 electrical power with uninterruptible power supply \(UPS\)
* **ETH balance:** at least 32 Goerli ETH
* **Wallet**: Metamask installed

If you need to install Ubuntu, refer to

{% page-ref page="../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}

If you need to install Metamask, refer to

{% page-ref page="../../wallets/browser-wallets/metamask-ethereum.md" %}

## 🤖 1. Install Prysm

```text
 mkdir prysm && cd prysm 
 curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh 
```

{% hint style="info" %}
Prysm is a Ethereum 2.0 client and it comes in two components.

**Beacon chain client** - Responsible for managing the state of the beacon chain, validator shuffling, and more.

**Validator client** - Responsible for producing new blocks and attestations in the beacon chain and shard chains.
{% endhint %}

## 🛸 2. Download geth, a eth1 node

{% hint style="info" %}
Ethereum 2.0 requires a connection to Ethereum 1.0 in order to monitor for 32 ETH validator deposits. Hosting your own Ethereum 1.0 node is the best way to maximize decentralization and minimize dependency on third parties such as Infura.
{% endhint %}

```text
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update -y
sudo apt-get install ethereum -y
```

## ⚙ 3. Create a geth startup script

```text
cat > startGethNode.sh << EOF 
geth --goerli --datadir="$HOME/Goerli" --rpc
EOF
```

## 👩🌾 4. Start the geth node for ETH Goerli testnet <a id="3-start-the-geth-node-for-eth-goerli-testnet"></a>

```text
chmod +x startGethNode.sh
./startGethNode.sh
```

{% hint style="info" %}
Syncing the node could take up to 1 hour.
{% endhint %}

{% hint style="success" %}
You are fully sync'd when you see the message: `Imported new chain segment`
{% endhint %}

## 🚀 5. Obtain Goerli test network ETH

Join the [Prysmatic Labs Discord](https://discord.com/invite/YMVYzv6) and send a request for ETH in the **`-request-goerli-eth channel`**

```text
!send <your metamask goerli network ETH address>
```

Otherwise, visit the 🚰 [Goerli Authenticated Faucet](https://faucet.goerli.mudit.blog).

## 👩💻6. Signup to be a validator at the Launchpad

1. Visit [https://medalla.launchpad.ethereum.org/](https://medalla.launchpad.ethereum.org/)
2. Study the eth2 phase 0 overview material. Understanding eth2 is the key to success!
3. Enter the amount of validators you would like to run.
4. Install dependencies, the ethereum foundation deposit tool and generate keys.

```text
sudo apt install python3-pip git
```

```text
mkdir ~/git
cd ~/git
git clone https://github.com/ethereum/eth2.0-deposit-cli.git
cd eth2.0-deposit-cli
sudo ./deposit.sh install
```

```text
./deposit.sh --chain medalla
```

5. Follow the prompts and pick a password. Write down your mnemonic and keep this safe, preferably **offline**.

6. Upload the `deposit_data.json` found in the `validator_keys` directory.

7. Connect your metamask wallet, review and accept terms.

8. Confirm the transaction.

{% hint style="danger" %}
Be sure to safely save your mnemonic seed offline.
{% endhint %}

## 🎩 7. Import validator key

```text
~/prysm/prysm.sh validator accounts-v2 import --keys-dir=~/git/eth2.0-deposit-cli/validator_keys
```

Accept default locations and enter a password to your imported accounts.

{% hint style="danger" %}
**WARNING**: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

## 🔥 8. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, ensure your beacon node's ports are open and reachable. Use [https://canyouseeme.org/](https://canyouseeme.org/) to verify.

* **Beacon chain** requires port 12000 for udp and port 13000 for tcp
* **geth** node requires port 30303 for tcp and udp

## 🏂 9. Start the beacon chain

{% hint style="warning" %}
If you participated in any of the prior test nets, you need to clear the database.

```text
~/prysm/prysm.sh beacon-chain --clear-db
```
{% endhint %}

In a new terminal, start the beacon chain.

```text
~/prysm/prysm.sh beacon-chain \
--p2p-host-ip=$(curl -s v4.ident.me) \
--http-web3provider=$HOME/Goerli/geth.ipc
```

## 🚥 10. Start the validator

In a new terminal, start the validator.

```text
~/prysm/prysm.sh validator \
--monitoring-host "0.0.0.0" \ 
--beacon-rpc-provider "127.0.0.1:4000" \
--graffiti "prysm and eth2 IS THE GOING TO THE MOON"
```

{% hint style="success" %}
Congratulations. Once your beacon-chain is sync'd, validator up and running, you just wait for activation. This process takes 4-5 hours. When you're assigned, your validator will begin creating and voting on blocks as well as earning eth2 staking rewards.
{% endhint %}

## 🕒 11. Time Synchronization

{% hint style="info" %}
Because beacon chain relies on accurate times to perform attestations and produce blocks, your computer's time must be accurate to real NTP or NTS time within 0.5 seconds.
{% endhint %}

Setup **Chrony** with the following guide.

{% page-ref page="../overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-setup-chrony.md" %}

{% hint style="info" %}
chrony is an implementation of the Network Time Protocol and helps to keep your computer's time synchronized with NTP.
{% endhint %}

## 🎞 12. Reference Material

Check out the official documentation at:

{% embed url="https://medalla.launchpad.ethereum.org/" %}

{% embed url="https://prylabs.net/participate" %}


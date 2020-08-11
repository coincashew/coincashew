---
description: >-
  Medalla is a multi-client ETH 2.0 testnet. It implements the Ethereum 2.0
  Phase 0 protocol for a proof-of-stake blockchain, enabling anyone holding
  Goerli test ETH to join.
---

# Guide: How to stake on ETH2 Medalla Testnet with Lighthouse on Ubuntu

{% hint style="success" %}
[Lighthouse](https://github.com/sigp/lighthouse) is an Eth2.0 client with a heavy focus on speed and security. The team behind it, [Sigma Prime](https://sigmaprime.io/), is an information security and software engineering firm who have funded Lighthouse along with the Ethereum Foundation, Consensys, and private individuals. Lighthouse is built in Rust and offered under an Apache 2.0 License.
{% endhint %}

## 🏁 0. Prerequisites

### 👩💻 Skills for operating a eth2 validator and beacon node

As a validator for eth2, you will typically have the following abilities:

* operational knowledge of how to set up, run and maintain a eth2 beacon node and validator continuously
* a commitment to maintain your validator 24/7/365
* basic operating system skills
* and have read the [8 Things Every Eth2 validator should know.](https://medium.com/chainsafe-systems/8-things-every-eth2-validator-should-know-before-staking-94df41701487)

### \*\*\*\*🎗 **Minimum Setup Requirements**

* **Operating system:** 64-bit Linux \(i.e. Ubuntu 20.04 LTS\)
* **Processor:** Dual core CPU, Intel Core i5–760 or AMD FX-8100 or better
* **Memory:** 4GB RAM
* **Storage:** 20GB SSD
* **Internet:** Broadband internet connection with speeds at least 1 Mbps.
* **Power:** Reliable electrical power.
* **ETH balance:** at least 32 Goerli ETH
* **Wallet**: Metamask installed

### 🏋♀ Recommended Hardware Setup

* **Operating system:** 64-bit Linux \(i.e. Ubuntu 20.04 LTS\)
* **Processor:** Quad core CPU, Intel Core i7–4770 or AMD FX-8310 or better
* **Memory:** 8GB RAM
* **Storage:** 100GB SSD
* **Internet:** Broadband internet connections with speeds at least 10 Mbps
* **Power:** Reliable electrical power with uninterruptible power supply \(UPS\)
* **ETH balance:** at least 32 Goerli ETH
* **Wallet**: Metamask installed

If you need to install Ubuntu, refer to

{% page-ref page="../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}

If you need to install Metamask, refer to

{% page-ref page="../../wallets/browser-wallets/metamask-ethereum.md" %}

## 🛸 1. Install a ETH1 node

{% hint style="info" %}
Ethereum 2.0 requires a connection to Ethereum 1.0 in order to monitor for 32 ETH validator deposits. Hosting your own Ethereum 1.0 node is the best way to maximize decentralization and minimize dependency on third parties such as Infura.
{% endhint %}

Your choice of either [**OpenEthereum**](https://www.parity.io/ethereum/)**,** [**Geth**](https://geth.ethereum.org/)**,** [**Besu**](https://besu.hyperledger.org/) **or** [**Nethermind**](https://www.nethermind.io/)**.**

{% tabs %}
{% tab title="OpenEthereum \(Parity\)" %}
####  🤖 Install and run OpenEthereum.

```text
mkdir ~/openethereum && cd ~/openethereum
wget https://github.com/openethereum/openethereum/releases/download/v3.0.1/openethereum-linux-v3.0.1.zip
unzip openethereum*.zip
chmod +x openethereum
rm openethereum*.zip
```

#### ⛓ Start OpenEthereum on goerli chain.

```text
./openethereum --chain goerli
```
{% endtab %}

{% tab title="Geth" %}
#### 🧬 Install from the repository.

```text
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update -y
sudo apt-get install ethereum -y
```

#### 🐣 Start the geth node for ETH Goerli testnet.

```text
geth --goerli --datadir="$HOME/Goerli" --rpc
```
{% endtab %}

{% tab title="Besu" %}
#### 🧬 Install java dependency.

```text
sudo apt install openjdk-11-jdk
```

#### 🌜 Download and unzip Besu.

```text
cd
wget -O besu.tar.gz https://bintray.com/hyperledger-org/besu-repo/download_file?file_path=besu-1.5.0.tar.gz
tar -xvf besu.tar.gz
rm besu.tar.gz
cd besu-1.5.0/bin
```

#### ⛓ Run Besu on the goerli network.

```text
./besu --network=goerli --data-path="$HOME/Goerli"
```
{% endtab %}

{% tab title="Nethermind" %}
#### ⚙ Install dependencies.

```text
sudo apt-get update && sudo apt-get install libsnappy-dev libc6-dev libc6 unzip -y
```

#### 🌜 Download and unzip Nethermind.

```text
mkdir ~/nethermind && cd ~/nethermind
wget -O nethermind.zip https://nethdev.blob.core.windows.net/builds/nethermind-linux-amd64-1.8.77-9d3a58a.zip
unzip nethermind.zip
rm nethermind.zip
```

#### 🛸 Launch Nethermind.

```text
./Nethermind.Launcher
```

* Select Ethereum Node
* Select Goerli select Fast sync 
* Yes to enable web3 / JSON RPC
* Accept default IP
* Skip ethstats registration
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Syncing the node could take up to 1 hour.
{% endhint %}

{% hint style="success" %}
Your eth1 node is fully sync'd when these events occur.

* **`OpenEthereum:`** `Imported #<block number>`
* **`Geth:`** `Imported new chain segment`
* **`Besu:`** `Imported #<block number>`
* **`Nethermind:`** `No longer syncing Old Headers`
{% endhint %}

\`\`

## ⚙ 2. Obtain Goerli test network ETH

Join the [Prysmatic Labs Discord](https://discord.com/invite/YMVYzv6) and send a request for ETH in the **`-request-goerli-eth channel`**

```text
!send <your metamask goerli network ETH address>
```

Otherwise, visit the 🚰 [Goerli Authenticated Faucet](https://faucet.goerli.mudit.blog).

## 👩💻3. Signup to be a validator at the Launchpad

1. Install dependencies, the ethereum foundation deposit tool and generate keys.

```text
sudo apt install python3-pip git -y
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

2. Follow the prompts and pick a password. Write down your mnemonic and keep this safe, preferably **offline**.

3. Follow the steps at [https://medalla.launchpad.ethereum.org/](https://medalla.launchpad.ethereum.org/) but skip the steps you already just completed. Study the eth2 phase 0 overview material. Understanding eth2 is the key to success!

4. Back on the launchpad website, upload the `deposit_data.json` found in the `validator_keys` directory.

5. Connect your metamask wallet, review and accept terms.

6. Confirm the transaction.

{% hint style="danger" %}
Be sure to safely save your mnemonic seed offline.
{% endhint %}

## 👩🌾 4. Install rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

{% hint style="info" %}
 In case of compilation errors, run`rustup update`
{% endhint %}

Enter '1' to proceed with the default install.

Update your environment variables.

```bash
echo export PATH="$HOME/.cargo/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

Install rust dependencies.

```text
sudo apt install -y git gcc g++ make cmake pkg-config libssl-dev
```

## 💡 5. Install Lighthouse

```text
cd ~/git
git clone https://github.com/sigp/lighthouse.git
cd lighthouse
make
```

{% hint style="info" %}
This build process may take up to an hour.
{% endhint %}

Verify lighthouse was installed properly.

```text
lighthouse --version
```

## 🎩 6. Import validator key

```bash
lighthouse account validator import --directory=$HOME/git/eth2.0-deposit-cli/validator_keys
```

Accept default locations and enter a password to your imported accounts.

{% hint style="danger" %}
WARNING: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

## 🔥 7. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, ensure your beacon node's ports are open and reachable. Use [https://canyouseeme.org/](https://canyouseeme.org/) to verify.

* **Lighthouse beacon chain** requires port 9000 for tcp and udp
* **geth** node requires port 30303 for tcp and udp

## 🏂 8. Start the beacon chain

{% hint style="warning" %}
If you participated in any of the prior test nets, you need to clear the database.

```bash
rm -rf $HOME/.lighthouse
```
{% endhint %}

In a new terminal, start the beacon chain.

```bash
lighthouse beacon --eth1 --http --graffiti "poapboP...CHANGEME"
```

{% hint style="danger" %}
Allow the beacon chain to fully sync with eth1 chain before continuing.

Continue when you see the "**Beacon chain initialized"** message.
{% endhint %}

## 🧬 9. Start the validator

```text
lighthouse vc
```

{% hint style="danger" %}
**WARNING**: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

{% hint style="info" %}
**Validator client** - Responsible for producing new blocks and attestations in the beacon chain and shard chains.

**Beacon chain client** - Responsible for managing the state of the beacon chain, validator shuffling, and more.
{% endhint %}

{% hint style="success" %}
Congratulations. Once your beacon-chain is sync'd, validator up and running, you just wait for activation. This process takes up to 8 hours. When you're assigned, your validator will begin creating and voting on blocks while earning ETH staking rewards.

Use [beaconcha.in](https://medalla.beaconcha.in/) and [register an account](https://medalla.beaconcha.in/register) to create alerts and track your validator's performance.
{% endhint %}

## 🕒 10. Time Synchronization

{% hint style="info" %}
Because beacon chain relies on accurate times to perform attestations and produce blocks, your computer's time must be accurate to real NTP or NTS time within 0.5 seconds.
{% endhint %}

Setup **Chrony** with the following guide.

{% page-ref page="../overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-setup-chrony.md" %}

{% hint style="info" %}
chrony is an implementation of the Network Time Protocol and helps to keep your computer's time synchronized with NTP.
{% endhint %}

## 🧩 11. Reference Material

{% embed url="https://medalla.launchpad.ethereum.org/lighthouse" %}

{% embed url="https://lighthouse-book.sigmaprime.io/intro.html" %}

## 🧙♂ 12. Updating Lighthouse

```text
cd ~/git/lighthouse
git pull
make
```

Restart beacon chain and validator as per normal operating procedures.


---
description: >-
  Medalla is a multi-client ETH 2.0 testnet. It implements the Ethereum 2.0
  Phase 0 protocol for a proof-of-stake blockchain, enabling anyone holding
  Goerli test ETH to join.
---

# Guide: How to stake on ETH2 Medalla Testnet with Teku on Ubuntu

{% hint style="success" %}
[PegaSys Teku](https://pegasys.tech/teku/) \(formerly known as Artemis\) is a Java-based Ethereum 2.0 client designed & built to meet institutional needs and security requirements. PegaSys is an arm of [ConsenSys](https://consensys.net/) dedicated to building enterprise-ready clients and tools for interacting with the core Ethereum platform. Teku is Apache 2 licensed and written in Java, a language notable for its materity & ubiquity.
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

## 🤖 1. Download geth, a eth1 node

```text
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update -y
sudo apt-get install ethereum -y
```

or manually download at:

{% embed url="https://geth.ethereum.org/downloads/" %}

## 📄 2. Create a geth startup script

```text
cat > startGethNode.sh << EOF 
geth --goerli --datadir="$HOME/Goerli" --rpc
EOF
```

## 🐣 3. Start the geth node for ETH Goerli testnet

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

## ⚙ 4. Obtain Goerli test network ETH

Join the [Prysmatic Labs Discord](https://discord.com/invite/YMVYzv6) and send a request for ETH in the **`-request-goerli-eth channel`**

```text
!send <your metamask goerli network ETH address>
```

Otherwise, visit the 🚰 [Goerli Authenticated Faucet](https://faucet.goerli.mudit.blog).

## 👩💻5. Signup to be a validator at the Launchpad

1. Visit [https://medalla.launchpad.ethereum.org/](https://medalla.launchpad.ethereum.org/)
2. Study the eth2 phase 0 overview material. Understanding eth2 is the key to success!
3. Enter the amount of validators you would like to run.
4. Install dependencies, the ethereum foundation deposit tool and generate keys.

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

5. Follow the prompts and pick a password. Write down your mnemonic and keep this safe, preferably **offline**.

6. Back on the launchpad website, upload the `deposit_data.json` found in the `validator_keys` directory.

7. Connect your metamask wallet, review and accept terms.

8. Confirm the transaction.

{% hint style="danger" %}
Be sure to safely save your mnemonic seed offline.
{% endhint %}

## 💡 6. Build Teku from source

Install dependencies -- Gradle, Git, tmux and Java JDK.

Download and unzip gradle.

```bash
wget https://services.gradle.org/distributions/gradle-6.5.1-bin.zip
```

```bash
sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle gradle-6.5.1-bin.zip
```

Verify gradle was installed running '`ls`' on the directory.

```bash
ls /opt/gradle/gradle-6.5.1
# LICENSE  NOTICE  bin  getting-started.html  init.d  lib  media
```

Install tmux and git.

```text
sudo apt-get install git tmux -y
```

Install java 14.

```text
sudo apt update
sudo add-apt-repository ppa:linuxuprising/java
```

```text
sudo apt -y install oracle-java14-installer
sudo apt -y install oracle-java14-set-default
```

Confirm java was installed properly.

```bash
java -version
```

Example version output:

> java version "14.0.2" 2020-07-14 Java\(TM\) SE Runtime Environment \(build 14.0.2+12-46\) Java HotSpot\(TM\) 64-Bit Server VM \(build 14.0.2+12-46, mixed mode, sharing\)

Add the following entries with nano `/etc/profile.d/jdk.sh`

```text
sudo nano /etc/profile.d/jdk.sh
```

```text
export JAVA_HOME=/usr/lib/jvm/java-14-oracle
export PATH=$PATH:$JAVA_HOME/bin
```

Reload environment variables.

```text
source /etc/profile.d/jdk.sh
```

Install and build Teku.

```text
cd ~/git
git clone https://github.com/PegaSysEng/teku.git
cd teku
./gradlew distTar installDist
cd build/install/teku
```

{% hint style="info" %}
This build process may take up to an hour.
{% endhint %}

Verify Teku was installed properly by displaying the help menu.

```text
cd $HOME/git/teku/build/install/teku/bin
./teku --help
```

## 🔥 7. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, ensure your beacon node's ports are open and reachable. Use [https://canyouseeme.org/](https://canyouseeme.org/) to verify.

* **Teku beacon chain node** will use port 9151 for tcp and udp
* **geth** node will use port 30303 for tcp and udp

## 🏂 8. Start the beacon chain and validator

{% hint style="warning" %}
If you participated in any of the prior test nets, you need to clear the database.

```text
rm -rf $HOME/.local/share/teku/data
```
{% endhint %}

Store your validator's password in a file.

```text
echo "my_password_goes_here" > $HOME/git/teku/password.txt
```

Update the `--validators-key-files` with the full path to your validator key. If you possess multiple validator keys then separate with commas. Use a [config file](https://docs.teku.pegasys.tech/en/latest/HowTo/Configure/Use-Configuration-File/) if you have many validator keys,

```text
./teku --network=medalla --eth1-endpoint=http://localhost:8545 \
--validators-key-files=$HOME/git/eth2.0-deposit-cli/validator_keys/<my keystore file.json i.e. keystore-m_12...324.json> \
--validators-key-password-files=$HOME/git/teku/password.txt \
--rest-api-enabled=true --rest-api-docs-enabled=true \
--metrics-enabled \
--validators-graffiti="teku and ETH2 the moon!" \
--p2p-port=9151 \
--rest-api-port=5151
```

{% hint style="danger" %}
**WARNING**: DO NOT USE THE ORIGINAL KEYSTORES TO VALIDATE WITH ANOTHER CLIENT, OR YOU WILL GET SLASHED.
{% endhint %}

{% hint style="info" %}
Allow the beacon chain to fully sync with eth1 chain.

This message means your node is synced:

**`Eth1 tracker successfully caught up to chain head`"** 
{% endhint %}

{% hint style="info" %}
**Validator client** - Responsible for producing new blocks and attestations in the beacon chain and shard chains.

**Beacon chain client** - Responsible for managing the state of the beacon chain, validator shuffling, and more.
{% endhint %}

{% hint style="success" %}
Congratulations. Once your beacon-chain is sync'd, validator up and running, you just wait for activation. This process takes up to 8 hours. When you're assigned, your validator will begin creating and voting on blocks while earning ETH staking rewards. 

Use [beaconcha.in](https://medalla.beaconcha.in/) and [register an account](https://medalla.beaconcha.in/register) to create alerts and track your validator's performance.
{% endhint %}



## 🕒 9. Time Synchronization

{% hint style="info" %}
Because beacon chain relies on accurate times to perform attestations and produce blocks, your computer's time must be accurate to real NTP or NTS time within 0.5 seconds.
{% endhint %}

Setup **Chrony** with the following guide.

{% page-ref page="../overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-setup-chrony.md" %}

{% hint style="info" %}
chrony is an implementation of the Network Time Protocol and helps to keep your computer's time synchronized with NTP.
{% endhint %}

## 🧩 10. Reference Material

{% embed url="https://medalla.launchpad.ethereum.org/teku" %}

{% embed url="https://pegasys.tech/teku-ethereum-2-for-enterprise/" %}

{% embed url="https://docs.teku.pegasys.tech/en/latest/HowTo/Get-Started/Build-From-Source/" %}


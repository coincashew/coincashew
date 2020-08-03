# Guide: How to stake on ETH2 Medalla Testnet with Lodestar on Ubuntu

{% hint style="danger" %}
WIP
{% endhint %}

{% hint style="success" %}
**Lodestar is a Typescript implementation** of the official [Ethereum 2.0 specification](https://github.com/ethereum/eth2.0-specs) by the [ChainSafe.io](https://lodestar.chainsafe.io/) team. In addition to the beacon chain client, the team is also working on 22 packages and libraries. A complete list can be found [here](https://hackmd.io/CcsWTnvRS_eiLUajr3gi9g). Finally, the Lodestar team is leading the Eth2 space in light client research and development and has received funding from the EF and Moloch DAO for this purpose.
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

```bash
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update -y
sudo apt-get install ethereum -y
```

or manually download at:

{% embed url="https://geth.ethereum.org/downloads/" %}

## 📄 2. Create a geth startup script

```bash
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

```bash
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

## 💡 6. Build Lodestar from source

Install curl and git.

```bash
sudo apt-get install git curl
```

Install yarn.

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install yarn
```

Confirm yarn is installed properly.

```bash
yarn --version
# Should output version >= 1.22.4
```

Install nodejs.

```text
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
cd ~/git
git clone https://github.com/chainsafe/lodestar.git
cd lodestar
yarn install
yarn run build
```

{% hint style="info" %}
This build process may take up to an hour.
{% endhint %}

Verify Lodestar was installed properly by displaying the help menu.

```text
yarn run cli --help
```

## 🔥 7. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, ensure your beacon node's ports are open and reachable. Use [https://canyouseeme.org/](https://canyouseeme.org/) to verify.

* **Lodestar beacon chain node** will use port 30607 for tcp
* **geth** node will use port 30303 for tcp and udp

## 🏂 8. Start the beacon chain and validator

Store your validator's password in a file.

```text
echo "my_password_goes_here" > $HOME/git/lodestar/password.txt
```

Update the `--validators-key-files` with the full path to your validator key. If you possess multiple validator keys then separate with commas. Use a [config file](https://docs.teku.pegasys.tech/en/latest/HowTo/Configure/Use-Configuration-File/) if you have many validator keys,

```text
yarn run cli beacon --testnet medalla \
  --eth1.provider.url http://localhost:8545 \
  --metrics.serverPort 8009 \
  --graffiti="lodestar and ETH2 the moon!"
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
Congratulations. Once your beacon-chain is sync'd, validator up and running, you just wait for activation. This process takes up to 8 hours. When you're assigned, your validator will begin creating and voting on blocks while earning ETH staking rewards. Find your validator's status at [beaconcha.in](https://altona.beaconcha.in)
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

{% embed url="https://chainsafe.github.io/lodestar/installation/" %}

{% embed url="https://medalla.launchpad.ethereum.org/" %}

{% embed url="https://github.com/ChainSafe/lodestar" %}




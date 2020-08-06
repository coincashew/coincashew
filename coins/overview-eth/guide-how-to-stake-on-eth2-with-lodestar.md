# Guide: How to stake on ETH2 Medalla Testnet with Lodestar on Ubuntu

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

## 🤖 1. Install a ETH1 node

Your choice of either **OpenEthereum** or **Geth**.

{% tabs %}
{% tab title="OpenEthereum \(Parity\)" %}
####  🤖 Install and run OpenEthereum by execute the following.

```text
mkdir ~/openethereum
cd ~/openethereum
wget https://github.com/openethereum/openethereum/releases/download/v3.0.1/openethereum-linux-v3.0.1.zip
unzip openethereum*.zip
chmod +x openethereum
```

#### ⛓ Start the node on goerli chain

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

#### 📄 Create a geth startup script

```bash
cat > startGethNode.sh << EOF 
geth --goerli --datadir="$HOME/Goerli" --rpc
EOF
```

#### 🐣 Start the geth node for ETH Goerli testnet

```text
chmod +x startGethNode.sh
./startGethNode.sh
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Syncing the node could take up to 1 hour.
{% endhint %}

{% hint style="success" %}
You are fully sync'd when you see the message: `Imported new chain segment`
{% endhint %}

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

## 💡 4. Build Lodestar from source

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

## 🔥 5. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, ensure your beacon node's ports are open and reachable. Use [https://canyouseeme.org/](https://canyouseeme.org/) to verify.

* **Lodestar beacon chain node** will use port 30607 for tcp and port 9000 for udp peer discovery.
* **geth** node will use port 30303 for tcp and udp

## 🏂 6. Start the beacon chain and validator

Locate your keystore filename\(s\).

```bash
ll $HOME/git/eth2.0-deposit-cli/validator_keys/
```

Update `MY_KEYSTORE_FILE` with your validator key's filename. If you have multiple validator keys, repeat this sequence for each key.

```text
MY_KEYSTORE_FILENAME=<FILENAME OF YOUR keystore-m_.....json>
```

Copy your **keystore** file to `voting-keystore.json` according to loadstar's expected file naming structure.

```bash
shortPubKey=$(cat ${MY_KEYSTORE_FILENAME} | jq -r '.pubkey')
PUBKEY=$(echo 0x${shortPubKey})
echo VALIDATOR PUBKEY: ${PUBKEY}

mkdir -p $HOME/git/lodestar/.medalla/keystores/${PUBKEY}

cp $HOME/git/eth2.0-deposit-cli/validator_keys/$MY_KEYSTORE_FILENAME \
   $HOME/git/lodestar/.medalla/keystores/${PUBKEY}/voting-keystore.json
```

**Example**: If your **pubkey** is `0x846...0f00` then your keystore should be located as follows:

> `$HOME/git/lodestar/.medalla/keystores/0x846...0f00/voting-keystore.json`

Store your validator's password in a secrets file, named as it's pubKey without 0x.

```bash
mkdir -p $HOME/git/lodestar/.medalla/secrets
echo "my_password_goes_here" > $HOME/git/lodestar/.medalla/secrets/${shortPubKey}
```

Start your beacon chain.

```bash
cd $HOME/git/lodestar
yarn run cli beacon --testnet medalla \
  --eth1.provider.url http://localhost:8545 \
  --metrics.serverPort 8009 \
  --graffiti="lodestar and ETH2 the moon!"
```

{% hint style="warning" %}
If you cannot find peers, then likely port 9000 is already in use. Change the port in the file`.medalla/beacon.config.json` located at **network** &gt; **bindAddr**
{% endhint %}

Start your validator in a new terminal window.

```bash
cd $HOME/git/lodestar
yarn run cli validator run --testnet medalla
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

## 🕒 7. Time Synchronization

{% hint style="info" %}
Because beacon chain relies on accurate times to perform attestations and produce blocks, your computer's time must be accurate to real NTP or NTS time within 0.5 seconds.
{% endhint %}

Setup **Chrony** with the following guide.

{% page-ref page="../overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-setup-chrony.md" %}

{% hint style="info" %}
chrony is an implementation of the Network Time Protocol and helps to keep your computer's time synchronized with NTP.
{% endhint %}

## 🧩 8. Reference Material

{% embed url="https://chainsafe.github.io/lodestar/installation/" %}

{% embed url="https://medalla.launchpad.ethereum.org/" %}

{% embed url="https://github.com/ChainSafe/lodestar" %}




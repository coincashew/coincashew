# Guide: How to stake on ETH2 Medalla Testnet with Lodestar on Ubuntu

{% hint style="danger" %}
**Nov 24 2020 Update**: The [new mainnet guide is located here](guide-or-how-to-setup-a-validator-on-eth2-mainnet/). 

Instructions below are now deprecated and for reference only.
{% endhint %}











{% hint style="info" %}
**Lodestar is a Typescript implementation** of the official [Ethereum 2.0 specification](https://github.com/ethereum/eth2.0-specs) by the [ChainSafe.io](https://lodestar.chainsafe.io) team. In addition to the beacon chain client, the team is also working on 22 packages and libraries. A complete list can be found [here](https://hackmd.io/CcsWTnvRS_eiLUajr3gi9g). Finally, the Lodestar team is leading the Eth2 space in light client research and development and has received funding from the EF and Moloch DAO for this purpose.
{% endhint %}

## :checkered_flag: 0. Prerequisites

### :woman_technologist: Skills for operating a eth2 validator and beacon node

As a validator for eth2, you will typically have the following abilities:

* operational knowledge of how to set up, run and maintain a eth2 beacon node and validator continuously
* a commitment to maintain your validator 24/7/365
* basic operating system skills
* have learned the essentials by watching ['Intro to Eth2 & Staking for Beginners' by Superphiz](https://www.youtube.com/watch?v=tpkpW031RCI)
* have passed or is actively enrolled in the [Eth2 Study Master course](https://ethereumstudymaster.com)
* and have read the [8 Things Every Eth2 validator should know.](https://medium.com/chainsafe-systems/8-things-every-eth2-validator-should-know-before-staking-94df41701487)

### ****:reminder_ribbon:**Minimum Setup Requirements**

* **Operating system: **64-bit Linux (i.e. Ubuntu 20.04 LTS)
* **Processor:** Dual core CPU, Intel Core i5–760 or AMD FX-8100 or better
* **Memory:** 8GB RAM
* **Storage:** 20GB SSD
* **Internet:** Broadband internet connection with speeds at least 1 Mbps.
* **Power:** Reliable electrical power.
* **ETH balance:** at least 32 Goerli ETH
* **Wallet**: Metamask installed

### :woman_lifting_weights: Recommended Hardware Setup

* **Operating system: **64-bit Linux (i.e. Ubuntu 20.04 LTS)
* **Processor:** Quad core CPU, Intel Core i7–4770 or AMD FX-8310 or better
* **Memory:** 32GB RAM
* **Storage:** 100GB SSD
* **Internet: **Broadband internet connections with speeds at least 10 Mbps
* **Power:** Reliable electrical power with uninterruptible power supply (UPS)
* **ETH balance:** at least 32 Goerli ETH
* **Wallet**: Metamask installed

### :unlock: Recommended ETH 2 Node Security

If you need ideas or a reminder on how to secure and harden your node, refer to

{% content-ref url="guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md" %}
[guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md](guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md)
{% endcontent-ref %}

### :tools: Setup Ubuntu

If you need to install Ubuntu, refer to

{% content-ref url="../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}
[install-ubuntu.md](../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md)
{% endcontent-ref %}

### :performing_arts: Setup Metamask

If you need to install Metamask, refer to

{% content-ref url="../../wallets/browser-wallets/metamask-ethereum.md" %}
[metamask-ethereum.md](../../wallets/browser-wallets/metamask-ethereum.md)
{% endcontent-ref %}

## :robot: 1. Install a ETH1 node

{% hint style="info" %}
Ethereum 2.0 requires a connection to Ethereum 1.0 in order to monitor for 32 ETH validator deposits. Hosting your own Ethereum 1.0 node is the best way to maximize decentralization and minimize dependency on third parties such as Infura.
{% endhint %}

Your choice of either [**OpenEthereum**](https://www.parity.io/ethereum/)**, **[**Geth**](https://geth.ethereum.org)**, **[**Besu**](https://besu.hyperledger.org)** or **[**Nethermind**](https://www.nethermind.io)**.**

{% tabs %}
{% tab title="OpenEthereum (Parity)" %}
####  :robot: Install and run OpenEthereum.

```
mkdir ~/openethereum && cd ~/openethereum
wget https://github.com/openethereum/openethereum/releases/download/v3.0.1/openethereum-linux-v3.0.1.zip
unzip openethereum*.zip
chmod +x openethereum
rm openethereum*.zip
```

#### :chains: Start OpenEthereum on goerli chain.

```
./openethereum --chain goerli
```
{% endtab %}

{% tab title="Geth" %}
#### :dna: Install from the repository.

```
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update -y
sudo apt-get install ethereum -y
```

#### :hatching_chick: Start the geth node for ETH Goerli testnet.

```
geth --goerli --datadir="$HOME/Goerli" --rpc
```
{% endtab %}

{% tab title="Besu" %}
#### :dna: Install java dependency.

```
sudo apt install openjdk-11-jdk
```

#### :last_quarter_moon_with_face: Download and unzip Besu.

```
cd
wget -O besu.tar.gz https://bintray.com/hyperledger-org/besu-repo/download_file?file_path=besu-1.5.0.tar.gz
tar -xvf besu.tar.gz
rm besu.tar.gz
cd besu-1.5.0/bin
```

#### :chains: Run Besu on the goerli network.

```
./besu --network=goerli --data-path="$HOME/Goerli"
```
{% endtab %}

{% tab title="Nethermind" %}
#### :gear: Install dependencies.

```
sudo apt-get update && sudo apt-get install libsnappy-dev libc6-dev libc6 unzip -y
```

#### :last_quarter_moon_with_face: Download and unzip Nethermind.

```
mkdir ~/nethermind && cd ~/nethermind
wget -O nethermind.zip https://nethdev.blob.core.windows.net/builds/nethermind-linux-amd64-1.8.77-9d3a58a.zip
unzip nethermind.zip
rm nethermind.zip
```

#### :flying_saucer: Launch Nethermind.

```
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

* **`OpenEthereum: `**`Imported #<block number>`
* **`Geth:`**` Imported new chain segment`
* **`Besu:`**` Imported #<block number>`
* **`Nethermind: `**`No longer syncing Old Headers`
{% endhint %}

## :gear: 2. Obtain Goerli test network ETH

Join the [Prysmatic Labs Discord](https://discord.com/invite/YMVYzv6) and send a request for ETH in the **`-request-goerli-eth channel`**

```
!send <your metamask goerli network ETH address>
```

Otherwise, visit the :potable_water: [Goerli Authenticated Faucet](https://faucet.goerli.mudit.blog).

## :woman_technologist:3. Signup to be a validator at the Launchpad

1. Install dependencies, the ethereum foundation deposit tool and generate keys.

```
sudo apt install python3-pip git -y
```

```
mkdir ~/git
cd ~/git
git clone https://github.com/ethereum/eth2.0-deposit-cli.git
cd eth2.0-deposit-cli
sudo ./deposit.sh install
```

```
./deposit.sh --chain medalla
```

2\. Follow the prompts and pick a password. Write down your mnemonic and keep this safe, preferably **offline**.

3\. Follow the steps at [https://medalla.launchpad.ethereum.org/](https://medalla.launchpad.ethereum.org) but skip the steps you already just completed. Study the eth2 phase 0 overview material. Understanding eth2 is the key to success!

4\. Back on the launchpad website, upload the `deposit_data.json` found in the `validator_keys` directory.

5\. Connect your metamask wallet, review and accept terms.

6\. Confirm the transaction.

{% hint style="danger" %}
Be sure to safely save your mnemonic seed offline.
{% endhint %}

## :bulb: 4. Build Lodestar from source

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

```
yarn run cli --help
```

## :fire: 5. Configure port forwarding and/or firewall

Specific to your networking setup or cloud provider settings, ensure your beacon node's ports are open and reachable. Use [https://canyouseeme.org/](https://canyouseeme.org) to verify.

* **Lodestar beacon chain node** will use port 30607 for tcp and port 9000 for udp peer discovery.
* **geth **node will use port 30303 for tcp and udp

## :snowboarder: 6. Start the beacon chain and validator

Locate your keystore filename(s).

```bash
ll $HOME/git/eth2.0-deposit-cli/validator_keys/
```

Update `MY_KEYSTORE_FILE` with your validator key's filename. If you have multiple validator keys, repeat this sequence for each key.

```
MY_KEYSTORE_FILENAME=<FILENAME OF YOUR keystore-m_.....json>
```

Copy your **keystore **file to `voting-keystore.json` according to loadstar's expected file naming structure.

```bash
shortPubKey=$(cat ${MY_KEYSTORE_FILENAME} | jq -r '.pubkey')
PUBKEY=$(echo 0x${shortPubKey})
echo VALIDATOR PUBKEY: ${PUBKEY}

mkdir -p $HOME/git/lodestar/.medalla/keystores/${PUBKEY}

cp $HOME/git/eth2.0-deposit-cli/validator_keys/$MY_KEYSTORE_FILENAME \
   $HOME/git/lodestar/.medalla/keystores/${PUBKEY}/voting-keystore.json
```

**Example**: If your **pubkey **is `0x846...0f00` then your keystore should be located as follows:

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
  --graffiti="poapboP...CHANGEME"
```

{% hint style="warning" %}
If you cannot find peers, then likely port 9000 is already in use. Change the port in the file`.medalla/beacon.config.json `located at **network **> **bindAddr**
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

Use [beaconcha.in](https://medalla.beaconcha.in) and [register an account](https://medalla.beaconcha.in/register) to create alerts and track your validator's performance.
{% endhint %}

## :clock3: 7. Time Synchronization

{% hint style="info" %}
Because beacon chain relies on accurate times to perform attestations and produce blocks, your computer's time must be accurate to real NTP or NTS time within 0.5 seconds.
{% endhint %}

Setup **Chrony** with the following guide.

{% content-ref url="../overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-setup-chrony.md" %}
[how-to-setup-chrony.md](../overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-setup-chrony.md)
{% endcontent-ref %}

{% hint style="info" %}
chrony is an implementation of the Network Time Protocol and helps to keep your computer's time synchronized with NTP.
{% endhint %}

## :jigsaw: 8. Reference Material

{% embed url="https://discord.gg/yjyvFRP" %}

{% embed url="https://chainsafe.github.io/lodestar/installation/" %}

{% embed url="https://medalla.launchpad.ethereum.org/" %}

{% embed url="https://github.com/ChainSafe/lodestar" %}

## :man_mage: 9. Updating Lodestar

```
cd ~/git/lodestar
git pull
yarn install
yarn run build
```

Restart as per normal operating procedures.

{% hint style="success" %}
Congrats on completing the guide. 

Did you find our guide useful? Let us know with a tip and we'll keep updating it. 

It really energizes us to keep creating the best crypto guides. 

Use [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. :pray: 
{% endhint %}

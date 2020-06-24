---
description: >-
  On Ubuntu/Debian, this guide will illustrate how to install and configure a
  Cardano stakepool from source code.
---

# Guide: How to build a Haskell Testnet Cardano Stakepool

## 🏁 0. Prerequisites

### 🎗 Minimum Setup Requirements

* **Operating system:** 64-bit Linux \(i.e. Ubuntu 20.04 LTS\)
* **Processor:** Dual core CPU
* **Memory:** 4GB RAM
* **Storage:** 20GB
* **Internet:** 24/7 broadband internet connection with speeds at least 1 Mbps.
* **Data Plan**: at least 100MB per hour. 72GB per month.
* **Power:** 24/7 electrical power
* **ADA balance:** at least 1000 fADA

### 🏋♂ Recommended Futureproof Setup

* **Operating system:** 64-bit Linux \(i.e. Ubuntu 20.04 LTS\)
* **Processor:** Quad core or better CPU
* **Memory:** 16GB RAM
* **Storage:** 500GB SSD with RAID
* **Internet:** Multiple 24/7 broadband internet connections with speeds at least 10 Mbps \(i.e. fiber + cellular 4G\)
* **Data Plan**: at least 100MB per hour. 72GB per month.
* **Power:** Redundant 24/7 electrical power with UPS
* **ADA balance:** more pledge is better, to be determined by **a0**, the pledge influence factor

For instructions on installing **Ubuntu**, refer to the following:

{% page-ref page="../../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}

## 🏭 1. Install Cabal and GHC

**Press** Ctrl+Alt+T. This will launch a terminal window. 

First, update packages and install Ubuntu dependencies.

```text
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get -y install curl libsodium-dev build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 -y
```

Install Cabal.

```text
wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig
mkdir -p ~/.local/bin
mv cabal ~/.local/bin/
```

Install GHC.

```text
wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz
tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz
rm ghc-8.6.5-x86_64-deb9-linux.tar.xz
cd ghc-8.6.5
./configure
sudo make install
```

Update PATH to include Cabal and GHC.

```text
echo PATH="~/.local/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

Update cabal and verify the correct versions were installed successfully.

```text
cabal update
cabal -V
ghc -V
```

{% hint style="info" %}
Cabal library should be version 3.2.0.0 and GHC should be version 8.6.5
{% endhint %}

## 🏗 2. Build the node from source code

Download source code and switch to the latest tag. In this case, use `1.14.0` with commit `88ed4d1`.

```text
cd ~
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node
git fetch
git checkout 88ed4d1090fd713e7bcdb969eab42f2202acfa2c
```

Build the cardano-node from source code.

```text
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
cabal install cardano-node cardano-cli
```

{% hint style="info" %}
Building process may take a few minutes up to a few hours depending on your computer's processing power.
{% endhint %}

Copy **cardano-cli** and **cardano-node** files into bin directory.

```text
sudo cp $(find ~/.cabal/store/ghc-8.6.5/cardano-cli-1.14.0* -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find ~/.cabal/store/ghc-8.6.5/cardano-node-1.14.0* -type f -name "cardano-node") /usr/local/bin/cardano-node
```

## 📐 3. Configure the node

Here you'll grab the config.json, genesis.json, and topology.json files needed to configure your node.

```text
cd ~
mkdir cardano-my-node
cd cardano-my-node
wget https://hydra.iohk.io/build/3175192/download/1/shelley_testnet-config.json
wget https://hydra.iohk.io/build/3175192/download/1/shelley_testnet-genesis.json
wget https://hydra.iohk.io/build/3175192/download/1/shelley_testnet-topology.json
```

Run the following to modify **config.json** and 

* update ViewMode to "LiveView"
* update TraceBlockFetchDecisions to "true"

```text
sed -i.bak -e "s/SimpleView/LiveView/g" -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" shelley_testnet-config.json
```

Update **.bashrc** shell variables.

```
echo export CARDANO_NODE_SOCKET_PATH="$HOME/cardano-my-node/db/socket" >> ~/.bashrc
source ~/.bashrc
```

### 🔮 3.1 Configure the block-producer node and the relay nodes

{% hint style="info" %}
A block producing node will be configured with various key-pairs needed for block generation \(cold keys, KES hot keys and VRF hot keys\). It can only connect to its relay nodes.
{% endhint %}

{% hint style="info" %}
A relay node will not be in possession of any keys and will therefore be unable to produce blocks. It will be connected to its block-producing node, other relays and external nodes.
{% endhint %}

![](../../../.gitbook/assets/producer-relay-diagram.png)

Create two new directories, one for each relay node.

```text
mkdir relaynode1
mkdir relaynode2
```

Copy the essential json files to each directory.

```text
cp shelley_testnet-*.json relaynode1
cp shelley_testnet-*.json relaynode2
```

Configure **shelley\_testnet-topology.json** file so that 

* only relay nodes connect to the public internet and your block-producing node
* the block-producing node can only connect to your relay nodes

Update relaynode1 with the following. Simply copy/paste.

```text
cat > relaynode1/shelley_testnet-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "127.0.0.1",
        "port": 3000,
        "valency": 2
      },
      {
        "addr": "127.0.0.1",
        "port": 3002,
        "valency": 2
      },
      {
        "addr": "relays-new.shelley-testnet.dev.cardano.org",
        "port": 3001,
        "valency": 2
      }
    ]
  }
EOF
```

Update relaynode2 with the following. Simply copy/paste.

```text
cat > relaynode2/shelley_testnet-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "127.0.0.1",
        "port": 3000,
        "valency": 2
      },
      {
        "addr": "127.0.0.1",
        "port": 3001,
        "valency": 2
      },
      {
        "addr": "relays-new.shelley-testnet.dev.cardano.org",
        "port": 3001,
        "valency": 2
      }
    ]
  }
EOF
```

Update the block-producer node with the following. Simply copy/paste.

```text
cat > shelley_testnet-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "127.0.0.1",
        "port": 3001,
        "valency": 2
      },
      {
        "addr": "127.0.0.1",
        "port": 3002,
        "valency": 2
      }
    ]
  }
EOF
```

{% hint style="info" %}
Valency tells the node how many connections to keep open. Only DNS addresses are affected. If value is 0, the address is ignored.
{% endhint %}

{% hint style="success" %}
\*\*\*\*✨ **Port Forwarding Tip:** You'll need to forward ports 3001 and 3002 to your computer.
{% endhint %}

## 🤖 4. Create startup scripts

The startup script contains all the variables needed to run a cardano-node such as directory, port, db path, config file, and topology file.

For your **block-producing node**:

```text
cat > startBlockProducingNode.sh << EOF 
DIRECTORY=~/cardano-my-node
PORT=3000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/shelley_testnet-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/shelley_testnet-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF

```

For your **relaynode1**:

```text
cat > relaynode1/startRelayNode1.sh << EOF 
DIRECTORY=~/cardano-my-node/relaynode1
PORT=3001
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/shelley_testnet-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/shelley_testnet-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```

For your **relaynode2**:

```text
cat > relaynode2/startRelayNode2.sh << EOF 
DIRECTORY=~/cardano-my-node/relaynode2
PORT=3002
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/shelley_testnet-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/shelley_testnet-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```

## ✅ 5. Start the node

**Press** Ctrl+Alt+T. This will launch a terminal window. Do this 3 times for 3 terminals. 

Add execute permissions to the script and begin syncing the ADA blockchain!

Run each in a separate terminal.

```text
cd ~/cardano-my-node
chmod +x startBlockProducingNode.sh
./startBlockProducingNode.sh
```

```text
cd ~/cardano-my-node
chmod +x relaynode1/startRelayNode1.sh
./relaynode1/startRelayNode1.sh
```

```text
cd ~/cardano-my-node
chmod +x relaynode2/startRelayNode2.sh
./relaynode2/startRelayNode2.sh
```

![](../../../.gitbook/assets/ada-node-htn.png)

{% hint style="success" %}
Congratulations! Your node is running successfully now. Let it sync up.
{% endhint %}

## ⚙ 6. Generate block-producer keys

Make a KES key pair.

```text
cd ~/cardano-my-node
cardano-cli shelley node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```

{% hint style="info" %}
KES \(key evolving signature\) keys are created to secure your stakepool against hackers who might compromise your keys. On mainnet, these will be regenerated every 90 days.
{% endhint %}

Make a directory to store your cold keys

```text
mkdir ~/cold-keys
pushd ~/cold-keys
```

Make a set of cold keys and create the cold counter file.

```text
cardano-cli shelley node key-gen \
    --cold-verification-key-file node.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter
```

{% hint style="info" %}
Be sure to **back up your all your keys** to another secure storage device. 
{% endhint %}

Copy the node.vkey to your node directory

```text
cp ~/cold-keys/node.vkey ~/cardano-my-node
```

{% hint style="info" %}
Currently on testnet, delegators who delegate via CLI tools will require the ****data contained in `node.vkey` in order to delegate to your stakepool. You can share this file. DO NOT accidentally share the secret key,`node.skey` file.
{% endhint %}

Determine the number of slots per KES period from the genesis file.

```text
pushd +1
cat shelley_testnet-genesis.json | grep KESPeriod
```

Example **KES Period** output:

> "slotsPerKESPeriod": 3600,

Determine the KES period.

{% hint style="warning" %}
Before continuing, your node must be fully synchronized to the blockchain. Otherwise, you won't calculate the latest KES period. Your node is synchronized when the _epoch_ and _slot\#_ is equal to that found on a block explorer such as [https://ff.pooltool.io/](https://ff.pooltool.io/)
{% endhint %}

```text
cardano-cli shelley query tip --testnet-magic 42 | grep -oP 'SlotNo = \K\d+'
```

Example **query tip** output:

> 80000

Find the tip number\(e.g. 690000\) and divide by one period which is 3600 slots.

```text
expr 80000 / 3600
```

Example **expr calculation** output:

> 22

With this calculation, update your **--kes-period** and you can generate a operational certificate for your pool. 

```text
cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file ~/cold-keys/node.skey \
    --operational-certificate-issue-counter ~/cold-keys/node.counter \
    --kes-period <kes period from expr calculation> \
    --out-file node.cert
```

{% hint style="info" %}
You are required to regenerate the hot keys and issue a new operational certificate, a process called rotating the KES keys, when the hot keys expire.

**Mainnet**: KES keys will be valid for 120 rotations or 90 days

**Testnet**: KES keys will be valid for 120 rotations or 5 days
{% endhint %}

{% hint style="info" %}
When it's time to issue a new operational certificate, update your KES period value and run the following:

```text
chmod u+rwx ~/cold-keys
cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file ~/cold-keys/node.skey \
    --operational-certificate-issue-counter ~/cold-keys/node.counter \
    --kes-period <new kes period = old period + 120> \
    --out-file node.cert
chmod a-rwx ~/cold-keys
```
{% endhint %}

{% hint style="warning" %}
**Optional tip:** Save this step until after you finish the guide.

With your hot keys created, you can remove access to the cold keys for improved security. This protects against accidental deletion, editing, or access. 

To lock,

```text
chmod a-rwx ~/cold-keys
```

To unlock,

```text
chmod u+rwx ~/cold-keys
```
{% endhint %}

Make a VRF key pair.

```text
cardano-cli shelley node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
```

On your **block-producing node's terminal**, stop your **block-producing node** by typing the letter `q`

Update your startup script with the new **KES, VRF and Operation Certificate.**

```text
cd ~/cardano-my-node
cat > startBlockProducingNode.sh << EOF 
DIRECTORY=~/cardano-my-node
PORT=3000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/shelley_testnet-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/shelley_testnet-config.json
KES=\${DIRECTORY}/kes.skey
VRF=\${DIRECTORY}/vrf.skey
CERT=\${DIRECTORY}/node.cert
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG} --shelley-kes-key \${KES} --shelley-vrf-key \${VRF} --shelley-operational-certificate \${CERT}
EOF
```

{% hint style="info" %}
To operate a stakepool, two sets of keys are needed: they KES key \(hot\) and the cold key. Cold keys generate new hot keys periodically.
{% endhint %}

Now start the new block-producing node.

```text
cd ~/cardano-my-node
./startBlockProducingNode.sh
```

## 🔐 7. Setup payment and staking keys

First, obtain the protocol-parameters.

```text
cardano-cli shelley query protocol-parameters \
    --testnet-magic 42 \
    --out-file params.json
```

Create a new payment key pair:  `payment.skey` & `payment.vkey`

```text
cardano-cli shelley address key-gen \
    --verification-key-file payment.vkey \
    --signing-key-file payment.skey
```

 Create a new stake address key pair: `stake.skey` & `stake.vkey`

```text
cardano-cli shelley stake-address key-gen \
    --verification-key-file stake.vkey \
    --signing-key-file stake.skey
```

Create your stake address from the stake address verification key and store it in `stake`

```text
cardano-cli shelley stake-address build \
    --staking-verification-key-file stake.vkey \
    --out-file stake.addr \
    --testnet-magic 42
```

Build a payment address for the payment key `payment.vkey` which will delegate to the stake address, `stake.vkey`

```text
cardano-cli shelley address build \
    --payment-verification-key-file payment.vkey \
    --staking-verification-key-file stake.vkey \
    --out-file payment.addr \
    --testnet-magic 42
```

{% hint style="info" %}
Payment keys are used to send and receive payments and staking keys are used to manage stake delegations.
{% endhint %}

Next step is to fund your payment address.

Run the following command to request funds to your `payment.addr`

```text
curl -v -XPOST "https://faucet.shelley-testnet.dev.cardano.org/send-money/$(cat payment.addr)"
```

{% hint style="info" %}
The Shelly Testnet Faucet can deliver up to 100,000 fADA every 24 hours.
{% endhint %}

After funding your account, check your payment address balance.

{% hint style="warning" %}
Before continuing, your nodes must be fully synchronized to the blockchain. Otherwise, you won't see your funds.
{% endhint %}

```text
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 42
```

You should see output similar to this. This is your unspent transaction output \(UXTO\).

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        100000000000
```

## 👩💻 8. Register your stake address

Create a certificate, `stake.cert`, using the `stake.vkey`

```text
cardano-cli shelley stake-address registration-certificate \
    --staking-verification-key-file stake.vkey \
    --out-file stake.cert
```

You need to find the **tip** of the blockchain to set the **ttl** parameter properly.

```
cardano-cli shelley query tip --testnet-magic 42 | grep -oP 'SlotNo = \K\d+'
```

Example **tip** output:

> `690000`

{% hint style="info" %}
You will want to set your **ttl** value greater than the current tip. In this example, we use 250000000. 
{% endhint %}

Calculate the current minimum fee:

```text
cardano-cli shelley transaction calculate-min-fee \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --ttl 250000000 \
    --testnet-magic 42 \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --certificate stake.cert \
    --protocol-params-file params.json
```

Example of **calculate-min-fee**:

> `runTxCalculateMinFee: 171309`

Build your transaction which will register your stake address.

```text
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 42
```

Example **utxo** output:

```text
                 TxHash                         Ix        Lovelace
--------------------------------------------------------------------
81acd93...                                        0      100000000000
```

{% hint style="info" %}
Notice the TxHash and Ix \(index\). Will use this data shortly.
{% endhint %}

Calculate your transaction's change

```text
expr 100000000000 - 400000 - 171133
```

Example **transaction change amount**:

> 99999428867

{% hint style="info" %}
Registration of a stake address certificate costs 400000 lovelace.
{% endhint %}

Run the build-raw transaction command

{% hint style="info" %}
Pay close attention to **tx-in**. The data should in the format`<TxHash>#<Ix number>`from above.
{% endhint %}

```text
cardano-cli shelley transaction build-raw \
    --tx-in <TxHash>#<Index number> \
    --tx-out $(cat payment.addr)+99999428867 \
    --ttl 250000000 \
    --fee 171133 \
    --tx-body-file tx.raw \
    --certificate stake.cert
```

Sign the transaction with both the payment and stake secret keys.

```text
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --testnet-magic 42 \
    --tx-file tx.signed
```

Send the signed transaction.

```text
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --testnet-magic 42
```

## 📄 9. Register your stakepool

Create your pool's metadata with a JSON file. Update with your pool information.

```text
cat > poolMetaData.json << EOF
{
"name": "MyPoolName",
"description": "My pool description",
"ticker": "MPN",
"homepage": "https://myadapoolnamerocks.com"
}
EOF
```

Get the hash of your metadata file.

```text
cardano-cli shelley stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```

Now upload your **poolMetaData.json** to a public website such as [https://pages.github.com/](https://pages.github.com/)

Create a registration certificate for your stakepool. Update with your metadata URL and pool relay IP.

{% hint style="warning" %}
Metadata URL must be a maximum length of 64 characters.
{% endhint %}

```text
cardano-cli shelley stake-pool registration-certificate \
    --cold-verification-key-file node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 1000000000 \
    --pool-cost 10000000 \
    --pool-margin 0.1 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --testnet-magic 42 \
    --pool-relay-port 3001 \
    --pool-relay-ipv4 <your relay IP address> \
    --metadata-url <url where you uploaded poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```

{% hint style="info" %}
Here we are pledging 1000 ADA with a fixed pool cost of 10 ADA and a pool margin of 10%. 
{% endhint %}

Pledge stake to your stakepool.

```text
cardano-cli shelley stake-address delegation-certificate \
    --staking-verification-key-file stake.vkey \
    --cold-verification-key-file node.vkey \
    --out-file deleg.cert
```

{% hint style="info" %}
 This creates a delegation certificate which delegates funds from all stake addresses associated with key `stake.vkey` to the pool belonging to cold key `node.vkey`
{% endhint %}

You need to find the **tip** of the blockchain to set the **ttl** parameter properly.

```
cardano-cli shelley query tip --testnet-magic 42 | grep -oP 'SlotNo = \K\d+'
```

Example **tip** output:

> `690000`

{% hint style="info" %}
You will want to set your **ttl** value greater than the current tip. In this example, we use 250000000. 
{% endhint %}

Calculate the fee for a stakepool registration transaction.

```text
cardano-cli shelley transaction calculate-min-fee \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --ttl 250000000 \
    --testnet-magic 42 \
    --signing-key-file payment.skey \
    --signing-key-file ~/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --certificate pool.cert \
    --certificate deleg.cert \
    --protocol-params-file params.json
```

Example **calculate-min-fee** output:

> runTxCalculateMinFee: 188469

Find the deposit fee for a pool.

```text
cat shelley_testnet-genesis.json | grep poolDeposit
```

Example **poolDeposit** output:

> "poolDeposit": 500000000,

Find your unspent output \(UTXO\).

```text
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 42
```

Example of **query utxo** output:

```text
                 TxHash                         Ix        Lovelace
--------------------------------------------------------------------
3ac393d...                                        0      99999428867
```

Calculate the change amount.

```text
expr 99999428867 - 500000000 - 188469
```

Example **change amount** output:

> 99499240398

Build the transaction.

{% hint style="info" %}
Pay close attention to **tx-in**. The data should in the format`<TxHash>#<Ix number>`from above.
{% endhint %}

```text
cardano-cli shelley transaction build-raw \
    --tx-in <TxHash>#<Index number> \
    --tx-out $(cat payment.addr)+99499240398 \
    --ttl 250000000 \
    --fee 188469\
    --tx-body-file tx.raw \
    --certificate pool.cert \
    --certificate deleg.cert
```

Sign the transaction.

```text
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file ~/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --testnet-magic 42 \
    --tx-file tx.signed
```

Send the transaction.

```text
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --testnet-magic 42
```

## 🐣 10. Locate your Stakepool ID and verify everything is working 

Your stakepool ID can be computed with:

```text
cardano-cli shelley stake-pool id --verification-key-file node.vkey > stakepoolid.txt
cat stakepoolid.txt
```

Now that you have your stakepool ID,  verify it's included in the blockchain.

```text
cardano-cli shelley query ledger-state --testnet-magic 42 | grep publicKey | grep $(cat stakepoolid.txt)
```

{% hint style="info" %}
A non-empty string return means you're registered! 👏 
{% endhint %}

With your stakepool ID, now you can find your data on block explorers such as [https://htn.pooltool.io/](https://htn.pooltool.io/)



## ⚙ 11. Configure topology with Pooltool.io

{% hint style="info" %}
Shelley testnet has been launched without peer-to-peer \(p2p\) node discovery so that means we will need to manually add trusted nodes in order to configure our topology. This is a **critical step** as skipping this step will result in your minted blocks being orphaned by the rest of the network.
{% endhint %}

1. Visit [https://htn.pooltool.io/](https://htn.pooltool.io/)
2. Create an account and login
3. Search for your stakepool id
4. Click ➡ **Pool Details** &gt; **Manage** &gt; **CLAIM THIS POOL**
5. Fill in your pool name and pool URL if you have one.
6. Fill in your **Private Nodes** and **Your Relays** as follows.

![](../../../.gitbook/assets/configurepooltool.png)

Add requests for nodes or "buddies" to each of your relay nodes. Make sure you include the IOHK node and your private nodes.

For example, on relaynode1's buddies you should add **requests** for

* your BlockProducingNode
* your RelayNode2
* IOHK
* and any other buddy/friend nodes your can find or know

For example, on relaynode2's buddies you should add **requests** for

* your BlockProducingNode
* your RelayNode1
* IOHK
* and any other buddy/friend nodes your can find or know

{% hint style="info" %}
A relay node connection is not established until there is a request and an approval.
{% endhint %}

For relaynode1, create a get\_buddies.sh script to update your ff-topology.json file.

```text
cd ~/cardano-my-node
cat > relaynode1/get_buddies.sh << EOF 
#!/usr/bin/env bash

## CHANGE THESE TO SUIT YOUR POOL TO YOUR POOL ID AS ON THE EXPLORER
MY_POOL_ID="XXXXXXXX"
## GET THIS FROM YOUR ACCOUNT PROFILE PAGE ON POOLTOOL WEBSITE
MY_API_KEY="XXXXXXXX"
## GET THIS FROM YOUR POOL MANAGE TAB ON POOLTOOL WEBSITE
MY_NODE_ID="XXXXXXXX"
## SET THIS TO THE LOCATION OF YOUR TOPOLOGY FILE THAT YOUR NODE USES
TOPOLOGY_FILE="$HOME/cardano-my-node/relaynode1/shelley_testnet-topology.json"

JSON="\$(jq -n --compact-output --arg MY_API_KEY "\$MY_API_KEY" --arg MY_POOL_ID "\$MY_POOL_ID" --arg MY_NODE_ID "\$MY_NODE_ID" '{apiKey: \$MY_API_KEY, nodeId: \$MY_NODE_ID, poolId: \$MY_POOL_ID}')"
echo "Packet Sent: \$JSON"
RESPONSE="\$(curl -s -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "\$JSON" "https://api.pooltool.io/v0/getbuddies")"
SUCCESS="\$(echo \$RESPONSE | jq '.success')"
if [ \$SUCCESS ]; then
  echo "Success"
  echo \$RESPONSE | jq '. | {Producers: .message}' > \$TOPOLOGY_FILE
  echo "Topology saved to \$TOPOLOGY_FILE.  Note topology will only take effect next time you restart your node"
else
  echo "Failure "
  echo \$RESPONSE | jq '.message'
fi
EOF
```

For relaynode2, create a get\_buddies.sh script to update your ff-topology.json file.

```text
cd ~/cardano-my-node
cat > relaynode2/get_buddies.sh << EOF 
#!/usr/bin/env bash

## CHANGE THESE TO SUIT YOUR POOL TO YOUR POOL ID AS ON THE EXPLORER
MY_POOL_ID="XXXXXXXX"
## GET THIS FROM YOUR ACCOUNT PROFILE PAGE ON POOLTOOL WEBSITE
MY_API_KEY="XXXXXXXX"
## GET THIS FROM YOUR POOL MANAGE TAB ON POOLTOOL WEBSITE
MY_NODE_ID="XXXXXXXX"
## SET THIS TO THE LOCATION OF YOUR TOPOLOGY FILE THAT YOUR NODE USES
TOPOLOGY_FILE="$HOME/cardano-my-node/relaynode2/shelley_testnet-topology.json"

JSON="\$(jq -n --compact-output --arg MY_API_KEY "\$MY_API_KEY" --arg MY_POOL_ID "\$MY_POOL_ID" --arg MY_NODE_ID "\$MY_NODE_ID" '{apiKey: \$MY_API_KEY, nodeId: \$MY_NODE_ID, poolId: \$MY_POOL_ID}')"
echo "Packet Sent: \$JSON"
RESPONSE="\$(curl -s -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "\$JSON" "https://api.pooltool.io/v0/getbuddies")"
SUCCESS="\$(echo \$RESPONSE | jq '.success')"
if [ \$SUCCESS ]; then
  echo "Success"
  echo \$RESPONSE | jq '. | {Producers: .message}' > \$TOPOLOGY_FILE
  echo "Topology saved to \$TOPOLOGY_FILE.  Note topology will only take effect next time you restart your node"
else
  echo "Failure "
  echo \$RESPONSE | jq '.message'
fi
EOF
```

For each of your relay nodes, update the following variables from pooltool.io into your get\_buddies.sh file

* MY\_POOL\_ID 
* MY\_API\_KEY 
* MY\_NODE\_ID

Update your get\_buddies.sh scripts with this information.

{% hint style="info" %}
Use **nano** to edit your files. 

`nano relaynode1/get_buddies.sh`

`nano relaynode2/get_buddies.sh`
{% endhint %}

Add execute permissions to these scripts. Run the scripts to update your topology files.

```text
chmod +x relaynode1/get_buddies.sh
chmod +x relaynode2/get_buddies.sh
./relaynode1/get_buddies.sh
./relaynode2/get_buddies.sh
```

Stop and then restart your relay nodes in order for the new topology settings to take effect.

```text
kill $(lsof -t -i:3001)
kill $(lsof -t -i:3002)
```

```text
cd ~/cardano-my-node
./relaynode1/startRelayNode1.sh
```

```text
cd ~/cardano-my-node
./relaynode2/startRelayNode2.sh
```

{% hint style="info" %}
As your REQUESTS are approved, you must re-run the get\_buddies.sh script to pull the latest topology data. Restart your relay nodes afterwards.
{% endhint %}

You are properly connected to the network when you see the transactions processed increasing.

![](../../../.gitbook/assets/ada-tx-processed.png)

{% hint style="success" %}
Congratulations! Your stakepool is registered and ready to produce blocks.
{% endhint %}

## 🎇 12. Checking Stakepool Rewards

After the epoch is over and assuming you successfully minted blocks, check with this:

```text
cardano-cli shelley query stake-address-info --address $(cat payment.addr) --testnet-magic 42
```

## 👏 13. Thank yous and reference material

Thanks to all Cardano hodlers, buidlers, stakers, and pool operators for making the better future a reality.

For more information and official documentation, please refer to the following links:

{% embed url="https://testnets.cardano.org/en/shelley/get-started/creating-a-stake-pool/" %}

{% embed url="https://github.com/input-output-hk/cardano-tutorials" %}


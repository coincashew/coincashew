---
description: >-
  On Ubuntu/Debian, this guide will illustrate how to install and configure a
  stakepool from source code.
---

# Guide: How to build a Haskell Stakepool Node

## 🏁 0. Pre-requisites

### 🎗 Minimum Setup Requirements

* **Operating system:** 64-bit Linux \(i.e. Ubuntu 18.04.4 LTS\)
* **Processor:** Dual core CPU
* **Memory:** 4GB RAM
* **Storage:** 64GB SSD
* **Internet:** 24/7 broadband internet connection with speeds at least 1 Mbps
* **Power:** 24/7 electrical power
* **ADA balance:** at least 1000 ADA

### 🏋♂ Recommended Futureproof Setup

* **Operating system:** 64-bit Linux \(i.e. Ubuntu 18.04.4 LTS\)
* **Processor:** Quad core or better CPU
* **Memory:** 16GB RAM
* **Storage:** 500GB SSD with RAID
* **Internet:** Multiple 24/7 broadband internet connections with speeds at least 10 Mbps \(i.e. fiber + cellular 4G\)
* **Power:** Redundant 24/7 electrical power with UPS
* **ADA balance:** more pledge is better, TBD by a0, the pledge influence factor

For instructions on installing Ubuntu, refer to the following:

{% page-ref page="../../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}

## 🏭 1. Install Cabal and GHC

First, update packages and install Ubuntu dependencies.

```text
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get -y install build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 -y
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
cd ~
echo PATH="~/.local/bin:$PATH" >> .bashrc
source .bashrc
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

Download source code and switch to the latest tag. In this case, use 1.13.0.

```text
cd ~
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node
git fetch
git checkout 1.13.0
```

Build the cardano-node from source code.

```text
cabal install cardano-node cardano-cli
```

{% hint style="info" %}
Building process may take a few minutes up to a few hours depending on your computer's processing power.
{% endhint %}

Copy **cardano-cli** and **cardano-node** files into bin directory.

```text
sudo cp $(find ~/.cabal/store -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find ~/.cabal/store -type f -name "cardano-node") /usr/local/bin/cardano-node
```

## 📐 3. Configure the node

Here you'll grab the config.json, genesis.json, and topology.json files needed to configure your node.

```text
cd ~
mkdir cardano-my-node
cd cardano-my-node
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-topology.json
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-genesis.json
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-config.json
```

Run the following to modify **config.json** and 

* update ViewMode to "LiveView"
* update TraceBlockFetchDecisions to "true"

```text
sed -i.bak -e "s/SimpleView/LiveView/g" -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" ff-config.json
```

## 🤖 4. Create a startup script

The startup script contains all the variables needed to run a cardano-node such as directory, port, db path, config file, and topology file.

```text
cat > startBlockProducingNode.sh << EOF 
DIRECTORY=~/cardano-my-node
PORT=9770
TOPOLOGY=\${DIRECTORY}/ff-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/ff-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr 127.0.0.1 --port \${PORT} --config \${CONFIG}
EOF

```

## ✅ 5. Start the node

Add execute permissions to the script and start it to begin syncing the ADA blockchain!

```text
chmod +x startBlockProducingNode.sh
./startBlockProducingNode.sh
```

![Screenshot of a running Shelley Node](../../../.gitbook/assets/shellynode.png)

{% hint style="success" %}
Congratulations! Your node is running successfully now. Let it sync up.
{% endhint %}

## ⚙ 6. Generate block-producer keys

Make a KES key pair.

```text
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
    --operational-certificate-issue-counter coldcounter
```

{% hint style="info" %}
Be sure to **back up your all your keys** to another secure storage device. 
{% endhint %}

Copy the node.vkey to your node directory

```text
cp ~/cold-keys/node.vkey ~/cardano-my-node
```

{% hint style="info" %}
Delegators will require the **pool ID** data contained in `node.vkey` in order to delegate to your stakepool. You can share this file or the **pool ID text**. DO NOT share the `node.skey` file.
{% endhint %}

Determine the number of slots per KES period from the genesis file.

```text
cat ff-genesis.json | grep KESPeriod
> "slotsPerKESPeriod": 3600,
```

Determine the KES period.

```text
export CARDANO_NODE_SOCKET_PATH=~/cardano-my-node/db/socket
cardano-cli shelley query tip --testnet-magic 42
> Tip (SlotNo {unSlotNo = 507516}) ...
```

Find the tip number\(e.g. 507516\) and divide by one period which is 3600 slots.

```text
expr 507516 / 3600
> 140
```

With this information, now you can generate a operational certificate for your pool.

```text
pushd +1
cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter ~/cold-keys/coldcounter \
    --kes-period 140 \
    --out-file opcert
```

{% hint style="info" %}
You are required to regenerate the hot keys and issue a new operational certificate, a process called rotating the KES keys, when the hot keys expire.
{% endhint %}

With your hot keys created, now you can remove access to the cold keys for improved security. This protects against accidental deletion, editing, or access.

```text
chmod a-rwx ~/cold-keys
```

{% hint style="info" %}
When it's time to regenerate the hot keys, run the following:

```text
chmod u+rwx ~/cold-keys
cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file ~/cold-keys/node.skey \
    --operational-certificate-issue-counter ~/cold-keys/coldcounter \
    --kes-period 140 \
    --out-file opcert
$  chmod a-rwx ~/cold-keys
```
{% endhint %}

Make a VRF key pair.

```text
cardano-cli shelley node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
```

On your node's terminal window, stop your node by typing the letter `q`

Update your startup script with the new **KES, VRF and Operation Certificate.**

```text
cat > startBlockProducingNode.sh << EOF 
DIRECTORY=~/cardano-my-node
PORT=9770
TOPOLOGY=\${DIRECTORY}/ff-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/ff-config.json
KES=\${DIRECTORY}/kes.skey
VRF=\${DIRECTORY}/vrf.skey
CERT=\${DIRECTORY}/opcert
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr 127.0.0.1 --port \${PORT} --config \${CONFIG} --shelley-kes-key \${KES} --shelley-vrf-key \${VRF} --shelley-operational-certificate \${CERT}
EOF
```

{% hint style="info" %}
To operate a stakepool, two sets of keys are needed: they KES key \(hot\) and the cold key. Cold keys generate new hot keys periodically.
{% endhint %}

Now start the new block-producing node.

```text
startBlockProducingNode.sh
```

## 🔐 7. Setup payment and staking keys

First, obtain the protocol-parameters.

```text
export CARDANO_NODE_SOCKET_PATH=~/cardano-my-node/db/socket
cardano-cli shelley query protocol-parameters \
    --testnet-magic 42 \
    --out-file params.json
```

Create a new payment key pair:  `pay.skey` & `pay.vkey`

```text
cardano-cli shelley address key-gen \
    --verification-key-file pay.vkey \
    --signing-key-file pay.skey
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

Build a payment address for the payment key `pay.vkey` which will delegate to the stake address, `stake.vkey`

```text
cardano-cli shelley address build \
    --payment-verification-key-file pay.vkey \
    --staking-verification-key-file stake.vkey \
    --out-file pay.addr \
    --testnet-magic 42
```

{% hint style="info" %}
Payment keys are used to send and receive payments and staking keys are used to manage stake delegations.
{% endhint %}

Next step is to fund your payment address from a faucet or other address.

{% hint style="info" %}
[The Shelly Testnet Faucet](https://testnets.cardano.org/en/shelley/tools/faucet/) can deliver up to 1000 fADA per 24 hours.
{% endhint %}

You can find your payment address in `pay.addr`

```text
cat pay.addr
```

After funding your account, to check your payment address balance you will run the following

```text
cardano-cli shelley query utxo \
    --address $(cat pay.addr) \
    --testnet-magic 42
```

You should see output similar to this. This is your UXTO.

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        100000000
```

## 📄 8. Register your stakepool

Create a registration certificate for your stake pool.

```text
cardano-cli shelley stake-pool registration-certificate \
    --stake-pool-verification-key-file node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 1000000000 \
    --pool-cost 100000000 \
    --pool-margin 0.08 \
    --reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --out-file pool.cert \
    --testnet-magic 42
```

{% hint style="info" %}
Here we are pledging 1000 ADA with a fixed pool cost of 100 ADA and a pool margin of 8%. 
{% endhint %}

Pledge stake to your stake pool.

```text
cardano-cli shelley stake-address delegation-certificate \
    --staking-verification-key-file stake.vkey \
    --stake-pool-verification-key-file node.vkey \
    --out-file deleg.cert
```

{% hint style="info" %}
 This creates a delegation certificate which delegates funds from all stake addresses associated with key `stake.vkey` to the pool belonging to cold key `cold.vkey`
{% endhint %}

Calculate the fee for a stakepool registration transaction.

```text
cardano-cli shelley transaction calculate-min-fee \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --ttl 530000 \
    --testnet-magic 42 \
    --signing-key-file pay.skey \
    --signing-key-file ~/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --certificate pool.cert \
    --certificate deleg.cert \
    --protocol-params-file params.json

> runTxCalculateMinFee: 184861

```

Find the deposit fee for a pool.

```text
cat ff-genesis.json | grep poolDeposit
> "poolDeposit": 500000000,
```

Find your unspent output \(UTXO\).

```text
cardano-cli shelley query utxo \
    --address $(cat pay.addr) \
    --testnet-magic 42

                 TxHash                       TxIx        Lovelace
--------------------------------------------------------------------
3ac393d...                                        0       999428691
```

Calculate the change amount.

```text
expr 999428691 - 500000000 - 184861
> 499243830
```

Build the transaction.

```text
cardano-cli shelley transaction build-raw \
    --tx-in 3ac393d...#0 \
    --tx-out $(cat pay.addr)+499243830\
    --ttl 530000 \
    --fee 184861\
    --tx-body-file tx.raw \
    --certificate pool.cert \
    --certificate deleg.cert
```

Sign the transaction.

```text
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file pay.skey \
    --signing-key-file ~/cold-keys/cold.skey \
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

{% hint style="success" %}
Congratulations! Your stakepool is registered and ready to accept delegations.
{% endhint %}

In the next section, you can learn to delegate ADA accounts to your stakepool.

{% page-ref page="how-to-delegate-to-a-stakepool.md" %}


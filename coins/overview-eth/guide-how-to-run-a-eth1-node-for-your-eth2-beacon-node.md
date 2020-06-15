---
description: How to run a geth node for your Eth 2.0 beacon node on Ubutnu.
---

# Guide: How to run a Goerli ETH1 node for your ETH2 Prysm Beacon Node on Testnet with Ubuntu

## 🏁 0. Prerequisites

* Prysm ETH 2.0 beacon node
* Ubuntu OS

If you need a prysm beacon node, follow this guide.

{% page-ref page="guide-how-to-stake-on-eth-2.0-onyx-testnet.md" %}

If you need to install Ubuntu, follow this guide.

{% page-ref page="../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}

{% hint style="info" %}
Ethereum 2.0 requires a connection to Ethereum 1.0 in order to monitor for 32 ETH validator deposits. Hosting your own Ethereum 1.0 node is the best way to maximize decentralization and minimize dependency on third parties such as Infura.
{% endhint %}

## 🤖 1. Download a ETH1 node, geth

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

## 🔮 4. Start prysm beacon chain

Start prysm.sh with these new parameters to connect your new geth node.

```text
./prysm.sh beacon-chain --http-web3provider=http://localhost:8545/
```

{% hint style="success" %}
Congratulations. In your logs, this means it's working

`INFO powchain: Connected to eth1 proof-of-work chain endpoint=`[`http://localhost:8545/`](http://localhost:8545/)\`\`
{% endhint %}




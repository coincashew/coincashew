---
description: 'Where the magic begins... Estimated duration: ~ 1 hour.'
---

# 3. Install a Tezos Node

## 📖 1. Open a Terminal Window in Ubuntu

**Press** Ctrl+Alt+T. This will launch the Terminal.

## 🏭 2. Getting and building Tezos from source

Copy and paste these commands into the terminal line by line.

```text
sudo apt install -y rsync git m4 build-essential patch unzip bubblewrap wget pkg-config libgmp-dev libev-dev libhidapi-dev
```

{% hint style="info" %}
Type your **password** when prompted.

`[sudo] password for username:`
{% endhint %}

```bash
cd $HOME
wget https://sh.rustup.rs/rustup-init.sh
chmod +x rustup-init.sh
./rustup-init.sh --profile minimal --default-toolchain 1.44.0 -y

source $HOME/.cargo/env

wget https://raw.githubusercontent.com/zcash/zcash/master/zcutil/fetch-params.sh
chmod +x fetch-params.sh
./fetch-params.sh
```

```bash
wget https://github.com/ocaml/opam/releases/download/2.0.3/opam-2.0.3-x86_64-linux
sudo cp opam-2.0.3-x86_64-linux /usr/local/bin/opam
sudo chmod a+x /usr/local/bin/opam
git clone https://gitlab.com/tezos/tezos.git
cd tezos
git checkout latest-release
opam init --bare
```

{% hint style="info" %}
Answers the prompts with '**N**' then '**y**'.
{% endhint %}

```bash
make build-deps
eval $(opam env)
make
export PATH=~/tezos:$PATH
source ./src/bin_client/bash-completion.sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y
```

{% hint style="success" %}
Congratulations! You built your own Tezos node.
{% endhint %}

## ✨ 3. Starting the Node

First, you must generate a new identity in order to connect to the Tezos network.

```text
./tezos-node identity generate 26.
```

{% hint style="info" %}
This may take a few minutes to complete.
{% endhint %}

## 💿 4. Restore a snapshot

Rather than taking days to download the Tezos blockchain from the p2p network, a node can be quickly synchronized in a few minutes from snapshot.

Download a **rolling mode** snapshot from one of the following sources.

* [https://github.com/Phlogi/tezos-snapshots/releases](https://github.com/Phlogi/tezos-snapshots/releases)
* [https://tezosshots.com](https://tezosshots.com/)
* [https://snapshots.baketzfor.me](https://snapshots.baketzfor.me/)

For example, here we will download from the first link both a **rolling snapshot** and a **verification file**, `checksums.sha256`. 

First, we will install some tools.

```bash
sudo apt install -y jq curl
```

```bash
cd ~/tezos
curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep roll | xargs wget -q --show-progress
curl -s https://api.github.com/repos/Phlogi/tezos-snapshots/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep checksums.sha256 | xargs wget -q --show-progress
```

Next, verify the sha256 checksum to validate that the file was downloaded correctly. 

```bash
cat checksums.sha256 | grep mainnet.roll | sed -e 's/\(.*\) \(\/.*\/\)\(mainnet.roll*\)/\1\3/' > checksum
sha256sum -c checksum
```

{% hint style="success" %}
Ensure the checksum hash matches. This means the snapshot was downloaded fully and properly.
{% endhint %}

Sample output says **OK** when you successfully validate the file:

> `mainnet.roll.date.12345.chain.xz : OK`

{% hint style="warning" %}
If the checksum did not match, you can try downloading the file again or try downloading a snapshot from a different source.
{% endhint %}

Extract the snapshot, then import the snapshot.

```bash
unxz mainnet.roll*
./tezos-node snapshot import mainnet.roll*
rm mainnet.roll* checksums.sha256 checksum
```

{% hint style="info" %}
\*\*\*\*🏸 **FYI:** Rolling mode vs Full mode

* **`rolling`** mode are the most lightweight snapshots. Keeps a minimal rolling fragment of the chain and deleting everything before this fragment. Safe for baking, endorsing, and validating new blocks.
* **`full`** mode store all chain data since the beginning of the chain, but drop the archived contexts below the current checkpoint. Safe for baking, endorsing, and validating new blocks.
{% endhint %}

## 🧱5. Starting the node

```bash
./tezos-node run --rpc-addr 127.0.0.1:8732 --log-output tezos.log &
```

The node will now catch up syncing with the live network.

Watch the progress by viewing **tezos.log**

```bash
tail -f tezos.log
```

Downloading the latest blocks from peers, your node will gather the blocks created since the snapshot. To check the progress of syncing and to know when the node is ready, this command will exit when completely synced. Run the following in a new terminal.

```bash
cd ~/tezos
./tezos-client bootstrapped
```


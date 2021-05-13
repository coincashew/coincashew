# How to update a Stakepool

## 🎉 ∞ Pre-Announcements

{% hint style="info" %}
🎊 This latest update brought to you by the generous donations by [**BEBOP stake pool**](https://bebopadapool.com/). If you found this helpful, consider using [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. 🙏 
{% endhint %}

{% hint style="success" %}
As of May 13 2021, this guide is written for **mainnet** with **release v1.27.0** 😁 
{% endhint %}

## 📡 1. How to perform an update

From time to time, there will be new versions of `cardano-node`. Follow the [Official Cardano-Node Github Repo](https://github.com/input-output-hk/cardano-node) by enabling **notifications** with the watch functionality.

{% hint style="danger" %}
Read the patch notes for any other special updates or dependencies that may be required for the latest release.
{% endhint %}

{% tabs %}
{% tab title="v1.27.0 Notes" %}
**Full release notes:** [**https://github.com/input-output-hk/cardano-node/releases/tag/1.27.0**](https://github.com/input-output-hk/cardano-node/releases/tag/1.27.0)\*\*\*\*

Node version 1.27.0 provides important new functionality, including supporting new CLI commands that have been requested by stake pools, providing garbage collection metrics.  
It includes the performance fixes for the epoch boundary calculation that were released in node version [1.26.2](https://github.com/input-output-hk/cardano-node/releases/tag/1.26.2), plus a number of bug fixes and code improvements.  
It also includes many fundamental changes that are needed to prepare for forthcoming feature releases \(notably Plutus scripts in the Alonzo era\).  
Note that this release includes breaking changes to the API and CLI commands, and that compilation using GHC version 8.6.5 is no longer supported.

### 🛑 Release Dependencies

#### 1. If using cncli for leaderlogs and sendslots, update to `cncli version 2.10` is required.

```bash
RELEASETAG=$(curl -s https://api.github.com/repos/AndrewWestberg/cncli/releases/latest | jq -r .tag_name)
VERSION=$(echo ${RELEASETAG} | cut -c 2-)
echo "Installing release ${RELEASETAG}"
curl -sLJ https://github.com/AndrewWestberg/cncli/releases/download/${RELEASETAG}/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -o /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz
```

```bash
sudo tar xzvf /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/bin/
```

#### Checking that cncli is properly updated

```text
cncli -V
```

It should return the updated version number.
{% endtab %}

{% tab title="v1.26.2 Notes" %}
**Full release notes:** [**https://github.com/input-output-hk/cardano-node/releases/tag/1.26.2**](https://github.com/input-output-hk/cardano-node/releases/tag/1.26.2)\*\*\*\*

This point release is a recommended upgrade for all stake pool operators. It is not required for relays or other passive nodes. It ensures that block producing nodes do not unnecessarily re-evaluate the stake distribution at the epoch boundary.

{% hint style="info" %}
It is possible to upgrade from v1.25.1 but for a smooth update, ensure you have completed the v1.26.1 release dependencies, notably the ghc and cabal updates. Also note the database migration can take up to 2 hours.
{% endhint %}
{% endtab %}

{% tab title="v1.26.1 Notes" %}
**Full release notes:** [**https://github.com/input-output-hk/cardano-node/releases/tag/1.26.1**](https://github.com/input-output-hk/cardano-node/releases/tag/1.26.1)\*\*\*\*

This release includes significant performance improvements and numerous other minor improvements and feature additions. In particular the reward calculation pause is eliminated, and the CPU load for relays handling lots of incoming transactions should be significantly reduced.  
The focus of the current development work is on completing and integrating support for the Alonzo era. This release includes many of the internal changes but does not yet include support for the new era.

* Note that this release will automatically perform a DB migration on the first startup after the update. The **migration should take 10-120 minutes** however it can take up to 60 minutes depending on your CPU. If this is a problem for your use, then see below for steps to mitigate this.
* The format of the `cardano-cli query tip` query has changed - see release notes for the CLI below.
* The `cardano-cli query ledger-state` query now produces a binary file if `--out-file` is specified. If required \(e.g. for use in `cncli`\), JSON output can be obtained by omitting this parameter, and redirecting the standard output to a file

#### Steps to mitigate downtime for this update

This release will automatically perform a DB migration on the first startup after the update. The migration should take 10-20 minutes however it can take up to 60 minutes depending on your CPU.

To mitigate downtime:

1. Update a non-production mainnet node
2. Take a DB snapshot
3. Stop production node
4. Backup and replace DB with snapshot
5. Restart production node on 1.26.1
6. Repeat steps 3-5 for all production nodes

### 🛑 Release v1.26.1 New Dependencies

#### 1. Install GHC 8.10.4 and Cabal 3.4.0.0 and update dependencies

```bash
sudo apt-get -y install pkg-config libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev
```

```bash
sudo apt-get -y install build-essential curl libgmp-dev libffi-dev libncurses-dev libtinfo5
```

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

Answer **NO** to installing haskell-language-server \(HLS\).

Answer **YES** to automatically add the required PATH variable to ".bashrc".

```bash
source ~/.bashrc
ghcup upgrade
ghcup install ghc 8.10.4
ghcup set ghc 8.10.4
# Verify 8.10.4 is installed
ghc --version  
```

```bash
ghcup install cabal 3.4.0.0
ghcup set cabal 3.4.0.0
# Verify 3.4.0.0 is installed
cabal --version 
```

#### 2. Update variables for topologyUpdater.sh on relay nodes

`.blockNo` was changed to `.block`

```bash
cd $NODE_HOME
sed -i topologyUpdater.sh \
  -e "s/jq -r .blockNo/jq -r .block/g"
```

**3. Update gLiveView**

```bash
cd ${NODE_HOME}
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh
# Update env file with the stake pools configuration.
sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```

#### 4. If used, update qcpolsendmytip.sh on block producer core node

Various variables changed.

```bash
cd $NODE_HOME
sed -i qcpolsendmytip.sh \
  -e "s/jq -r '.slotNo, .headerHash, .blockNo'/jq -r '.slot, .hash, .block'/g"
sudo systemctl restart qcpolsendmytip
```
{% endtab %}

{% tab title="v1.25.1 Notes" %}
**Full release notes:** [https://github.com/input-output-hk/cardano-node/releases/tag/1.25.1](https://github.com/input-output-hk/cardano-node/releases/tag/1.25.1)

This release is expected to be the final release for the upcoming Mary hard fork, and everyone _**must**_ upgrade to this \(or a later\) version to cross the Mary hard fork.

The Mary hard fork introduces native token functionality to Cardano. This is directly useful and is also one of the significant building blocks for the later Goguen smart contracts.

Stake Pool Operators \(SPOs\) and Exchanges should take note that the metric namespace has undergone consolidation, so all metrics now reside in `cardano.node.metrics`:

* cardano.node.Forge.metrics.\* -&gt; cardano.node.metrics.Forge.\*
* cardano.node.ChainDB.metrics.\* -&gt; cardano.node.metrics.ChainDB.\*
* cardano.node.BlockFetchDecision.connectedPeers -&gt; cardano.node.metrics.connectedPeers

The node configs require no changes, but allow dropping entries that became redundant: wherever `cardano.node.Forge.metrics.*`, `cardano.node.ChainDB.metrics.*` or `cardano.node.BlockFetchDecision.connectedPeers` were mentioned, those entries can be removed. Only `cardano.node.metric` needs to remain. Please see [\#2281](https://github.com/input-output-hk/cardano-node/pull/2281) for further details.

This release uses a new cabal snapshot so could be rather resource intensive when building for the first time.

### 🛑 Release v1.25.1 New Dependencies

#### 1. Update Grafana monitoring dashboard to use new metrics

1. On relaynode1 \(or server with grafana\), open [http://localhost:3000](http://localhost:3000) 
2. Login to grafana
3. **Download and save** this [**updated json file**](https://raw.githubusercontent.com/coincashew/coincashew/master/.gitbook/assets/grafana-monitor-cardano-nodes-by-kaze.json)**.**
4. Click **Create +** icon &gt; **Import**
5. Add dashboard by **Upload JSON file**
6. Change **Name**/**uid** or click the **Import \(Overwrite\)** button 

**2. Update mainnet-config file on all relays and block producer nodes.**

```bash
cd ${NODE_HOME}
# Download a current mainnet config
NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-config.json
# Update config settings back to stock. Add any custom changes as needed.
sed -i mainnet-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" \
  	-e "s/127.0.0.1/0.0.0.0/g" 
```

#### **3. Update** gLiveView

```bash
cd ${NODE_HOME}
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh
# Update env file with the stake pools configuration.
sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```
{% endtab %}
{% endtabs %}

### Compiling the new binaries

To update with `$HOME/git/cardano-node` as the current binaries directory, clone a new git repo named `cardano-node2` so that you have a backup in case of rollback. Remove the old binaries.

```bash
cd $HOME/git
rm -rf cardano-node-old/
git clone https://github.com/input-output-hk/cardano-node.git cardano-node2
cd cardano-node2/
```

Run the following command to pull and build the latest binaries. Change the checkout **tag** or **branch** as needed.

```bash
cd $HOME/git/cardano-node2
cabal update
git fetch --all --recurse-submodules --tags
git checkout $(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)
cabal configure -O0 -w ghc-8.10.4
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
cabal build cardano-node cardano-cli
```

{% hint style="info" %}
Build process may take a few minutes up to a few hours depending on your computer's processing power.
{% endhint %}

Verify your **cardano-cli** and **cardano-node** were updated to the expected version.

```bash
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") version
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") version
```

{% hint style="danger" %}
Stop your node before updating the binaries.
{% endhint %}

{% tabs %}
{% tab title="systemd" %}
```
sudo systemctl stop cardano-node
```
{% endtab %}

{% tab title="cnode" %}
```
sudo systemctl stop cnode
```
{% endtab %}

{% tab title="block producer node" %}
```bash
killall -s 2 cardano-node
```
{% endtab %}

{% tab title="relaynode1" %}
```
killall -s 2 cardano-node
```
{% endtab %}
{% endtabs %}

Copy **cardano-cli** and **cardano-node** files into bin directory.

```bash
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
```

```bash
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

Verify your **cardano-cli** and **cardano-node** were copied successfully and updated to the expected version.

```bash
cardano-node version
cardano-cli version
```

{% hint style="success" %}
Now restart your node to use the updated binaries.
{% endhint %}

{% tabs %}
{% tab title="systemd" %}
```
sudo systemctl start cardano-node
```
{% endtab %}

{% tab title="cnode" %}
```
sudo systemctl start cnode
```
{% endtab %}

{% tab title="block producer node" %}
```bash
cd $NODE_HOME
./startBlockProducingNode.sh
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
cd $NODE_HOME
./startRelayNode1.sh
```
{% endtab %}
{% endtabs %}

Finally, the following sequence will switch-over to your newly built cardano-node folder while keeping the old directory for backup.

```bash
cd $HOME/git
mv cardano-node/ cardano-node-old/
mv cardano-node2/ cardano-node/
```

{% hint style="danger" %}
\*\*\*\*🤖 **Important Reminder**: Don't forget to update your **air-gapped offline machine \(cold environment\)** with the new **Cardano CLI** binaries.
{% endhint %}

{% hint style="success" %}
Congrats on completing the update. ✨ 

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it. 

It really energizes us to keep creating the best crypto guides. 

Use [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. 🙏 

Any feedback and all pull requests much appreciated. 🌛 

Hang out and chat with fellow stake pool operators on Discord @

[https://discord.gg/w8Bx8W2HPW](https://discord.gg/w8Bx8W2HPW) 😃 

Hang out and chat with our stake pool community on Telegram @ [https://t.me/coincashew](https://t.me/coincashew)
{% endhint %}

## 🤯 2. In case of problems

### 🛣 4.1 Forked off

Forget to update your node and now your node is stuck on an old chain?

Reset your database files and be sure to grab the [latest genesis, config, topology json files](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html).

```bash
cd $NODE_HOME
rm -rf db
```

### 📂 4.2 Roll back to previous version from backup

{% hint style="danger" %}
Stop your node before updating the binaries.
{% endhint %}

{% tabs %}
{% tab title="systemd" %}
```
sudo systemctl stop cardano-node
```
{% endtab %}

{% tab title="cnode" %}
```
sudo systemctl stop cnode
```
{% endtab %}

{% tab title="block producer node" %}
```bash
killall -s 2 cardano-node
```
{% endtab %}

{% tab title="relaynode1" %}
```
killall -s 2 cardano-node
```
{% endtab %}
{% endtabs %}

Restore the old repository.

```bash
cd $HOME/git
mv cardano-node/ cardano-node-rolled-back/
mv cardano-node-old/ cardano-node/
```

Copy the binaries to `/usr/local/bin`

```bash
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

Verify the binaries are the correct version.

```bash
/usr/local/bin/cardano-cli version
/usr/local/bin/cardano-node version
```

{% hint style="success" %}
Now restart your node to use the updated binaries.
{% endhint %}

{% tabs %}
{% tab title="systemd" %}
```
sudo systemctl start cardano-node
```
{% endtab %}

{% tab title="cnode" %}
```
sudo systemctl start cnode
```
{% endtab %}

{% tab title="block producer node" %}
```bash
cd $NODE_HOME
./startBlockProducingNode.sh
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
cd $NODE_HOME
./startRelayNode1.sh
```
{% endtab %}
{% endtabs %}

### 🤖 4.3 Last resort: Rebuild from source code

Follow the steps in [How to build a Stakepool.](./)


# Upgrading a Node

## :tada: Introduction

{% hint style="info" %}
:confetti_ball: This latest update brought to you by the generous donations by [**BEBOP stake pool**](https://bebopadapool.com). 

If you want to support this free educational Cardano content or found this helpful, visit [cointr.ee to find our donation addresses](https://cointr.ee/coincashew). Much appreciated in advance. :pray: 
{% endhint %}

{% hint style="success" %}
As of Oct 1 2021, this guide is written for **mainnet **with **release v1.30.1** :grin: 
{% endhint %}

## :satellite: How to Perform an Upgrade

From time to time, there will be new versions of `cardano-node`. Follow the [Official Cardano-Node Github Repo](https://github.com/input-output-hk/cardano-node) by enabling **notifications **with the watch functionality.

{% hint style="danger" %}
Read the patch notes for any other special updates or dependencies that may be required for the latest release.
{% endhint %}

{% tabs %}
{% tab title="v1.30.1 Notes" %}
**Full release notes: **[**https://github.com/input-output-hk/cardano-node/releases/tag/1.30.1**](https://github.com/input-output-hk/cardano-node/releases/tag/1.30.1)****

### :octagonal_sign: Upgrading Release Dependencies

#### CNCLI

If you use CNCLI for leaderlogs and sendslots, then you must upgrade to `cncli version 4.0.1`

```bash
RELEASETAG=$(curl -s https://api.github.com/repos/AndrewWestberg/cncli/releases/latest | jq -r .tag_name)
VERSION=$(echo ${RELEASETAG} | cut -c 2-)
echo "Installing release ${RELEASETAG}"
curl -sLJ https://github.com/AndrewWestberg/cncli/releases/download/${RELEASETAG}/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -o /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz
```

```bash
sudo tar xzvf /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/bin/
```

To confirm that the new version of CNCLI is installed, type:

```
cncli -V
```

It should return the updated version number.

#### gLiveView

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

{% tab title="v1.29.0 Notes" %}
**Full release notes: **[**https://github.com/input-output-hk/cardano-node/releases/tag/1.29.0**](https://github.com/input-output-hk/cardano-node/releases/tag/1.29.0)****

This release is an important update to the node that provides the functionality that is needed following the Alonzo hard fork.\
**All users, including stake pool operators, must upgrade to this version (or a later version) of the node.**

The release includes features that will enable the use of the node in the Alonzo era, allowing the on-chain execution of Plutus scripts,\
including extended CLI commands to support the construction of transactions that include Plutus scripts, datums and redeemers.\
It incorporates several improvements, including a new `transaction build` command that calculates transaction fees and Plutus script execution units, and a new version of the `query tip` command that provides additional information, including node synchronisation progress. The `transaction build` command requires a local instance of the node in order to check Plutus script validity and to provide information that is used by the fee calculation. The Shelley specification has also been updated with respect to rewards calculation.

Note that this release changes the log format of traces configured by `TraceChainSyncHeaderServer` and `TraceChainSyncClient` . See [#2746](https://github.com/input-output-hk/cardano-node/pull/2746) for more detail.

### :octagonal_sign: Release Dependencies

#### 1. If using cncli for leaderlogs and sendslots, update to `cncli version 3.15` is required.

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

```
cncli -V
```

It should return the updated version number.

**2. Download `mainnet-alonzo-genesis.json` file**

```bash
cd $NODE_HOME
wget -N https://hydra.iohk.io/build/7416228/download/1/mainnet-alonzo-genesis.json
```

**3. Download new`mainnet-config.json` file to with alonzo configurations.**

{% hint style="info" %}
If you have any custom mainnet configurations, be sure to backup and re-apply your settings.
{% endhint %}

```bash
cd $NODE_HOME
wget -N https://hydra.iohk.io/build/7416228/download/1/mainnet-config.json
sed -i mainnet-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" \
    -e "s/127.0.0.1/0.0.0.0/g"
```

Verify that your **mainnet-config.json** contains the following two new lines.

```
  "AlonzoGenesisFile": "mainnet-alonzo-genesis.json",
  "AlonzoGenesisHash": "7e94a15f55d1e82d10f09203fa1d40f8eede58fd8066542cf6566008068ed874",
```

View your **mainnet-config.json**

```bash
cat mainnet-config.json
```

Example of what it should look like with the two new lines.

```bash
{
  "AlonzoGenesisFile": "mainnet-alonzo-genesis.json",
  "AlonzoGenesisHash": "7e94a15f55d1e82d10f09203fa1d40f8eede58fd8066542cf6566008068ed874",
  "ApplicationName": "cardano-sl",
  "ApplicationVersion": 1,
  "ByronGenesisFile": "byron-genesis.json",
  "ByronGenesisHash": "5f20df933584822601f9e3f8c024eb5eb252fe8cefb24d1317dc3d432e940ebb",
  "LastKnownBlockVersion-Alt": 0,
  "LastKnownBlockVersion-Major": 3,
  "LastKnownBlockVersion-Minor": 0,
  "MaxKnownMajorProtocolVersion": 2,
  "Protocol": "Cardano",
  "RequiresNetworkMagic": "RequiresNoMagic",
  "ShelleyGenesisFile": "genesis.json",
  "ShelleyGenesisHash": "1a3be38bcbb7911969283716ad7aa550250226b76a61fc51cc9a9a35d9276d81",
```

**\[ Optional Troubleshooting ] **4. In case your node does not start up properly, refresh `mainnet-shelley-genesis.json`

```bash
cd $NODE_HOME
wget -N https://hydra.iohk.io/build/7416228/download/1/mainnet-shelley-genesis.json
```
{% endtab %}

{% tab title="v1.27.0 Notes" %}
**Full release notes: **[**https://github.com/input-output-hk/cardano-node/releases/tag/1.27.0**](https://github.com/input-output-hk/cardano-node/releases/tag/1.27.0)****

Node version 1.27.0 provides important new functionality, including supporting new CLI commands that have been requested by stake pools, providing garbage collection metrics.\
It includes the performance fixes for the epoch boundary calculation that were released in node version [1.26.2](https://github.com/input-output-hk/cardano-node/releases/tag/1.26.2), plus a number of bug fixes and code improvements.\
It also includes many fundamental changes that are needed to prepare for forthcoming feature releases (notably Plutus scripts in the Alonzo era).\
Note that this release includes breaking changes to the API and CLI commands, and that compilation using GHC version 8.6.5 is no longer supported.

### :octagonal_sign: Release Dependencies

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

```
cncli -V
```

It should return the updated version number.
{% endtab %}

{% tab title="v1.26.2 Notes" %}
**Full release notes: **[**https://github.com/input-output-hk/cardano-node/releases/tag/1.26.2**](https://github.com/input-output-hk/cardano-node/releases/tag/1.26.2)****

This point release is a recommended upgrade for all stake pool operators. It is not required for relays or other passive nodes. It ensures that block producing nodes do not unnecessarily re-evaluate the stake distribution at the epoch boundary.

{% hint style="info" %}
It is possible to upgrade from v1.25.1 but for a smooth update, ensure you have completed the v1.26.1 release dependencies, notably the ghc and cabal updates. Also note the database migration can take up to 2 hours.
{% endhint %}
{% endtab %}
{% endtabs %}

### Compiling the New Binaries

To update with `$HOME/git/cardano-node` as the current binaries directory, clone a new git repo named `cardano-node2` so that you have a backup in case of rollback. Remove the old binaries.

```bash
cd $HOME/git
rm -rf cardano-node-old/
git clone https://github.com/input-output-hk/cardano-node.git cardano-node2
cd cardano-node2/
```

Run the following command to pull and build the latest binaries. Change the checkout **tag **or **branch **as needed.

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

Verify your **cardano-cli **and **cardano-node** were updated to the expected version.

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

Copy **cardano-cli **and **cardano-node** files into bin directory.

```bash
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
```

```bash
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

Verify your **cardano-cli **and **cardano-node** were copied successfully and updated to the expected version.

```bash
cardano-node version
cardano-cli version
```

{% hint style="info" %}
**Optional Best Practice**: Now is an opportune time to update/upgrade and reboot your Ubuntu operating system.

```
sudo apt-get update && sudo apt-get upgrade -y && sudo reboot
```
{% endhint %}

{% hint style="success" %}
Now restart your node to use the updated binaries. If you used the previously mentioned optional best practice, your binaries should've already auto-started.
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

Verify that your node is working successfully by either checking gLiveView, your other journalctl logs, or grafana dashboard.

{% tabs %}
{% tab title="gLiveView" %}
```bash
cd ${NODE_HOME}
./gLiveView.sh
```
{% endtab %}

{% tab title="journalctl" %}
```
journalctl -fu cardano-node
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
It may take some time to start a node, sometimes up to 30 minutes. gLiveView may appear stuck on "Starting..." but this is normal behavior and simply requires time.
{% endhint %}

{% hint style="danger" %}
****:robot: **Important Reminder**: Don't forget to update your **air-gapped offline machine (cold environment) **with the new **Cardano CLI** binaries.
{% endhint %}

{% hint style="success" %}
Congrats on completing the update. :sparkles: 

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it. 

It really energizes us to keep creating the best crypto guides. 

Use [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. :pray: 

Any feedback and all pull requests much appreciated. :first_quarter_moon_with_face: 

Hang out and chat with fellow stake pool operators on Discord @

[https://discord.gg/w8Bx8W2HPW](https://discord.gg/w8Bx8W2HPW) :smiley: 

Hang out and chat with our stake pool community on Telegram @ [https://t.me/coincashew](https://t.me/coincashew)
{% endhint %}

## :exploding_head: 2. In case of problems

### :motorway: 4.1 Forked off

Forget to update your node and now your node is stuck on an old chain?

Reset your database files and be sure to grab the [latest genesis, config, topology json files](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html).

```bash
cd $NODE_HOME
rm -rf db
```

### :open_file_folder: 4.2 Roll back to previous version from backup

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

### :robot: 4.3 Last resort: Rebuild from source code

Follow the steps in [How to build a Stakepool.](./)

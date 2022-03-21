# Upgrading a Node

## :tada: Introduction

If you want to support this free educational Cardano content or found this helpful, visit [cointr.ee to find our donation addresses](https://cointr.ee/coincashew). Much appreciated in advance. :pray:

Input-Output (IOHK) regularly releases new versions of Cardano Node via the `cardano-node` [GitHub repository](https://github.com/input-output-hk/cardano-node). Carefully review release notes available in the repository for new features, known issues, technical specifications, related downloads, documentation, changelogs, assets and other details of each release.

{% hint style="info" %}
To receive notifications related to activity in the Cardano Node GitHub repository, configure [Watch](https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/configuring-notifications#automatic-watching) functionality.
{% endhint %}

The following procedure describes how to upgrade your Cardano node to the current version.

{% hint style="info" %}
For instructions on upgrading to a previous Cardano version, see the [archive](./upgrading-a-node-archive.md).
{% endhint %}

## :satellite: How to Perform an Upgrade






**Full release notes:** [**https://github.com/input-output-hk/cardano-node/releases/tag/1.30.1**](https://github.com/input-output-hk/cardano-node/releases/tag/1.30.1)

### :octagonal\_sign: Upgrading Release Dependencies

**CNCLI**

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

**gLiveView**

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

### Setting GHC and Cabal Versions

For each release, you must compile Cardano Node binaries using the versions of GHC and Cabal that Input-Output recommends. For example, refer to [Installing cardano-node and cardano-cli from source](https://developers.cardano.org/docs/get-started/installing-cardano-node/) in the [Cardano Developer Portal](https://developers.cardano.org/docs/get-started/) to determine the GHC and Cabal versions required for the current Cardano Node release.

_Table 1_ lists GHC and Cabal version requirements for the current Cardano Node release.

_Table 1 Current Cardano Node Version Requirements_

|  Release Date  |  Cardano Node Version  |  GHC Version   | Cabal Version  |
|:--------------:|:----------------------:|:--------------:|:--------------:|
|  March 7, 2022 |         1.34.1         |     8.10.7     |    3.6.2.0     |







### Compiling the New Binaries

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
:robot: **Important Reminder**: Don't forget to update your **air-gapped offline machine (cold environment)** with the new **Cardano CLI** binaries.
{% endhint %}

{% hint style="success" %}
Congrats on completing the update. :sparkles:

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it.

It really energizes us to keep creating the best crypto guides.

Use [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. :pray:

Any feedback and all pull requests much appreciated. :first\_quarter\_moon\_with\_face:

Hang out and chat with our stake pool community on Telegram @ [https://t.me/coincashew](https://t.me/coincashew)
{% endhint %}

## :exploding\_head: Troubleshooting

### :motorway: Forked off

Forget to update your node and now your node is stuck on an old chain?

Reset your database files and be sure to grab the [latest genesis, config, topology json files](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html).

```bash
cd $NODE_HOME
rm -rf db
```

### :open\_file\_folder: Reverting to a Previous Version Using a Backup

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

### :robot: Last Resort: Rebuild the Stake Pool

Follow the steps in [Setting Up a Cardano Stake Pool](../)

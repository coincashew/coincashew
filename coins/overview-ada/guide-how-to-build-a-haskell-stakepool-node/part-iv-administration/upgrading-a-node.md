# Upgrading a Node

## :tada: Introduction

{% hint style="success" %}
If you want to support this free educational Cardano content or found the content helpful, visit [cointr.ee to find our donation addresses](https://cointr.ee/coincashew). Much appreciated in advance. :pray:

Technical writing by Paradoxical Sphere and [Change Stake Pool \[CHG\]](https://change.paradoxicalsphere.com)
{% endhint %}

Input-Output (IOHK) regularly releases new versions of Cardano Node via the `cardano-node` [GitHub repository](https://github.com/input-output-hk/cardano-node). Carefully review release notes available in the repository for new features, known issues, technical specifications, related downloads, documentation, changelogs, assets and other details of each new release.

{% hint style="info" %}
To receive notifications related to activity in the Cardano Node GitHub repository, configure [Watch](https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/configuring-notifications#automatic-watching) functionality.
{% endhint %}

The *Upgrading a Node* topic describes how to upgrade a Cardano node to the latest version. Complete the following procedures on each block producer and relay node comprising your stake pool, as needed to complete the upgrade.

{% hint style="info" %}
For instructions on upgrading your stake pool to a previous Cardano version, see the [archive](./upgrading-a-node-archive.md).
{% endhint %}

## :octagonal\_sign: Upgrading Third-party Software

### CNCLI

If you use Andrew Westberg's [CNCLI](https://github.com/AndrewWestberg/cncli) command line utilities, then upgrade to the latest version if a newer version is available.

{% hint style="danger" %}
Do not confuse Andrew Westberg's CNCLI utilities with the [`cncli.sh`](https://cardano-community.github.io/guild-operators/Scripts/cncli/) companion script for stake pool operators maintained by [Guild Operators](https://cardano-community.github.io/guild-operators/).
{% endhint %}

**To upgrade Andrew Westberg's CNCLI binary:**

1. In a terminal window, type the following commands:
```bash
RELEASETAG=$(curl -s https://api.github.com/repos/AndrewWestberg/cncli/releases/latest | jq -r .tag_name)
VERSION=$(echo ${RELEASETAG} | cut -c 2-)
echo "Installing release ${RELEASETAG}"
curl -sLJ https://github.com/AndrewWestberg/cncli/releases/download/${RELEASETAG}/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -o /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz
sudo tar xzvf /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/bin/
```

2. To confirm that the new version of the CNCLI binary is installed, type:
```
cncli -V
```

If the command displays the latest version number, then the upgrade is successful.

### Guild LiveView

[Guild Operators](https://cardano-community.github.io/guild-operators/) maintains a set of tools to simplify operating a Cardano stake pool, including [Guild LiveView](https://cardano-community.github.io/guild-operators/Scripts/gliveview/). If you use the gLiveView script, then ensure that you are using the latest version prior to upgrading your Cardano node.

{% hint style="info" %}
In the [Common `env`](https://cardano-community.github.io/guild-operators/Scripts/env/) file for Guild Operator scripts, by default the `UPDATE_CHECK` user variable is set to check for updates to scripts when you start `gLiveView.sh`. If your implementation displays the message `Checking for script updates` when gLiveView starts and you install available updates when prompted, then you do NOT need to complete the following procedure.
{% endhint %}

**To upgrade the Guild LiveView tool manually:**

1. To navigate to the folder where Guild LiveView is located, type the following command in a terminal window:
```bash
cd ${NODE_HOME}
```

2. To back up existing Guild LiveView script files, type:
```bash
mv gLiveView.sh gLiveView.sh.bak
mv env env.bak
```

3. To download the latest Guild LiveView script files, type:
```bash
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
```

4. To set file permissions on the `gLiveView.sh` file that you downloaded in step 3, type:
```bash
chmod 755 gLiveView.sh
```

5. To set the `CONFIG` and `SOCKET` user variables in the `env` file that you downloaded in step 3, type:
```bash
sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```
{% hint style="info" %}
For details on setting the `NODE_HOME` environment variable, see the topic [Installing Cabal and GHC](../part-i-installation/installing-cabal-and-ghc.md)
{% endhint %}

6. As needed to configure Guild LiveView for your stake pool, use a text editor to transfer additional user variable definitions from the `env.bak` file that you created in step 2 to the `env` file that you downloaded in step 3.

7. To test the upgrade, type:
```bash
gLiveView.sh
```

If the upgrade is successful, then the terminal window displays the Guild LiveView dashboard having the version number of the latest release.

## <a name="SetGCVersions"></a>Setting GHC and Cabal Versions

For each Cardano Node release, Input-Output recommends compiling binaries using specific versions of GHC and Cabal. For example, refer to [Installing cardano-node and cardano-cli from source](https://developers.cardano.org/docs/get-started/installing-cardano-node/) in the [Cardano Developer Portal](https://developers.cardano.org/docs/get-started/) to determine the GHC and Cabal versions required for the current Cardano Node release. _Table 1_ lists GHC and Cabal version requirements for the current Cardano Node release.

_Table 1 Current Cardano Node Version Requirements_

|  Release Date  |  Cardano Node Version  |  GHC Version   | Cabal Version  |
|:--------------:|:----------------------:|:--------------:|:--------------:|
|  March 7, 2022 |         1.34.1         |     8.10.7     |    3.6.2.0     |

**To upgrade the GHCup installer for GHC and Cabal to the latest version:**

- In a terminal window, type:
```
ghcup upgrade
ghcup --version
```

**To install other GHC versions:**

- In a terminal window, type the following commands where `<GHCVersionNumber>` is the GHC version that you want to install and use:
```
ghcup install ghc <GHCVersionNumber>
ghcup set ghc <GHCVersionNumber>
ghc --version
```

**To install other Cabal versions:**

- In a terminal window, type the following commands where `<CabalVersionNumber>` is the Cabal version that you want to install and use:
```
ghcup install cabal <CabalVersionNumber>
ghcup set cabal <CabalVersionNumber>
cabal --version
```

{% hint style="info" %}
To set GHCup, GHC and Cabal versions using a graphical user interface, type `ghcup tui` in a terminal window.
{% endhint %}

## Building Cardano Node Binaries

**To build binaries for a new Cardano Node version:**

1. To create a clone of the Cardano Node [GitHub repository](https://github.com/input-output-hk/cardano-node), type the following commands in a terminal window on the computer you want to upgrade where `<NewFolderName>` is the name of a folder that does not exist:
```bash
# Navigate to the folder where you want to clone the repository
cd $HOME/git
# Download the Cardano Node repository to your local computer
git clone https://github.com/input-output-hk/cardano-node.git ./<NewFolderName>
```  
{% hint style="info" %}
Cloning the GitHub repository to a new folder allows you to roll back the upgrade, if needed.
{% endhint %}

2. To build Cardano Node binaries using the source code that you downloaded in step 1, type the following commands where `<NewFolderName>` is the name of the folder you created in step 1 and `<GHCVersionNumber>` is the GHC version that you set in the section [Setting GHC and Cabal Versions](./upgrading-a-node.md#SetGCVersions):
```bash
# Navigate to the folder where you cloned the Cardano Node repository
cd $HOME/git/<NewFolderName>
# Update the list of available packages
cabal update
# Download all branches and tags from the remote repository
git fetch --all --recurse-submodules --tags
# Switch to the branch of the latest Cardano Node release
git checkout $(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)
# Adjust the project configuration to disable optimization and use the recommended compiler version
cabal configure -O0 -w ghc-<GHCVersionNumber>
# Append the cabal.project.local file in the current folder to avoid installing the custom libsodium library
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" >> cabal.project.local
# Compile the cardano-node and cardano-cli packages found in the current directory
cabal build cardano-node cardano-cli
```  
<!-- References:
https://stackoverflow.com/questions/67748740/what-is-the-difference-between-git-clone-git-fetch-and-git-pull
https://cabal.readthedocs.io/en/3.4/cabal-project.html#package-configuration-options
https://iohk.zendesk.com/hc/en-us/articles/900001951646-Building-a-node-from-source -->  
{% hint style="info" %}
The time required to compile the `cardano-node` and `cardano-cli` packages may be a few minutes to hours, depending on the specifications of your computer.
{% endhint %}

3. When the compiler finishes, to verify the version numbers of the new `cardano-node` and `cardano-cli` binaries, type:
```bash
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") version
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") version
```

## Installing New Cardano Node Binaries

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

Now restart your node to use the updated binaries. If you used the previously mentioned optional best practice, your binaries should've already auto-started.

{% hint style="info" %}
For details on creating the `startBlockProducingNode.sh` and `startRelayNode1.sh` scripts, see the topic [Creating Startup Scripts](../part-ii-configuration/creating-startup-scripts.md)
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

## Cleaning Up

Finally, the following sequence will switch-over to your newly built cardano-node folder while keeping the old directory for backup.

```bash
cd $HOME/git
mv cardano-node/ cardano-node-old/
mv cardano-node2/ cardano-node/
```

## Verifying the Upgrade

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

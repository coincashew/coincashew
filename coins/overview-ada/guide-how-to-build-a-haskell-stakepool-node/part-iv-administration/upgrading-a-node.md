# Upgrading a Node

## :tada: Introduction

{% hint style="success" %}
If you want to support this free educational Cardano content or found the content helpful, visit [cointr.ee](https://cointr.ee/coincashew) to find our donation addresses. Much appreciated in advance. :pray:

:ledger:Technical writing by [Change Pool (ticker CHG)](https://change.paradoxicalsphere.com)
{% endhint %}

[Input-Output (IOHK)](https://iohk.io/) regularly releases new versions of Cardano Node via the `cardano-node` [GitHub repository](https://github.com/input-output-hk/cardano-node). Carefully review release notes available in the repository for new features, configurations, known issues, technical specifications, related downloads, documentation, changelogs, assets and other details of each new release.

{% hint style="info" %}
To receive notifications related to activity in the Cardano Node GitHub repository, configure [Watch](https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/configuring-notifications#automatic-watching) functionality.
{% endhint %}

The _Upgrading a Node_ topic describes how to upgrade a Cardano node to the latest version. Complete the following procedures on each block producer and relay node comprising your stake pool as needed to complete the upgrade.

{% hint style="info" %}
For instructions on upgrading your stake pool to a previous Cardano version, see the [archive](upgrading-a-node-archive.md).
{% endhint %}

## :revolving\_hearts: Upgrading Third-party Software

### CNCLI

If you use [CNCLI](https://github.com/cardano-community/cncli) command line utilities developed by the Cardano Community, then upgrade to the latest version if a newer version is available.

{% hint style="danger" %}
Do not confuse the Cardano Community's CNCLI utilities with the [`cncli.sh`](https://cardano-community.github.io/guild-operators/Scripts/cncli/) companion script for stake pool operators maintained by [Guild Operators](https://cardano-community.github.io/guild-operators/).
{% endhint %}

**To upgrade the Cardano Community's CNCLI binary:**

1. In a terminal window, type the following commands:

```bash
RELEASETAG=$(curl -s https://api.github.com/repos/cardano-community/cncli/releases/latest | jq -r .tag_name)
VERSION=$(echo ${RELEASETAG} | cut -c 2-)
echo "Installing release ${RELEASETAG}"
curl -sLJ https://github.com/cardano-community/cncli/releases/download/${RELEASETAG}/cncli-${VERSION}-ubuntu22-x86_64-unknown-linux-gnu.tar.gz -o /tmp/cncli-${VERSION}-ubuntu22-x86_64-unknown-linux-gnu.tar.gz
sudo tar xzvf /tmp/cncli-${VERSION}-ubuntu22-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/bin/
```

2\. To confirm that the new version of the CNCLI binary is installed, type:

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

1. To back up existing Guild LiveView script files, type the following commands where `<gLiveViewFolder>` is the folder where the `gLiveView.sh` script is located on your computer:

```bash
cd <gLiveViewFolder>
mv gLiveView.sh gLiveView.sh.bak
mv env env.bak
```

{% hint style="info" %}
If you follow the Coin Cashew instructions for [Starting the Nodes](../part-iii-operation/starting-the-nodes.md), then you can type `$NODE_HOME` to replace
{% endhint %}

2\. To download the latest Guild LiveView script files, type:

```bash
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
```

3\. To set file permissions on the `gLiveView.sh` file that you downloaded in step 2, type:

```bash
chmod 755 gLiveView.sh
```

4\. To set the `CONFIG` and `SOCKET` user variables in the `env` file that you downloaded in step 2, type:

```bash
sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```

{% hint style="info" %}
For details on setting the `NODE_HOME` environment variable, see the topic [Installing Cabal and GHC](../part-i-installation/installing-cabal-and-ghc.md)
{% endhint %}

5\. As needed to configure Guild LiveView for your stake pool, use a text editor to transfer additional user variable definitions from the `env.bak` file that you created in step 1 to the `env` file that you downloaded in step 2.

6\. To test the upgrade, type:

```bash
gLiveView.sh
```

If the upgrade is successful, then the terminal window displays the Guild LiveView dashboard having the version number of the latest release.

## :nut\_and\_bolt:Setting GHC and Cabal Versions <a href="#setgcversions" id="setgcversions"></a>

For each Cardano Node release, Input-Output recommends compiling binaries using specific versions of GHC and Cabal. For example, refer to [Installing cardano-node and cardano-cli from source](https://developers.cardano.org/docs/get-started/installing-cardano-node/) in the [Cardano Developer Portal](https://developers.cardano.org/docs/get-started/) to determine the GHC and Cabal versions required for the current Cardano Node release. _Table 1_ lists GHC and Cabal version requirements for the current Cardano Node release.

_Table 1 Current Cardano Node Version Requirements_

|     Release Date     | Cardano Node Version | Cardano CLI Version | GHC Version | Cabal Version |
|  :----------------:  | :------------------: | :-----------------: | :---------: | :-----------: |
|     October 2024     |         9.2.1        |       9.4.1.0       |    8.10.7   |    3.8.1.0    |


**To upgrade the GHCup installer for GHC and Cabal to the latest version:**

* In a terminal window, type:

```
ghcup upgrade
ghcup --version
```

**To install other GHC versions:**

* In a terminal window, type the following commands where `<GHCVersionNumber>` is the GHC version that you want to install and use:

```
ghcup install ghc <GHCVersionNumber>
ghcup set ghc <GHCVersionNumber>
ghc --version
```

**To install other Cabal versions:**

* In a terminal window, type the following commands where `<CabalVersionNumber>` is the Cabal version that you want to install and use:

```
ghcup install cabal <CabalVersionNumber>
ghcup set cabal <CabalVersionNumber>
cabal --version
```

{% hint style="info" %}
To set GHCup, GHC and Cabal versions using a graphical user interface, type `ghcup tui` in a terminal window.
{% endhint %}

**To update Libsodium:**

As of version 8.0.0, a new version of `libsodium` is required.

```bash
cd $HOME/git
git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout dbb48cc
./autogen.sh
./configure
make
make check
sudo make install
```

**To update secp256k1:**

As of version 8.9.0, a new version of `libsecp256k1` is required

```
cd $HOME/git
git clone https://github.com/bitcoin-core/secp256k1
cd secp256k1
git checkout v0.3.2
./autogen.sh
./configure --enable-module-schnorrsig --enable-experimental
make
make check
sudo make install
sudo ldconfig
```

**To install the blst library:**

As of version 8.9.0, a new version of `blst` is required.

```
cd $HOME/git
git clone https://github.com/supranational/blst
cd blst
git checkout v0.3.11
./build.sh
cat > libblst.pc << EOF
prefix=/usr/local
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libblst
Description: Multilingual BLS12-381 signature library
URL: https://github.com/supranational/blst
Version: 0.3.11
Cflags: -I\${includedir}
Libs: -L\${libdir} -lblst
EOF
sudo cp libblst.pc /usr/local/lib/pkgconfig/
sudo cp bindings/blst_aux.h bindings/blst.h bindings/blst.hpp /usr/local/include/
sudo cp libblst.a /usr/local/lib
sudo chmod u=rw,go=r /usr/local/{lib/{libblst.a,pkgconfig/libblst.pc},include/{blst.{h,hpp},blst_aux.h}}
```

## :inbox\_tray:Downloading New Configuration Files

A new Cardano Node release may include updated configuration files. If configuration files are updated for a release, then you need to download and install the new configuration files when you upgrade a node.

**To download and install new Cardano Node configuration files:**

1. To stop your Cardano node, type the following command in a terminal window where `<CardanoServiceName>` is the name of the systemd service running your Cardano node:

```bash
sudo systemctl stop <CardanoServiceName>.service
```

{% hint style="info" %}
If you follow the Coin Cashew instructions for [Creating Startup Scripts](../part-ii-configuration/creating-startup-scripts.md), then `<CardanoServiceName>` is `cardano-node`
{% endhint %}

2\. To back up the configuration files that your node currently uses, type the following commands as appropriate where `<ConfigurationFileFolder>` is the path to the folder where the configuration files are located:

```bash
cd <ConfigurationFileFolder>
mv config.json config.bak
mv byron-genesis.json byron-genesis.bak
mv shelley-genesis.json shelley-genesis.bak
mv alonzo-genesis.json alonzo-genesis.bak
mv conway-genesis.json conway-genesis.bak
mv topology.json topology.bak
```

{% hint style="info" %}
If you follow the Coin Cashew instructions for [Preparing Configuration Files](../part-ii-configuration/preparing-configuration-files.md), then `<ConfigurationFileFolder>` is `$HOME/cardano-my-node` Alternately, you can type `$NODE_HOME` If needed, you can also use the environment variable `$NODE_CONFIG` to indicate the `mainnet` cluster in configuration file names.
{% endhint %}

3\. Using a Web browser, navigate to the Cardano Node [GitHub repository](https://github.com/IntersectMBO/cardano-node), then browse to the latest release, then click to expand the Downloads dropdown list in the Technical Specification section of the release notes, and then click the Configuration Files link.

4\. On the Cardano Configurations page, click the following links to download configuration files for the `mainnet` cluster to the folder where you created backups of your current configuration files in step 2: `config`, `byronGenesis`, `shelleyGenesis`, `alonzoGenesis, conwayGenesis` and `topology`

{% hint style="warning" %}
As of version 8.9.0, you need to download a new config file, `conway-genesis.json`

```bash
cd <ConfigurationFileFolder>
wget https://book.world.dev.cardano.org/environments/mainnet/conway-genesis.json
```

Then, verify `config.json` contains the following two lines:

```
"ConwayGenesisFile": "conway-genesis.json", 
"ConwayGenesisHash": "de609b281cb3d8ae91a9d63a00c87092975612d603aa54c0f1c6a781e33d6e1e",
```
{% endhint %}

{% hint style="info" %}
If you want to download new configuration files using the command line, then navigate to the folder where you created backups of your current configuration files in step 2 using a terminal window, and then type the following command where `<ConfigurationFileURL>` is the URL for the configuration file that you want to download: `wget <ConfigurationFileURL>`
{% endhint %}

5\. Using [`diff`](https://www.man7.org/linux/man-pages/man1/diff.1.html) or a similar file comparison utility, identify and copy customizations as needed from the backup configuration files that you created in step 2 to each new configuration file that you downloaded in step 4.

{% hint style="warning" %}
The `config.json` file contains hashes for the `byron-genesis.json`, `shelley-genesis.json`, `alonzo-genesis.json` and `conway-genesis.json` files using the `ByronGenesisHash`, `ShelleyGenesisHash`, `AlonzoGenesisHash` and `ConwayGenesisHash` keys, respectively. Therefore, do NOT manually edit the `*genesis.json` files.
{% endhint %}

## :zap:Installing New Cardano Binaries <a href="#buildingcn" id="buildingcn"></a>

You can install pre-built Cardano Node binaries available for download from the Cardano Node [GitHub repository](https://github.com/IntersectMBO/cardano-node), or you can download the source code and compile the binaries yourself.

### Using Pre-built Binaries

**To install pre-built Cardano Node binaries:**

1. To create a temporary path to store the pre-built binaries, type:

```
mkdir ~/tmp2
cd ~/tmp2
```

2. Using a Web browser, visit the [Releases](https://github.com/IntersectMBO/cardano-node/releases) page for the Cardano Node GitHub repository, and then scroll down to the *Assets* section for the Cardano Node release you want to install. Right-click the archive containing the binaries that you want to install, and then click *Copy Link*

3. To download the binaries, type the following commands where <BinaryURL> the link that you copied in step 2:

```
wget <BinaryURL>
```

4. To extract the archive that you downloaded in step 3, type:

```
tar -xvf ./cardano*.gz
```

5. To install the new node and cli binaries, type:

```
sudo mv ~/tmp2/bin/cardano-cli /usr/local/bin/
```

```
sudo mv ~/tmp2/bin/cardano-node /usr/local/bin/
```

6. To delete the temporary folder, type:

```
cd ..
rm -rf ~/tmp2
```

7. [Complete](./upgrading-a-node.md#complete) the upgrade.

### Compiling the Binaries

**To build binaries for a new Cardano Node version:**

1. To create a clone of the Cardano Node [GitHub repository](https://github.com/IntersectMBO/cardano-node), type the following commands in a terminal window on the computer you want to upgrade where `<NewFolderName>` is the name of a folder that does not exist:

```bash
# Navigate to the folder where you want to clone the repository
cd $HOME/git
# Download the Cardano Node repository to your local computer
git clone https://github.com/IntersectMBO/cardano-node.git ./<NewFolderName>
```

Cloning the GitHub repository to a new folder allows you to roll back the upgrade, if needed, by re-installing on your computer the `cardano-node` and `cardano-cli` binaries from a folder where you compiled a previous version of Cardano Node packages.

2\. To build Cardano Node binaries using the source code that you downloaded in step 1, type the following commands where `<NewFolderName>` is the name of the folder you created in step 1 and `<GHCVersionNumber>` is the GHC version that you set in the section [Setting GHC and Cabal Versions](upgrading-a-node.md#SetGCVersions):

```bash
# Navigate to the folder where you cloned the Cardano Node repository
cd $HOME/git/<NewFolderName>
# Update the list of available packages
cabal update
# Download all branches and tags from the remote repository
git fetch --all --recurse-submodules --tags
# Switch to the branch of the latest Cardano Node release
git checkout $(curl -s https://api.github.com/repos/IntersectMBO/cardano-node/releases/latest | jq -r .tag_name)
# Adjust the project configuration to disable optimization and use the recommended compiler version
cabal configure -O0 -w ghc-<GHCVersionNumber>
# Compile the cardano-node and cardano-cli packages found in the current directory
cabal build all
cabal build cardano-cli
```
<!-- Source: https://github.com/input-output-hk/cardano-node-wiki/blob/main/docs/getting-started/install.md -->

The time required to compile the `cardano-node` and `cardano-cli` packages may be a few minutes to hours, depending on the specifications of your computer.

3\. When the compiler finishes, to verify the version numbers of the new `cardano-node` and `cardano-cli` binaries type:

```bash
$(./scripts/bin-path.sh cardano-node) version
$(./scripts/bin-path.sh cardano-cli) version
```

**To install the binaries that you compiled:**

1. If your Cardano node is running, then type the following command to stop the node where `<CardanoServiceName>` is the name of the systemd service running your node:

```bash
sudo systemctl stop <CardanoServiceName>.service
```

2\. To replace the existing `cardano-node` and `cardano-cli` binaries, type the following commands where `<DestinationPath>` is the absolute file path to the folder where you install Cardano Node binaries on your local computer:

```bash
sudo cp -p "$(./scripts/bin-path.sh cardano-node)" <DestinationPath>/cardano-node
sudo cp -p "$(./scripts/bin-path.sh cardano-cli)" <DestinationPath>/cardano-cli

```

If you follow the Coin Cashew instructions for [Compiling Source Code](../part-i-installation/compiling-source-code.md), then `<DestinationPath>` is `/usr/local/bin`

### Completing the Upgrade <a href="#complete" id="complete"></a>

**To finish upgrading Cardano Node binaries:**

1\. To verify that you installed the new Cardano Node binaries successfully, type:

```bash
cardano-node version
cardano-cli version
```

2\. Restart your Cardano node systemd service to finish the upgrade process.

```bash
sudo systemctl restart cardano-node
```

3\. Optionally, to install the latest versions of all previously installed packages on your computer, and then reboot the computer, type:

```
sudo apt-get update && sudo apt-get upgrade -y && sudo reboot
```

{% hint style="info" %}
Upgrading to a new Cardano Node version may require replaying the copy of the blockchain residing on the local computer. The task of replaying the blockchain may require hours to complete.

To monitor your node, type the command `journalctl -fu cardano-node`in a terminal window.
{% endhint %}

4\. Copy the new `cardano-cli` binary to the air-gapped, offline computer that you use to sign transactions for your stake pool.

5\. On your air-gapped, offline computer, ensure that [libsecp256k1](../part-ii-configuration/configuring-an-air-gapped-offline-computer.md#libsecp) and [blst](../part-ii-configuration/configuring-an-air-gapped-offline-computer.md#blst) are installed and up to date.

## :checkered\_flag:Verifying the Upgrade

To verify that the upgrade is successful, open gLiveView, journalctl logs or Grafana dashboard.

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

{% hint style="warning" %}
After an upgrade, starting a node may take up to a few hours. Be patient.
{% endhint %}

{% hint style="success" %}
Congrats on completing the update. :sparkles:

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it.

It really energizes us to keep creating the best crypto guides.

Use [cointr.ee](https://cointr.ee/coincashew) to find our donation addresses. :pray:

Any feedback and all pull requests much appreciated. :first\_quarter\_moon\_with\_face:

Hang out and chat with our stake pool community on Telegram @ [https://t.me/coincashew](https://t.me/coincashew)
{% endhint %}

## :rotating\_light:Troubleshooting

If your upgrade is unsuccessful, then try [Fixing a Corrupt Blockchain](../part-v-tips/fixing-a-corrupt-blockchain.md) and [Resetting an Installation](../part-v-tips/resetting-an-installation.md), as needed.

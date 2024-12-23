---
description: >-
  Scenario: In discord, you see an alert that your consensus client just
  announced a new release. How best to update?
---

# Updating your consensus client

{% hint style="info" %}
:confetti\_ball: **Support us on Gitcoin Grants:** [We improve this guide with your support!](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew)🙏
{% endhint %}

## :fast\_forward: Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

When a new release is cut, you will want to update to the latest stable release. The following shows you how to update your beacon chain and validator.

{% hint style="info" %}
Always review the **git logs** with command **`git log`**&#x6F;r **release notes** before updating. There may be changes requiring your attention.
{% endhint %}

{% hint style="success" %}
:fire: **Pro tip**: Plan your update to overlap with the longest attestation gap. [Learn how here.](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/finding-the-longest-attestation-slot-gap.md)
{% endhint %}

1. Select your consensus client.

{% tabs %}
{% tab title="Lighthouse" %}
Review release notes and check for breaking changes/features.

[https://github.com/sigp/lighthouse/releases](https://github.com/sigp/lighthouse/releases)

#### Option 1: Download binaries

```bash
RELEASE_URL="https://api.github.com/repos/sigp/lighthouse/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep x86_64-unknown-linux-gnu.tar.gz$)"

echo Downloading URL: $BINARIES_URL

cd $HOME
# Download
wget -O lighthouse.tar.gz $BINARIES_URL
# Untar
tar -xzvf lighthouse.tar.gz -C $HOME
# Cleanup
rm lighthouse.tar.gz

# Stop the services.
sudo systemctl stop beacon-chain validator

# Remove old binaries, install new binaries, display version and restart the services.
sudo rm -r $HOME/.cargo/bin/lighthouse
sudo mv $HOME/lighthouse $HOME/.cargo/bin
$HOME/.cargo/bin/lighthouse --version
sudo systemctl restart beacon-chain validator
```

#### Option 2: Build from source

Pull the latest source and build it.

```bash
cd $HOME/git/lighthouse
git fetch --all && git checkout stable && git pull
make
```

{% hint style="info" %}
Improve some Lighthouse benchmarks by around 20% at the expense of increased compile time? Use `maxperf` profile.\
\
To compile with maxperf, replace the above `make` command with

&#x20; `PROFILE=maxperf make`
{% endhint %}

{% hint style="info" %}
In case of compilation errors, update Rust with the following sequence.

```
rustup update
cargo clean
make
```
{% endhint %}

Verify the build completed by checking the new version number.

```bash
lighthouse --version
```

Restart beacon chain and validator as per normal operating procedures.

```
sudo systemctl reload-or-restart beacon-chain validator
```
{% endtab %}

{% tab title="Nimbus" %}
Review release notes and check for breaking changes/features.

[https://github.com/status-im/nimbus-eth2/releases](https://github.com/status-im/nimbus-eth2/releases)

#### Option 1: Download binaries

```bash
RELEASE_URL="https://api.github.com/repos/status-im/nimbus-eth2/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep _Linux_amd64.*.tar.gz$)"

echo Downloading URL: $BINARIES_URL

cd $HOME
# Download
wget -O nimbus.tar.gz $BINARIES_URL
# Untar
tar -xzvf nimbus.tar.gz -C $HOME
# Rename folder
mv nimbus-eth2_Linux_amd64_* nimbus
# Cleanup
rm nimbus.tar.gz

# Stop the services.
sudo systemctl stop beacon-chain

# Remove old binaries, install new binaries, display version and restart the services.
sudo rm -r /usr/bin/nimbus_beacon_node
sudo mv nimbus/build/nimbus_beacon_node  /usr/bin/nimbus_beacon_node
/usr/bin/nimbus_beacon_node --version
sudo systemctl restart beacon-chain
rm -r $HOME/nimbus
```

#### Option 2: Build from source

Pull the latest source and build it.

```bash
cd $HOME/git/nimbus-eth2
git checkout stable && git pull && make -j$(nproc) update
make -j$(nproc) nimbus_beacon_node
```

Verify the build completed by checking the new version number.

```bash
cd $HOME/git/nimbus-eth2/build
./nimbus_beacon_node --version
```

Stop, copy new binary, and restart beacon chain and validator as per normal operating procedures.

```bash
sudo systemctl stop beacon-chain
sudo rm /usr/bin/nimbus_beacon_node
sudo cp $HOME/git/nimbus-eth2/build/nimbus_beacon_node /usr/bin
sudo systemctl reload-or-restart beacon-chain
```
{% endtab %}

{% tab title="Teku" %}
Review release notes and check for breaking changes/features.

{% embed url="https://github.com/ConsenSys/teku/releases" %}

{% hint style="info" %}
If you encounter an error fetching the latest release TAG, install `jq` with following:

```
sudo apt-get install jq -y
```
{% endhint %}

#### Option 1: Download binaries

<pre class="language-bash"><code class="lang-bash"><strong>RELEASE_URL="https://api.github.com/repos/ConsenSys/teku/releases/latest"
</strong>LATEST_TAG="$(curl -s $RELEASE_URL | jq -r ".tag_name")"
BINARIES_URL="https://artifacts.consensys.net/public/teku/raw/names/teku.tar.gz/versions/${LATEST_TAG}/teku-${LATEST_TAG}.tar.gz"

echo Downloading URL: $BINARIES_URL

cd $HOME
# Download
wget -O teku.tar.gz $BINARIES_URL
# Untar
tar -xzvf teku.tar.gz -C $HOME
# Rename folder
mv teku-* teku
# Cleanup
rm teku.tar.gz

# Stop the services.
sudo systemctl stop beacon-chain

# Remove old binaries, install new binaries, display version and restart the services.
sudo rm -rf /usr/bin/teku
sudo mv $HOME/teku /usr/bin/teku
/usr/bin/teku/bin/teku --version
sudo systemctl restart beacon-chain
</code></pre>

#### Option 2: Build from source

Pull the latest release's tag and build it.

```bash
cd $HOME/git/teku
git fetch --all
RELEASETAG=$(curl -s https://api.github.com/repos/ConsenSys/teku/releases/latest | jq -r .tag_name)
git checkout tags/$RELEASETAG

echo "Updating to version: $RELEASETAG"

./gradlew distTar installDist
```

Verify the build completed by checking the new version number.

```bash
cd $HOME/git/teku/build/install/teku/bin
./teku --version
```

Restart beacon chain and validator as per normal operating procedures.

```bash
sudo systemctl stop beacon-chain
sudo rm -rf /usr/bin/teku
sudo cp -r $HOME/git/teku/build/install/teku /usr/bin/teku
sudo systemctl reload-or-restart beacon-chain
```
{% endtab %}

{% tab title="Prysm" %}
Review release notes and check for breaking changes/features.

[https://github.com/prysmaticlabs/prysm/releases](https://github.com/prysmaticlabs/prysm/releases)

```bash
#Simply restart the processes
sudo systemctl reload-or-restart beacon-chain validator
```
{% endtab %}

{% tab title="Lodestar" %}
Review release notes and check for breaking changes/features.

[https://github.com/ChainSafe/lodestar/releases](https://github.com/ChainSafe/lodestar/releases)

Pull the latest source and build it.

```bash
cd $HOME/git/lodestar
git checkout stable && git pull
yarn install
yarn run build
```

Verify the build completed by checking the new version number.

```bash
./lodestar --version
```

Restart beacon chain and validator as per normal operating procedures.

```bash
sudo systemctl restart beacon-chain validator
```
{% endtab %}
{% endtabs %}

2\. Check the logs to verify the services are working properly and ensure there are no errors.

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl status beacon-chain validator
```
{% endtab %}

{% tab title=" Nimbus | Teku" %}
```
sudo systemctl status beacon-chain
```
{% endtab %}
{% endtabs %}

3\. Finally, verify your validator's attestations are working with public block explorer such as

[https://beaconcha.in/](https://beaconcha.in) or [https://beaconscan.com/](https://beaconscan.com)

Enter your validator's pubkey to view its status.

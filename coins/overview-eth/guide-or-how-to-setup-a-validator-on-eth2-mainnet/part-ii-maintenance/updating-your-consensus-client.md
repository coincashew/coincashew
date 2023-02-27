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
The following steps align with our [mainnet guide](../). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

When a new release is cut, you will want to update to the latest stable release. The following shows you how to update your beacon chain and validator.

{% hint style="info" %}
Always review the **git logs** with command **`git log`**or **release notes** before updating. There may be changes requiring your attention.
{% endhint %}

{% hint style="success" %}
:fire: **Pro tip**: Plan your update to overlap with the longest attestation gap. [Learn how here.](finding-the-longest-attestation-slot-gap.md)
{% endhint %}

1. Select your consensus client.

{% tabs %}
{% tab title="Lighthouse" %}
Review release notes and check for breaking changes/features.

[https://github.com/sigp/lighthouse/releases](https://github.com/sigp/lighthouse/releases)



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



Pull the latest source and build it.

```bash
cd $HOME/git/nimbus-eth2
git pull && make -j$(nproc) update
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



Pull the latest release's tag and build it.

```bash
cd $HOME/git/teku
git pull
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
git switch stable
git pull
yarn install
yarn run build
```



Verify the build completed by checking the new version number.

```bash
./lodestar --version
```



Restart beacon chain and validator as per normal operating procedures.

```
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

---
description: >-
  Scenario: In discord, you see an alert that your eth2 client just announced a
  new release. How best to update?
---

# How to update your eth2 client

{% hint style="info" %}
🎊 **2021-09 Gitcoin Grant Round 11:** We improve this guide with your support! 

[Help fund us and earn a **POAP NFT**](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew). Appreciate your support!🙏 
{% endhint %}

{% embed url="https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew" %}

## ⏩ Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](./). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

When a new release is cut, you will want to update to the latest stable release. The following shows you how to update your eth2 beacon chain and validator.

{% hint style="info" %}
Always review the **git logs** with command**`git log`** or **release notes** before updating. There may be changes requiring your attention.
{% endhint %}

{% hint style="success" %}
\*\*\*\*🔥 **Pro tip**: Plan your update to overlap with the longest attestation gap. [Learn how here.](how-to-find-longest-attestation-slot-gap.md)
{% endhint %}

1. Select your ETH2 client.

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
In case of compilation errors, update Rust with the following sequence.

```text
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

```text
sudo systemctl reload-or-restart beacon-chain validator
```
{% endtab %}

{% tab title="Nimbus" %}
Review release notes and check for breaking changes/features.

[https://github.com/status-im/nimbus-eth2/releases](https://github.com/status-im/nimbus-eth2/releases)

Pull the latest source and build it.

```bash
cd $HOME/git/nimbus-eth2
git pull && make update
make nimbus_beacon_node
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

[https://github.com/ConsenSys/teku/releases](https://github.com/ConsenSys/teku/releases)

Pull the latest source and build it.

```bash
cd $HOME/git/teku
git pull
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
git pull
yarn install
yarn run build
```

Verify the build completed by checking the new version number.

```bash
yarn run cli --version
```

Restart beacon chain and validator as per normal operating procedures.

```text
sudo systemctl reload-or-restart beacon-chain validator
```
{% endtab %}
{% endtabs %}

2. Check the logs to verify the services are working properly and ensure there are no errors.

{% tabs %}
{% tab title="Lighthouse \| Prysm \| Lodestar" %}
```bash
sudo systemctl status beacon-chain validator
```
{% endtab %}

{% tab title=" Nimbus \| Teku" %}
```
sudo systemctl status beacon-chain
```
{% endtab %}
{% endtabs %}

3. Finally, verify your validator's attestations are working with public block explorer such as

[https://beaconcha.in/](https://beaconcha.in/) or [https://beaconscan.com/](https://beaconscan.com/)

Enter your validator's pubkey to view its status.

##  🤖 Start staking by building a validator <a id="start-staking-by-building-a-validator"></a>

### Visit here for our [Mainnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet) and here for our [Testnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-testnet). <a id="visit-here-for-our-mainnet-guide-and-here-for-our-testnet-guide"></a>

{% hint style="success" %}
Congrats on completing the guide. ✨

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it.

It really energizes us to keep creating the best crypto guides.

Use [cointr.ee to find our donation](https://cointr.ee/coincashew) addresses. 🙏

Any feedback and all pull requests much appreciated. 🌛

Hang out and chat with fellow stakers on Discord @

​[https://discord.gg/w8Bx8W2HPW](https://discord.gg/w8Bx8W2HPW) 😃
{% endhint %}

🎊 **2020-12 Update**: Thanks to all [Gitcoin](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew) contributors, where you can contribute via [quadratic funding](https://vitalik.ca/general/2019/12/07/quadratic.html) and make a big impact. Funding complete! Thank you!🙏

{% embed url="https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew" %}


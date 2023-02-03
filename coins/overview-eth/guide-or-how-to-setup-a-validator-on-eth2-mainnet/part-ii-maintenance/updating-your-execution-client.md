---
description: >-
  Scenario: In discord, you see an alert that your execution client just
  announced a new release. How best to update?
---

# Updating your execution client

{% hint style="info" %}
​:confetti\_ball: **Support us on Gitcoin Grants:** [We improve this guide with your support!](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew)🙏
{% endhint %}

## :fast\_forward: Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](../). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

{% hint style="success" %}
:fire: **Pro tip**: Plan your update to overlap with the longest attestation gap. [Learn how here.](finding-the-longest-attestation-slot-gap.md)
{% endhint %}

From time to time, be sure to update to the latest ETH1 releases to enjoy new improvements and features.

0.1 Update your operating system and ensure it's on the latest long term (LTS) support version.

```bash
sudo apt update
sudo apt dist-upgrade -y
```

1\. Stop your execution client process.

```bash
# This can take a few minutes.
sudo systemctl stop eth1
```

2\. Update the execution client package or binaries.

{% tabs %}
{% tab title="Geth" %}
Review the latest release notes at [https://github.com/ethereum/go-ethereum/releases](https://github.com/ethereum/go-ethereum/releases)

```bash
# Already handled by previous commands.
# sudo apt update
# sudo apt upgrade -y
```
{% endtab %}

{% tab title="Besu" %}
Review the latest release at [https://github.com/hyperledger/besu/releases](https://github.com/hyperledger/besu/releases)



Run the following to automatically download the latest linux release, un-tar and cleanup.

```bash
BINARIES_URL="$(curl -s https://api.github.com/repos/hyperledger/besu/releases/latest | grep -o 'https://hyperledger.jfrog.io/hyperledger/besu-binaries/besu/.*tar.gz' | sed -e 's/.*\\n\(https.*.tar.gz$\)/\1/')"

echo Downloading URL: $BINARIES_URL

cd $HOME
# backup previous besu version in case of rollback
mv besu besu_backup_$(date +"%Y%d%m-%H%M%S")
# download latest besu
wget -O besu.tar.gz "$BINARIES_URL"
# untar
tar -xvf besu.tar.gz
# cleanup
rm besu.tar.gz
# rename besu to standard folder location
mv besu-* besu
```
{% endtab %}

{% tab title="Nethermind" %}
Review the latest release at [https://github.com/NethermindEth/nethermind/releases](https://github.com/NethermindEth/nethermind/releases)

Automatically download the latest linux release, un-zip and cleanup.



```bash
cd $HOME
# backup previous nethermind version in case of rollback
mv nethermind nethermind_backup_$(date +"%Y%d%m-%H%M%S")
# store new version in nethermind directory
mkdir nethermind && cd nethermind 
# download latest version
curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux-x64  | xargs wget -q --show-progress
# unzip
unzip -o nethermind*.zip
# cleanup
rm nethermind*linux*.zip
```
{% endtab %}

{% tab title="Erigon" %}
Review the latest release at [https://github.com/ledgerwatch/erigon/releases](https://github.com/ledgerwatch/erigon/releases)

```bash
cd $HOME/erigon
git pull
make erigon
```
{% endtab %}
{% endtabs %}

3\. Start your execution client process.

```bash
sudo systemctl start eth1
```

4\. Check the logs to verify the services are working properly and ensure there are no errors.

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl status eth1 beacon-chain validator
```
{% endtab %}

{% tab title="Nimbus | Teku" %}
```
sudo systemctl status eth1 beacon-chain
```
{% endtab %}
{% endtabs %}

5\. Finally, verify your validator's attestations are working with public block explorer such as

[https://beaconcha.in/](https://beaconcha.in) or [https://beaconscan.com/](https://beaconscan.com)

Enter your validator's pubkey to view its status.

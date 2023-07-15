# Improving Validator Attestation Effectiveness

{% hint style="info" %}
Learn about [attestation effectiveness from Attestant.io](https://www.attestant.io/posts/defining-attestation-effectiveness/)
{% endhint %}

#### :family\_mwgg: Strategy: Increase beacon chain peer count

{% hint style="info" %}
This change will result in increased bandwidth and memory usage. Tweak and tailor appropriately for your hardware.

_Kudos to_ [_Rémy Roy_](https://www.reddit.com/user/remyroy/) _for this strat._
{% endhint %}

Edit your consensus.`service` unit file.

```bash
sudo nano /etc/systemd/system/consensus.service
```

Add the following flag to increase peers on the `ExecStart` line.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
--target-peers 100
# Example
# lighthouse bn --target-peers 100 --staking --metrics --network mainnet
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
--max-peers=100
# Example
# /usr/bin/nimbus_beacon_node --network=mainnet --max-peers=100
```
{% endtab %}

{% tab title="Teku" %}
```bash
--p2p-peer-upper-bound 100
```
{% endtab %}

{% tab title="Prysm" %}
```bash
--p2p-max-peers=100
# Example
# prysm.sh beacon-chain --mainnet --p2p-max-peers=100 --http-web3provider=http://127.0.0.1:8545 --accept-terms-of-use 
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
--network.maxPeers 100
# Example
# ./lodestar beacon --network.maxPeers 100 --network mainnet
```
{% endtab %}
{% endtabs %}

Reload the updated unit file and restart the beacon-chain process to complete this change.

```bash
sudo systemctl daemon-reload
sudo systemctl restart consensus
```

#### :gear: Strategy: Perform updates or reboots during the longest attestation gap

Learn how to at [this quick guide.](../part-ii-maintenance/finding-the-longest-attestation-slot-gap.md)

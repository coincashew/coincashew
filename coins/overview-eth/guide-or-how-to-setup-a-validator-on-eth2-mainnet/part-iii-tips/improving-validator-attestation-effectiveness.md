# :sparkles: Improving Validator Attestation Effectiveness

{% hint style="info" %}
Learn about [attestation effectiveness from Attestant.io](https://www.attestant.io/posts/defining-attestation-effectiveness/)
{% endhint %}

#### :family\_mwgg: Strategy #1: Increase beacon chain peer count

{% hint style="info" %}
This change will result in increased bandwidth and memory usage. Tweak and tailor appropriately for your hardware.

_Kudos to _[_Rémy Roy_](https://www.reddit.com/user/remyroy/)_ for this strat._
{% endhint %}

Edit your `beacon-chain.service` unit file (except for Teku).

```bash
sudo nano /etc/systemd/system/beacon-chain.service
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
# Edit teku.yaml
sudo nano /etc/teku/teku.yaml

# add the following line to teku.yaml and save the file
p2p-peer-upper-bound: 100
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
sudo systemctl restart beacon-chain
```

#### :man\_technologist: Strategy #2: Execution Client (Eth1) redundancy

{% hint style="info" %}
Especially useful during eth1 upgrades, when your primary node is temporarily unavailable.
{% endhint %}

Edit your `beacon-chain.service` unit file.

```bash
sudo nano /etc/systemd/system/beacon-chain.service
```

Add the following flag on the `ExecStart` line.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
--eth1-endpoints <http://alternate eth1 endpoints>
# Example, separate endpoints with commas.
# --eth1-endpoints http://localhost:8545,https://nodes.mewapi.io/rpc/eth,https://mainnet.eth.cloud.ava.do,https://mainnet.infura.io/v3/xxx
```
{% endtab %}

{% tab title="Prysm" %}
```bash
--fallback-web3provider=<http://<alternate eth1 provider one> --fallback-web3provider=<http://<alternate eth1 provider two>
# Example, repeat flag for multiple eth1 providers
# --fallback-web3provider=https://nodes.mewapi.io/rpc/eth --fallback-web3provider=https://mainnet.infura.io/v3/YOUR-PROJECT-ID
```
{% endtab %}

{% tab title="Teku" %}
```bash
--eth1-endpoints <http://alternate eth1 endpoints>,<http://alternate eth1 endpoints>
# Support for automatic fail-over of eth1-endpoints. Multiple endpoints can be specified with the new --eth1-endpoints CLI option.
# Example
# --eth1-endpoints http://localhost:8545,https://infura.io/
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
--web3-url <http://alternate eth1 endpoint>
# Multiple endpoints can be specified with additional parameters of --web3-url
# Example
# --web3-url http://localhost:8545 --web3-url wss://mainnet.infura.io/ws/v3/...
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
:money\_with\_wings: Find free ethereum fallback nodes at [https://ethereumnodes.com/](https://ethereumnodes.com)
{% endhint %}

Reload the updated unit file and restart the beacon-chain process to complete this change.

```bash
sudo systemctl daemon-reload
sudo systemctl restart beacon-chain
```

#### :gear: Strategy #3: Perform updates or reboots during the longest attestation gap

Learn how to at [this quick guide.](../part-ii-maintenance/finding-the-longest-attestation-slot-gap.md)

#### :chains: Strategy #4: Beacon node redundancy

{% hint style="info" %}
Allows the VC (validator client) to connect to multiple BN (beacon nodes). This means your validator client can use multiple BNs. Whenever a BN fails to respond, the VC will try again with the next BN.

Must install a BN of the same consensus client on another server.

Currently only works for Lighthouse.
{% endhint %}

Edit your `validator.service` unit file.

```bash
sudo nano /etc/systemd/system/validator.service
```

Add the following flag on the `ExecStart` line.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
--beacon-nodes <BEACON-NODE ENDPOINTS>
# Example, separate endpoints with commas.
# lighthouse vc --beacon-nodes http://localhost:5052,http://192.168.1.100:5052
# If localhost is not responsive (perhaps during an update), the VC will attempt to use 192.168.1.100 instead.
```
{% endtab %}

{% tab title="Nimbus" %}
```
--web3-url=ws://127.0.0.1:8546 --web3-url=<update with your wss://mainnet.infura.io/ws/v3/nnnnn>
# Example, separate endpoints with commas.
# nimbus_beacon_node --data-dir=/var/lib/nimbus --web3-url=ws://127.0.0.1:8546 --web3-url=wss://mainnet.infura.io/ws/v3/zzz --
# If localhost is not responsive (perhaps during an update), the VC will attempt to use 192.168.1.100 instead.
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
[Infura.io](https://infura.io) offers beacon-node endpoints.
{% endhint %}

Reload the updated unit file and restart the validator process to complete this change.

```bash
sudo systemctl daemon-reload
sudo systemctl restart validator
```
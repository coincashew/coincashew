# Nimbus

## Overview

{% hint style="info" %}
[Nimbus](https://our.status.im/tag/nimbus/) is a research project and a client implementation for Ethereum designed to perform well on embedded systems and personal mobile devices, including older smartphones with resource-restricted hardware. The Nimbus team are from [Status](https://status.im/about/) the company best known for [their messaging app/wallet/Web3 browser](https://status.im) by the same name. Nimbus (Apache 2) is written in Nim, a language with Python-like syntax that compiles to C.
{% endhint %}

{% hint style="info" %}
**Note**: Nimbus is configured to run both **validator client** and **beacon chain client** in one process.
{% endhint %}

#### Official Links

| Subject       | Links                                                                                                  |
| ------------- | ------------------------------------------------------------------------------------------------------ |
| Releases      | [https://github.com/status-im/nimbus-eth2/releases](https://github.com/status-im/nimbus-eth2/releases) |
| Documentation | [https://nimbus.guide](https://nimbus.guide/)                                                          |
| Website       | [https://our.status.im/tag/nimbus](https://our.status.im/tag/nimbus/)                                  |

### 1. Initial configuration

Create a service user for the consensus service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group consensus
sudo mkdir -p /var/lib/nimbus
sudo chown -R consensus:consensus /var/lib/nimbus
```

Install dependencies.

```bash
sudo apt install curl libsnappy-dev libc6-dev jq libc6 unzip ccze -y
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

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
```

Install the binaries, display version and cleanup.

```bash
sudo mv nimbus/build/nimbus_beacon_node /usr/local/bin
sudo mv nimbus/build/nimbus_validator_client /usr/local/bin
nimbus_beacon_node --version
rm -r nimbus
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Install dependencies.

```bash
sudo apt-get update
sudo apt-get install curl build-essential git -y
```

Build the binary.

```bash
mkdir -p ~/git
cd ~/git
git clone -b stable https://github.com/status-im/nimbus-eth2
cd nimbus-eth2
make -j$(nproc) update
make -j$(nproc) nimbus_beacon_node
make -j$(nproc) nimbus_validator_client
```

Verify Nimbus was built properly by displaying the version.

```bash
cd $HOME/git/nimbus-eth2/build
./nimbus_beacon_node --version
```

Install the binary.

```bash
sudo cp $HOME/git/nimbus-eth2/build/nimbus_beacon_node /usr/local/bin
sudo cp $HOME/git/nimbus-eth2/build/nimbus_validator_client /usr/local/bin
```

</details>

### **3. Setup and configure systemd**

Create a **systemd unit file** to define your `consensus.service` configuration.

```bash
sudo nano /etc/systemd/system/consensus.service
```

Paste the following configuration into the file.

{% tabs %}
{% tab title="Standalone Beacon Node (Recommended)" %}
```shell
[Unit]
Description=Nimbus Consensus Layer Client service for Hoodi
Wants=network-online.target
After=network-online.target
Documentation=https://www.coincashew.com

[Service]
Type=simple
User=consensus
Group=consensus
Restart=on-failure
RestartSec=3
KillSignal=SIGINT
TimeoutStopSec=900
ExecStart=/usr/local/bin/nimbus_beacon_node \
  --network=hoodi \
  --data-dir=/var/lib/nimbus \
  --tcp-port=9000 \
  --udp-port=9000 \
  --max-peers=100 \
  --rest-port=5052 \
  --enr-auto-update=true \
  --non-interactive \
  --status-bar=false \
  --in-process-validators=false \
  --web3-url=http://127.0.0.1:8551 \
  --rest \
  --metrics \
  --metrics-port=8008 \
  --jwt-secret="/secrets/jwtsecret" \
  --suggested-fee-recipient=<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
```
{% endtab %}

{% tab title="Combined (BN+VC)" %}
{% hint style="info" %}
This configuration combines the beacon chain and validator into one running service. While it is simpler to manage and run, this configuration is less flexible when it comes to running EL+CL failover nodes or in times you wish to resync your execution client and temporarily use [Rocket Pool's Rescue Node](https://rescuenode.com/docs/how-to-connect/solo).
{% endhint %}

```shell
[Unit]
Description=Nimbus Consensus Layer Client service for Hoodi
Wants=network-online.target
After=network-online.target
Documentation=https://www.coincashew.com

[Service]
Type=simple
User=consensus
Group=consensus
Restart=on-failure
RestartSec=3
KillSignal=SIGINT
TimeoutStopSec=900
ExecStart=/usr/local/bin/nimbus_beacon_node \
  --network=hoodi \
  --data-dir=/var/lib/nimbus \
  --tcp-port=9000 \
  --udp-port=9000 \
  --max-peers=100 \
  --rest-port=5052 \
  --enr-auto-update=true \
  --web3-url=http://127.0.0.1:8551 \
  --rest \
  --metrics \
  --metrics-port=8008 \
  --jwt-secret="/secrets/jwtsecret" \
  --graffiti="🏠🥩🪙🛡️" \
  --suggested-fee-recipient=<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
```
{% endtab %}
{% endtabs %}

* Replace `<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>` with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
* **Not staking?** If you only want a full node, use the Standalone Beacon Node configuration and delete the whole line beginning with

```
--suggested-fee-recipient
```

To exit and save, press `Ctrl` + `X`, then `Y`, then `Enter`.

Run the following to quickly sync with Checkpoint Sync.

{% hint style="info" %}
Checkpoint sync allows you to start your consensus layer within minutes instead of days.
{% endhint %}

```bash
sudo -u consensus /usr/local/bin/nimbus_beacon_node trustedNodeSync \
--network=holesky \
--trusted-node-url=https://holesky.beaconstate.ethstaker.cc \
--data-dir=/var/lib/nimbus \
--backfill=false
```

When the checkpoint sync is complete, you'll see the following message:

> Done, your beacon node is ready to serve you! Don't forget to check that you're on the canonical chain by comparing the checkpoint root with other online sources. See https://nimbus.guide/trusted-node-sync.html for more information.

Run the following to enable auto-start at boot time.

```bash
sudo systemctl daemon-reload
sudo systemctl enable consensus
```

Finally, start your consensus layer client and check it's status.

```bash
sudo systemctl start consensus
sudo systemctl status consensus
```

Press `Ctrl` + `C` to exit the status.

Check your logs to confirm that the consensus clients are up and syncing.

```bash
sudo journalctl -fu consensus | ccze
```

**Example of Synced Consensus Client Logs**

```
nimbus_beacon_node[292966]: INF 2023-02-05 01:20:00.000+00:00 Slot start       topics="beacnde" slot=31205 epoch=903 sync=synced peers=80 head=13a131:31204 finalized=1111:cdba33411 delay=69us850ns
nimbus_beacon_node[292966]: INF 2023-02-05 01:20:08.000+00:00 Slot end         topics="beacnde" slot=31205 nextActionWait=7m27s985ms126us530ns nextAttestationSlot=31235 nextProposalSlot=-1 syncCommitteeDuties=none head=13a131:31204
```

### 4. Helpful consensus client commands

{% tabs %}
{% tab title="View Logs" %}
```bash
sudo journalctl -fu consensus | ccze
```

**Example of Synced Nimbus Consensus Client Logs**

```bash
nimbus_beacon_node[292966]: INF 2023-02-05 01:20:00.000+00:00 Slot start       topics="beacnde" slot=31205 epoch=903 sync=synced peers=80 head=13a131:31204 finalized=1111:cdba33411 delay=69us850ns
nimbus_beacon_node[292966]: INF 2023-02-05 01:20:08.000+00:00 Slot end         topics="beacnde" slot=31205 nextActionWait=7m27s985ms126us530ns nextAttestationSlot=31235 nextProposalSlot=-1 syncCommitteeDuties=none head=13a131:31204
```
{% endtab %}

{% tab title="Stop" %}
```bash
sudo systemctl stop consensus
```
{% endtab %}

{% tab title="Start" %}
```bash
sudo systemctl start consensus
```
{% endtab %}

{% tab title="View Status" %}
```bash
sudo systemctl status consensus
```
{% endtab %}

{% tab title="Reset Database" %}
Common reasons to reset the database can include:

* To reduce disk space usage
* To recover from a corrupted database due to power outage or hardware failure
* To upgrade to a new storage format

```bash
sudo systemctl stop consensus
sudo rm -rf /var/lib/nimbus/db

#Perform checkpoint sync
sudo -u consensus /usr/local/bin/nimbus_beacon_node trustedNodeSync \
--network=holesky \
--trusted-node-url=https://holesky.beaconstate.ethstaker.cc \
--data-dir=/var/lib/nimbus \
--backfill=false

sudo systemctl restart consensus
```

With checkpoint sync, time to re-sync the consensus client should take only a minute or two.
{% endtab %}
{% endtabs %}

Now that your consensus client is configured and started, you have a full node.

Proceed to the next step on setting up your validator client, which turns a full node into a staking node.

{% hint style="info" %}
If you wanted to setup a full node, not a staking node, stop here! Congrats on running your own full node! :tada:
{% endhint %}

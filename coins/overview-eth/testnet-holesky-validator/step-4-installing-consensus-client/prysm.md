# Prysm

## Overview

{% hint style="info" %}
[Prysm](https://github.com/prysmaticlabs/prysm) is a Go implementation of Ethereum protocol with a focus on usability, security, and reliability. Prysm is developed by [Prysmatic Labs](https://prysmaticlabs.com), a company with the sole focus on the development of their client. Prysm is written in Go and released under a GPL-3.0 license.
{% endhint %}

#### Official Links

| Subject       | Links                                                                                              |
| ------------- | -------------------------------------------------------------------------------------------------- |
| Releases      | [https://github.com/prysmaticlabs/prysm/releases](https://github.com/prysmaticlabs/prysm/releases) |
| Documentation | [https://docs.prylabs.network](https://docs.prylabs.network/)                                      |
| Website       | [https://prysmaticlabs.com](https://prysmaticlabs.com/)                                            |

### 1. Initial configuration

Create a service user for the consensus service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group consensus
sudo mkdir -p /var/lib/prysm/beacon
sudo chown -R consensus:consensus /var/lib/prysm/beacon
```

Install dependencies.

```bash
sudo apt install curl jq git ccze -y
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest binaries.

```bash
cd $HOME
prysm_version=$(curl -f -s https://prysmaticlabs.com/releases/latest)
file_beacon=beacon-chain-${prysm_version}-linux-amd64
file_validator=validator-${prysm_version}-linux-amd64
curl -f -L "https://prysmaticlabs.com/releases/${file_beacon}" -o beacon-chain
curl -f -L "https://prysmaticlabs.com/releases/${file_validator}" -o validator
chmod +x beacon-chain validator
```

Install the binaries.

<pre class="language-bash"><code class="lang-bash"><strong>sudo mv beacon-chain validator /usr/local/bin
</strong></code></pre>

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Install Bazel

```bash
wget -O bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.16.0/bazelisk-linux-amd64
chmod +x bazel
sudo mv bazel /usr/local/bin
```

Build the binaries.

```bash
mkdir -p ~/git
cd ~/git
git clone https://github.com/prysmaticlabs/prysm.git
cd prysm
git fetch --tags
RELEASETAG=$(curl -s https://api.github.com/repos/prysmaticlabs/prysm/releases/latest | jq -r .tag_name)
git checkout tags/$RELEASETAG
bazel build //cmd/beacon-chain:beacon-chain --config=release
bazel build //cmd/validator:validator --config=release
```

Verify Prysm was built properly by displaying the help menu.

```shell
bazel run //beacon-chain -- --help
```

Install the binaries.

```shell
sudo cp -a $HOME/git/prysm /usr/local/bin/prysm
```

</details>

### **3. Setup and configure systemd**

Create a **systemd unit file** to define your `consensus.service` configuration.

```bash
sudo nano /etc/systemd/system/consensus.service
```

Depending on whether you're downloading binaries or building from source, choose the appropriate option. Paste the following configuration into the file.

<details>

<summary>Option 1 - Configuration for binaries</summary>

<pre class="language-bash"><code class="lang-bash"><strong>[Unit]
</strong>Description=Prysm Consensus Layer Client service for Holesky
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
ExecStart=/usr/local/bin/beacon-chain \
  --holesky \
  --datadir=/var/lib/prysm/beacon \
  --p2p-tcp-port 13000 \
  --p2p-udp-port 12000 \
  --p2p-max-peers 80 \
  --monitoring-port 8008 \
  --checkpoint-sync-url=https://holesky.beaconstate.ethstaker.cc \
  --execution-endpoint=http://localhost:8551 \
  --jwt-secret=/secrets/jwtsecret \
  --accept-terms-of-use=true \
  --suggested-fee-recipient=&#x3C;0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
</code></pre>

</details>

<details>

<summary>Option 2 - Configuration for building from source</summary>

<pre class="language-shell"><code class="lang-shell"><strong>[Unit]
</strong>Description=Prysm Consensus Layer Client service for Holesky
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
WorkingDirectory=/usr/local/bin/prysm
ExecStart=bazel run //cmd/beacon-chain --config=release -- \
  --holesky \
  --datadir=/var/lib/prysm/beacon \
  --p2p-tcp-port 13000 \
  --p2p-udp-port 12000 \
  --p2p-max-peers 80 \
  --monitoring-port 8008 \
  --checkpoint-sync-url=https://holesky.beaconstate.ethstaker.cc \
  --execution-endpoint=http://localhost:8551 \
  --jwt-secret=/secrets/jwtsecret \
  --accept-terms-of-use=true \
  --suggested-fee-recipient=&#x3C;0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
</code></pre>

</details>

* Replace`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>` with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
* **Not staking?** If you only want a full node, delete the whole lines beginning with

```
--suggested-fee-recipient
```

To exit and save, press `Ctrl` + `X`, then `Y`, then `Enter`.

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

```bash
"Peer summary" activePeers=69 inbound=0 outbound=69 prefix=p2p
"Synced new block" block=0xb5ccb2f85... epoch=1837 finalizedEpoch=1838 finalizedRoot=0x1dce0... prefix=blockchain slot=21338 "Finished applying state transition" attestations=128 payloadHash=0x000000000000 prefix=blockchain slot=2138 syncBitsCount=213 txCount=0"terminal difficulty has not been reached yet" latestDifficulty=10000000 prefix=powchain terminalDifficulty=10000000
```

### 4. Helpful consensus client commands

{% tabs %}
{% tab title="View Logs" %}
```bash
sudo journalctl -fu consensus | ccze
```

**Example of Synced Prysm Consensus Client Logs**

```bash
time="2023-02-02 11:21:00" level=info msg="Peer summary" activePeers=35 inbound=10 outbound=25 prefix=p2p
time="2023-02-02 11:21:00" level=info msg="Synced new block" block=0xd9ddeza1289... epoch=11795 finalizedEpoch=111794 finalizedRoot=0x462e3275... prefix=blockchain slot=31205
time="2023-02-02 11:21:00" level=info msg="Finished applying state transition" attestations=64 payloadHash=0x000000000000 prefix=blockchain slot=31205 syncBitsCount=209 txCount=0
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
sudo rm -rf /var/lib/prysm/beacon/beaconchaindata
sudo systemctl restart consensus
```

With checkpoint sync enabled, time to re-sync the consensus client should take only a minute or two.
{% endtab %}
{% endtabs %}

Now that your consensus client is configured and started, you have a full node.

Proceed to the next step on setting up your validator client, which turns a full node into a staking node.

{% hint style="info" %}
If you wanted to setup a full node, not a staking node, stop here! Congrats on running your own full node! :tada:
{% endhint %}

# Teku

## Overview

{% hint style="info" %}
[PegaSys Teku](https://consensys.net/knowledge-base/ethereum-2/teku/) (formerly known as Artemis) is a Java-based Ethereum client designed & built to meet institutional needs and security requirements. PegaSys is an arm of [ConsenSys](https://consensys.net) dedicated to building enterprise-ready clients and tools for interacting with the core Ethereum platform. Teku is Apache 2 licensed and written in Java, a language notable for its materity & ubiquity.
{% endhint %}

{% hint style="info" %}
**Note**: Teku is configured to run both **validator client** and **beacon chain client** in one process.
{% endhint %}

#### Official Links

| Subject       | Links                                                                                                         |
| ------------- | ------------------------------------------------------------------------------------------------------------- |
| Releases      | [https://github.com/ConsenSys/teku/releases](https://github.com/ConsenSys/teku/releases)                      |
| Documentation | [https://docs.teku.consensys.net/introduction](https://docs.teku.consensys.net/introduction)                  |
| Website       | [https://consensys.net/knowledge-base/ethereum-2/teku](https://consensys.net/knowledge-base/ethereum-2/teku/) |

### 1. Initial configuration

Create a service user for the consensus service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group consensus
sudo mkdir -p /var/lib/teku
sudo chown -R consensus:consensus /var/lib/teku
```

Install dependencies.

```bash
sudo apt install curl ccze openjdk-17-jdk libsnappy-dev libc6-dev jq git libc6 unzip -y
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/ConsenSys/teku/releases/latest"
LATEST_TAG="$(curl -s $RELEASE_URL | jq -r ".tag_name")"
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
```

Install the binaries.

<pre class="language-bash"><code class="lang-bash"><strong>sudo mv $HOME/teku /usr/local/bin/teku
</strong></code></pre>

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Build the binaries.

```bash
mkdir -p ~/git
cd ~/git
git clone https://github.com/ConsenSys/teku.git
cd teku
# Get new tags
git fetch --tags
RELEASETAG=$(curl -s https://api.github.com/repos/ConsenSys/teku/releases/latest | jq -r .tag_name)
git checkout tags/$RELEASETAG
./gradlew distTar installDist
```

Verify Teku was built properly by displaying the version.

```shell
cd $HOME/git/teku/build/install/teku/bin
./teku --version
```

Install the binaries.

```shell
sudo cp -a $HOME/git/teku/build/install/teku /usr/local/bin/teku
```

</details>

### **3. Setup and configure systemd**

Create a **systemd unit file** to define your `consensus.service` configuration.

```bash
sudo nano /etc/systemd/system/consensus.service
```

Paste the following configuration into the file.

<pre class="language-shell"><code class="lang-shell"><strong>[Unit]
</strong>Description=Teku Consensus Layer Client service for Holesky
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
Environment=JAVA_OPTS=-Xmx5g
ExecStart=/usr/local/bin/teku/bin/teku \
  --network holesky \
  --data-path /var/lib/teku/ \
  --data-storage-mode="prune" \
  --initial-state="https://holesky.beaconstate.ethstaker.cc/eth/v2/debug/beacon/states/finalized" \
  --ee-endpoint http://127.0.0.1:8551 \
  --ee-jwt-secret-file /secrets/jwtsecret \
  --rest-api-enabled true \
  --metrics-enabled true \
  --metrics-port 8008 \
  --validator-keys /var/lib/teku/validator_keys:/var/lib/teku/validator_keys \
  --validators-graffiti "" \
  --validators-proposer-default-fee-recipient &#x3C;0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
</code></pre>

* Replace`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>` with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
* **Not staking?** If you only want a full node, delete the whole three lines beginning with

```
--validator-keys
--validators-graffiti
--validators-proposer-default-fee-recipient
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
teku[64122]: 02:24:28.010 INFO  - Slot Event  *** Slot: 19200, Block: 1468A43F874EDE790DB6B499A51003500B5BA85226E9500A7A187DB9A169DE20, Justified: 1132, Finalized: 1133, Peers: 70
teku[64122]: 02:24:40.010 INFO  - Slot Event  *** Slot: 19200, Block: 72B092AADFE146F5D3F395A720C0AA3B2354B2095E3F10DC18F0E9716D286DCB, Justified: 1132, Finalized: 1133, Peers: 70
```

### 4. Helpful consensus client commands

{% tabs %}
{% tab title="View Logs" %}
```bash
sudo journalctl -fu consensus | ccze
```

**Example of Synced Teku Consensus Client Logs**

```bash
teku[64122]: 02:24:28.010 INFO  - Slot Event  *** Slot: 19200, Block: 1468A43F874EDE790DB6B499A51003500B5BA85226E9500A7A187DB9A169DE20, Justified: 1132, Finalized: 1133, Peers: 70
teku[64122]: 02:24:40.010 INFO  - Slot Event  *** Slot: 19200, Block: 72B092AADFE146F5D3F395A720C0AA3B2354B2095E3F10DC18F0E9716D286DCB, Justified: 1132, Finalized: 1133, Peers: 70
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
sudo rm -rf /var/lib/teku/beacon
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

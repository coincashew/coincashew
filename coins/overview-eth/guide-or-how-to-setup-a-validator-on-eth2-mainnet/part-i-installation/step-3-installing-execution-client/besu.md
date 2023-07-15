# Besu

## Overview

{% hint style="info" %}
**Hyperledger Besu** is an open-source Ethereum client designed for demanding enterprise applications requiring secure, high-performance transaction processing in a private network. It's developed under the Apache 2.0 license and written in **Java**.
{% endhint %}

#### Official Links

| Subject       | Link                                                                                         |
| ------------- | -------------------------------------------------------------------------------------------- |
| Releases      | [https://github.com/hyperledger/besu/releases](https://github.com/hyperledger/besu/releases) |
| Documentation | [https://besu.hyperledger.org](https://besu.hyperledger.org/en/stable/)                      |
| Website       | [https://www.hyperledger.org/use/besu](https://www.hyperledger.org/use/besu)                 |

### 1. Initial configuration

Create a service user for the execution service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group execution
sudo mkdir -p /var/lib/besu
sudo chown -R execution:execution /var/lib/besu
```

Install dependencies.

```bash
sudo apt install -y openjdk-17-jdk libjemalloc-dev
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/hyperledger/besu/releases/latest"
FILE="https://hyperledger.jfrog.io/artifactory/besu-binaries/besu/[a-zA-Z0-9./?=_%:-]*.tar.gz"
BINARIES_URL="$(curl -s $RELEASE_URL | grep -Eo $FILE)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O besu.tar.gz $BINARIES_URL
tar -xzvf besu.tar.gz -C $HOME
rm besu.tar.gz
sudo mv $HOME/besu-* besu
```

Install the binaries.

<pre class="language-bash"><code class="lang-bash"><strong>sudo mv $HOME/besu /usr/local/bin/besu
</strong></code></pre>

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Build the binaries.

```bash
mkdir -p ~/git
cd ~/git
# Clone the repo
git clone https://github.com/hyperledger/besu.git
cd besu
# Get new tags
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
# Build
./gradlew installDist
```

Verify Besu was properly built by checking the version.

```shell
./build/install/besu/bin/besu --version
```

Sample output of a compatible version.

```
besu/v23.4.0/linux-x86_64/openjdk-java-17
```

Install the binaries.

<pre class="language-shell"><code class="lang-shell"><strong>sudo cp -a $HOME/git/besu/build/install/besu /usr/local/bin/besu
</strong></code></pre>

</details>

### **3. Setup and configure systemd**

Create a **systemd unit file** to define your `execution.service` configuration.

```bash
sudo nano /etc/systemd/system/execution.service
```

Paste the following configuration into the file.

```shell
[Unit]
Description=Besu Execution Layer Client service for Mainnet
Wants=network-online.target
After=network-online.target
Documentation=https://www.coincashew.com

[Service]
Type=simple
User=execution
Group=execution
Restart=on-failure
RestartSec=3
KillSignal=SIGINT
TimeoutStopSec=900
Environment="JAVA_OPTS=-Xmx5g"
ExecStart=/usr/local/bin/besu/bin/besu \
  --network=mainnet \
  --metrics-enabled=true \
  --sync-mode=X_CHECKPOINT \
  --data-storage-format=BONSAI \
  --data-path="/var/lib/besu" \
  --Xplugin-rocksdb-high-spec-enabled \
  --engine-jwt-secret=/secrets/jwtsecret
  
[Install]
WantedBy=multi-user.target
```

To exit and save, press `Ctrl` + `X`, then `Y`, then `Enter`.

Run the following to enable auto-start at boot time.

```bash
sudo systemctl daemon-reload
sudo systemctl enable execution
```

Finally, start your execution layer client and check it's status.

```bash
sudo systemctl start execution
sudo systemctl status execution
```

Press `Ctrl` + `C` to exit the status.

### 4. Helpful execution client commands

{% tabs %}
{% tab title="View Logs" %}
```bash
sudo journalctl -fu execution | ccze
```

A properly functioning **Besu** execution client will indicate "Fork-Choice-Updates". For example,

```
2022-03-19 04:09:36.315+00:00 | vert.x-worker-thread-0 | INFO  | EngineForkchoiceUpdated | Consensus fork-choice-update: head: 0xcd2a_8b32..., finalized: 0xfa22_1142...
2022-03-19 04:09:48.328+00:00 | vert.x-worker-thread-0 | INFO  | EngineForkchoiceUpdated | Consensus fork-choice-update: head: 0xff1a_f12a..., finalized: 0xfa22_1142...
```
{% endtab %}

{% tab title="Stop" %}
```bash
sudo systemctl stop execution
```
{% endtab %}

{% tab title="Start" %}
```bash
sudo systemctl start execution
```
{% endtab %}

{% tab title="View Status" %}
```bash
sudo systemctl status execution
```
{% endtab %}
{% endtabs %}

Now that your execution client is configured and started, proceed to the next step on setting up your consensus client.

{% hint style="warning" %}
If you're checking the logs and see any warnings or errors, please be patient as these will normally resolve once both your execution and consensus clients are fully synced to the Ethereum network.
{% endhint %}

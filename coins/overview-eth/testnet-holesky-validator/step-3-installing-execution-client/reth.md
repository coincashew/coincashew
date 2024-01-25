# Reth

## Overview

{% hint style="info" %}
**Reth** - short for Rust Ethereum, is an Ethereum full node implementation that is focused on being user-friendly, highly modular, as well as being fast and efficient.
{% endhint %}

{% hint style="warning" %}
:construction: Reth is the bleeding edge of Ethereum EL clients. As alpha software, expect rapid change and proceed with caution. :construction:
{% endhint %}

#### Official Links



| Subject       | Link                                                                       |
| ------------- | -------------------------------------------------------------------------- |
| Releases      | [https://github.com/paradigmxyz/reth](https://github.com/paradigmxyz/reth) |
| Documentation | [https://paradigmxyz.github.io/reth/](https://paradigmxyz.github.io/reth/) |
| Website       | [https://www.paradigm.xyz/oss/reth](https://www.paradigm.xyz/oss/reth)     |

### 1. Create service account and data directory

Create a service user for the execution service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group execution
sudo mkdir -p /var/lib/reth
sudo chown -R execution:execution /var/lib/reth
```

Install dependencies.

```bash
sudo apt-get update
sudo apt install -y ccze jq curl
```

### **2. Install binaries**

* Downloading binaries is often faster and more convenient.
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

```bash
RELEASE_URL="https://api.github.com/repos/paradigmxyz/reth/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep x86_64-unknown-linux-gnu.tar.gz$)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O reth.tar.gz $BINARIES_URL
tar -xzvf reth.tar.gz -C $HOME
rm reth.tar.gz
```

Install the binaries and display the version.

```bash
sudo mv $HOME/reth /usr/local/bin
reth --version
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

**Install rust dependency**

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

When prompted, enter '1' to proceed with the default install.

Update your environment variables.

```bash
echo export PATH="$HOME/.cargo/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

Install rust dependencies.

```bash
sudo apt-get update
sudo apt install -y git libclang-dev pkg-config build-essential
```

Build the binaries.

```bash
mkdir -p ~/git
cd ~/git
git clone https://github.com/paradigmxyz/reth.git
cd reth
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
# Build the release
cargo build --release
```

In case of compilation errors, run the following sequence.

```bash
rustup update
cargo clean
cargo build --release
```

Verify Reth was built properly by checking the version number.

```bash
~/git/reth/target/release/reth --version
```

Install the binary.

```bash
sudo cp ~/git/reth/target/release/reth /usr/local/bin
```

</details>

### **3. Setup and configure systemd**

Create a **systemd unit file** to define your `execution.service` configuration.

```bash
sudo nano /etc/systemd/system/execution.service
```

Paste the following configuration into the file.

<pre class="language-bash"><code class="lang-bash">[Unit]
Description=Reth Execution Layer Client service for Holesky
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
Environment=RUST_LOG=info
ExecStart=/usr/local/bin/reth node \
    --full \
    --chain holesky \
    --datadir=/var/lib/reth \
    --metrics 127.0.0.1:6060 \
    --port 30303 \
    --http \
    --http.port 8545 \
    --http.api="rpc,eth,web3,net,debug" \
    --log.file.directory=/var/lib/reth/logs \
    --max-outbound-peers 25 \
    --max-inbound-peers 25 \
    --authrpc.jwtsecret=/secrets/jwtsecret
   
<strong>[Install]
</strong>WantedBy=multi-user.target
</code></pre>

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
<pre class="language-bash"><code class="lang-bash"><strong>sudo journalctl -fu execution | ccze
</strong></code></pre>

A properly functioning **Reth** execution client will indicate "Block added to canonical chain". For example,

```
INFO reth::node::events: Forkchoice updated head_block_hash=2317ae..c41107 safe_block_hash=ab173f..33a21b finalized_block_hash=ab173f..33a21b status=Valid
INFO reth::node::events: Block added to canonical chain number=16000 hash=2317ae..c41107
INFO reth::node::events: Canonical chain committed number=16000 hash=2317ae..c41107 elapsed=12.508272ms
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

{% tab title="Reset Database" %}
Common reasons to reset the database can include:

* Recovering from a corrupted database due to power outage or hardware failure
* Re-syncing to reduce disk space usage
* Upgrading to a new storage format

```bash
sudo systemctl stop execution
sudo rm -rf /var/lib/reth/*
sudo systemctl restart execution
```

Time to re-sync the execution client can take a few hours up to a day.
{% endtab %}
{% endtabs %}

Now that your execution client is configured and started, proceed to the next step on setting up your consensus client.

{% hint style="warning" %}
If you're checking the logs and see any warnings or errors, please be patient as these will normally resolve once both your execution and consensus clients are fully synced to the Ethereum network.
{% endhint %}

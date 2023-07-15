# Lighthouse

## Overview

{% hint style="info" %}
[Lighthouse](https://github.com/sigp/lighthouse) is an Eth client with a heavy focus on speed and security. The team behind it, [Sigma Prime](https://sigmaprime.io), is an information security and software engineering firm who have funded Lighthouse along with the Ethereum Foundation, Consensys, and private individuals. Lighthouse is built in Rust and offered under an Apache 2.0 License.
{% endhint %}

#### Official Links

| Subject       | Links                                                                                      |
| ------------- | ------------------------------------------------------------------------------------------ |
| Releases      | [https://github.com/sigp/lighthouse/releases](https://github.com/sigp/lighthouse/releases) |
| Documentation | [https://lighthouse-book.sigmaprime.io](https://lighthouse-book.sigmaprime.io/)            |
| Website       | [https://lighthouse.sigmaprime.io](https://lighthouse.sigmaprime.io/)                      |

### 1. Initial configuration

Create a service user for the consensus service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group consensus
sudo mkdir -p /var/lib/lighthouse
sudo chown -R consensus:consensus /var/lib/lighthouse
```

Install dependencies.

```bash
sudo apt install curl -y
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.&#x20;
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/sigp/lighthouse/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep x86_64-unknown-linux-gnu.tar.gz$)"

echo Downloading URL: $BINARIES_URL

cd $HOME
# Download
wget -O lighthouse.tar.gz $BINARIES_URL
# Untar
tar -xzvf lighthouse.tar.gz -C $HOME
# Cleanup
rm lighthouse.tar.gz
```

Install the binaries.

<pre class="language-bash"><code class="lang-bash"><strong>sudo mv $HOME/lighthouse /usr/local/bin/lighthouse
</strong></code></pre>

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
sudo apt install -y git gcc g++ make cmake pkg-config libssl-dev libclang-dev clang protobuf-compiler
```

Build the binaries.

```bash
mkdir -p ~/git
cd ~/git
git clone -b stable https://github.com/sigp/lighthouse.git
cd lighthouse
make
```

In case of compilation errors, run the following sequence.

```bash
rustup update
cargo clean
make
```

Verify lighthouse was built properly by checking the version number.

```
lighthouse --version
```

Install the binary.

```bash
sudo cp $HOME/.cargo/bin/lighthouse /usr/local/bin/lighthouse
```

</details>

### **3. Setup and configure systemd**

Create a **systemd unit file** to define your `consensus.service` configuration.

```bash
sudo nano /etc/systemd/system/consensus.service
```

Paste the following configuration into the file.

```shell
[Unit]
Description=Lighthouse Consensus Layer Client service for Mainnet
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
ExecStart=/usr/local/bin/lighthouse bn \
  --datadir /var/lib/lighthouse \
  --network mainnet \
  --staking \
  --validator-monitor-auto \
  --metrics \
  --checkpoint-sync-url=https://beaconstate.info \
  --port 9000 \
  --execution-endpoint http://127.0.0.1:8551 \
  --execution-jwt /secrets/jwtsecret

[Install]
WantedBy=multi-user.target
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

Check your logs to confirm that the consensus client is up and syncing.

```bash
sudo journalctl -fu consensus | ccze
```

Press `Ctrl` + `C` to exit the logs.

### 4. Helpful consensus client commands

{% tabs %}
{% tab title="View Logs" %}
```bash
sudo journalctl -fu consensus | ccze
```

**Example of Synced Lighthouse Consensus Client Logs**

```bash
Feb 03 01:02:36.000 INFO New block received                      root: 0xb5ccb2f85d981ca9e1c0d904f967403ddf8c47532c195fe213c94a28ffaf6a2e, slot: 2138
Feb 03 01:02:42.000 INFO Synced                                  slot: 2138, block: 0x1cb281a, epoch: 121, finalized_epoch: 120, finalized_root: 0x1dce0, exec_hash: 0x6827aeb (verified), peers: 50, service: slot_notifier
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
{% endtabs %}

Now that your consensus client is configured and started, you have a full node.

Proceed to the next step on setting up your validator client, which turns a full node into a staking node.

{% hint style="info" %}
If you wanted to setup a full node, not a staking node, stop here! Congrats on running your own full node! :tada:
{% endhint %}


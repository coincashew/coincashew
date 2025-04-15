# Erigon

{% hint style="info" %}
**Erigon** - Successor to OpenEthereum, Erigon is an implementation of Ethereum (aka "Ethereum client"), on the efficiency frontier, written in Go.
{% endhint %}

## Overview

#### Official Links

| Subject       | Link                                                                                           |
| ------------- | ---------------------------------------------------------------------------------------------- |
| Releases      | [https://github.com/erigontech/erigon/releases](https://github.com/erigontech/erigon/releases) |
| Documentation | [https://docs.erigon.tech](https://docs.erigon.tech/)                                          |
| Website       | [https://erigon.tech](https://erigon.tech/)                                                    |

### 1. Initial configuration

Create a service user for the execution service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group execution
sudo mkdir -p /var/lib/erigon
sudo chown -R execution:execution /var/lib/erigon
```

Install dependencies.

```bash
sudo apt install curl libsnappy-dev libc6-dev jq libc6 unzip -y
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/erigontech/erigon/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux_amd64.tar.gz)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O erigon.tar.gz $BINARIES_URL
tar -xzvf erigon.tar.gz -C $HOME
mv erigon_* erigon
```

Install the binaries and cleanup.

```bash
sudo mv $HOME/erigon/erigon /usr/local/bin
rm -rf erigon erigon.tar.gz
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Install Go dependencies. Latest version [available here](https://go.dev/dl/).

```bash
wget -O go.tar.gz <LATEST VERSION URL FROM ABOVE>
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz
echo export PATH=$PATH:/usr/local/go/bin >> $HOME/.bashrc
source $HOME/.bashrc
```

Verify Go is properly installed by checking the version and cleanup files.

```bash
go version
rm go.tar.gz
```

Install build dependencies.

```bash
sudo apt-get update
sudo apt install build-essential git
```

Build the binary.

```bash
mkdir -p ~/git
cd ~/git
git clone https://github.com/erigontech/erigon.git
cd erigon
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
make erigon
```

Install the binary.

<pre class="language-bash"><code class="lang-bash"><strong>sudo cp $HOME/git/erigon/build/bin/erigon /usr/local/bin
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
Description=Erigon Execution Layer Client service for Mainnet
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
ExecStart=/usr/local/bin/erigon \
   --datadir /var/lib/erigon \
   --chain mainnet \
   --port 30303 \
   --torrent.port 42069 \
   --maxpeers 50 \
   --private.api.addr 127.0.0.1:9099 \
   --authrpc.port 8551 \
   --http.api web3,eth,net,engine \
   --metrics \
   --pprof \
   --prune.mode minimal \
   --authrpc.jwtsecret=/secrets/jwtsecret \
   --externalcl=true

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

A properly functioning **Erigon** execution client will indicate "Handling new payload". For example,

```
erigon[3]: [INFO] [09-29|03:36:24.689] [NewPayload] Handling new payload        height=19999 hash=0xea060...2846a907ceb4
erigon[3]: [INFO] [09-29|03:36:25.278] [updateForkchoice] Fork choice update: flushing in-memory state (built by previous newPayload)
erigon[3]: [INFO] [09-29|03:36:25.280] RPC Daemon notified of new headers       from=19998 to=19999 hash=0xeeed..710b597 header sending=13.32µs log sending=290ns
erigon[3]: [INFO] [09-29|03:36:25.280] head updated                             hash=0xea06098ad5e...5e5f43 number=20000
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
sudo rm -rf /var/lib/erigon/*
sudo systemctl restart execution
```

Time to re-sync the execution client can take a few hours up to a day.
{% endtab %}
{% endtabs %}

Now that your execution client is configured and started, proceed to the next step on setting up your consensus client.

{% hint style="warning" %}
If you're checking the logs and see any warnings or errors, please be patient as these will normally resolve once both your execution and consensus clients are fully synced to the Ethereum network.
{% endhint %}

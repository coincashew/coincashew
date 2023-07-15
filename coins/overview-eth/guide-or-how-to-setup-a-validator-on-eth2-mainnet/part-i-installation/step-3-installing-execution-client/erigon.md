# Erigon

{% hint style="info" %}
**Erigon** - Successor to OpenEthereum, Erigon is an implementation of Ethereum (aka "Ethereum client"), on the efficiency frontier, written in Go.
{% endhint %}

## Overview

#### Official Links

| Subject       | Link                                                                                                     |
| ------------- | -------------------------------------------------------------------------------------------------------- |
| Releases      | [https://github.com/ledgerwatch/erigon/releases](https://github.com/ledgerwatch/erigon/releases)         |
| Documentation | [https://erigon.readthedocs.io/en/latest/index.html](https://erigon.readthedocs.io/en/latest/index.html) |
| Website       | [https://erigon.substack.com](https://erigon.substack.com/)                                              |

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
RELEASE_URL="https://api.github.com/repos/ledgerwatch/erigon/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux_amd64)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O erigon.tar.gz $BINARIES_URL
tar -xzvf erigon.tar.gz -C $HOME
rm erigon.tar.gz
```

Install the binaries.

```bash
sudo mv $HOME/erigon /usr/local/bin/erigon
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Install Go dependencies. Latest version [available here](https://go.dev/dl/).

```bash
wget -O go.tar.gz https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
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
git clone -b stable https://github.com/ledgerwatch/erigon.git
cd erigon
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
   --metrics \
   --pprof \
   --prune htc \
   --prune.r.before=11052984 \
   --authrpc.jwtsecret=/secrets/jwtsecret

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
erigon[41]: [INFO] [02-04|01:36:50.362] [2/15 Headers] Waiting for Consensus Layer...
erigon[41]: [INFO] [02-04|01:37:00.273] [2/15 Headers] Handling new payload      height=14001 hash=0x1b2476a50d976536c2846a907ceb4f88cff4d0129ad.
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

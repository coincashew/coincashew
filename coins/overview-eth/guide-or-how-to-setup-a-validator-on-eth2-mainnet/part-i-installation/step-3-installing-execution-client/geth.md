# Geth

## Overview

{% hint style="info" %}
**Geth** - Go Ethereum is one of the three original implementations (along with C++ and Python) of the Ethereum protocol. It is written in **Go**, fully open source and licensed under the GNU LGPL v3.
{% endhint %}

#### Official Links

| Subject       | Link                                                                                                 |
| ------------- | ---------------------------------------------------------------------------------------------------- |
| Releases      | [https://github.com/ethereum/go-ethereum/releases](https://github.com/ethereum/go-ethereum/releases) |
| Documentation | [https://geth.ethereum.org/docs](https://geth.ethereum.org/docs)                                     |
| Website       | [https://geth.ethereum.org](https://geth.ethereum.org/)                                              |

### 1. Create service account and data directory

Create a service user for the execution service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group execution
sudo mkdir -p /var/lib/geth
sudo chown -R execution:execution /var/lib/geth
```

### **2. Install binaries**

* Downloading binaries is often faster and more convenient.&#x20;
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

<pre class="language-bash"><code class="lang-bash">RELEASE_URL="https://geth.ethereum.org/downloads"
<strong>FILE="https://gethstore.blob.core.windows.net/builds/geth-linux-amd64[a-zA-Z0-9./?=_%:-]*.tar.gz"
</strong>BINARIES_URL="$(curl -s $RELEASE_URL | grep -Eo $FILE | head -1)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O geth.tar.gz $BINARIES_URL
tar -xzvf geth.tar.gz -C $HOME
rm geth.tar.gz
sudo mv $HOME/geth-* geth
</code></pre>

Install the binaries.

```bash
sudo mv $HOME/geth/geth /usr/local/bin
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Install Go dependencies

```bash
wget -O go.tar.gz https://go.dev/dl/go1.19.6.linux-amd64.tar.gz
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
git clone -b master https://github.com/ethereum/go-ethereum.git
cd go-ethereum
# Get new tags
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
# Build
make geth
```

Install the binary.

<pre class="language-bash"><code class="lang-bash"><strong>sudo cp $HOME/git/go-ethereum/build/bin/geth /usr/local/bin
</strong></code></pre>

</details>

### **3. Setup and configure systemd**

Create a **systemd unit file** to define your `execution.service` configuration.

```bash
sudo nano /etc/systemd/system/execution.service
```

Paste the following configuration into the file.

<pre class="language-bash"><code class="lang-bash">[Unit]
Description=Geth Execution Layer Client service for Mainnet
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
ExecStart=/usr/local/bin/geth \
    --mainnet \
    --metrics \
    --http \
    --datadir=/var/lib/geth \
    --pprof \
    --state.scheme=path \
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

A properly functioning **Geth** execution client will indicate "Imported new potential chain segment". For example,

```
geth[4531]: INFO [02-04|01:20:48.280] Chain head was updated    number=16000 hash=2317ae..c41107
geth[4531]: INFO [02-04|01:20:49.648] Imported new potential chain segment       number=16000 hash=ab173f..33a21b
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

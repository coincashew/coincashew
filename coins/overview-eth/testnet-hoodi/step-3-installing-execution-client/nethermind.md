# Nethermind

## Overview

{% hint style="info" %}
**Nethermind** is a flagship Ethereum client all about performance and flexibility. Built on **.NET** core, a widespread, enterprise-friendly platform, Nethermind makes integration with existing infrastructures simple, without losing sight of stability, reliability, data integrity, and security.
{% endhint %}

#### Official Links

| Subject       | Link                                                                                                         |
| ------------- | ------------------------------------------------------------------------------------------------------------ |
| Releases      | [https://github.com/NethermindEth/nethermind/releases](https://github.com/NethermindEth/nethermind/releases) |
| Documentation | [https://docs.nethermind.io](https://docs.nethermind.io/)                                                    |
| Website       | [https://nethermind.io/nethermind-client](https://nethermind.io/nethermind-client/)                          |

### 1. Initial configuration

Create a service user for the execution service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group execution
sudo mkdir -p /var/lib/nethermind
sudo chown -R execution:execution /var/lib/nethermind
```

Install dependencies.

```bash
sudo apt update
sudo apt install ccze curl libsnappy-dev libc6-dev jq libc6 unzip -y
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>



Run the following to automatically download the latest linux release, un-zip and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/NethermindEth/nethermind/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux-x64)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O nethermind.zip $BINARIES_URL
unzip -o nethermind.zip -d $HOME/nethermind
rm nethermind.zip
```

Install the binaries.

<pre class="language-bash"><code class="lang-bash"><strong>sudo mv $HOME/nethermind /usr/local/bin/nethermind
</strong></code></pre>

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Install .NET SDK build dependencies.

```bash
#Get latest .net sdk
curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --channel 9.0 --runtime aspnetcore
```

Build the binaries.

```bash
mkdir -p ~/git
cd ~/git
# Clone the repo
git clone https://github.com/NethermindEth/nethermind.git
cd nethermind
# Get new tags
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
# Build
dotnet publish src/Nethermind/Nethermind.Runner -c release -o nethermind
```

Verify Nethermind was properly built by checking the version.

```shell
./nethermind/nethermind --version
```

Sample output of a compatible version.

```
Version: 1.25.2+78c7bf5f
Commit: 78c7bf5f2c0819f23e248ee6d108c17cd053ffd3
Build Date: 2024-01-23 06:34:53Z
OS: Linux x64
Runtime: .NET 8.0.1
```

Install the binaries.

<pre class="language-shell"><code class="lang-shell"><strong>sudo mv $HOME/git/nethermind/nethermind /usr/local/bin
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
Description=Nethermind Execution Layer Client service for Hoodi
Wants=network-online.target
After=network-online.target
Documentation=https://www.coincashew.com

[Service]
Type=simple
User=execution
Group=execution
Restart=always
RestartSec=3
KillSignal=SIGINT
TimeoutStopSec=900
WorkingDirectory=/var/lib/nethermind
Environment="DOTNET_BUNDLE_EXTRACT_BASE_DIR=/var/lib/nethermind"
ExecStart=/usr/local/bin/nethermind/nethermind \
  --config hoodi \
  --datadir="/var/lib/nethermind" \
  --Network.DiscoveryPort 30303 \
  --Network.P2PPort 30303 \
  --Network.MaxActivePeers 50 \
  --JsonRpc.Port 8545 \
  --JsonRpc.EnginePort 8551 \
  --Metrics.Enabled true \
  --Metrics.ExposePort 6060 \
  --JsonRpc.JwtSecretFile /secrets/jwtsecret \
  --Pruning.Mode=Hybrid \
  --Pruning.FullPruningTrigger=VolumeFreeSpace \
  --Pruning.FullPruningThresholdMb=375810 \
  --Pruning.FullPruningMemoryBudgetMb=16384 \
  --Pruning.FullPruningMaxDegreeOfParallelism=2 \
  --Pruning.FullPruningCompletionBehavior=AlwaysShutdown
   
[Install]
WantedBy=multi-user.target
```

{% hint style="info" %}
Nethermind will prune the database when disk space is low (below 300GB)
{% endhint %}

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

A properly functioning **Nethermind** execution client will indicate "Received new block". For example,

```
Nethermind.Runner[2]: 29 Sep 03:00:00 | Received new block:  8372 (0x425ab9...854f4)
Nethermind.Runner[2]: 29 Sep 03:00:00 | Processed                8372     |      0.17 ms  |  slot     13,001 ms |
Nethermind.Runner[2]: 29 Sep 03:00:00 | - Block               0.00 MGas   |      0    txs |  calls      0 (  0) | sload       0 | sstore      0 | create   0
Nethermind.Runner[2]: 29 Sep 03:00:00 | - Block throughput    0.00 MGas/s |      0.00 t/s |       7217.16 Blk/s | recv        0 | proc        0
Nethermind.Runner[2]: 29 Sep 03:00:00 | Received ForkChoice: Head: 8372 (0x425ab9...854f4), Safe: 8350 (0xfd781...c2e19f), Finalized: 8332 (0x9ccf...88684c)
Nethermind.Runner[2]: 29 Sep 03:00:00 | Synced chain Head to 8372 (0x425ab9...2881a5)
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
sudo rm -rf /var/lib/nethermind/*
sudo systemctl restart execution
```

Time to re-sync the execution client can take a few hours up to a day.
{% endtab %}
{% endtabs %}

Now that your execution client is configured and started, proceed to the next step on setting up your consensus client.

{% hint style="warning" %}
If you're checking the logs and see any warnings or errors, please be patient as these will normally resolve once both your execution and consensus clients are fully synced to the Ethereum network.
{% endhint %}

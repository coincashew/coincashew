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
sudo apt install curl libsnappy-dev libc6-dev jq libc6 unzip -y
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.&#x20;

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

### **3. Setup and configure systemd**

Create a **systemd unit file** to define your `execution.service` configuration.

```bash
sudo nano /etc/systemd/system/execution.service
```

Paste the following configuration into the file.

```shell
[Unit]
Description=Nethermind Execution Layer Client service for Mainnet
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
WorkingDirectory=/var/lib/nethermind
Environment="DOTNET_BUNDLE_EXTRACT_BASE_DIR=/var/lib/nethermind"
ExecStart=/usr/local/bin/nethermind/Nethermind.Runner \
  --config mainnet \
  --datadir="/var/lib/nethermind" \
  --Metrics.Enabled true \
  --Metrics.ExposePort 6060 \
  --Metrics.IntervalSeconds 10000 \
  --Sync.SnapSync true \
  --Sync.AncientBodiesBarrier 11052984 \
  --Sync.AncientReceiptsBarrier 11052984 \
  --JsonRpc.JwtSecretFile /secrets/jwtsecret
  
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

A properly functioning **Nethermind** execution client will indicate "block nnn ... was processed". For example,

```
Nethermind.Runner[2]: 2023-02-03 00:01:36.2643|FCU - block 16001 (fd781...c2e19f) was processed.
Nethermind.Runner[2]: 2023-02-03 00:01:36.2643|Block 0xd78eaabc854f4e4a844c5c0f9ccf45bed0b2f13d77ea978af62d0eef2210c2e19f was set as head.
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

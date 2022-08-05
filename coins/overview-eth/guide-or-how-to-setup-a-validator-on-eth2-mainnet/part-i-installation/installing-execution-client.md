# Installing execution client

{% hint style="info" %}
Ethereum requires a connection to execution client in order to monitor for 32 ETH validator deposits. Hosting your own execution client is the best way to maximize decentralization.
{% endhint %}

{% hint style="warning" %}
The subsequent steps assume you have completed the [best practices security guide.](guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md)

:octagonal\_sign: Do not run your processes as **ROOT** user. :scream:
{% endhint %}

Your choice of either [**Geth**](https://geth.ethereum.org)**,** [**Besu**](https://besu.hyperledger.org)**,** [**Nethermind**](https://www.nethermind.io)**, or** [**Erigon**](https://github.com/ledgerwatch/erigon)**.**

{% tabs %}
{% tab title="Geth" %}
{% hint style="info" %}
**Geth** - Go Ethereum is one of the three original implementations (along with C++ and Python) of the Ethereum protocol. It is written in **Go**, fully open source and licensed under the GNU LGPL v3.
{% endhint %}

Review the latest release notes at [https://github.com/ethereum/go-ethereum/releases](https://github.com/ethereum/go-ethereum/releases)

:dna:**Install from the repository**

```
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update -y
sudo apt dist-upgrade -y
sudo apt-get install ethereum -y
```

:gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = geth execution client service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
ExecStart       = /usr/bin/geth --http --metrics --pprof
Restart         = on-failure
RestartSec      = 3
TimeoutSec      = 300

[Install]
WantedBy    = multi-user.target
EOF
```

{% hint style="info" %}
**Nimbus Specific Configuration**: Add the following flag to the ExecStart line.

```bash
--ws
```
{% endhint %}

Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
```

Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1
```

:chains:**Start geth**

```
sudo systemctl start eth1
```

{% hint style="info" %}
**Geth Tip**: When is my geth node synched?

1. Attach to the geth console with:`geth attach` [`http://127.0.0.1:8545`](http://127.0.0.1:8545)\`\`
2. Type the following:`eth.syncing`
3. If it returns false, your geth node is synched.
{% endhint %}
{% endtab %}

{% tab title="Besu" %}
{% hint style="info" %}
**Hyperledger Besu** is an open-source Ethereum client designed for demanding enterprise applications requiring secure, high-performance transaction processing in a private network. It's developed under the Apache 2.0 license and written in **Java**.
{% endhint %}



:dna:**Install java dependency**

```
sudo apt update
sudo apt install openjdk-18-jdk -y
```



:last\_quarter\_moon\_with\_face:**Download and unzip Besu**

Review the latest release at [https://github.com/hyperledger/besu/releases](https://github.com/hyperledger/besu/releases)

Update BINARIES\_URL with the latest url.

```
BINARIES_URL="https://hyperledger.jfrog.io/artifactory/besu-binaries/besu/22.7.0/besu-22.7.0.tar.gz"

cd $HOME
wget -O besu.tar.gz "$BINARIES_URL"
tar -xzvf besu.tar.gz -C $HOME
rm besu.tar.gz
mv besu* besu
```



:gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = Besu Execution Layer Client service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $USER
Restart         = on-failure
RestartSec      = 3
KillSignal      = SIGINT
TimeoutStopSec  = 300
ExecStart       = $HOME/besu/bin/besu \
  --network=mainnet \
  --rpc-http-host="0.0.0.0" \
  --rpc-http-cors-origins="*" \
  --rpc-ws-enabled=true \
  --rpc-http-enabled=true \
  --rpc-ws-host="0.0.0.0" \
  --host-allowlist="*" \
  --metrics-enabled=true \
  --metrics-host=0.0.0.0 \
  --sync-mode=X_CHECKPOINT \
  --data-storage-format=BONSAI \
  --data-path="$HOME/.besu"

[Install]
WantedBy    = multi-user.target
EOF
```



Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
```



Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1
```



:chains: **Start besu**

```
sudo systemctl start eth1
```
{% endtab %}

{% tab title="Nethermind" %}
{% hint style="info" %}
**Nethermind** is a flagship Ethereum client all about performance and flexibility. Built on **.NET** core, a widespread, enterprise-friendly platform, Nethermind makes integration with existing infrastructures simple, without losing sight of stability, reliability, data integrity, and security.
{% endhint %}



:gear: **Install dependencies**

```
sudo apt-get update
sudo apt-get install curl libsnappy-dev libc6-dev jq libc6 unzip -y
```



:last\_quarter\_moon\_with\_face:**Download and unzip Nethermind**

Review the latest release at [https://github.com/NethermindEth/nethermind/releases](https://github.com/NethermindEth/nethermind/releases)

Automatically download the latest linux release, un-zip and cleanup.

```bash
mkdir $HOME/nethermind
chmod 775 $HOME/nethermind
cd $HOME/nethermind
curl -s https://api.github.com/repos/NethermindEth/nethermind/releases/latest | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux-amd64  | xargs wget -q --show-progress
unzip -o nethermind*.zip
rm nethermind*linux*.zip
```



:gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = nethermind eth1 service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
ExecStart       = $(echo $HOME)/nethermind/Nethermind.Runner --baseDbPath $HOME/.nethermind --Metrics.Enabled true --JsonRpc.Enabled true --Sync.DownloadBodiesInFastSync true --Sync.DownloadReceiptsInFastSync true --Sync.AncientBodiesBarrier 11052984 --Sync.AncientReceiptsBarrier 11052984
WorkingDirectory= $(echo $HOME)/nethermind
Restart         = on-failure
RestartSec      = 3
KillSignal      = SIGINT
TimeoutStopSec  = 300

[Install]
WantedBy    = multi-user.target
EOF
```



Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
```



Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1
```



{% hint style="info" %}
On Ubuntu 22.xx+, a [workaround](https://github.com/NethermindEth/nethermind/issues/4039) is required.

```
sudo ln -s /usr/lib/x86_64-linux-gnu/libdl.so.2 /usr/lib/x86_64-linux-gnu/libdl.so
```
{% endhint %}



:chains: **Start Nethermind**

```
sudo systemctl start eth1
```

{% hint style="info" %}
**Note about Metric Error messages**: You will see these until prometheus pushergateway is setup in section 6. `Error in MetricPusher: System.Net.Http.HttpRequestException: Connection refused`
{% endhint %}
{% endtab %}

{% tab title="Erigon" %}
{% hint style="info" %}
**Erigon** - Successor to OpenEthereum, Erigon is an implementation of Ethereum (aka "Ethereum client"), on the efficiency frontier, written in Go.
{% endhint %}

:gear: **Install Go dependencies**

```
wget -O go.tar.gz https://golang.org/dl/go1.16.5.linux-amd64.tar.gz
```

```bash
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz
```

```bash
echo export PATH=$PATH:/usr/local/go/bin>> $HOME/.bashrc
source $HOME/.bashrc
```

Verify Go is properly installed and cleanup files.

```bash
go version
rm go.tar.gz
```

:robot: **Build and install Erigon**

Install build dependencies.

```bash
sudo apt-get update
sudo apt install build-essential git
```

Review the latest release at [https://github.com/ledgerwatch/erigon/releases](https://github.com/ledgerwatch/erigon/releases)

```bash
cd $HOME
git clone --recurse-submodules -j8 https://github.com/ledgerwatch/erigon.git
cd erigon
make erigon && make rpcdaemon
```

​ Make data directory and update directory ownership.

```bash
sudo mkdir -p /var/lib/erigon
sudo chown $USER:$USER /var/lib/erigon
```

​ :gear: **Setup and configure systemd**

Run the following to create a **unit file** to define your `eth1.service` configuration.

Simply copy/paste the following.

```bash
cat > $HOME/eth1.service << EOF 
[Unit]
Description     = erigon eth1 service
Wants           = network-online.target
After           = network-online.target 
Requires        = eth1-erigon.service

[Service]
Type            = simple
User            = $USER
ExecStart       = $HOME/erigon/build/bin/erigon --datadir /var/lib/erigon --chain mainnet --private.api.addr=localhost:9089 --metrics --pprof --prune htc
Restart         = on-failure
RestartSec      = 3
KillSignal      = SIGINT
TimeoutStopSec  = 300

[Install]
WantedBy    = multi-user.target
EOF
```

{% hint style="info" %}
By default with Erigon, `--prune` deletes data older than 90K blocks from the tip of the chain (aka, for if tip block is no. 12'000'000, only the data between 11'910'000-12'000'000 will be kept).
{% endhint %}

```bash
cat > $HOME/eth1-erigon.service << EOF 
[Unit]
Description     = erigon rpcdaemon service
BindsTo	        = eth1.service
After           = eth1.service

[Service]
Type            = simple
User            = $USER
ExecStartPre	  = /bin/sleep 3
ExecStart       = $HOME/erigon/build/bin/rpcdaemon --private.api.addr=localhost:9089 --datadir /var/lib/erigon --http.api=eth,erigon,web3,net,debug,trace,txpool,shh --txpool.api.addr=localhost:9089
Restart         = on-failure
RestartSec      = 3
KillSignal      = SIGINT
TimeoutStopSec  = 300

[Install]
WantedBy    = eth1.service
EOF
```

Move the unit files to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $HOME/eth1.service /etc/systemd/system/eth1.service
sudo mv $HOME/eth1-erigon.service /etc/systemd/system/eth1-erigon.service
```

```bash
sudo chmod 644 /etc/systemd/system/eth1.service
sudo chmod 644 /etc/systemd/system/eth1-erigon.service
```

Run the following to enable auto-start at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable eth1 eth1-erigon
```

:chains:**Start Erigon**

```
sudo systemctl start eth1
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Syncing an execution client can take up to 1 week. On high-end machines with gigabit internet, expect syncing to take less than a day.
{% endhint %}

{% hint style="success" %}
Your execution client is fully sync'd when these events occur.

* **`OpenEthereum:`** `Imported #<block number>`
* **`Geth:`** `Imported new chain segment`
* **`Besu:`** `Imported #<block number>`
* **`Nethermind:`** `No longer syncing Old Headers`
{% endhint %}

#### :tools: Helpful eth1.service commands

​​ :notepad\_spiral: **To view and follow eth1 logs**

```
journalctl -fu eth1
```

:notepad\_spiral: **To stop eth1 service**

```
sudo systemctl stop eth1
```

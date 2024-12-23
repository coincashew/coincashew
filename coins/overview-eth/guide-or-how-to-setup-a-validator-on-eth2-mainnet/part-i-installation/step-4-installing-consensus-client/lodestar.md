# Lodestar

## Overview

{% hint style="info" %}
[Lodestar ](https://lodestar.chainsafe.io)is a Typescript implementation of the official Ethereum specification by the [ChainSafe.io](https://lodestar.chainsafe.io) team. In addition to the beacon chain client, the team is also working on 22 packages and libraries. A complete list can be found [here](https://hackmd.io/CcsWTnvRS_eiLUajr3gi9g). Finally, the Lodestar team is leading in light client research and development and has received funding from the EF and Moloch DAO for this purpose.
{% endhint %}

#### Official Links

| Subject       | Links                                                                                            |
| ------------- | ------------------------------------------------------------------------------------------------ |
| Releases      | [https://github.com/ChainSafe/lodestar/releases](https://github.com/ChainSafe/lodestar/releases) |
| Documentation | [https://chainsafe.github.io/lodestar](https://chainsafe.github.io/lodestar/)                    |
| Website       | [https://lodestar.chainsafe.io](https://lodestar.chainsafe.io/)                                  |

### 1. Initial configuration

Create a service user for the consensus service, create data directory and assign ownership.

```bash
sudo adduser --system --no-create-home --group consensus
sudo mkdir -p /var/lib/lodestar
sudo chown -R consensus:consensus /var/lib/lodestar
```

Install dependencies.

```bash
sudo apt-get install gcc g++ make git curl ccze -y
```

### 2. Install Binaries

* Downloading binaries is often faster and more convenient.
* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/ChainSafe/lodestar/releases/latest"
LATEST_TAG="$(curl -s $RELEASE_URL | jq -r ".tag_name")"
BINARIES_URL="https://github.com/ChainSafe/lodestar/releases/download/${LATEST_TAG}/lodestar-${LATEST_TAG}-linux-amd64.tar.gz"
	
echo Downloading URL: $BINARIES_URL

cd $HOME
# Download
wget -O lodestar.tar.gz $BINARIES_URL
# Untar
tar -xzvf lodestar.tar.gz -C $HOME
# Cleanup
rm lodestar.tar.gz
```

Install the binaries.

```bash
sudo mkdir -p /usr/local/bin/lodestar
sudo mv $HOME/lodestar /usr/local/bin/lodestar
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Install yarn.

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install yarn -y
```

Confirm yarn is installed properly.

```bash
yarn --version
# Should output version >= 1.22.19
```

Install nodejs.

```bash
#Download and import the Nodesource GPG key
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

#Create deb repository
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

#Run Update and Install
sudo apt-get update
sudo apt-get install nodejs -y
```

Install and build Lodestar.

```bash
mkdir -p ~/git
cd ~/git
git clone -b stable https://github.com/chainsafe/lodestar.git
cd lodestar
yarn install
yarn run build
```

Verify Lodestar was installed properly by displaying the version.

```bash
./lodestar --version
```

Sample output of a compatible version.

```
🌟 Lodestar: TypeScript Implementation of the Ethereum Consensus Beacon Chain.
  * Version: v1.8.0/stable/a4b29cf
  * by ChainSafe Systems, 2018-2022
```

Install the binaries.

```bash
sudo cp -a $HOME/git/lodestar /usr/local/bin/lodestar
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
Description=Lodestar Consensus Layer Client service for Mainnet
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
WorkingDirectory=/usr/local/bin/lodestar
ExecStart=/usr/local/bin/lodestar/lodestar beacon \
  --dataDir /var/lib/lodestar \
  --network mainnet \
  --rest.port 5052 \
  --port 9000 \
  --targetPeers 100 \
  --metrics.port 8008 \
  --metrics true \
  --checkpointSyncUrl https://beaconstate.info \
  --jwt-secret /secrets/jwtsecret \
  --execution.urls http://127.0.0.1:8551 \
  --suggestedFeeRecipient <0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
```

* Replac&#x65;**`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>`** with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
* **Not staking?** If you only want a full node, delete the whole line beginning with

```
--suggestedFeeRecipient
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

### 4. Helpful consensus client commands

{% tabs %}
{% tab title="View Logs" %}
```bash
sudo journalctl -fu consensus | ccze
```

**Example of Synced Lodestar Consensus Client Logs**

```bash
Mar-19 04:09:49.000    info: Synced - slot: 3338 - head: 3355 0x5abb_ac30 - execution: valid(0x1a3c_2ca5) - finalized: 0xfa22_1142:3421 - peers: 25
Mar-19 04:09:52.000    info: Synced - slot: 3339 - head: 3356 0xcd2a_8b32 - execution: valid(0xab34_fa32) - finalized: 0xfa22_1142:3421 - peers: 25
Mar-19 04:09:04.000    info: Synced - slot: 3340 - head: 3357 0xff1a_f12a - execution: valid(0xfaf1_b35f) - finalized: 0xfa22_1142:3421 - peers: 25
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
sudo rm -rf /var/lib/lodestar/chain-db
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

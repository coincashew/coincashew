# Lodestar

## Overview

{% hint style="info" %}
[Lodestar ](https://lodestar.chainsafe.io)is a Typescript implementation of the official Ethereum specification by the [ChainSafe.io](https://lodestar.chainsafe.io) team. In addition to the beacon chain client, the team is also working on 22 packages and libraries. A complete list can be found [here](https://hackmd.io/CcsWTnvRS\_eiLUajr3gi9g). Finally, the Lodestar team is leading in light client research and development and has received funding from the EF and Moloch DAO for this purpose.
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

* Building from source code can offer better compatibility and is more aligned with the spirit of FOSS (free open source software).

<details>

<summary>Option 1 - Build from source code</summary>

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
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
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
Description=Lodestar Consensus Layer Client service for Holesky
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
  --network holesky \
  --metrics true \
  --checkpointSyncUrl https://checkpoint-sync.holesky.ethpandaops.io \
  --jwt-secret /secrets/jwtsecret \
  --execution.urls http://127.0.0.1:8551 \
  --suggestedFeeRecipient <0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
```

* Replace`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>` with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
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
{% endtabs %}

Now that your consensus client is configured and started, you have a full node.

Proceed to the next step on setting up your validator client, which turns a full node into a staking node.

{% hint style="info" %}
If you wanted to setup a full node, not a staking node, stop here! Congrats on running your own full node! :tada:
{% endhint %}

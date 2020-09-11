---
description: >-
  This quick start guide walks through setting up an external relay node with
  the help of CNTOOLs.
---

# How to setup an external passive relay node

{% hint style="success" %}
Major credits and appreciation to the fine folks at [Cardano Community Guild Operators](https://cardano-community.github.io/guild-operators/#/README) for creating and maintaining [CNtool](https://cardano-community.github.io/guild-operators/#/Scripts/cntools), a most helpful swiss army knife for pool operators. You MUST be familiar with how [ADA staking works](https://docs.cardano.org/en/latest/getting-started/stake-pool-operators/index.html) and possess [fundamental Linux system administration skills](https://www.tecmint.com/free-online-linux-learning-guide-for-beginners/) before continuing this guide.
{% endhint %}

{% hint style="info" %}
**Relay nodes** do not have any keys, so they cannot produce blocks. Instead, relays act as proxies between the core network nodes and the internet, establishing a security perimeter around the core, block-producing network nodes. Since external nodes cannot communicate with block-producing nodes directly, relay nodes ensure that the integrity of the core nodes and the blockchain remains intact, even if one or more relays become compromised.
{% endhint %}

## 🌜 0. Prerequisites

* A different server/VM \(not located on the same machine as your block-producer node\)

## 🛸 1. Run prereqs.sh

Installs prerequisite dependencies and creates folder structure.

```text
sudo apt-get install curl net-tools
```

```bash
mkdir "$HOME/tmp";cd "$HOME/tmp"
# Install curl
# CentOS / RedHat - sudo dnf -y install curl
# Ubuntu / Debian - sudo apt -y install curl
curl -sS -o prereqs.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/prereqs.sh
chmod 755 prereqs.sh

# Ensure you can run sudo commands with your user before execution
# You can check the syntax for prereqs.sh using command below:
#
# ./prereqs.sh -h
# Usage: prereqs.sh [-o] [-s] [-i] [-g] [-p]
# Install pre-requisites for building cardano node and using cntools
# -o    Do *NOT* overwrite existing genesis, topology.json and topology-updater.sh files (Default: will overwrite)
# -s    Skip installing OS level dependencies (Default: will check and install any missing OS level prerequisites)
# -i    Interactive mode (Default: silent mode)
# -g    Connect to guild network instead of public network (Default: connect to public cardano network)
# -p    Copy Transitional Praos config as default instead of Combinator networks (Default: copies combinator network)

# You can use one of the options above, if you'd like to defer from defaults (below).
# Running without any parameters will run script in silent mode with OS Dependencies, and overwriting existing files.

./prereqs.sh
```

Reload environment variables.

```text
. "${HOME}/.bashrc"
```

{% hint style="info" %}
Familiarize yourself with the [folder structure](https://cardano-community.github.io/guild-operators/#/basics?id=folder-structure) created by CNtools.
{% endhint %}

## 🤹♀ 2. Build Cardano Node and CLI

#### Clone the git repository.

```bash
cd ~/git
git clone https://github.com/input-output-hk/cardano-node
cd cardano-node
```

#### Build all the binaries. Replace the tag with the desired version.

```bash
git fetch --tags --all
git pull
# Replace tag 1.19.1 with the version/branch you'd like to build
git checkout 1.19.1

echo -e "package cardano-crypto-praos\n  flags: -external-libsodium-vrf" > cabal.project.local
$CNODE_HOME/scripts/cabal-build-all.sh
```

#### Install binaries to local bin directory.

```text
sudo cp $HOME/.cabal/bin/cardano* /usr/local/bin
```

#### Verify the correct versions were compiled.

```bash
cardano-cli version
cardano-node version
```

## ⚒ 3. Auto-starting with systemd services

#### 🎊 Benefits of using systemd for your stake pool

1. Auto-start your node when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed node processes.
3. Maximize your stake pool up-time and performance.

```bash
sudo bash -c "cat << 'EOF' > /etc/systemd/system/cnode.service
[Unit]
Description=Cardano Node
After=network.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5
User=$USER
LimitNOFILE=1048576
WorkingDirectory=$CNODE_HOME/scripts
ExecStart=/bin/bash -l -c \"exec $CNODE_HOME/scripts/cnode.sh\"
ExecStop=/bin/bash -l -c \"exec kill -2 \$(ps -ef | grep [c]ardano-node.*.${CNODE_HOME} | tr -s ' ' | cut -d ' ' -f2)\"
KillSignal=SIGINT
SuccessExitStatus=143
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=cnode
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl enable cnode.service
```

{% hint style="success" %}
Nice work. Your node is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

####   ✅ Check whether the node service is active <a id="check-whether-the-stake-pool-service-is-active"></a>

```text
sudo systemctl is-active cnode
```

#### ​ 🔎 View the status of the node service <a id="view-the-status-of-the-stake-pool-service"></a>

```text
sudo systemctl status cnode
```

#### ​ 🔄 Restarting the node service <a id="restarting-the-stake-pool-service"></a>

```text
sudo systemctl reload-or-restart cnode
```

#### ​ 🛑 Stopping the node service <a id="stopping-the-stake-pool-service"></a>

```text
sudo systemctl stop cnode
```

#### 🚧 Filtering logs <a id="filtering-logs"></a>

```text
journalctl --unit=cnode --since=yesterday
journalctl --unit=cnode --since=today
journalctl --unit=cnode --since='2020-07-29 00:00:00' --until='2020-07-29 12:00:00'
```

## 🚀 4. Start the relay node

{% hint style="success" %}
**Pro tip:** 🎇 Speed this step up by copying the **db** folder from another node you control.
{% endhint %}

```bash
sudo systemctl start cnode
```

Install Guild LiveView.

```bash
cd $CNODE_HOME/scripts
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
chmod 755 gLiveView.sh
```

Run Guild Liveview.

```text
./gLiveView.sh
```

Sample output of Guild Live View

![Guild Live View](../../../.gitbook/assets/gliveview-core.png)

For more information, refer to the [official Guild Live View docs.](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview)

## 🛑5. Configure and review the relay node topology file

Use [pooltool.io](https://pooltool.io/) and the get\_buddies script to manage your **NEW** relay node's topology.

Alternatively use topologyUpdater.sh. Refer to the [official documentation for more info.](https://cardano-community.github.io/guild-operators/#/Scripts/topologyupdater?id=download-and-configure-topologyupdatersh)

After adding your relay node information to pooltool or the topologyUpdater.sh process, review your topology.json and check that it looks correct. Your new relay node's topology should contain your block producer node, your other relay nodes, and other public buddy relay nodes.

```bash
cat $CNODE_HOME/files/topology.json
```

## 🔥 6. Configure port-forwarding and/or firewall

Specific to your networking setup or cloud provider settings, ensure your relay node's port 6000 is open and reachable. 

{% hint style="danger" %}
\*\*\*\*✨ **Port Forwarding Tip:** Check that your relay port 6000 is open with [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) or [https://canyouseeme.org/](https://canyouseeme.org/) .
{% endhint %}

Additionally, if you have node-exporter installed for grafana stats, you will need to open ports 9100 and 12798. Don't forget to update `prometheus.yml` on your prometheus server \(aka relaynode1\). Restart prometheus service for the new relay node to appear in your dashboard.

## 👩💻 7. Configure existing relay or block producing node's topology

Finally, add your new **NEW** relay node IP/port information to your **EXISTING** block producer and/or relay node's topology file. 

For your block producer node, you'll want to manually add the new relay node information to your topology.json file.

Example snippet to add to your block producer's topology file. Add a comma to separate the nodes where appropriate.

```text
 {
    "addr": "<relay node public ip address>",
    "port": 6000,
    "valency": 1
 }
```

For relay nodes, you can use pooltool.io or topologyUpdater process to manage your topology file.

## 🔄 8. Restart all relay and block producer nodes for new topology configurations to take effect

## 🎊 9. Verify the connection is working

On the Guild LiveView screen, press `P` to view the peer list. You should see the connection to other node's IP.

{% hint style="success" %}
✨ Congrats on the new relay node.
{% endhint %}

{% hint style="danger" %}
\*\*\*\*🔥 **Critical Security Reminder:** Relay nodes must not contain any **`operational certifications`, `vrf`, `skey` or `cold`** ``**keys**.
{% endhint %}


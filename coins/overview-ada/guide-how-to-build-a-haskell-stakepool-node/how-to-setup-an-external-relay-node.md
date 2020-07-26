---
description: This guide walks through setting up an external relay node.
---

# How to setup an external relay node

**Relay nodes** do not have any keys, so they cannot produce blocks. Instead, relays act as proxies between the core network nodes and the internet, establishing a security perimeter around the core, block-producing network nodes. Since external nodes cannot communicate with block-producing nodes directly, relay nodes ensure that the integrity of the core nodes and the blockchain remains intact, even if one or more relays become compromised.

{% hint style="info" %}
We call the current relay node **NEW** and the previous block producing or relay node **EXISTING**.
{% endhint %}

### ⚙ 1. Set the relay node IP/port info

`NEW_RELAY_NODE_IP` can be discovered automatically with help from [ifconfig.me](http://ifconfig.me)

```text
NEW_RELAY_NODE_IP=$(curl http://ifconfig.me/ip)
NEW_RELAY_NODE_PORT=3001
EXISTING_NODE_IP=<IP OF MY EXISTING BLOCK PRODUCING OR RELAY NODE>
EXISTING_NODE_PORT=<PORT OF MY EXISTING BLOCK PRODUCING OR RELAY NODE>
```

### 🚧 2. Review the IP/port information before continuing

```text
echo NEW_RELAY_NODE_IP: $NEW_RELAY_NODE_IP
echo NEW_RELAY_NODE_PORT: $NEW_RELAY_NODE_PORT
echo EXISTING_NODE_IP: $EXISTING_NODE_IP
echo EXISTING_NODE_PORT: $EXISTING_NODE_PORT
```

### 🤹♀ 3. Set the node configuration data

```text
echo export NODE_HOME=$HOME/cardano-my-node >> ~/.bashrc
echo export NODE_CONFIG=mainnet_candidate_4>> ~/.bashrc
echo export NODE_URL=mainnet-candidate-4 >> ~/.bashrc
echo export NODE_BUILD_NUM=3622471>> ~/.bashrc
```

### 👩🌾 4. Run the following auto-setup relaynode script

```text
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install git make tmux rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf -y
mkdir ~/git
cd ~/git
git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
sudo make install
cd
wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig
mkdir -p ~/.local/bin
mv cabal ~/.local/bin/
wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz
tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz
rm ghc-8.6.5-x86_64-deb9-linux.tar.xz
cd ghc-8.6.5
./configure
sudo make install
echo PATH="~/.local/bin:$PATH" >> ~/.bashrc
echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc
cabal update
cabal -V
ghc -V
cd ~/git
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node
git fetch --all
git checkout tags/1.18.0
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
sed -i $HOME/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
rm -rf $HOME/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.6.5
cabal build cardano-cli cardano-node
sudo cp $(find ~/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find ~/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
cardano-node version
cardano-cli version
mkdir $NODE_HOME
cd $NODE_HOME
wget https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-byron-genesis.json
wget https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-topology.json
wget https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-shelley-genesis.json
wget https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json
sed -i ${NODE_CONFIG}-config.json \
    -e "s/SimpleView/LiveView/g" \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> ~/.bashrc
source ~/.bashrc
mkdir relaynode1
cp *.json relaynode1
cat > $NODE_HOME/relaynode1/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "$EXISTING_NODE_IP",
        "port": $EXISTING_NODE_PORT,
        "valency": 1
      },
      {
        "addr": "relays-new.${NODE_URL}.dev.cardano.org",
        "port": 3001,
        "valency": 2
      }
    ]
  }
EOF
cat > $NODE_HOME/relaynode1/startRelayNode1.sh << EOF 
DIRECTORY=\$NODE_HOME/relaynode1
PORT=3001
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
cat > $NODE_HOME/startRelay.sh << EOF
#!/bin/bash
SESSION=$(whoami)
tmux has-session -t \$SESSION 2>/dev/null
if [ \$? != 0 ]; then
   # tmux attach-session -t \$SESSION
    tmux new-session -s \$SESSION -n window -d
    tmux split-window -h
    tmux select-pane -t \$SESSION:window.0
    tmux send-keys -t \$SESSION:window.0 $NODE_HOME/relaynode1/startRelayNode1.sh Enter
    tmux send-keys -t \$SESSION:window.1 htop Enter
    echo Relaynode started. \"tmux a\" to view.
fi
EOF
cat > $NODE_HOME/stopRelay.sh << EOF
#!/bin/bash
SESSION=$(whoami)
tmux has-session -t \$SESSION 2>/dev/null
if [ \$? != 0 ]; then
        echo Relaynode not running.
else
        echo Stopped Relaynode.
        tmux kill-session -t \$SESSION
fi
EOF
cd $NODE_HOME
chmod +x relaynode1/startRelayNode1.sh
chmod +x startRelay.sh
chmod +x stopRelay.sh
```

### 🛑5. Review the NEW relay node topology file

```text
cat $NODE_HOME/relaynode1/${NODE_CONFIG}-topology.json
```

Use [pooltool.io](https://pooltool.io/) and the get\_buddies script to manage your **NEW** relay node's topology.

Alternatively, if you have multiple relay nodes you would like to connect to, add their configurations to your topology.json file. 

Example snippet below:

```text
  {
    "addr": "3.3.3.3",
    "port": 3002,
    "valency": 1
  },
```

### 🔥 6. Configure port-forwarding and/or firewall

Specific to your networking setup or cloud provider settings, ensure your relay node's ports are open and reachable. Use [https://canyouseeme.org/](https://canyouseeme.org/) to verify.

### 👩💻 7. Configure existing relay or block producing node's topology

Finally, add your new **NEW** relay node IP/port information to your **EXISTING** node's topology file. 

Same process as [step 5](how-to-setup-an-external-relay-node.md#5-review-the-topology-file) but for your **EXISTING** node.

### 🔄 8. Restart both NEW and EXISTING nodes for new configs to take effect

On **NEW** relay node,

```text
cd $NODE_HOME
./stopRelay.sh
./startRelay.sh
```

On **EXISTING** relay / block producing node,

{% tabs %}
{% tab title="Scripts" %}
```text
cd $NODE_HOME
./stopStakePool.sh 
./startStakePool.sh
```
{% endtab %}

{% tab title="Systemd" %}
```
## or if you are using systemd
sudo systemctl stop cardano-stakepool
sudo systemctl start cardano-stakepool
```
{% endtab %}
{% endtabs %}

{% hint style="success" %}
✨ Congrats on the new relay node.
{% endhint %}

{% hint style="info" %}
Reminder, relay nodes should NOT contain any `operational certifications`, `vrf`, `skey` or `cold` keys.
{% endhint %}


# Creating Startup Scripts

{% hint style="warning" %}
:construction: In the Coin Cashew guide, procedures may refer to your relay nodes using the name `relaynode<N>` where `<N>` is `1` for your first relay, `2` for your second relay, and so on.
{% endhint %}

{% hint style="info" %}
You can have multiple relay nodes as you scale up your stake pool architecture. Simply create `relaynode<N>` and adapt the guide instructions accordingly.
{% endhint %}

Update **.bashrc** shell variables.

```bash
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> $HOME/.bashrc
source $HOME/.bashrc
```
<!--NOTE (220503):
Setting the CARDANO_NODE_SOCKET_PATH environment variable is moved from the Downloading Configuration Files topic. Setting CARDANO_NODE_SOCKET_PATH is required on the block producer and all relay nodes in a stake pool. Match the relative location of the information in the Coin Cashew guide with https://developers.cardano.org/docs/get-started/running-cardano/ -->

The startup script contains all the variables needed to run a cardano-node such as directory, port, db path, config file, and topology file.

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
#!/bin/bash
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
/usr/local/bin/cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
cat > $NODE_HOME/startRelayNode1.sh << EOF 
#!/bin/bash
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
/usr/local/bin/cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```
{% endtab %}
{% endtabs %}

Add execute permissions to the startup script.

{% tabs %}
{% tab title="block producer node" %}
```bash
chmod +x $NODE_HOME/startBlockProducingNode.sh
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
chmod +x $NODE_HOME/startRelayNode1.sh 
```
{% endtab %}
{% endtabs %}

Run the following to create a **systemd unit file** to define your`cardano-node.service` configuration.

{% hint style="info" %}
## :cake: Benefits of Using systemd for a Stake Pool

1. Auto-start your stake pool when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed stake pool processes.
3. Maximize your stake pool up-time and performance.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > $NODE_HOME/cardano-node.service << EOF 
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service 

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = ${USER}
Type            = simple
WorkingDirectory= ${NODE_HOME}
ExecStart       = /bin/bash -c '${NODE_HOME}/startBlockProducingNode.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=300
LimitNOFILE=32768
Restart=always
RestartSec=5
SyslogIdentifier=cardano-node

[Install]
WantedBy	= multi-user.target
EOF
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
cat > $NODE_HOME/cardano-node.service << EOF 
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service 

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = ${USER}
Type            = simple
WorkingDirectory= ${NODE_HOME}
ExecStart       = /bin/bash -c '${NODE_HOME}/startRelayNode1.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=300
LimitNOFILE=32768
Restart=always
RestartSec=5
SyslogIdentifier=cardano-node

[Install]
WantedBy	= multi-user.target
EOF
```
{% endtab %}
{% endtabs %}

Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
```

```bash
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

Run the following to enable auto-starting of your stake pool at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable cardano-node
```

{% hint style="success" %}
Your stake pool is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

## :mag\_right: Viewing the Status of the Node Service

```
sudo systemctl status cardano-node
```

## :arrows\_counterclockwise: Restarting the Node Service

```
sudo systemctl reload-or-restart cardano-node
```

## :octagonal\_sign: Stopping the Node Service

```
sudo systemctl stop cardano-node
```

## :notebook: Viewing and Filtering Logs

```bash
journalctl --unit=cardano-node --follow
```

```bash
journalctl --unit=cardano-node --since=yesterday
```

```
journalctl --unit=cardano-node --since=today
```

```
journalctl --unit=cardano-node --since='2020-07-29 00:00:00' --until='2020-07-29 12:00:00'
```

## :chart_with_upwards_trend: Improving Cardano Node Performance

If you are not satisfied with the performance of an instance of Cardano Node, then [Configuring Runtime Options](../part-v-tips/configuring-runtime-options.md) may help.


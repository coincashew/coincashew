# Creating Startup Scripts and Services

To run an instance of Cardano Node, create a bash script to configure options. Also, implement Cardano Node as a `systemd` service.

<!-- Update **.bashrc** shell variables.

```bash
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> $HOME/.bashrc
source $HOME/.bashrc
``` -->
<!--NOTE (220503):
Setting the CARDANO_NODE_SOCKET_PATH environment variable is moved from the Downloading Configuration Files topic. The CARDANO_NODE_SOCKET_PATH environment variable seems unused throughout the Coin Cashew guide. Match the relative location of the information in the Coin Cashew guide with https://developers.cardano.org/docs/get-started/running-cardano/ -->

**To create a startup script and service for an instance of Cardano Node:**

1. On the computer hosting your block producing node, using a terminal window type the following command to navigate to the folder containing configuration files and scripts related to operating your Cardano node:
```bash
cd $NODE_HOME
```
{% hint style="info" %}
You set the `$NODE_HOME` environment variable when [Installing GHC and Cabal](../part-i-installation/installing-ghc-and-cabal.md).
{% endhint %}

2. In the folder where you navigated in step 1, using a text editor create a file named `startCardanoNode.sh` and then add the following contents to the file:
```bash
#!/bin/bash
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
/usr/local/bin/cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
```
{% hint style="info" %}
For details on options for the `cardano-node run` command, see the topic [How to run cardano-node](https://developers.cardano.org/docs/get-started/running-cardano) in the [Cardano Developer Portal](https://developers.cardano.org/docs/get-started/).
{% endhint %}

3. Save and close the `startCardanoNode.sh` file.

4. To set execute permissions for the `startCardanoNode.sh` file, type:
```bash
chmod +x $NODE_HOME/startCardanoNode.sh
```

5. To run Cardano Node as a service, using a text editor create a file named `cardano-node.service` and then add the following contents to the file:
```bash
# The Cardano Node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service  
  
 [Unit]
Description       = Cardano node service
Wants             = network-online.target
After             = network-online.target  
  
 [Service]
User              = ${USER}
Type              = simple
WorkingDirectory  = ${NODE_HOME}
ExecStart         = /bin/bash -c '${NODE_HOME}/startCardanoNode.sh'
KillSignal        = SIGINT
RestartKillSignal = SIGINT
TimeoutStopSec    = 300
LimitNOFILE       = 32768
Restart           = always
RestartSec        = 5
SyslogIdentifier  = cardano-node  
  
 [Install]
WantedBy          = multi-user.target
```
{% hint style="info" %}
Running Cardano Node as a `systemd` service maximizes the uptime of your stake pool by restarting the stake pool automatically if any stake pool processes may crash, or when the computer reboots.
{% endhint %}

6. Save and close the `cardano-node.service` file.

7. To move the `cardano-node.service` file to the folder `/etc/systemd/system` and set execute permissions, type:
```bash
sudo mv $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

8. To start Cardano Node as a service when the computer boots, type:
```bash
sudo systemctl daemon-reload
sudo systemctl enable cardano-node.service
```

9. Repeat steps 1 to 8 on each computer hosting a relay node in your stake pool configuration.

## Managing Services

To help administer an instance of Cardano Node running as a service, use the following commands.

**To view the status of the Cardano Node service, type:**
```bash
sudo systemctl status cardano-node
```

**To restart the Cardano Node service, type:**
```bash
sudo systemctl reload-or-restart cardano-node
```

**To stop the Cardano Node service, type:**
```bash
sudo systemctl stop cardano-node
```

**To view and filter logs, type one of the following commands, for example:**
```bash
journalctl --unit=cardano-node --follow
journalctl --unit=cardano-node --since=yesterday
journalctl --unit=cardano-node --since=today
journalctl --unit=cardano-node --since='2022-07-29 00:00:00' --until='2022-07-29 12:00:00'
```

## :chart_with_upwards_trend: Improving Cardano Node Performance

If you are not satisfied with the performance of an instance of Cardano Node, then see the topic [Configuring Runtime Options](../part-v-tips/configuring-runtime-options.md).

















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




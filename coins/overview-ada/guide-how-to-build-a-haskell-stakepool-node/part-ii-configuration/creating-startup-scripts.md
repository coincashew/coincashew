# Creating Startup Scripts and Services

To run an instance of Cardano Node, create a bash script to configure options. Also, implement Cardano Node as a `systemd` service.

{% hint style="info" %}
Running Cardano Node as a `systemd` service maximizes the uptime of your stake pool by restarting the stake pool automatically if any stake pool processes may crash, or when the computer reboots.
{% endhint %}

**To create a startup script and service for an instance of Cardano Node:**

1. On the computer hosting your block producing node, using a terminal window type the following command to navigate to the folder containing configuration files and scripts related to operating your Cardano node:

```bash
cd $NODE_HOME
```

{% hint style="info" %}
You set the `$NODE_HOME` environment variable when [Installing GHC and Cabal](../part-i-installation/installing-ghc-and-cabal.md).
{% endhint %}

2. To retrieve the values of the `$NODE_HOME` and `$USER` environment variables, type:

```bash
echo $NODE_HOME
echo $USER
```

3. In the folder where you navigated in step 1, using a text editor create a file named `startCardanoNode.sh` and then add the following contents to the file where `<NodeHomeValue>` is the value of your `$NODE_HOME` environment variable that you retrieved in step 2, and `<ConfigFileName>` is `config-bp.json` on your block-producing node and `config.json` on all your relay nodes:

```bash
#!/bin/bash
#
# Set variables to indicate Cardano Node options
#
# Set a variable to indicate the port where the Cardano Node listens
PORT=6000
# Set a variable to indicate the local IP address of the computer where Cardano Node runs
# 0.0.0.0 listens on all local IP addresses for the computer
HOSTADDR=0.0.0.0
# Set a variable to indicate the file path to your topology file
TOPOLOGY=<NodeHomeValue>/topology.json
# Set a variable to indicate the folder where Cardano Node stores blockchain data
DB_PATH=<NodeHomeValue>/db
# Set a variable to indicate the path to the Cardano Node socket for Inter-process communication (IPC)
SOCKET_PATH=<NodeHomeValue>/db/socket
# Set a variable to indicate the file path to your main Cardano Node configuration file
CONFIG=<NodeHomeValue>/<ConfigFileName>
#
# Run Cardano Node using the options that you set using variables
#
/usr/local/bin/cardano-node run --topology ${TOPOLOGY} --database-path ${DB_PATH} --socket-path ${SOCKET_PATH} --host-addr ${HOSTADDR} --port ${PORT} --config ${CONFIG}
```

{% hint style="info" %}
You configured the `topology.json` file when [Configuring Stake Pool Topology](configuring-stake-pool-topology.md). You downloaded the `config.json` file when [Downloading Configuration Files](downloading-configuration-files.md). For more details on options for the `cardano-node run` command, see the topic [How to run cardano-node](https://developers.cardano.org/docs/get-started/running-cardano) in the [Cardano Developer Portal](https://developers.cardano.org/docs/get-started/).
{% endhint %}

4. Save and close the `startCardanoNode.sh` file.

5. To set execute permissions for the `startCardanoNode.sh` file, type:

```bash
chmod +x $NODE_HOME/startCardanoNode.sh
```

6. To create the folder where Cardano Node stores blockchain data, type:

```bash
mkdir $NODE_HOME/db
```

7. To run Cardano Node as a service, using a text editor create a file named `cardano-node.service` and then add the following contents to the file where `<UserValue>` is the value of your `$USER` environment variable and `<NodeHomeValue>` is the value of your `$NODE_HOME` environment variable that you retrieved in step 2:

```bash
# The Cardano Node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service  
  
 [Unit]
Description       = Cardano Node Service
Wants             = network-online.target
After             = network-online.target  
  
 [Service]
User              = <UserValue>
Type              = simple
WorkingDirectory  = <NodeHomeValue>
ExecStart         = /bin/bash -c '<NodeHomeValue>/startCardanoNode.sh'
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

8. Save and close the `cardano-node.service` file.

9. To move the `cardano-node.service` file to the folder `/etc/systemd/system` and set file permissions, type:

```bash
sudo mv $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

10. To start Cardano Node as a service when the computer boots, type:

```bash
sudo systemctl daemon-reload
sudo systemctl enable cardano-node.service
```

11. Repeat steps 1 to 10 on each computer hosting a relay node in your stake pool configuration.

## Managing Services

To help administer an instance of Cardano Node running as a `systemd` service, use the following commands.

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

**To display and filter logs, type one of the following commands, for example:**

```bash
journalctl --unit=cardano-node --follow
journalctl --unit=cardano-node --since=yesterday
journalctl --unit=cardano-node --since=today
journalctl --unit=cardano-node --since='2022-07-29 00:00:00' --until='2022-07-29 12:00:00'
```

## :chart\_with\_upwards\_trend: Improving Cardano Node Performance

If you are not satisfied with the performance of an instance of Cardano Node, then see the topic [Configuring Runtime Options](../part-v-tips/configuring-runtime-options.md).

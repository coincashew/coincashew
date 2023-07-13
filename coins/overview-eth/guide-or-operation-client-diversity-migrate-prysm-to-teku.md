---
description: Step by step guide on how to switch for the solo home or cloud staker.
---

# Guide | Operation Client Diversity: Migrate Prysm to Teku

{% hint style="info" %}
:confetti\_ball: **Support us on Gitcoin Grants:** [We improve this guide with your support!](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew)🙏
{% endhint %}

## :fast\_forward: Complete step by step guide

{% hint style="info" %}
The following steps align with our [mainnet guide](guide-or-how-to-setup-a-validator-on-eth2-mainnet/). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

{% hint style="warning" %}
As per best practices, always try everything on a testnet before doing it _for real_ on mainnet.
{% endhint %}

## :fire: Problem: Why the commotion?

> If improving the stability of the beacon chain is not a good enough reason for you to switch from Prysm to either Teku or Nimbus, you also need to consider that due to the design of the beacon chain you will be subject to severe financial penalties if Prysm ever has an issue. \~[Lamboshi on Twitter](https://twitter.com/L\_Nakaghini/status/1440771303745540096)

![](../../.gitbook/assets/meme2.jpg)

## :rocket: Solution: Increase client diversity by migrating to Teku

![](../../.gitbook/assets/meme1.jpg)

## :construction: How to Migrate from Prysm to Teku

{% hint style="info" %}
[PegaSys Teku](https://consensys.net/knowledge-base/ethereum-2/teku/) (formerly known as Artemis) is a Java-based Ethereum 2.0 client designed & built to meet institutional needs and security requirements. PegaSys is an arm of [ConsenSys](https://consensys.net/) dedicated to building enterprise-ready clients and tools for interacting with the core Ethereum platform. Teku is Apache 2 licensed and written in Java, a language notable for its materity & ubiquity.
{% endhint %}

### :chains: 1. Setup Teku CL

Install git.

```
sudo apt-get install git -y
```

Install Java 17 LTS

```
sudo apt update
sudo apt install openjdk-17-jdk -y
```

Verify Java 17+ is installed.

```
java --version
```

Install and build Teku.

```bash
mkdir ~/git
cd ~/git
git clone https://github.com/ConsenSys/teku.git
cd teku
./gradlew distTar installDist
```

{% hint style="info" %}
This build process may take a few minutes.
{% endhint %}

Verify Teku was installed properly by displaying the version.

```
cd $HOME/git/teku/build/install/teku/bin
./teku --version
```

Copy the Teku binary file to `/usr/bin/teku`

```
sudo cp -r $HOME/git/teku/build/install/teku /usr/bin/teku
```

{% hint style="info" %}
Teku combines both the beacon chain and validator into one process.
{% endhint %}

Setup a directory structure for Teku.

```bash
sudo mkdir -p /var/lib/teku
sudo mkdir -p /etc/teku
sudo chown $USER:$USER /var/lib/teku
```

Create your teku.yaml configuration file.

```bash
sudo nano /etc/teku/teku.yaml
```

Paste the following configuration into the file.

```bash
# network
network: "mainnet"
initial-state: "https://beaconstate.info/eth/v2/debug/beacon/states/finalized"

# validators
validators-graffiti: "<MY_GRAFFITI>"

# execution engine
ee-endpoint: http://localhost:8551 
ee-jwt-secret-file: "/secrets/jwtsecret" 

# fee recipient
validators-proposer-default-fee-recipient: "<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>"

# metrics
metrics-enabled: true
metrics-port: 8008

# database
data-path: "/var/lib/teku"
data-storage-mode: "prune"
```

* Replace**`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>`** with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable, unlike the validator's attestation and block proposal rewards.
* Replace **`<MY_GRAFFITI>`** with your own graffiti message. However for privacy and opsec reasons, avoid personal information. Optionally, leave it blank by deleting the flag option.

### :octagonal\_sign: 2. Stop and disable Prysm

Stop and disable the Prysm services. Choose your guide.

{% tabs %}
{% tab title="CoinCashew" %}
```bash
sudo systemctl stop validator beacon-chain
sudo systemctl disable validator beacon-chain
```
{% endtab %}

{% tab title="SomerEsat" %}
```
sudo systemctl stop prysmvalidator
sudo systemctl stop prysmbeacon
sudo systemctl disable prysmvalidator
sudo systemctl disable prysmbeacon
```
{% endtab %}
{% endtabs %}

Confirm the Prysm validator is stopped by checking the service status.

{% tabs %}
{% tab title="CoinCashew" %}
```bash
service validator status
```
{% endtab %}

{% tab title="SomerEsat" %}
```
service prysmvalidator status
```
{% endtab %}
{% endtabs %}

Delete existing Prysm validators keys so that there's no accidental starting of Prysm's validator.

{% tabs %}
{% tab title="CoinCashew" %}
```bash
sudo rm -rf ~/.eth2validators
```
{% endtab %}

{% tab title="SomerEsat" %}
```
sudo rm -rf /var/lib/prysm/validator
```
{% endtab %}
{% endtabs %}

As a double check, verify that Prysm validator can't find it's keys by starting the validator again.

{% tabs %}
{% tab title="CoinCashew" %}
```bash
sudo systemctl start validator
```
{% endtab %}

{% tab title="SomerEsat" %}
```
 sudo systemctl start prysmvalidator
```
{% endtab %}
{% endtabs %}

Observe the logs and check for errors about missing validator keys.

{% tabs %}
{% tab title="CoinCashew" %}
```bash
journalctl -fu validator
```
{% endtab %}

{% tab title="SomerEsat" %}
```
journalctl -fu prysmvalidator
```
{% endtab %}
{% endtabs %}

Finally, stop Prysm validator.

{% tabs %}
{% tab title="CoinCashew" %}
```bash
sudo systemctl stop validator
```
{% endtab %}

{% tab title="SomerEsat" %}
```
 sudo systemctl stop prysmvalidator
```
{% endtab %}
{% endtabs %}

{% hint style="danger" %}
**Before continuing - Required Waiting Period !!!**

Wait until your validator's last attestation is in a finalized epoch - usually about 15 minutes.

By waiting for a finalized epoch, there's no need to migrate the slashing database.

Confirm that your validator has stopped attesting with block explorer [beaconcha.in](https://beaconcha.in/) or [beaconscan.com](https://beaconscan.com/)
{% endhint %}

### :bricks: 3. Update firewall / port forwarding.

Allow Teku ports:

```
sudo ufw allow 9000/tcp
sudo ufw allow 9000/udp
```

Delete Prysm firewall rules:

```
sudo ufw delete allow 13000/tcp
sudo ufw delete allow 12000/udp
```

Verify that your firewall configuration is correct.

```
sudo ufw status numbered
```

Example output of firewall configuration:

> ```csharp
>      To                         Action      From
>      --                         ------      ----
> [ 1] 22/tcp                     ALLOW IN    Anywhere       # SSH
> [ 2] 9000/tcp                   ALLOW IN    Anywhere       # eth2 p2p traffic
> [ 3] 9000/udp                   ALLOW IN    Anywhere       # eth2 p2p traffic
> [ 4] 30303/tcp                  ALLOW IN    Anywhere       # eth1
> [ 5] 22/tcp (v6)                ALLOW IN    Anywhere (v6)  # SSH
> [ 6] 9000/tcp (v6)              ALLOW IN    Anywhere (v6)  # eth2 p2p traffic
> [ 7] 9000/udp (v6)              ALLOW IN    Anywhere (v6)  # eth2 p2p traffic
> [ 8] 30303/tcp (v6)             ALLOW IN    Anywhere (v6)  # eth1
> ```

{% hint style="info" %}
Your router's port forwarding setup or cloud provider settings will need to be updated to ensure your validator's firewall ports are open and reachable.

You'll need to add new port forwarding rules for Teku and remove the existing Prysm port forwarding rules.
{% endhint %}

**Optional** - Update your server and reboot for best practice.

```bash
sudo apt update && sudo apt upgrade
sudo apt dist-upgrade && sudo apt autoremove
sudo reboot
```

### :key2: 4. Import Validator Keys

Copy your `validator_keys` directory to the data directory we created above and remove the extra deposit\_data file. If you no longer have the validator keys on your node, you will need to restore from file backup or [restore from secret recovery phrase](guide-or-how-to-setup-a-validator-on-eth2-mainnet/#8-2-verify-your-mnemonic-phrase).

```
cp -r $HOME/eth2deposit-cli/validator_keys /var/lib/teku
rm /var/lib/teku/validator_keys/deposit_data*
```

{% hint style="danger" %}
:octagonal\_sign: **FINAL WARNING REMINDER !!!** **Do not** start the Teku validator client until you have stopped the Prysm one, or you **will get slashed** (penalized and exited from the system).

Wait until your validator's last attestation is in a finalized epoch - usually about 15 minutes.

Confirm that your validator has stopped attesting with block explorer [beaconcha.in](https://beaconcha.in/) or [beaconscan.com](https://beaconscan.com/)
{% endhint %}

Storing your **keystore password** in a text file is required so that Teku can decrypt and load your validators automatically.

Replace `<my_keystore_password_goes_here>` with your **keystore password** between the single quotation marks and then run the command to save it to validators-password.txt

```bash
echo '<my_keystore_password_goes_here>' > $HOME/validators-password.txt
```

Confirm that your **keystore password** is correct.

```bash
cat $HOME/validators-password.txt
```

Move the password file and make it read-only.

```bash
sudo mv $HOME/validators-password.txt /etc/teku/validators-password.txt
sudo chmod 600 /etc/teku/validators-password.txt
```

Clear the bash history in order to remove traces of keystore password.

```
shred -u ~/.bash_history && touch ~/.bash_history
```

{% hint style="info" %}
When specifying directories for your validator-keys, Teku expects to find identically named keystore and password files. For example `keystore-m_12221_3600_1_0_0-11222333.json` and `keystore-m_12221_3600_1_0_0-11222333.txt`
{% endhint %}

Create a corresponding password file for every one of your validators.

```
for f in /var/lib/teku/validator_keys/keystore*.json; do cp /etc/teku/validators-password.txt /var/lib/teku/validator_keys/$(basename $f .json).txt; done
```

Verify that your validator's keystore and validator's passwords are present by checking the following directory.

```
ll /var/lib/teku/validator_keys
```

Add validator-keys configuration to teku.yaml

```bash
cat >> /etc/teku/teku.yaml << EOF
validator-keys: "/var/lib/teku/validator_keys:/var/lib/teku/validator_keys"
EOF
```

### :rocket: 5. Setup and start the Teku service

Run the following to create a **unit file** to define your`beacon-chain.service` configuration.

```bash
cat > $HOME/beacon-chain.service << EOF
# The eth beacon chain service (part of systemd)
# file: /etc/systemd/system/beacon-chain.service 

[Unit]
Description     = eth beacon chain service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $USER
ExecStart       = /usr/bin/teku/bin/teku -c /etc/teku/teku.yaml
Restart         = on-failure
Environment     = JAVA_OPTS=-Xmx5g

[Install]
WantedBy	= multi-user.target
EOF
```

Move the unit file to `/etc/systemd/system`

```
sudo mv $HOME/beacon-chain.service /etc/systemd/system/beacon-chain.service
```

Update file permissions.

```
sudo chmod 644 /etc/systemd/system/beacon-chain.service
```

Run the following to enable auto-start at boot time and then start your beacon node service.

```
sudo systemctl daemon-reload
sudo systemctl enable beacon-chain
sudo systemctl start beacon-chain
```

{% hint style="info" %}
Syncing the beacon node might take up to 36 hours depending on your hardware. Keep validating using your current Prysm setup until it completes. However, thanks to Teku's Checkpoint sync, you'll complete this step in a few minutes.

Syncing is complete when your beacon node's slot matches that of a block explorer's slot number (i.e. [https://beaconcha.in/](https://beaconcha.in/))

Check the beacon node syncing progress with the following:

```bash
journalctl -fu beacon-chain
```
{% endhint %}

Check the logs to verify the services are working properly and ensure there are no errors.

```bash
#view and follow the log
journalctl -fu beacon-chain
```

{% hint style="success" %}
Confirm that your new Teku validator has started attesting with block explorer [beaconcha.in](https://beaconcha.in/) or [beaconscan.com](https://beaconscan.com/)
{% endhint %}

#### 🛠 Some helpful systemd commands

**🗄 Viewing and filtering logs**

```bash
#view and follow the log
journalctl -fu beacon-chain
```

```bash
#view log since yesterday
journalctl --unit=beacon-chain --since=yesterday
```

```bash
#view log since today
journalctl --unit=beacon-chain --since=today
```

```bash
#view log between a date
journalctl --unit=beacon-chain --since='2020-12-01 00:00:00' --until='2020-12-02 12:00:00'
```

:mag\_right: **View the status of the beacon chain**

```
sudo systemctl status beacon-chain
```

:repeat: **Restart the beacon chain**

```
sudo systemctl restart beacon-chain
```

:octagonal\_sign: **Stop the beacon chain**

```
sudo systemctl stop beacon-chain
```

### :satellite: 6. Update Prometheus and Grafana monitoring

Select your Ethereum execution engine and then re-create your `prometheus.yml` configuration file to match Teku's metric's settings.

{% tabs %}
{% tab title="Geth" %}
```bash
cat > $HOME/prometheus.yml << EOF
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
   - job_name: 'node_exporter'
     static_configs:
       - targets: ['localhost:9100']
   - job_name: 'nodes'
     metrics_path: /metrics    
     static_configs:
       - targets: ['localhost:8008']
   - job_name: 'geth'
     scrape_interval: 15s
     scrape_timeout: 10s
     metrics_path: /debug/metrics/prometheus
     scheme: http
     static_configs:
     - targets: ['localhost:6060']
EOF
```
{% endtab %}

{% tab title="Besu" %}
```bash
cat > $HOME/prometheus.yml << EOF
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
   - job_name: 'node_exporter'
     static_configs:
       - targets: ['localhost:9100']
   - job_name: 'nodes'
     metrics_path: /metrics    
     static_configs:
       - targets: ['localhost:8008']
   - job_name: 'besu'
     scrape_interval: 15s
     scrape_timeout: 10s
     metrics_path: /metrics
     scheme: http
     static_configs:
     - targets:
       - localhost:9545
EOF
```
{% endtab %}

{% tab title="Nethermind" %}
```bash
cat > $HOME/prometheus.yml << EOF
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
   - job_name: 'node_exporter'
     static_configs:
       - targets: ['localhost:9100']
   - job_name: 'nodes'
     metrics_path: /metrics    
     static_configs:
       - targets: ['localhost:8008']
   - job_name: 'nethermind'
     scrape_interval: 15s
     scrape_timeout: 10s
     honor_labels: true
     static_configs:
       - targets: ['localhost:9091']
EOF
```

Nethermind monitoring requires [Prometheus Pushgateway](https://github.com/prometheus/pushgateway). Install with the following command.

```bash
sudo apt-get install -y prometheus-pushgateway
```

{% hint style="info" %}
Pushgateway listens for data from Nethermind on port 9091.
{% endhint %}
{% endtab %}

{% tab title="OpenEthereum" %}
```bash
cat > $HOME/prometheus.yml << EOF
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
   - job_name: 'node_exporter'
     static_configs:
       - targets: ['localhost:9100']
   - job_name: 'nodes'
     metrics_path: /metrics    
     static_configs:
       - targets: ['localhost:8008']
   - job_name: 'openethereum'
     scrape_interval: 15s
     scrape_timeout: 10s
     metrics_path: /metrics
     scheme: http
     static_configs:
     - targets: ['localhost:6060']
EOF
```
{% endtab %}

{% tab title="Erigon" %}
```bash
cat > $HOME/prometheus.yml << EOF
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
   - job_name: 'node_exporter'
     static_configs:
       - targets: ['localhost:9100']
   - job_name: 'nodes'
     metrics_path: /metrics    
     static_configs:
       - targets: ['localhost:8008']
   - job_name: 'erigon'
     scrape_interval: 10s
     scrape_timeout: 3s
     metrics_path: /debug/metrics/prometheus
     scheme: http
     static_configs:
       - targets: ['localhost:6060']
EOF
```
{% endtab %}
{% endtabs %}

Move it to `/etc/prometheus/prometheus.yml`

```bash
sudo mv $HOME/prometheus.yml /etc/prometheus/prometheus.yml
```

Update file permissions.

```bash
sudo chmod 644 /etc/prometheus/prometheus.yml
```

Finally, restart the services.

```bash
sudo systemctl restart grafana-server prometheus prometheus-node-exporter
```

#### Import your new Teku dashboard into Grafana.

1. Open [http://localhost:3000](http://localhost:3000) or http://\<your validator's ip address>:3000 in your local browser.
2. Login with your credentials
3. **Download and save** [Teku's Dashboard json file](https://grafana.com/api/dashboards/13457/revisions/2/download).
4. Click **Create +** icon > **Import**
5. Add the ETH2 client dashboard via **Upload JSON file**

![Teku by PegaSys Engineering](../../.gitbook/assets/teku.dash.png)

Credits: [https://grafana.com/grafana/dashboards/13457](https://grafana.com/grafana/dashboards/13457)

### :ocean: 7. Clean up Prysm Storage

After a period of stable attestations on Teku, you can safely dispose of the former Prysm files and reclaim disk space.

{% tabs %}
{% tab title="CoinCashew" %}
```bash
# executables
rm -rf ~/prysm 

# Validator Keys
rm -rf ~/.eth2validators

# Beacon Chain Data
rm -rf ~/.eth2
```
{% endtab %}

{% tab title="SomerEsat" %}
```bash
# executables
sudo rm /usr/local/bin/validator
sudo rm /usr/local/bin/beacon-chain

# datadir
sudo rm -rf /var/lib/prysm

# users
sudo deluser prysmbeacon
sudo deluser prysmvalidator
```
{% endtab %}
{% endtabs %}

{% hint style="success" %}
Well done on successfully switching! Cheers to client diversity and a healthy beacon chain.
{% endhint %}

## :pray: Alternative Community Migration Guides

{% embed url="https://lighthouse.sigmaprime.io/switch-to-lighthouse.html" %}

{% embed url="https://nimbus.guide/migration.html" %}

[https://www.reddit.com/r/ethstaker/comments/pu30fa/short\_guide\_to\_migrate\_from\_prysm\_to\_teku\_or/](https://www.reddit.com/r/ethstaker/comments/pu30fa/short\_guide\_to\_migrate\_from\_prysm\_to\_teku\_or/)

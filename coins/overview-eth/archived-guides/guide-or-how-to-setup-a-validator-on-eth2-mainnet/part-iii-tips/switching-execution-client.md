# 🛡 Switching / Migrating Execution Client

{% hint style="info" %}
Important reasons why you would want to switch Execution Clients:

:owl: **Client Diversity**: Improve Ethereum's resilience by using a [minority client](https://mirror.xyz/jmcook.eth/S7ONEka\_0RgtKTZ3-dakPmAHQNPvuj15nh0YGKPFriA)

:floppy\_disk: **Unique Features**: Each client has their own strengths, i.e. faster sync, lower resource requirements, different programming language, unique abilities
{% endhint %}

{% hint style="info" %}
:fire:**Optional Tip**: Before switching, it is possible to minimize downtime and keep your validator online by using a failover node, either your own EL/CL stack, or a public service.

Here are some public options:

* [RocketPool's Rescue Node](https://rescuenode.com/docs/how-to-connect/solo)
* [Tennisbowling's Open Execution Node](https://openexecution.tennisbowling.com/)

However, as validator downtime incurs minimal penalties, the added complexity might not be worth your time and extra work configuring a failover option.
{% endhint %}

{% hint style="info" %}
The following steps align with our [mainnet guide](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

## Manual Method

<details>

<summary>Step 1: Remove OLD Execution Client</summary>

Stop execution client and remove data paths, binaries and service files.

```bash
# Stop Execution Client
sudo systemctl stop eth1
sudo systemctl disable eth1

# Remove service file
sudo rm /etc/systemd/system/eth1.service

# Nethermind
sudo rm -rf $HOME/nethermind
sudo rm -rf $HOME/.nethermind

# Besu
sudo rm -rf $HOME/besu
sudo rm -rf $HOME/.besu

# Geth
sudo rm -rf /usr/bin/geth
sudo rm -rf $HOME/.ethereum
sudo add-apt-repository --remove ppa:ethereum/ethereum -y
sudo apt remove ethereum -y

# Erigon
sudo rm -rf $HOME/erigon
sudo rm -rf /var/lib/erigon
```

</details>

<details>

<summary>Step 2: Install NEW Execution Client</summary>

Follow the instructions found under section: [Installing a new Execution Client.](../part-i-installation/installing-execution-client.md)

***

:fire:**Tip**: As well as being a minority client, **Nethermind** is known to be incredibly fast at syncing, often as quick as 2 hours with fast NVME drives.

</details>

<details>

<summary>Step 3: Restart Consensus Client</summary>

Ensure the consensus client establishes a connection to the new execution client.

```bash
sudo systemctl restart beacon-chain
```

</details>

<details>

<summary>Step 4: Update Monitoring tools</summary>

**Promentheus and Grafana**:

* Revisit the [monitoring guide](../part-i-installation/monitoring-your-validator-with-grafana-and-prometheus.md) and update your `prometheus.yml`configuration for the new execution client.
* Ensure prometheus is connected to your new execution client's metrics port 6060.
* Also import your new execution client's dashboard.

**Beaconcha.in Mobile App:**

* To receive new notifications, update your app's settings to indicate you're using a different execution client

</details>

{% hint style="success" %}
Congrats on switching to a new execution client!
{% endhint %}

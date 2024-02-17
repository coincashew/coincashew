# Uninstalling Staking Node

{% hint style="info" %}
Whether changing clients for client diversity purposes, moving to a new node, or retiring a staking node, here's how to uninstall the three key components of a staking node.
{% endhint %}

### Uninstalling execution client&#x20;

```bash
sudo systemctl stop execution
sudo systemctl disable execution
sudo rm /etc/systemd/system/execution.service

#Nethermind
sudo rm -rf /usr/local/bin/nethermind
sudo rm -rf /var/lib/nethermind

#Besu
sudo rm -rf /usr/local/bin/besu
sudo rm -rf /var/lib/besu

#Geth
sudo rm -rf /usr/local/bin/geth
sudo rm -rf /var/lib/geth

#Erigon
sudo rm -rf /usr/local/bin/erigon
sudo rm -rf /var/lib/erigon

sudo userdel execution
```

### Uninstalling consensus client&#x20;

<pre class="language-bash"><code class="lang-bash">sudo systemctl stop consensus
sudo systemctl disable consensus
sudo rm /etc/systemd/system/consensus.service

#Lighthouse
sudo rm -rf /usr/local/bin/lighthouse
sudo rm -rf /var/lib/lighthouse

#Lodestar
sudo rm -rf /usr/local/bin/lodestar
sudo rm -rf /var/lib/lodestar

#Teku
sudo rm -rf /usr/local/bin/teku
sudo rm -rf /var/lib/teku

#Nimbus
sudo rm -rf /usr/local/bin/nimbus_beacon_node
sudo rm -rf /var/lib/nimbus

#Prysm from Binaries
sudo rm -rf /usr/local/bin/beacon-chain
#Prysm from Build from Source
<strong>sudo rm -rf /usr/local/bin/prysm
</strong>sudo rm -rf /var/lib/prysm

sudo userdel consensus
</code></pre>

### Uninstalling validator

```bash
sudo systemctl stop validator
sudo systemctl disable validator
sudo rm /etc/systemd/system/validator.service

#Lighthouse
sudo rm -rf /var/lib/lighthouse/validators

#Lodestar
sudo rm -rf /var/lib/lodestar/validators

#Teku, if running Standalone Teku Validator
sudo rm -rf /var/lib/teku_validator

#Nimbus, if running standalone Nimbus Validator
sudo rm -rf /var/lib/nimbus_validator

#Prysm from Binaries
sudo rm -rf /usr/local/bin/validator
sudo rm -rf /var/lib/prysm/validators

sudo userdel validator
```

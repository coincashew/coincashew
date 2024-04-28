# Uninstalling V1 Staking Node

{% hint style="info" %}
Whether changing clients for client diversity purposes, moving to a new node, or retiring a staking node, here's how to uninstall the three key components of a staking node.
{% endhint %}

### Uninstalling eth1 client&#x20;

```bash
sudo systemctl stop eth1
sudo systemctl disable eth1
sudo rm /etc/systemd/system/eth1.service

#Nethermind
sudo rm -rf $HOME/nethermind
sudo rm -rf $HOME/.nethermind

#Besu
sudo rm -rf $HOME/besu
sudo rm -rf $HOME/besu_backup*
sudo rm -rf $HOME/.besu

#Geth
sudo rm -rf /usr/bin/geth
sudo rm -rf $HOME/.ethereum

#Erigon
sudo rm -rf $HOME/erigon
sudo rm -rf /var/lib/erigon
```

### Uninstalling beacon-chain client&#x20;

```bash
sudo systemctl stop beacon-chain
sudo systemctl disable beacon-chain
sudo rm /etc/systemd/system/beacon-chain.service

#Lighthouse
sudo rm -r $HOME/.cargo/bin/lighthouse
sudo rm -rf ~/.lighthouse/mainnet/beacon

#Lodestar
sudo rm -rf $HOME/git/lodestar
sudo rm -rf /var/lib/lodestar

#Teku
sudo rm -rf /usr/bin/teku
sudo rm -rf /var/lib/teku

#Nimbus
sudo rm -r /usr/bin/nimbus_beacon_node
sudo rm -rf /var/lib/nimbus

#Prysm
sudo rm -rf $HOME/prysm
sudo rm -rf ~/.eth2/beaconchaindata
```

### Uninstalling validator

```bash
sudo systemctl stop validator
sudo systemctl disable validator
sudo rm /etc/systemd/system/validator.service

#Lighthouse
sudo rm -rf ~/.lighthouse/mainnet/validators

#Lodestar
sudo rm -rf /var/lib/lodestar

#Teku
sudo rm -rf /var/lib/teku/validator

#Nimbus
sudo rm -rf /var/lib/nimbus/validators

#Prysm
sudo rm -rf ~/.eth2validators/prysm-wallet-v2
```

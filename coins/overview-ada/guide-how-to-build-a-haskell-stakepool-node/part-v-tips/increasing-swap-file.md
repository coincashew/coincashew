# Increasing Swap file

Common scenarios encountered by a Stake Pool Operator and why they might want to increase swap file.

* Running low on RAM for cardano-node processes.
* Checking slot leader schedule is crashing due to not enough RAM.

#### Here is an example to create a 8GB swapfile.

{% tabs %}
{% tab title="cardano-node" %}
```bash
#Stop cardano-node first
sudo systemctl stop cardano-node

sudo swapoff /swapfile

#Verify swapfile is off
swapon --show 

#8gb swapfile. Change if you wish.
sudo fallocate -l 8G /swapfile

#Verify swapfile exists
ls -lh /swapfile

sudo mkswap /swapfile
sudo swapon /swapfile

#Verify swapfile increased in size
swapon --show

#Restart cardano-node
sudo systemctl start cardano-node
```
{% endtab %}

{% tab title="cnode" %}
```bash
#Stop cardano-node first
sudo systemctl stop cnode

sudo swapoff /swapfile

#Verify swapfile is off
swapon --show 

#8gb swapfile. Change if you wish.
sudo fallocate -l 8G /swapfile

#Verify swapfile exists
ls -lh /swapfile

sudo mkswap /swapfile
sudo swapon /swapfile

#Verify swapfile increased in size
swapon --show

#Restart cardano-node
sudo systemctl start cnode
```
{% endtab %}
{% endtabs %}

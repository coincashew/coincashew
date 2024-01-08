# Increasing Swap File Size

## Increasing Swap File Size

The following common scenarios encountered by stake pool operators may require increasing swap file size:

* Running low on RAM for cardano-node processes
* Checking slot leader schedule is crashing due to not enough RAM

{% hint style="info" %}
Calculating the slot leader schedule for your stake pool in the current epoch may require a minimum of 16GB combined memory and/or swap space in addition to the memory that `cardano-node` may use.
{% endhint %}


**Here is an example to create a 12GB swapfile.**


{% tabs %}
{% tab title="cardano-node" %}
```bash
#Stop cardano-node first
sudo systemctl stop cardano-node

sudo swapoff /swapfile

#Verify swapfile is off
swapon --show 

#12gb swapfile. Change if you wish.
sudo fallocate -l 12G /swapfile

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

#12gb swapfile. Change if you wish.
sudo fallocate -l 12G /swapfile

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

# Adjusting the Swappiness Parameter

The `swappiness` parameter defines how aggressively the Linux kernel swaps memory pages. Higher values increase the swapping of memory pages. Lower values decrease the amount of swap. Decreasing the amount of swap increases the aggressiveness of the Linux kernel in freeing up memory using other techniques when memory usage is high, including randomly killing processes. For details on adjusting the `swappiness` parameter appropriately for your system, see [Tuning Your Swap Settings](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-20-04#step-6-tuning-your-swap-settings) for example.

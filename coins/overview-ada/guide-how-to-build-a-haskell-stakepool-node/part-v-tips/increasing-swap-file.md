# Increasing Swap File Size

The following common scenarios encountered by stake pool operators may require increasing swap file size:

* Running low on RAM for cardano-node processes
* Checking slot leader schedule is crashing due to not enough RAM

{% hint style="info" %}
Calculating the slot leader schedule for your stake pool in the current epoch may require a minimum of 16GB combined memory and/or swap space in addition to the memory that `cardano-node` may use.
{% endhint %}

## Enabling zRAM

zRAM is a Linux kernel module that creates compressed swap devices on memory, allowing much faster access to data than a traditional swap using SSD or HDD devices.

**To check whether zRAM is enabled:**

1. In a terminal window, type:

```
cat /proc/swaps
```

If the output lists a filename containing the text `zram` then zRAM is enabled.

**To install zRAM:**

1. In a terminal window, type:

```
sudo apt install zram-config
```

2. By default, zRAM creates a swap device half the size of your real RAM. If needed, to customize zRAM configuration options type:

```
sudo nano /usr/bin/init-zram-swapping
```

3. Press `CTRL+S` and then press `ENTER` to save changes that you made in step 2. Press `CTRL+X` to exit the nano editor.

4. Reboot the computer.

<!-- Sources: https://fosspost.org/enable-zram-on-linux-better-system-performance/ -->

## Increasing Disk Swap File Size

#### Here is an example to create a 12GB swapfile.

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

<!-- References:
https://www.reddit.com/r/Ubuntu/comments/4id842/deleted_by_user/
https://www.howtogeek.com/449691/what-is-swapiness-on-linux-and-how-to-change-it/ -->


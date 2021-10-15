---
description: >-
  Become a validator, start staking and help secure Ethereum, a proof-of-stake
  blockchain. Anyone with 32 ETH can join.
---

# Guide | How to setup a validator for Ethereum staking on Pithos testnet in 10 minutes or less

## Your **Mission**

To participate in the public testnet known as **Pithos**, which is the public's first glimpse in helping Ethereum's journey towards "[The Merge](https://consensys.net/blog/ethereum-2-0/an-update-on-the-merge-after-the-amphora-interop-event-in-greece/)", where Ethereum will transition from proof of work to a much more sustainable proof of stake consensus model.

{% hint style="info" %}
Major props and credits to [parithosh](https://github.com/parithosh/consensus-deployment-ansible#pithos-testnet-ansible-files--config) for this knowledge share. Without his extensive work and dedication, this guide would not be possible.
{% endhint %}

![The MergETHEREUM Panda](../../.gitbook/assets/meme-merge.jpg)

## Prerequisites

This guide was tested against Ubuntu 20.04.1 LTS client. You'll need a virtual machine or local desktop/server/laptop/RaspberryPi.

### **Minimum Hardware Requirements**

* **Operating system:** 64-bit Linux (i.e. Ubuntu 20.04 LTS Server or Desktop)
* **Processor:** Dual core CPU, Intel Core i5–760 or AMD FX-8100 or better
* **Memory:** 4GB RAM
* **Storage:** 16GB SSD

{% hint style="info" %}
 For examples of actual staking hardware builds, check out [RocketPool's hardware guide](https://github.com/rocket-pool/docs.rocketpool.net/blob/main/src/guides/node/local/hardware.md).
{% endhint %}

{% hint style="success" %}
**Pro Staking Tip**: Highly recommend you begin with a brand new instance of an OS, VM, and/or machine. Avoid headaches by NOT reusing testnet keys, wallets, or databases for your validator.
{% endhint %}

## How to participate with Pithos

{% hint style="info" %}
At present, only the consensus engine beacon client and execution engine are available now. Consensus layer's validator client are coming soon.
{% endhint %}

### 1. Install dependencies and updates

Install packages and update OS

```
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install git ufw curl -y
```

Install Docker

```shell
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

Install Docker Compose

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Verify docker and docker-compose installed properly.

```
docker --version
docker-compose --version
```

Sample output of known working versions.

> Docker version 20.10.9, build c2ea9bc
>
> docker-compose version 1.29.2, build 5becea4c

Reboot your machine to complete docker installation.

```
sudo reboot
```

### 2. Configure Firewall

Initialize the firewall with Ethereum's p2p ports and ssh.

{% hint style="info" %}
More comprehensive [staking validator node security best practices](guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md) also available.
{% endhint %}

```bash
# By default, deny all incoming and outgoing traffic
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH access
sudo ufw allow ssh
aa
# Allow execution engine client port
sudo ufw allow 30303/tcp

# Allow consensus engine client port
sudo ufw allow 9000/tcp
sudo ufw allow 9000/udp

# Enable UFW
sudo ufw enable
```

Confirm the settings are in effect.

> ```csharp
> sudo ufw status numbered
> ```

Example output:

```
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 9000/udp                   ALLOW IN    Anywhere
[ 2] 22/tcp                     ALLOW IN    Anywhere
[ 3] 30303/tcp                  ALLOW IN    Anywhere
[ 4] 9000/tcp                   ALLOW IN    Anywhere
[ 5] 9000/udp (v6)              ALLOW IN    Anywhere (v6)
[ 6] 22/tcp (v6)                ALLOW IN    Anywhere (v6)
[ 7] 30303/tcp (v6)             ALLOW IN    Anywhere (v6)
[ 8] 9000/tcp (v6)              ALLOW IN    Anywhere (v6)
```

{% hint style="info" %}
For optimal connectivity, ensure Port Forwarding is setup for your router.
{% endhint %}

### 3. Setup Pithos ansible files

```bash
#Setup git directory
mkdir ~/git
cd ~/git

#Clone the repository
git clone https://github.com/parithosh/consensus-deployment-ansible

#Change directories 
cd ~/git/consensus-deployment-ansible/scripts/quick-run/

#Create the required directories for persistent data
mkdir -p execution_data beacon_data
```

### 4. Set IP Address

Set your public IP address into the **pithos.vars** file. Ensure your IP address is correct by cross checking with [https://www.whatismyip.com](https://www.whatismyip.com).

```
IP_ADDRESS=$(curl ifconfig.me)
echo My IP address: $IP_ADDRESS
sed -i -e "s/<ENTER-IP-ADDRESS-HERE>/$IP_ADDRESS/g" ~/git/consensus-deployment-ansible/scripts/quick-run/pithos.vars
```

### 5. Run the execution and consensus engines

Choose and start up your **execution engine client**.

{% tabs %}
{% tab title="Geth" %}
```
docker-compose --env-file pithos.vars -f docker-compose.geth.yml up -d
```
{% endtab %}
{% endtabs %}

Choose and start up your **consensus engine client.**

{% tabs %}
{% tab title="Lodestar" %}
```
docker-compose --env-file pithos.vars -f docker-compose.lodestar.yml up -d
```
{% endtab %}

{% tab title="Teku" %}
```
docker-compose --env-file pithos.vars -f docker-compose.teku.yml up -d
```
{% endtab %}

{% tab title="Lighthouse" %}
```
docker-compose --env-file pithos.vars -f docker-compose.lighthouse.yml up -d
```
{% endtab %}
{% endtabs %}

Check your logs to confirm that the execution and consensus clients are up and syncing.

{% tabs %}
{% tab title="Geth" %}
```
docker logs geth -f --tail=20
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="Lodestar" %}
```
docker logs lodestar_beacon -f --tail=20
```
{% endtab %}

{% tab title="Teku" %}
```
docker logs teku_beacon -f --tail=20
```
{% endtab %}

{% tab title="Lighthouse" %}
```
docker logs lighthouse_beacon -f --tail=20
```
{% endtab %}
{% endtabs %}

Syncing is complete when your slot number matches that of a block explorers. Check [https://pithos-explorer.ethdevops.io/](https://pithos-explorer.ethdevops.io)

{% hint style="info" %}
Since the network is new, syncing both the execution and consensus layers should take a few minutes or so.
{% endhint %}

{% hint style="success" %}
Congrats on setting up your Pithos staking node! 



Note: Validator Deposits not yet available. Deposits for general public should be available in a week.



If you haven't already, learn to setup a [Validator for Ethereum Staking.](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet)
{% endhint %}

## Additional Information

### Stopping the execution and consensus clients

To stop the clients, run

{% tabs %}
{% tab title="Geth" %}
```
docker-compose -f docker-compose.geth.yml down
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="Lodestar" %}
```
docker-compose -f docker-compose.lodestar.yml down
```
{% endtab %}

{% tab title="Teku" %}
```
docker-compose -f docker-compose.teku.yml down
```
{% endtab %}

{% tab title="Lighthouse" %}
```
docker-compose -f docker-compose.lighthouse.yml down
```
{% endtab %}
{% endtabs %}

### Troubleshooting

View the current running docker processes.

```
docker ps
```

Example output:

```
CONTAINER ID   IMAGE                                               COMMAND                  CREATED         STATUS         PORTS     NAMES
592fd5931a1b   parithoshj/geth:merge-ac736f9                       "geth --datadir=/exe…"   1 hours ago     Up 1 hours               geth
```

Notice the column under NAMES. In this example, it's **geth**.

We can shutdown and clean the container by calling geth's yml filename (e.g **docker-compose.geth.yml**). Update this filename for your specific execution or consensus client.

```
docker-compose -f docker-compose.geth.yml down --remove-orphans
```

Now start up the [execution and consensus engines again.](guide-or-how-to-setup-a-validator-for-ethereum-staking-on-pithos-testnet-in-10-minutes-or-less.md#3.-setup-pithos-testnet-ansible-files-1)

### Change Ports

**Scenario**: The default ports 30303 and 9000 are already in use and you need to change ports.

Edit the appropriate docker .yml file. e.g.  `docker-compose.geth.yml`

Add this to the command line.

```
--port <your port#>
```

Update UFW firewalls and/or port forwarding rules accordingly.

## Reference Material <a href="10.-reference-material" id="10.-reference-material"></a>

* [https://github.com/parithosh/consensus-deployment-ansible#pithos-testnet-ansible-files--config](https://github.com/parithosh/consensus-deployment-ansible#pithos-testnet-ansible-files--config)

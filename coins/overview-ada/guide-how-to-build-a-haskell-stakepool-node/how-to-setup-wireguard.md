---
description: >-
  WireGuard® is an extremely simple yet fast and modern VPN that utilizes
  state-of-the-art cryptography. It aims to be faster, simpler, leaner.
---

# How to setup WireGuard

{% hint style="info" %}
Assuming you have a local node \(i.e. block producer / validator client / local laptop\) and remote node \(i.e. relay node / beacon-chain node / VPS\), this guide helps you secure and encrypt your network traffic between the two machines with WireGuard.

This greatly minimizes the chances that your local node is attacked and minimizes the attack surface of the remote node by not requiring you to open ports for services such as Grafana.

Only the remote node is public internet facing online and the local machine can access the remote node's internal services, such as Grafana.
{% endhint %}

## 🐣 1. Install Wireguard

{% hint style="info" %}
Linux Headers needs to be installed before Wireguard. Below you see the generic headers being installed. 
{% endhint %}

{% tabs %}
{% tab title="local and remote node" %}
```bash
sudo apt install linux-headers-generic
sudo add-apt-repository ppa:wireguard/wireguard -y
sudo apt-get update
sudo apt-get install wireguard -y
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
In case of linux header problems, use the following instead.

```text
sudo apt install linux-headers-$(uname -r)
```

Be aware this will require installing the headers again. Not restarting with the new linux-headers will prevent Wireguard network interface from functioning.
{% endhint %}

##  🗝 2. Setup Public / Private Keypair

Generate a public/private key on each node by running the following commands.

{% tabs %}
{% tab title="local and remote nodes" %}
```bash
sudo su

cd /etc/wireguard
umask 077
wg genkey | tee wireguard-privatekey | wg pubkey > wireguard-publickey
```
{% endtab %}
{% endtabs %}

## 🤖 3. Configure Wireguard

Create a `wg0.conf` configuration file in  `/etc/wireguard` directory.

Update your Private and Public Keys accordingly. 

Change the Endpoint to your remote node public IP or DNS address.

#### Two Node Setup \( i.e. 1 block producer, 1 relay node\)

{% tabs %}
{% tab title="local node" %}
```bash
# local node WireGuard Configuration
[Interface]
# local node address
Address = 10.0.0.1/32
# local node private key
PrivateKey = <i.e. SJ6ygM3csa36...+pO4XW1QU0B2M=>
# local node wireguard listening port
ListenPort = 51820

# remote node
[Peer]
# remote node's publickey
PublicKey = <i.e. Rq7QEe2g3qIjDftMu...knBGS9mvJDCa4WQg=>
# remote node's public ip address or dns address
Endpoint = remotenode.mydomainname.com:51820
# remote node's interface address
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 21
```
{% endtab %}

{% tab title="remote node" %}
```bash
# remote node WireGuard Configuration
[Interface]
Address = 10.0.0.2/32
PrivateKey = <i.e. cF3OjVhtKJAY/rQ...LFi7ASWg=>
ListenPort = 51820

# local node
[Peer]
# local node's public key
PublicKey = <i.e. rZLBzslvFtEJ...JdfX4XSwk=>
# local node's public ip address or dns address
Endpoint = localnodesIP-or-domain.com:51820
# local node's interface address
AllowedIPs = 10.0.0.1/32
PersistentKeepalive = 21
```
{% endtab %}
{% endtabs %}

#### Triple Node Setup \( i.e. 1 block producer, 2 relay nodes\)

{% tabs %}
{% tab title="local node" %}
```bash
# local node WireGuard Configuration
[Interface]
# local node address
Address = 10.0.0.1/32
# local node private key
PrivateKey = <i.e. SJ6ygM3csa36...+pO4XW1QU0B2M=>
# local node wireguard listening port
ListenPort = 51820

# remote node 1 config
[Peer]
# remote node's publickey
PublicKey = <i.e. R11q7QEe2g3qIjDftMu...knBGdd2mvJDCaasde=>
# remote node's public ip address or dns address
Endpoint = remotenode1.mydomainname.com:51820
# remote node's interface address
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 21

# remote node 2 config
[Peer]
# remote node 2's publickey
PublicKey = <i.e. ESDd7QEe2g3qIjDftMu...knBGS9mvJDCa4WQg=>
# remote node 2's public ip address or dns address
Endpoint = remotenode2.mydomainname.com:51820
# remote node 2's interface address
AllowedIPs = 10.0.0.3/32
PersistentKeepalive = 21
```
{% endtab %}

{% tab title="remote node 1" %}
```bash
# remote node 1's WireGuard Configuration
[Interface]
Address = 10.0.0.2/32
PrivateKey = <i.e. cF3OjVhtKJAY/rQ...LFi7ASWg=>
ListenPort = 51820

# local node config
[Peer]
PublicKey = <i.e. rZLBzslvFtEJ...knBGS9mvJDCa4WQg=>
Endpoint = localnodesIP-or-domain.com:51820
AllowedIPs = 10.0.0.1/32
PersistentKeepalive = 21

# remote node 2 config
[Peer]
PublicKey = <i.e. m2222zslvFtEJ...JdfX4XSwk=>
Endpoint = remotenode2.mydomainname.com:51820
AllowedIPs = 10.0.0.3/32
PersistentKeepalive = 21
```
{% endtab %}

{% tab title="remote node 2" %}
```bash
# remote node WireGuard Configuration
[Interface]
Address = 10.0.0.3/32
PrivateKey = <i.e. 222jVhtKJAY/rQ...LFi7ASWg=>
ListenPort = 51820

# local node config
[Peer]
PublicKey = <i.e. rZLBzslvFtEJ...knBGS9mvJDCa4WQg=>
Endpoint = localnodesIP-or-domain.com:51820
AllowedIPs = 10.0.0.1/32
PersistentKeepalive = 21

# remote node 1 config
[Peer]
PublicKey = <i.e. R11q7QEe2g3qIjDftMu...knBGdd2mvJDCaasde=>
Endpoint = remotenode1.mydomainname.com:51820
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 21
```
{% endtab %}
{% endtabs %}

#### 🧱 Configure your firewall / port forwarding to allow port 51820 udp traffic to your node.

{% tabs %}
{% tab title="local node" %}
```bash
sudo ufw allow 51820/udp
# check the firewall rules
sudo ufw verbose
```
{% endtab %}

{% tab title="remote nodes" %}
```bash
sudo ufw allow 51820/udp
# check the firewall rules
sudo ufw verbose
```
{% endtab %}
{% endtabs %}

## 🔗 4. Setup autostart with systemd

{% hint style="info" %}
Setup systemd on both your local node and remote node.
{% endhint %}

Add the service to systemd.

{% tabs %}
{% tab title="local and remote node" %}
```text
sudo systemctl enable wg-quick@wg0.service
sudo systemctl daemon-reload
```
{% endtab %}
{% endtabs %}

Start wireguard.

{% tabs %}
{% tab title="local and remote node" %}
```text
sudo systemctl start wg-quick@wg0
```
{% endtab %}
{% endtabs %}

Check the status.

{% tabs %}
{% tab title="local and remote node" %}
```text
sudo systemctl status wg-quick@wg0
```
{% endtab %}
{% endtabs %}

## ✅ 5. Verify Connection is Working

Check the status of the interfaces by running `wg`

{% tabs %}
{% tab title="local and remote node" %}
```bash
sudo wg

## Example Output
# interface: wg0
#  public key: rZLBzslvFtEJ...JdfX4XSwk=
#  private key: (hidden)
#  listening port: 51820

#peer:
#  endpoint: 12.34.56.78:51820
#  allowed ips: 10.0.0.2/32
#  latest handshake: 15 seconds ago
#  transfer: 500 KiB received, 900 KiB sent
#  persistent keepalive: every 21 seconds
```
{% endtab %}
{% endtabs %}

Verify ping works between nodes.

{% tabs %}
{% tab title="local node" %}
```bash
ping 10.0.0.2

# if triple node configuration
ping 10.0.0.3
```
{% endtab %}

{% tab title="remote node" %}
```bash
ping 10.0.0.1

# if triple node configuration
ping 10.0.0.3
```
{% endtab %}

{% tab title="remote node 2" %}
```bash
# if triple node configuration
ping 10.0.0.1
ping 10.0.0.2
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="Cardano" %}
### Cardano Specific Configuration

Update and/or review your topology.json file to ensure the "addr" matches this new tunneled IP address, and not the usual public node IP address.

**Dual node setup**

> Example: topology.json on **blockproducer**  
> { "addr": "10.0.0.2", "port": 6000, "valency": 1 },

> topology.json on **relaynode1**   
> { "addr": "10.0.0.1", "port": 6000, "valency": 1 },



**Triple node setup**

> Example: topology.json on **blockproducer**  
> { "addr": "10.0.0.2", "port": 6000, "valency": 1 },
>
> { "addr": "10.0.0.3", "port": 6000, "valency": 1 },

> topology.json on **relaynode1**   
> { "addr": "10.0.0.1", "port": 6000, "valency": 1 },
>
> { "addr": "10.0.0.3", "port": 6000, "valency": 1 },

> topology.json on **relaynode2**  
> { "addr": "10.0.0.1", "port": 6000, "valency": 1 },
>
> { "addr": "10.0.0.2", "port": 6000, "valency": 1 },
{% endtab %}

{% tab title="ETH2" %}
### ETH2 Validator Specific Configuration

Update and/or review your validator's configuration and ensure it connects to the beacon-chain's new tunneled IP address, and not the usual public node IP address.

In this example, the beacon-chain is the remote node with IP address `10.0.0.2`

To access Grafana from your local machine, enter into the browser `http://10.0.0.2:3000`
{% endtab %}
{% endtabs %}

{% hint style="success" %}
Wireguard setup is complete.
{% endhint %}

## 🛑 6. Stop and disable Wireguard

```text
sudo systemctl stop wg-quick@wg0
sudo systemctl disable wg-quick@wg0.service
sudo systemctl daemon-reload
```


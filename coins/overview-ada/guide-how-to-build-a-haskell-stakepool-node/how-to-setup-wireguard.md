---
description: >-
  WireGuard® is an extremely simple yet fast and modern VPN that utilizes
  state-of-the-art cryptography. It aims to be faster, simpler, leaner.
---

# How to setup WireGuard

{% hint style="info" %}
Assuming you have a block producer setup and relay node setup, this guide helps you secure and encrypt your network traffic between the two nodes with WireGuard. This minimizes the chances that your block producer is attacked or hacked. Only the relay node is public facing online and the block producer can only communicate with the relay node.
{% endhint %}

## 🐣 1. Install Wireguard

{% tabs %}
{% tab title="BlockProducer and RelayNode1" %}
```bash
sudo apt install linux-headers-$(uname -r)
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install wireguard -y
```
{% endtab %}
{% endtabs %}

##  🗝 2. Setup Public / Private Keypair

{% tabs %}
{% tab title="BlockProducer" %}
```bash
sudo su

cd /etc/wireguard
umask 077
wg genkey | tee blockproducer-privatekey | wg pubkey > blockproducer-publickey
wg genkey | tee relaynode1-privatekey | wg pubkey > relaynode1-publickey
```
{% endtab %}
{% endtabs %}

## 🤖 3. Configure Wireguard

Create a `wg0.conf` configuration file in  `/etc/wireguard` directory. Update your Private and Public Keys accordingly. Change the Endpoint to your RelayNode's public IP or DNS address.

{% tabs %}
{% tab title="BlockProducer" %}
```bash
# blockproducer WireGuard Configuration
[Interface]
# blockproducer address
Address = 10.0.0.1/32
# blockproducer private key
PrivateKey = SJ6ygM3csa36...+pO4XW1QU0B2M=
# blockproducer wireguard listening port
ListenPort = 51820
SaveConfig = true

# RelayNode1
[Peer]
# relaynode1's publickey
PublicKey = Rq7QEe2g3qIjDftMu...knBGS9mvJDCa4WQg=
# relaynode1's public ip address or dns address
Endpoint = relay.mydomainname.com:51820
# relaynode1's interface address
AllowedIPs = 10.0.0.2/32
# send a handshake every 21 seconds
PersistentKeepalive = 21
```
{% endtab %}

{% tab title="RelayNode1" %}
```bash
# RelayNode1 WireGuard Configuration
[Interface]
Address = 10.0.0.2/32
PrivateKey = cF3OjVhtKJAY/rQ...LFi7ASWg=
ListenPort = 51820
SaveConfig = true

# BlockProducer
[Peer]
# blockproducer's public key
PublicKey = rZLBzslvFtEJ...JdfX4XSwk=
# blockproducer's public ip address or dns address
Endpoint = 12.34.56.78:51820
# blockproducer's interface address
AllowedIPs = 10.0.0.1/32
PersistentKeepalive = 21
```
{% endtab %}
{% endtabs %}

#### 🧱 Configure your firewall / port forwarding to allow port 51820 udp traffic to your node.

{% tabs %}
{% tab title="BlockProducer" %}
```bash
ufw allow 51820/udp
# check the firewall rules
ufw verbose
```
{% endtab %}

{% tab title="RelayNode1" %}
```
ufw allow 51820/udp
# check the firewall rules
ufw verbose
```
{% endtab %}
{% endtabs %}

## 🔗 4. Setup autostart with systemd

{% hint style="info" %}
Setup systemd on both your block producer and relaynode.
{% endhint %}

Add the service to systemd.

{% tabs %}
{% tab title="BlockProducer and RelayNode1" %}
```text
sudo systemctl enable wg-quick@wg0.service
sudo systemctl daemon-reload
```
{% endtab %}
{% endtabs %}

Start wireguard.

{% tabs %}
{% tab title="BlockProducer and RelayNode1" %}
```text
sudo systemctl start wg-quick@wg0
```
{% endtab %}
{% endtabs %}

Check the status.

{% tabs %}
{% tab title="BlockProducer and RelayNode1" %}
```text
sudo systemctl status wg-quick@wg0
```
{% endtab %}
{% endtabs %}

## ✅ 5. Verify Connection is Working

Check the status of the interfaces by running `wg`

{% tabs %}
{% tab title="BlockProducer and RelayNode1" %}
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
{% tab title="BlockProducer" %}
```text
ping 10.0.0.2
```
{% endtab %}

{% tab title="RelayNode1" %}
```
ping 10.0.0.1
```
{% endtab %}
{% endtabs %}

Update and/or review your topology.json file to ensure the "addr" matches this new tunneled IP address, and not the usual public node IP address.

> Example: topology.json on blockproducer  
> { "addr": "10.0.0.2", "port": 6000, "valency": 1 },

> topology.json on relaynode1   
> { "addr": "10.0.0.1", "port": 6000, "valency": 1 },

{% hint style="success" %}
Congrats! Wireguard is working!
{% endhint %}

## 🛑 6. Stop and disable Wireguard

```text
sudo systemctl stop wg-quick@wg0
sudo systemctl disable wg-quick@wg0.service
sudo systemctl daemon-reload
```


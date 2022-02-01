# :crystal\_ball: Configuring a Block-producing Node

{% hint style="info" %}
A block producer node will be configured with various key-pairs needed for block generation (cold keys, KES hot keys and VRF hot keys). It can only connect to its relay nodes.
{% endhint %}

{% hint style="info" %}
A relay node will not be in possession of any keys and will therefore be unable to produce blocks. It will be connected to its block-producing node, other relays and external nodes.
{% endhint %}

![](../../../.gitbook/assets/producer-relay-diagram.png)

{% hint style="success" %}
For the purposes of this guide, we will be building **two nodes** on two **separate servers**. One node will be designated the **block producer node**, and the other will be the relay node, named **relaynode1**.
{% endhint %}

{% hint style="danger" %}
Configure **topology.json** file so that&#x20;

* relay node(s) connect to public relay nodes (like IOHK) and your block-producer node
* block-producer node **only **connects to your relay node(s)
{% endhint %}

On your **block-producer node, **run the following. Update the **addr **with your relay node's IP address.

{% hint style="warning" %}
**What IP address to use?**

* If both block producer and relay nodes are a local network, then use the relay node's local IP address. `i.e. 192.168.1.123`
* If you are running all nodes in the cloud/VPS , then use the relay node's public IP address. `i.e. 173.45.12.32`
* If your block producer node is local and relay node is in the cloud, then use the relay node's public IP address. `i.e. 173.45.12.32`
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "<RELAYNODE1'S IP ADDRESS>",
        "port": 6000,
        "valency": 1
      }
    ]
  }
EOF
```
{% endtab %}
{% endtabs %}
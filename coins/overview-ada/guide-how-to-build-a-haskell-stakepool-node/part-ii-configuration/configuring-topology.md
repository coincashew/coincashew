# Configuring Topology

Network topology describes the physical and logical structure of a network. In the Cardano network, each stake pool must operate at least one block-producing node and one relay node. The keys and certificates required to issue blocks are located on the block-producing node. For security reasons, your block producer must connect **only** to one or more relay nodes that you—the stake pool operator—control.

The following diagram illustrates Cardano network topology:

![](../../../../.gitbook/assets/producer-relay-diagram.png)

For details on Cardano networking components, visit [Peer-to-peer (P2P) Networking](https://docs.cardano.org/explore-cardano/cardano-network/p2p-networking/).

Before you start the nodes comprising your stake pool, you must:

* Configure your relay node(s) to connect with your block-producing node
* Configure your block-producing node to connect only with your relay node(s)

## Configuring a Relay Node

**To configure your relay node(s) to connect with your block-producing node:**

1. On the computer hosting your relay node, using a text editor open the `config.json` file, and then edit the following option if needed:

```bash
"EnableP2P": true,
```

2. Save and close the `config.json` file.

3. In a terminal window, type the following command to navigate to the folder where you downloaded Cardano configuration files:

```bash
cd ${NODE_HOME}
```

4. To create a backup of the original topology configuration file, type:

```bash
cp topology.json topology.json.bak
```

5. Using a text editor, open the `topology.json` file, and then add a record for the block-producing node in the `localRoots` section as follows, where `<BlockProducingNodeIPAddress>` is the IP address of the block-producing node in your stake pool configuration, and `<BlockProducingNodeName>` is an optional descriptive label for your block-producing node. Also, set the value `true` for the `trustable` key:

```bash
{
  "bootstrapPeers": [
    {
      "address": "backbone.cardano.iog.io",
      "port": 3001
    },
    {
      "address": "backbone.mainnet.emurgornd.com",
      "port": 3001
    },
    {
      "address": "backbone.mainnet.cardanofoundation.org",
      "port": 3001
    }
  ],
  "localRoots": [
    {
      "accessPoints": [
	    {
          "address": "<BlockProducingNodeIPAddress>",
          "port": 6000,
          "name": "<BlockProducingNodeName>"
        }
	  ],
      "advertise": false,
	  "comment": "Do NOT advertise the block-producing node",
      "trustable": true,
      "valency": 1
    }
  ],
  "publicRoots": [
    {
      "accessPoints": [],
      "advertise": false
    }
  ],
  "useLedgerAfterSlot": 128908821
}
```

{% hint style="info" %}
To follow best practices, set `<BlockProducingNodeIPAddress>` to the local area network (LAN) Internet protocol (IP) address of the computer hosting the block-producing node when possible. If necessary—for example, if you set up your block-producing node on a different network than the relay node—then use the wide area network (WAN) IP address. Connecting to `backbone.cardano.iog.io`, `backbone.mainnet.emurgornd.com` and `backbone.mainnet.cardanofoundation.org` allows your relay node to synchronize with the blockchain.
{% endhint %}

6. Save and close the `topology.json` file.

7. To configure additional relay nodes, repeat steps 1 to 6 for each additional relay node in your stake pool configuration.

For more details on configuring topology, visit [Understanding Configuration Files](https://github.com/input-output-hk/cardano-node-wiki/blob/main/docs/getting-started/understanding-config-files.md#the-topologyjson-file).

## Configuring Your Block-producing Node

**To configure your block-producing node to connect only with your relay node(s):**

1. On the computer hosting your block-producing node, using a text editor open the `config-bp.json` file, and then edit the following option if needed:

```bash
"EnableP2P": true,
```

2. Save and close the `config-bp.json` file.

3. On the computer hosting your block-producing node, in a terminal window type the following command to navigate to the folder where you downloaded Cardano configuration files:

```bash
cd ${NODE_HOME}
```

4. To create a backup of the original topology configuration file, type:

```bash
cp topology.json topology.json.bak
```

5. Using a text editor, open the `topology.json` file, and then replace the contents of the file with one or more records, as needed, to reference only the relay node(s) in your stake pool configuration. For example, the following lines configure a single relay node where `<RelayNodeIPAddress>` is the IP address of the relay node and `<RelayNodeName>` is an optional descriptive label for the relay node. Set the value `true` for the `trustable` key. Also, set the value of `bootstrapPeers` to `null` and the value of `useLedgerAfterSlot` to `-1`:

```bash
{
  "bootstrapPeers": null,
  "localRoots": [
    {
      "accessPoints": [
	    {
          "address": "<RelayNodeIPAddress>",
          "port": 6000,
          "name": "<RelayNodeName>"
        }
	  ],
      "advertise": false,
      "trustable": true,
      "valency": 1
    }
  ],
  "publicRoots": [
    {
      "accessPoints": [],
      "advertise": false
    }
  ],
  "useLedgerAfterSlot": -1
}
```

{% hint style="info" %}
To follow best practices, set `<RelayNodeIPAddress>` to the LAN IP address of the computer hosting the relay node when possible. If necessary—for example, if you set up a relay node on a different network than the block-producing node—then use the WAN IP address. If you configure multiple relay nodes in the `localRoots` section, then set the `valency` key to match the number of relay nodes.
{% endhint %}

6. Save and close the `topology.json` file.

## Configuring Port Forwarding

Port forwarding creates an association between the public WAN IP address of a router and a private LAN IP address dedicated to a computer or device on the private network that the router manages.

So that relay nodes in the Cardano network can connect to a relay node in your stake pool configuration, in your firewall configuration you must open a port and forward traffic received on the port to the computer and port where the relay node listens.

{% hint style="info" %}
In the procedures to configure topology above, all block-producing and relay nodes in the stake pool configuration listen on port 6000 If you followed Coin Cashew instructions for [Configuring Your Firewall](../part-i-installation/hardening-an-ubuntu-server.md#ufw), then also ensure that in `ufw` you allow incoming traffic on the port where the Cardano Node on the local computer listens, as needed.
{% endhint %}

To help confirm that your ports are configured as needed, you can use the [Port Forwarding Tester](https://www.yougetsignal.com/tools/open-ports/) or [CanYouSeeMe.org](https://canyouseeme.org/) for example.

## Conclusion

The topology configuration described above allows your nodes to connect securely with each other, as well as with other relay nodes in the Cardano network.

If you configure two or more relays in your stake pool, then consider [Implementing Peer Sharing](../part-v-tips/implementing-peer-sharing.md) to help improve network security.
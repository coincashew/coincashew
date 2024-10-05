# Implementing Peer Sharing

To improve network security, the peer sharing feature available in the Cardano Node software allows you to connect one or more relay nodes to the Cardano network without registering the relay(s) on the blockchain. One or more relay nodes that you register on the blockchain advertise your unregistered relay(s) to other nodes on the network.

**To implement peer sharing:**

1. On a relay node that you registered on the blockchain using a registration certificate, open the `config.json` file using a text editor, and then edit the following values:

```
"PeerSharing": true,
"TargetNumberOfKnownPeers": 150,
"TargetNumberOfRootPeers": 60,
```

{% hint style="info" %}
Setting the value of `TargetNumberOfRootPeers` less than the value of `TargetNumberOfKnownPeers` allows peer sharing to provide additional peers. For more details on registering a relay node on the blockchain, see the topic [Registering Your Stake Pool](../part-iii-operation/registering-your-stake-pool.md).
{% endhint %}

2. Save and close the `config.json` file.

3. On the relay node where you edited the `config.json` file in step 1, open the `topology.json` file using a text editor. Add another `accessPoints` subsection to the `localRoots` section as follows where `<UnregisteredRelayNodeIPAddress>` is the wide area network (WAN) IP address of the unregistered relay node in your stake pool configuration, and `<UnregisteredRelayNodeName>` is an optional descriptive label for your unregistered relay. Also, set the `advertise` key to `true` in the new `accessPoints` subsection:

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
    },
	{
      "accessPoints": [
        {
          "address": "<UnregisteredRelayNodeIPAddress>",
          "port": 6000,
          "name": "<UnregisteredRelayNodeName>"
        }
      ],
      "advertise": true,
      "valency": 1,
      "trustable": true,
      "comment": "Share connection details for one or more unregistered relay nodes"
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
For more details on editing the `topology.json` file, see the topic [Configuring Topology](../part-ii-configuration/configuring-topology.md).
{% endhint %}

4. Save and close the `topology.json` file.

5. On your registered relay, to restart the Cardano Node type:

```
sudo systemctl restart cardano-node.service
```

After the registered relay node restarts, verify that other relay nodes in the Cardano network slowly begin connecting to your unregistered relay.
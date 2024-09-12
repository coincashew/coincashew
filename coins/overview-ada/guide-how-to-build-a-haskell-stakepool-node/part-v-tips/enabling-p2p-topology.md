# Enabling Peer-to-peer Network Topology

The legacy network topology that Cardano uses relies on centralized servers. Development efforts continue to work towards removing security risks associated with centralization within the Cardano ecosystem. Since 2023, Cardano node software includes functionality supporting peer-to-peer network topology aiming to reduce centralization.

Currently, Input Output recommends the following configuration in a stake pool using peer-to-peer topology:

- One relay node using legacy topology that is NOT registered on the blockchain
- At least two additional relay nodes implementing peer-to-peer network topology
- On the block-producing node, implementing peer-to-peer topology

{% hint style="warning" %}
To operate a relay node using peer-to-peer topology, you MUST register the relay on the blockchain. The requirement to register all relay nodes using peer-to-peer topology publicly may create a security risk. A relay node using legacy topology operates when registered or unregistered. The block-producing node connects only to relay nodes in your stake pool configuration. Do NOT register a block-producing node using peer-to-peer networking on the blockchain.
{% endhint %}

Using peer-to-peer topology requires maintaining the configuration. If the configuration for nodes using peer-to-peer topology is out of date and your stake pool falls behind in synchronizing with the network, then the nodes may not resynchronize until you update the configuration.

**To enable peer-to-peer topology on a Cardano node:**

1. To register a relay node to participate in the Cardano peer-to-peer network, create a registration certificate for your stake pool that lists in the options the domain name or IP address of the relay node, as well as the port where the relay node listens, and then submit the registration certificate to the blockchain.

{% hint style="info" %}
Submitting a registration certificate replaces any registration certificates that you submitted previously. For details on creating and submitting a registration certificate, see the topic [Registering Your Stake Pool](../part-iii-operation/registering-your-stake-pool.md).
{% endhint %}

2. Using [Cardanoscan](https://cardanoscan.io/pools) or another Cardano block explorer, confirm that the relay node you registered in step 1 appears as a relay for your stake pool.

{% hint style="warning" %}
When enabling peer-to-peer topology for a relay node, do NOT complete additional steps in the procedure until you successfully register the node on the blockchain. If a relay node using peer-to-peer topology is not registered, then other nodes in the peer-to-peer network will NOT connect to the relay.
{% endhint %}

3. To stop the Cardano node, type `sudo systemctl stop cardano-node`

4. Using a text editor, open the `$NODE_HOME/config.json` file for the node that you want to configure to use peer-to-peer topology, and then edit the following line:

```bash
"EnableP2P": true,
```

5. Save and close the `config.json` file.

6. Using a text editor, create a new file named `$NODE_HOME/topology.json` using syntax supporting peer-to-peer topology. For details on the syntax that peer-to-peer topology requires, visit [Understanding Configuration Files](https://github.com/input-output-hk/cardano-node-wiki/blob/main/docs/getting-started/understanding-config-files.md#the-topologyjson-file).

7. Using a text editor, update the value of the `TOPOLOGY` variable in the `$NODE_HOME/startCardanoNode.sh` script so that the node uses the new `topology.json` file that you created in step 6

{% hint style="info" %}
For more details on configuring the `startCardanoNode.sh` script to use the new `topology.json` file, see the topic [Creating Startup Scripts and Services](../part-ii-configuration/creating-startup-scripts.md).
{% endhint %}

8. To start the node, type `sudo systemctl start cardano-node`

9. To confirm that the node starts successfully, type `journalctl -fu cardano-node` and then monitor the log messages that display.

When a node operates using peer-to-peer topology, the gLiveView dashboard displays statistics reflecting the configuration in the `CONNECTIONS` area. For example:

```bash
│- CONNECTIONS --------------------------------------------------------│
│ P2P        : enabled   Cold Peers : 32        Uni-Dir    : 23        │
│ Incoming   : 19        Warm Peers : 30        Bi-Dir     : 45        │
│ Outgoing   : 50        Hot Peers  : 20        Duplex     : 1         │
│----------------------------------------------------------------------│
```

For details on Cardano networking components, visit [Peer-to-peer (P2P) Networking](https://docs.cardano.org/explore-cardano/cardano-network/p2p-networking/).
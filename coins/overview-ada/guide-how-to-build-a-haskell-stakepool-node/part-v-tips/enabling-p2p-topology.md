# Enabling Peer-to-peer Network Topology

The legacy network topology that Cardano uses relies on centralized servers. Development efforts continue work towards removing security risks associated with centralization within the Cardano ecosystem. Since 2023, Cardano node software includes functionality supporting peer-to-peer network topology designed to reduce the reliance on centralized servers.

Currently, Input Output recommends continuing to operate at least one relay node using legacy topology that is NOT registered on the blockchain in your stake pool configuration. If you implement more than one relay node in your stake pool, then Input Output recommends implementing peer-to-peer topology on the additional relays. You MUST register all relays using peer-to-peer topology on the blockchain.

{% hint style="warning" %}
If you configure peer-to-peer topology incorrectly and your stake pool falls behind in synchronizing with the network, then the nodes using peer-to-peer topology may not resynchronize with the network until you fix the configuration.
{% endhint %}

**To enable peer-to-peer topology on a Cardano node:**

1. You must register all relays using peer-to-peer topology.

{% hint style="info" %}
Registering nodes using legacy topology is optional.
{% endhint %}


2. Using a text editor, open the `config.json` file that you specify in the `cardano-node run` command using the `--config` option, and then edit the following line:

```bash

```

3. For details on updating the `topology.json` file that you specify in the `cardano-node run` command using the `--topology` option.

4. Restart the node.



Enabling peer-to-peer topology on a Cardano node involves editing a value in the `config.json` file that you , as well as updating the `topology.json` file that you specify in the `cardano-node run` command using the `--topology` option.
# Starting the Nodes

Start your stake pool with systemctl and begin syncing the blockchain!

{% tabs %}
{% tab title="block producer node" %}
```bash
sudo systemctl start cardano-node
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
sudo systemctl start cardano-node
```
{% endtab %}
{% endtabs %}

{% hint style="success" %}
Congratulations! Your nodes are running successfully. Synchronizing your local copies of the Cardano blockchain ledger with the network may take about 18 hours.
{% endhint %}

To monitor your Cardano nodes, install gLiveView. <a href="#gliveview" id="gliveview"></a>

{% hint style="info" %}
gLiveView displays crucial node status information and works well with systemd services.
{% endhint %}

```bash
cd $NODE_HOME
sudo apt install bc tcptraceroute -y
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh
```

Run the following to modify **env** with the updated file locations.

```bash
sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```

{% hint style="info" %}
For complete documentation from the developer on using the [gLiveView](https://cardano-community.github.io/guild-operators/Scripts/gliveview/) script and [env](https://cardano-community.github.io/guild-operators/Scripts/env/) file, visit [Guild Operators](https://cardano-community.github.io/guild-operators/).
{% endhint %}

{% hint style="warning" %}
A node must synchronize to epoch 208 (Shelley launch) before **gLiveView.sh** can start tracking the synchronization process. Before your node synchronizes to epoch 208, you can track node synchronization using the following command:

```
journalctl --unit=cardano-node --follow
```
{% endhint %}

{% hint style="info" %}
****:sparkles: **Pro tip**: If you synchronize a node, then you can copy the database directory to a different computer to save time synchronizing another node.
{% endhint %}

Run gLiveView to monitor the progress of the local Cardano Node synchronizing with the blockchain.

```
./gLiveView.sh
```

Sample output of gLiveView.

![](../../../../.gitbook/assets/glive-update2.jpg)
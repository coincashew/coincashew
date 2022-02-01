# :white\_check\_mark: 8. Start the Nodes

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

Install gLiveView, a monitoring tool.

{% hint style="info" %}
gLiveView displays crucial node status information and works well with systemd services. Credits to the [Guild Operators](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview) for creating this tool.
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
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```

{% hint style="warning" %}
A node must reach epoch 208 (Shelley launch) before **gLiveView.sh** can start tracking the node syncing. You can track the node syncing using `journalctl `before epoch 208.

```
journalctl --unit=cardano-node --follow
```
{% endhint %}

Run gLiveView to monitor the progress of the sync'ing of the blockchain.

```
./gLiveView.sh
```

Sample output of gLiveView.

![](../../../.gitbook/assets/glive-update2.jpg)

For more information, refer to the [official Guild Live View docs.](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview)

{% hint style="info" %}
****:sparkles: **Pro tip**: If you synchronize a node's database, you can copy the database directory over to your other node directly and save time.
{% endhint %}

{% hint style="success" %}
Congratulations! Your node is running successfully now. Let it sync up.
{% endhint %}
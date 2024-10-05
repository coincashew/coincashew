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

<!-- ![](../../../../.gitbook/assets/glive-update2.jpg) -->

```bash
           > Cardano Node - (Core - Mainnet) : 9.2.0 [341ea87b] <
┌───────────────────────────────┬────────────┬─────────────────────────┐
│ Uptime: 11:45:29              │ Port: 6000 │ Koios gLiveView v1.29.1 │
│-------------------------------└────────────┴─────────────────────────┤
│ Epoch 509 [38.4%], 3d 01:54:14 remaining                             │
│ ▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▌▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖▖ │
│                                                                      │
│ Block      : 10831281  Tip (ref)  : 134690746 Forks      : 4         │
│ Slot       : 134690744 Tip (diff) : 2 :)      Total Tx   : 1184      │
│ Slot epoch : 165944    Density    : 4.928     Pending Tx : 0/0K      │
│- CONNECTIONS --------------------------------------------------------│
│ P2P        : enabled   Cold Peers : 0         Uni-Dir    : 2         │
│ Incoming   : 1         Warm Peers : 0         Bi-Dir     : 0         │
│ Outgoing   : 1         Hot Peers  : 1         Duplex     : 0         │
│- BLOCK PROPAGATION --------------------------------------------------│
│ Last Block : 0.53s     Served     : 315       Late (>5s) : 0         │
│ Within 1s  : 93.56%    Within 3s  : 99.62%    Within 5s  : 100%      │
│- NODE RESOURCE USAGE ------------------------------------------------│
│ CPU (sys)  : 1.61%     Mem (RSS)  : 12.5G     GC Minor   : 5396      │
│ Disk util  : 57%       Mem (Live) : 5.2G      GC Major   : 26        │
│                        Mem (Heap) : 12.4G                            │
├─ CORE ───────────────────────────────────────────────────────────────┤
│ KES current|remaining|exp         : 1039 | 46 | 2024-11-21 01:44 PST │
│ OP Cert disk|chain                : 42 | 42                          │
│ Missed slot leader checks         : 0 (0.0000 %)                     │
│- BLOCK PRODUCTION ---------------------------------------------------│
│ Leader     : 0         Adopted    : 0         Missed     : 0         │
│ Ideal      : 0.83      Confirmed  : 0         Ghosted    : 0         │
│ Luck       : 0.0%      Invalid    : 0         Stolen     : 0         │
└──────────────────────────────────────────────────────────────────────┘
 TG Announcement/Support channel: t.me/CardanoKoios/9759

 [esc/q] Quit | [i] Info | [p] Peer Analysis | [v] Compact

```
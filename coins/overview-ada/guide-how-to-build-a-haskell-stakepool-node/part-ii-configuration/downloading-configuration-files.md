## :triangular\_ruler: 3. Configure the nodes

Here you'll grab the config.json, genesis.json, and topology.json files needed to configure your node.

```bash
mkdir $NODE_HOME
cd $NODE_HOME
wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-config.json
wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-byron-genesis.json
wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-shelley-genesis.json
wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-alonzo-genesis.json
wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-topology.json
```

Run the following to modify **mainnet-config.json** and&#x20;

* update TraceBlockFetchDecisions to "true"

```bash
sed -i ${NODE_CONFIG}-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
```

{% hint style="info" %}
****:sparkles: **Tip for relay nodes**: It's possible to reduce the number of missed slot leader checks, memory and cpu usage by setting "**TraceMempool**" to "**false**" in **mainnet-config.json**



**Side effects of TraceMempool = false**

* gLiveView will show 0 for transactions processed
* If your block producer is configured this way, troubleshooting topology / firewall / transaction processing issues may be harder to diagnose and identify. For block producer nodes, it is considered [best practice](https://github.com/input-output-hk/cardano-node/issues/2350) to keep TraceMempool as true.
{% endhint %}

Update **.bashrc **shell variables.

```bash
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> $HOME/.bashrc
source $HOME/.bashrc
```
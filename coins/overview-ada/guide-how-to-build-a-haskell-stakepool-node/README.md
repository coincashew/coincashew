---
description: >-
  On Ubuntu/Debian, this guide will illustrate how to install and configure a
  Cardano stake pool from source code on a two node setup with 1 block producer
  node and 1 relay node.
---

# Guide: Setting Up a Cardano Stake Pool



## :page\_facing\_up: 12. Register your stake pool

Create your pool's metadata with a JSON file. Update with your pool information.

{% hint style="warning" %}
**ticker **must be between 3-5 characters in length. Characters must be A-Z and 0-9 only.
{% endhint %}

{% hint style="warning" %}
**description **cannot exceed 255 characters in length.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > poolMetaData.json << EOF
{
"name": "MyPoolName",
"description": "My pool description",
"ticker": "MPN",
"homepage": "https://myadapoolnamerocks.com"
}
EOF
```
{% endtab %}
{% endtabs %}

Calculate the hash of your metadata file. It's saved to **poolMetaDataHash.txt**

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

Copy **poolMetaDataHash.txt** to your air-gapped offline machine, cold environment.

Now upload your **poolMetaData.json** to your website or a public website such as [https://pages.github.com/](https://pages.github.com)

Refer to [this quick guide](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-upload-poolmetadata.json-to-github) if you need help hosting your metadata on github.com

Verify the metadata hashes by comparing your uploaded .json file and your local .json file's hash.&#x20;

{% tabs %}
{% tab title="block producer node" %}
Get the metadata hash from your metadata json URL. Replace **\<https://REPLACE WITH YOUR METADATA\_URL>** with your actual URL.

```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file <(curl -s -L <https://REPLACE WITH YOUR METADATA_URL>)
```

This above hash must equal the local metadata hash.

```
cat poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
If the hashes do no match, then the uploaded .json file likely was truncated or extra whitespace caused issues. Upload the .json again or to a different web host.
{% endhint %}

Find the minimum pool cost.

{% tabs %}
{% tab title="block producer node" %}
```bash
minPoolCost=$(cat $NODE_HOME/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
minPoolCost is 340000000 lovelace or 340 ADA. Therefore, your `--pool-cost` must be at a minimum this amount.
{% endhint %}

Create a registration certificate for your stake pool. Update with your **metadata URL** and your **relay node information**. Choose one of the three options available to configure relay nodes -- DNS based, Round Robin DNS based, or IP based.&#x20;

{% hint style="info" %}
DNS based relays are recommended for simplicity of node management. In other words, you don't need to re-submit this **registration certificate** transaction every time your IP changes. Also you can easily update the DNS to point towards a new IP should you re-locate or re-build a relay node, for example.
{% endhint %}

{% hint style="info" %}
#### ****:sparkles: **How to configure multiple relay nodes. **

Update the next operation

`cardano-cli stake-pool registration-certificate`

to be run on your air-gapped offline machine appropriately. Replace with your proper domain names or IP addresses.

**DNS based relays, 1 entry per DNS record**

```bash
    --single-host-pool-relay <relaynode1.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
    --single-host-pool-relay <relaynode2.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
```

**Round Robin DNS based relays, 1 entry per **[**SRV DNS record**](https://support.dnsimple.com/articles/srv-record/)****

```bash
    --multi-host-pool-relay <relayNodes.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
```

**IP based relays, 1 entry per IP address**

```bash
    --pool-relay-port 6000 \
    --pool-relay-ipv4 <your first relay node public IP address> \
    --pool-relay-port 6000 \
    --pool-relay-ipv4 <your second relay node public IP address> \
```
{% endhint %}

{% hint style="warning" %}
**metadata-url** must be no longer than 64 characters.
{% endhint %}

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000 \
    --pool-cost 345000000 \
    --pool-margin 0.15 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --single-host-pool-relay <dns based relay, example ~ relaynode1.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
    --metadata-url <url where you uploaded poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Here we are pledging 100 ADA with a fixed pool cost of 345 ADA and a pool margin of 15%.&#x20;
{% endhint %}

Copy **pool.cert** to your **hot environment.**

Pledge stake to your stake pool.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
```
{% endtab %}
{% endtabs %}

Copy **deleg.cert** to your **hot environment**.

{% hint style="info" %}
This operation creates a delegation certificate which delegates funds from all stake addresses associated with key `stake.vkey` to the pool belonging to cold key `node.vkey`
{% endhint %}

{% hint style="info" %}
A stake pool owner's promise to fund their own pool is called **Pledge**.

* Your balance needs to be greater than the pledge amount.
* You pledge funds are not moved anywhere. In this guide's example, the pledge remains in the stake pool's owner keys, specifically `payment.addr`
* Failing to fulfill pledge will result in missed block minting opportunities and your delegators would miss rewards.&#x20;
* Your pledge is not locked up. You are free to transfer your funds.
{% endhint %}

You need to find the **tip **of the blockchain to set the **invalid-hereafter **parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Find your balance and **UTXOs**.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
{% endtab %}
{% endtabs %}

Find the deposit fee for a pool.

{% tabs %}
{% tab title="block producer node" %}
```bash
stakePoolDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakePoolDeposit')
echo stakePoolDeposit: $stakePoolDeposit
```
{% endtab %}
{% endtabs %}

Run the build-raw transaction command.

{% hint style="info" %}
The **invalid-hereafter **value must be greater than the current tip. In this example, we use current slot + 10000.&#x20;
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${stakePoolDeposit}))  \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

Calculate the minimum fee:

{% tabs %}
{% tab title="block producer node" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Ensure your balance is greater than cost of fee + minPoolCost or this will not work.
{% endhint %}

Calculate your change output.

{% tabs %}
{% tab title="block producer node" %}
```bash
txOut=$((${total_balance}-${stakePoolDeposit}-${fee}))
echo txOut: ${txOut}
```
{% endtab %}
{% endtabs %}

Build the transaction.&#x20;

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment.**

Sign the transaction.&#x20;

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

Copy **tx.signed** to your **hot environment.**

Send the transaction.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

## :hatching\_chick: 13. Locate your Stake pool ID and verify everything is working&#x20;

Your stake pool ID can be computed with:

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-pool id --cold-verification-key-file $HOME/cold-keys/node.vkey --output-format hex > stakepoolid.txt
cat stakepoolid.txt
```
{% endtab %}
{% endtabs %}

Copy **stakepoolid.txt **to your **hot environment.**

Now that you have your stake pool ID,  verify it's included in the blockchain.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query stake-snapshot --stake-pool-id $(cat stakepoolid.txt) --mainnet 
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
A non-empty string return means you're registered! :clap:&#x20;
{% endhint %}

With your stake pool ID, now you can find your data on block explorers such as [https://pooltool.io/](https://pooltool.io)

## :gear: 14. Configure your topology files

{% hint style="info" %}
Shelley has been launched without peer-to-peer (p2p) node discovery so that means we will need to manually add trusted nodes in order to configure our topology. This is a **critical step** as skipping this step will result in your minted blocks being orphaned by the rest of the network.
{% endhint %}

#### :rocket: Publishing your Relay Node with topologyUpdater.sh

{% hint style="info" %}
Credits to [GROWPOOL](https://twitter.com/PoolGrow) for this addition and credits to [CNTOOLS Guild OPS](https://cardano-community.github.io/guild-operators/Scripts/topologyupdater.html) on creating this process.
{% endhint %}

{% hint style="info" %}
**How Topology API works**

1. Your relay node pings an API server.
2. When the API server is convinced that your relay node is stable and is actually a running Cardano node, based on the ability to report the current block number accurately a number of times over a period of time, then the domain name or IP address of your node is automatically added to a list of other nodes that have been vetted similarly for quality and stability.
3. When your relay node is on the list, the relay node can request from the API server a list of other active Cardano nodes with which your node can synchronize in order to participate in the network of nodes as a peer. Also, the domain name or IP address of your relay node is distributed on lists that other active Cardano nodes may request from the same API server. **NOTE**: Other nodes refreshing their list of peer nodes with a list that may include the domain name or IP address of your relay node is dependent on how often other nodes request an updated list from the API server. Request an updated list of nodes from the API server for your relay regularly so that your list of peers remains accurate.
4. In order to stay on the list of active nodes, your relay node must ping the API server once every hour. If your relay node stops pinging the API server, then your relay node is removed from the list of active nodes after three hours.

Credits for the high level explanation: [Oliver Sterzik - Change (CHG) Cardano Stake Pool Operator](https://change.paradoxicalsphere.com)
{% endhint %}

Create the `topologyUpdater.sh` script which publishes your node information to a topology fetch list.

```bash
###
### On relaynode1
###
cat > $NODE_HOME/topologyUpdater.sh << EOF
#!/bin/bash
# shellcheck disable=SC2086,SC2034
 
USERNAME=$(whoami)
CNODE_PORT=6000 # must match your relay node port as set in the startup command
CNODE_HOSTNAME="CHANGE ME"  # optional. must resolve to the IP you are requesting from
CNODE_BIN="/usr/local/bin"
CNODE_HOME=$NODE_HOME
CNODE_LOG_DIR="\${CNODE_HOME}/logs"
GENESIS_JSON="\${CNODE_HOME}/${NODE_CONFIG}-shelley-genesis.json"
NETWORKID=\$(jq -r .networkId \$GENESIS_JSON)
CNODE_VALENCY=1   # optional for multi-IP hostnames
NWMAGIC=\$(jq -r .networkMagic < \$GENESIS_JSON)
[[ "\${NETWORKID}" = "Mainnet" ]] && HASH_IDENTIFIER="--mainnet" || HASH_IDENTIFIER="--testnet-magic \${NWMAGIC}"
[[ "\${NWMAGIC}" = "764824073" ]] && NETWORK_IDENTIFIER="--mainnet" || NETWORK_IDENTIFIER="--testnet-magic \${NWMAGIC}"
 
export PATH="\${CNODE_BIN}:\${PATH}"
export CARDANO_NODE_SOCKET_PATH="\${CNODE_HOME}/db/socket"
 
blockNo=\$(/usr/local/bin/cardano-cli query tip \${NETWORK_IDENTIFIER} | jq -r .block )
 
# Note:
# if you run your node in IPv4/IPv6 dual stack network configuration and want announced the
# IPv4 address only please add the -4 parameter to the curl command below  (curl -4 -s ...)
if [ "\${CNODE_HOSTNAME}" != "CHANGE ME" ]; then
  T_HOSTNAME="&hostname=\${CNODE_HOSTNAME}"
else
  T_HOSTNAME=''
fi

if [ ! -d \${CNODE_LOG_DIR} ]; then
  mkdir -p \${CNODE_LOG_DIR};
fi
 
curl -s "https://api.clio.one/htopology/v1/?port=\${CNODE_PORT}&blockNo=\${blockNo}&valency=\${CNODE_VALENCY}&magic=\${NWMAGIC}\${T_HOSTNAME}" | tee -a \$CNODE_LOG_DIR/topologyUpdater_lastresult.json
EOF
```

Add permissions and run the updater script.

```bash
###
### On relaynode1
###
cd $NODE_HOME
chmod +x topologyUpdater.sh
./topologyUpdater.sh
```

When the `topologyUpdater.sh` runs successfully, you will see

> `{ "resultcode": "201", "datetime":"2020-07-28 01:23:45", "clientIp": "1.2.3.4", "iptype": 4, "msg": "nice to meet you" }`

{% hint style="info" %}
Every time the script runs and updates your IP, a log is created in **`$NODE_HOME/logs`**&#x20;
{% endhint %}

Add a crontab job to automatically run `topologyUpdater.sh` every hour on the 33rd minute. You can change the 33 value to your own preference.

```bash
###
### On relaynode1
###
cat > $NODE_HOME/crontab-fragment.txt << EOF
33 * * * * ${NODE_HOME}/topologyUpdater.sh
EOF
crontab -l | cat - ${NODE_HOME}/crontab-fragment.txt > ${NODE_HOME}/crontab.txt && crontab ${NODE_HOME}/crontab.txt
rm ${NODE_HOME}/crontab-fragment.txt
```

{% hint style="success" %}
After four hours and four updates, your node IP will be registered in the topology fetch list.
{% endhint %}

#### Update your relay node topology files

{% hint style="danger" %}
Complete this section after **four hours** when your relay node IP is properly registered.
{% endhint %}

Create `relay-topology_pull.sh` script which fetches your relay node buddies and updates your topology file. **Update with your block producer's IP address.**

{% tabs %}
{% tab title="mainnet" %}
```bash
###
### On relaynode1
###
cat > $NODE_HOME/relay-topology_pull.sh << EOF
#!/bin/bash
BLOCKPRODUCING_IP=<BLOCK PRODUCERS IP ADDRESS>
BLOCKPRODUCING_PORT=6000
curl -s -o $NODE_HOME/${NODE_CONFIG}-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=\${BLOCKPRODUCING_IP}:\${BLOCKPRODUCING_PORT}:1|relays-new.cardano-mainnet.iohk.io:3001:2"
EOF
```
{% endtab %}

{% tab title="testnet" %}
```bash
###
### On relaynode1
###
cat > $NODE_HOME/relay-topology_pull.sh << EOF
#!/bin/bash
BLOCKPRODUCING_IP=<BLOCK PRODUCERS IP ADDRESS>
BLOCKPRODUCING_PORT=6000
curl -s -o $NODE_HOME/testnet-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&magic=1097911063&customPeers=${BLOCKPRODUCING_IP}:${BLOCKPRODUCING_PORT}:1|relays-new.cardano-testnet.iohkdev.io:3001:2"
EOF
```
{% endtab %}
{% endtabs %}

Add permissions and pull new topology files.

```bash
###
### On relaynode1
###
chmod +x relay-topology_pull.sh
./relay-topology_pull.sh
```

The new topology takes after after restarting your stake pool.

```bash
###
### On relaynode1
###
sudo systemctl restart cardano-node
```

{% hint style="warning" %}
Don't forget to restart your relay nodes after every time you fetch the topology!&#x20;
{% endhint %}

{% hint style="danger" %}
****:octagonal\_sign: **Critical Key Security Reminde**r: The only stake pool **keys **and **certs **that are required to run a stake pool are those required by the block producer. Namely, the following three files.

```bash
###
### On block producer node
###
KES=${NODE_HOME}/kes.skey
VRF=${NODE_HOME}/vrf.skey
CERT=${NODE_HOME}/node.cert
```

**All other keys must remain offline in your air-gapped offline cold environment.**
{% endhint %}

{% hint style="danger" %}
****:fire: **Relay Node Security Reminder:** Relay nodes must not contain any **`operational certifications`, `vrf`, `skey` or `cold`**` `**keys**.
{% endhint %}

{% hint style="success" %}
Congratulations! Your stake pool is registered and ready to produce blocks.



Continue to the next section 15 - Checking stake pool rewards.
{% endhint %}

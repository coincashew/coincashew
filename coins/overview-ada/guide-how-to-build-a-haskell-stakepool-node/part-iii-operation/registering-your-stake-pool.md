# Registering Your Stake Pool

Create your pool's metadata with a JSON file. Update with your pool information.

{% hint style="warning" %}
**ticker** must be between 3-5 characters in length. Characters must be A-Z and 0-9 only.
{% endhint %}

{% hint style="warning" %}
**description** cannot exceed 255 characters in length.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > md.json << EOF
{
"name": "MyPoolName",
"description": "My pool description",
"ticker": "MPN",
"homepage": "https://pool.example.net"
}
EOF
```
{% endtab %}
{% endtabs %}

Calculate the hash of your metadata file. It's saved to **poolMetaDataHash.txt**

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway stake-pool metadata-hash --pool-metadata-file md.json > poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

Copy **poolMetaDataHash.txt** to your air-gapped offline machine, cold environment.

Next, upload your **md.json** file to a Web site that you administer or a public Web site. For example, you can [upload your pool metadata to GitHub](../part-v-tips/uploading-pool-metadata-to-github.md).

Verify the metadata hashes by comparing your uploaded .json file and your local .json file's hash.

{% tabs %}
{% tab title="block producer node" %}
Get the metadata hash from your metadata json URL. Replace **\<https://REPLACE WITH YOUR METADATA\_URL>** with your actual URL.

```bash
cardano-cli conway stake-pool metadata-hash --pool-metadata-file <(curl -s -L <https://REPLACE WITH YOUR METADATA_URL>)
```

This above hash must equal the local metadata hash.

```
cat poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
If the hashes do no match, then the uploaded .JSON file likely was truncated or extra whitespace caused issues. Upload the .JSON again or to a different web host.
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
minPoolCost is 170000000 lovelace or 170 ADA. Therefore, your `--pool-cost` must be at a minimum this amount.
{% endhint %}

Create a registration certificate for your stake pool. Update with your **metadata URL** and your **relay node information**. Choose one of the three options available to configure relay nodes -- DNS based, Round Robin DNS based, or IP based.

{% hint style="info" %}
DNS based relays are recommended for simplicity of node management. In other words, you don't need to re-submit this **registration certificate** transaction every time your IP changes. Also you can easily update the DNS to point towards a new IP should you re-locate or re-build a relay node, for example.
{% endhint %}

{% hint style="warning" %}
You MUST register at least one relay node on the blockchain using the registration certificate. If you operate multiple relay nodes, then registering all your relay nodes publicly on the blockchain may create a security risk. You can operate one or more unregistered relays by [Implementing Peer Sharing](../part-v-tips/implementing-peer-sharing.md). Do NOT register your block-producing node on the blockchain.
 {% endhint %}

{% hint style="info" %}
:sparkles: **Configuring Multiple Relay Nodes**

Update the next operation

`cardano-cli conway stake-pool registration-certificate`

to be run on your air-gapped offline machine appropriately. Replace with your proper domain names or IP addresses.

**DNS based relays, 1 entry per DNS record**

```bash
    --single-host-pool-relay <relaynode1.pool.example.net> \
    --pool-relay-port 6000 \
    --single-host-pool-relay <relaynode2.pool.example.net> \
    --pool-relay-port 6000 \
```

**Round Robin DNS based relays, 1 entry per** [**SRV DNS record**](https://support.dnsimple.com/articles/srv-record/)

```bash
    --multi-host-pool-relay <relayNodes.pool.example.net> \
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

{% hint style="danger" %}
**metadata-url** must be less than 64 characters. Shorten your URL or file name.
{% endhint %}

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000 \
    --pool-cost 345000000 \
    --pool-margin 0.15 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --single-host-pool-relay <dns based relay, example ~ relaynode1.pool.example.net> \
    --pool-relay-port 6000 \
    --metadata-url <url where you uploaded md.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Here we are pledging 100 ADA with a fixed pool cost of 345 ADA and a pool margin of 15%.
{% endhint %}

Copy **pool.cert** to your **hot environment.**

Pledge stake to your stake pool.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway stake-address stake-delegation-certificate \
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
* Failing to fulfill pledge will result in missed block minting opportunities and your delegators would miss rewards.
* Your pledge is not locked up. You are free to transfer your funds.
{% endhint %}

You need to find the **tip** of the blockchain to set the **invalid-hereafter** parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli conway query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Find your balance and **UTXOs**.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    type=$(awk '{ print $6 }' <<< "${utxo}")
    if [[ ${type} == 'TxOutDatumNone' ]]
    then
        in_addr=$(awk '{ print $1 }' <<< "${utxo}")
        idx=$(awk '{ print $2 }' <<< "${utxo}")
        utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
        total_balance=$((${total_balance}+${utxo_balance}))
        echo TxHash: ${in_addr}#${idx}
        echo ADA: ${utxo_balance}
        tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
    fi
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total available ADA balance: ${total_balance}
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
The **invalid-hereafter** value must be greater than the current tip. In this example, we use current slot + 10000.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${stakePoolDeposit} ))  \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee 200000 \
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
fee=$(cardano-cli conway transaction calculate-min-fee \
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

Build the transaction.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment.**

Sign the transaction.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway transaction sign \
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
cardano-cli conway transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

# :octagonal\_sign: Critical Security Reminders :fire:

## Block-producing Node

The only stake pool **keys** and **certs** that are required to run a stake pool are those required by the block producer, specifically the following three files.

```bash
###
### On block producer node
###
KES=${NODE_HOME}/kes.skey
VRF=${NODE_HOME}/vrf.skey
CERT=${NODE_HOME}/node.cert
```

**All other keys must remain offline in your air-gapped offline cold environment.**

## Relay Nodes

Relay nodes must NOT store any **`operational certificates`, `vrf`, `skey` or `cold`**` ``` **keys**.

# Updating Stake Pool Information

{% hint style="danger" %}
**Important Reminder**:fire: Any changes made in this section take effect in two epochs. A common mistake is lowering the pledge amount and removing funds too soon. This results in zero rewards as the current live pledge amount is no longer met.
{% endhint %}

{% hint style="info" %}
Need to change your pledge, fee, margin, pool IP/port, or metadata? Simply resubmit your stake pool registration certificate.

**Reminder**: There is no requirement to pay the 500 ADA stake pool deposit again.
{% endhint %}

First, generate the protocol-parameters.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway query protocol-parameters \
    --mainnet \
    --out-file $NODE_HOME/params.json
```
{% endtab %}
{% endtabs %}

If you're changing your poolMetaData.json, remember to calculate the hash of your metadata file and re-upload the updated poolMetaData.json file. For more details, refer to the section [Registering Your Stake Pool](../part-iii-operation/registering-your-stake-pool.md).

{% tabs %}
{% tab title="block producer node" %}
```
cardano-cli conway stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

If you changed your poolMetaData.json, copy **poolMetaDataHash.txt** to your **cold environment.**

Update the below registration-certificate transaction with your desired stake pool settings.

If you have **multiple relay nodes**, then [change your parameters accordingly](../part-iii-operation/registering-your-stake-pool.md#multiplerelays).

{% hint style="warning" %}
**metadata-url** must be no longer than 64 characters.
{% endhint %}

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 1000000000 \
    --pool-cost 170000000 \
    --pool-margin 0.20 \
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

{% hint style="warning" %}
minPoolCost is 170000000 lovelace or 170 ADA. Therefore, your `--pool-cost` must be at a minimum this amount.
{% endhint %}

{% hint style="info" %}
Here we are pledging 1000 ADA with a fixed pool cost of 170 ADA and a pool margin of 20%.
{% endhint %}

Copy **pool.cert** to your **hot environment.**

Pledge stake to your stake pool.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```
cardano-cli conway stake-address stake-delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
```
{% endtab %}
{% endtabs %}

Copy **deleg.cert** to your **hot environment.**

You need to find the tip of the blockchain to set the invalid-hereafter parameter properly.

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

Run the build-raw transaction command.

{% hint style="info" %}
The **invalid-hereafter** value must be greater than the current tip. In this example, we use current slot + 10000.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
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

Calculate your change output.

{% tabs %}
{% tab title="block producer node" %}
```bash
txOut=$((${total_balance}-${fee}))
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

Some changes only take effect in two epochs. After the next epoch transition, verify that your pool settings are correct.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway query ledger-state --mainnet > ledger-state.json
sudo systemctl stop cardano-node.service
jq -r '.stateBefore.esLState.delegationState.pstate.stakePoolParams."'"$(cat stakepoolid.txt)"'" // empty' ledger-state.json
sudo systemctl start cardano-node.service
```
{% endtab %}
{% endtabs %}

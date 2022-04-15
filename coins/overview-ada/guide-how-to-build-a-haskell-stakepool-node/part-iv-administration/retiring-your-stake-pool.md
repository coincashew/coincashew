# Retiring Your Stake Pool

<!-- Reference:
https://cardano-foundation.gitbook.io/stake-pool-course/stake-pool-guide/stake-pool/retire_stakepool -->

If you no longer want to operate your stake pool, then you can deregister the pool. Deregistering the pool retires the pool.

{% hint style="info" %}
To retire your stake pool, your stake pool does NOT require valid KES keys. However, you must ensure that your nodes are fully synchronized with the blockchain.
{% endhint %}
<!--Reference:
https://forum.cardano.org/t/kes-key-expired/98936 -->

**To retire your stake pool:**

First, generate the protocol-parameters.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query protocol-parameters \
    --mainnet \
    --out-file $NODE_HOME/params.json
```
{% endtab %}
{% endtabs %}

Calculate the current epoch.

{% tabs %}
{% tab title="block producer node" %}
```bash
startTimeGenesis=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r .systemStart)
startTimeSec=$(date --date=${startTimeGenesis} +%s)
currentTimeSec=$(date -u +%s)
epochLength=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r .epochLength)
epoch=$(( (${currentTimeSec}-${startTimeSec}) / ${epochLength} ))
echo current epoch: ${epoch}
```
{% endtab %}
{% endtabs %}

Find the earliest and latest retirement epoch that your pool can retire.

{% tabs %}
{% tab title="block producer node" %}
```bash
poolRetireMaxEpoch=$(cat $NODE_HOME/params.json | jq -r '.poolRetireMaxEpoch')
echo poolRetireMaxEpoch: ${poolRetireMaxEpoch}

minRetirementEpoch=$(( ${epoch} + 1 ))
maxRetirementEpoch=$(( ${epoch} + ${poolRetireMaxEpoch} ))

echo earliest epoch for retirement is: ${minRetirementEpoch}
echo latest epoch for retirement is: ${maxRetirementEpoch}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
:construction: **Example**: if we are in epoch 39 and poolRetireMaxEpoch is 18,

* the earliest epoch for retirement is 40 ( current epoch + 1).
* the latest epoch for retirement is 57 ( poolRetireMaxEpoch + current epoch).

Let's presume that you want to retire as soon as possible, in epoch 40.
{% endhint %}

Create the deregistration certificate and save it as `pool.dereg.` Update the epoch to your desired retirement epoch, usually the earliest epoch or asap.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-pool deregistration-certificate \
--cold-verification-key-file $HOME/cold-keys/node.vkey \
--epoch <retirementEpoch> \
--out-file pool.dereg
```
{% endtab %}
{% endtabs %}

Copy **pool.dereg** to your **hot environment.**

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

Find the **tip** of the blockchain to set the **invalid-here** after parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Run the build-raw transaction command.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.dereg \
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
    --witness-count 2 \
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
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.dereg \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment.**

Sign the transaction.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
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

{% hint style="success" %}
Pool will retire at the end of your specified epoch. In this example, retirement occurs at the end of epoch 40.

If you have a change of heart, you can create and submit a new registration certificate before the end of epoch 40, which will then overrule the deregistration certificate.
{% endhint %}

After the retirement epoch, you can verify that the pool was successfully retired with the following query which should return an empty result.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query ledger-state --mainnet > ledger-state.json
jq -r '.esLState._delegationState._pstate._pParams."'"$(cat stakepoolid.txt)"'"  // empty' ledger-state.json
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
In two epochs, after retirement completes:

1. Verify that your pool is retired using a block explorer such as [cardanoscan.io](https://cardanoscan.io)
2. Your pool deposit of 500 ADA is returned to your stake address (stake.addr) as a reward.
3. [Claim](../part-iv-administration/claiming-stake-pool-rewards.md) your stake pool rewards.
4. As needed, [send](../part-v-tips/submitting-a-simple-transaction.md) funds to another wallet.
{% endhint %}

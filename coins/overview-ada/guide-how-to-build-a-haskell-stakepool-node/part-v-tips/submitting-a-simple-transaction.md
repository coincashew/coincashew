# :money\_with\_wings: Submitting a Simple Transaction

Let's walk through an example to send **10 ADA** to **CoinCashew's tip address** :upside\_down:&#x20;

{% hint style="info" %}
The minimum amount, or smallest UTXO, you can send in one transaction is 1 ADA.
{% endhint %}

First, find the **tip **of the blockchain to set the **invalid-hereafter **parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Set the amount to send in lovelaces. :sparkles: Remember **1 ADA** = **1,000,000 lovelaces.**

{% tabs %}
{% tab title="block producer node" %}
```bash
amountToSend=10000000
echo amountToSend: $amountToSend
```
{% endtab %}
{% endtabs %}

Set the destination address which is where you're sending funds to.

{% tabs %}
{% tab title="block producer node" %}
```bash
destinationAddress=addr1qxhazv2dp8yvqwyxxlt7n7ufwhw582uqtcn9llqak736ptfyf8d2zwjceymcq6l5gxht0nx9zwazvtvnn22sl84tgkyq7guw7q
echo destinationAddress: $destinationAddress
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

Run the build-raw transaction command.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --tx-out ${destinationAddress}+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

Calculate the current minimum fee:

{% tabs %}
{% tab title="block producer node" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 2 \
    --mainnet \
    --witness-count 1 \
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
txOut=$((${total_balance}-${fee}-${amountToSend}))
echo Change Output: ${txOut}
```
{% endtab %}
{% endtabs %}

Build your transaction.&#x20;

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --tx-out ${destinationAddress}+${amountToSend} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment.**

Sign the transaction with the payment secret key.&#x20;

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

Copy **tx.signed** to your **hot environment.**

Send the signed transaction.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

Check if the funds arrived.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query utxo \
    --address ${destinationAddress} \
    --mainnet
```
{% endtab %}
{% endtabs %}

You should see output similar to this showing the funds you sent.

```
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        10000000
```

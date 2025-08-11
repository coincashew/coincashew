# Submitting a Simple Transaction

Let's walk through an example to send **10 ADA** to **CoinCashew's tip address** :upside\_down:

{% hint style="info" %}
The minimum amount, or smallest UTXO, you can send in one transaction is 1 ADA.
{% endhint %}

First, find the **tip** of the blockchain to set the **invalid-hereafter** parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli conway query tip --mainnet | jq -r '.slot')
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

Retrieve the UTXOs available for your payment address and calculate the balance.

{% tabs %}
{% tab title="block producer node" %}
```bash
# Retrieve the list of UTXOs available for your payment address
utxo_json=$(cardano-cli conway query utxo --address $(cat payment.addr) --mainnet)

# Initialize variables
tx_in=""
total_balance=0
txcnt=0

# Loop through the list of UTXOs
while read -r utxo; do
    # Retrieve the values for the current UTXO
    values=$(jq -r --arg k "${utxo}" '.[$k]' <<< "${utxo_json}")
    # Retrieve datum associated with the UTXO
    datum=$(jq -r '.datum' <<< "${values}")
    # Retrieve the reference script associated with the UTXO
    script=$(jq -r '.referenceScript' <<< "${values}")
	# If limits on spending the UTXO may exist, then skip the UTXO
    if [[ ${datum} == 'null' && ${script} == 'null' ]]
    then
        hash=${utxo%%#*}
        idx=${utxo#*#}
        utxo_balance=$(jq -r '.value.lovelace' <<< "${values}")
        total_balance=$((${total_balance}+${utxo_balance}))
        echo "TxHash: ${hash}#${idx}"
        echo "ADA: ${utxo_balance}"
        tx_in="${tx_in} --tx-in ${hash}#${idx}"
		txcnt=$((txcnt + 1))
    fi
done <<< "$(jq -r 'keys[]' <<< "${utxo_json}")"

echo
echo "Total available ADA balance: ${total_balance}"
echo "Number of UTXOs: ${txcnt}"
echo "Final --tx-in string:${tx_in}"
```
{% endtab %}
{% endtabs %}

Run the build-raw transaction command.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${amountToSend} )) \
    --tx-out ${destinationAddress}+${amountToSend} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee 200000 \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

Calculate the current minimum fee:

{% tabs %}
{% tab title="block producer node" %}
```bash
fee=$(cardano-cli conway transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 2 \
    --mainnet \
    --witness-count 1 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | jq -r '.fee')
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

Build your transaction.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --tx-out ${destinationAddress}+${amountToSend} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee ${fee} \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment.**

Sign the transaction with the payment secret key.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway transaction sign \
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
cardano-cli conway transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

Check if the funds arrived.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway query utxo \
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

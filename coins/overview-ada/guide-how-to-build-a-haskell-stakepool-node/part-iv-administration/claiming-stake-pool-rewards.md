# Claiming Stake Pool Rewards

Let's walk through an example to claim your stake pools rewards.

{% hint style="info" %}
Rewards are accumulated in the `stake.addr` address.
{% endhint %}

First, you need to ensure that your `stake.addr` is [delegating to a representative](../part-iv-administration/delegating-to-a-representative.md).

Second, find the **tip** of the blockchain to set the **invalid-hereafter** parameter properly.

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
rewardBalance=$(cardano-cli conway query stake-address-info \
    --mainnet \
    --address $(cat stake.addr) | jq -r ".[0].rewardAccountBalance")
echo rewardBalance: $rewardBalance
```
{% endtab %}
{% endtabs %}

Set the destination address which is where you're moving your reward to. This address must have a positive balance to pay for transaction fees.

{% tabs %}
{% tab title="block producer node" %}
```bash
destinationAddress=$(cat payment.addr)
echo destinationAddress: $destinationAddress
```
{% endtab %}
{% endtabs %}

Retrieve the UTXOs available for your payment address, calculate the balance and build the withdrawal string.

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

withdrawalString="$(cat stake.addr)+${rewardBalance}"
```
{% endtab %}
{% endtabs %}

Run the build-raw transaction command.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} + ${rewardBalance} )) \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee 200000 \
    --withdrawal ${withdrawalString} \
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
txOut=$((${total_balance}-${fee}+${rewardBalance}))
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
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee ${fee} \
    --withdrawal ${withdrawalString} \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment.**

Sign the transaction with both the payment and stake secret keys.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
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

You should see output similar to this showing your updated Lovelace balance with rewards.

```
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....  
```

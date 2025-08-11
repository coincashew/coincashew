# Registering Your Stake Address

Pledge is the stake that you delegate to your own pool. Using a transaction, you must register on the blockchain the stake address associated with a payment address containing funds that you want to pledge.
<!-- References:
https://youtu.be/PCqvFMTGu3o 
https://developers.cardano.org/docs/operate-a-stake-pool/cardano-key-pairs -->

{% hint style="info" %}
For a general discussion on creating transactions, see the topic [Building and Signing Transactions](http://web.archive.org/web/20211025133818/https://testnets.cardano.org/en/testnets/cardano/transactions/creating-transactions/).
{% endhint %}

**To register a stake address on the blockchain:**

Create a certificate, `stake.cert`, using the `stake.vkey`

{% tabs %}
{% tab title="air-gapped offline machine" %}
```
cardano-cli conway stake-address registration-certificate \
    --stake-verification-key-file stake.vkey \
	--key-reg-deposit-amt 2000000 \
    --out-file stake.cert
```
{% endtab %}
{% endtabs %}

Copy **stake.cert** to your **hot environment.**

You need to find the **tip** of the blockchain to set the **invalid-hereafter** parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli conway query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
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

Find the amount of the deposit required to register a stake address.

{% tabs %}
{% tab title="block producer node" %}
```bash
stakeAddressDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakeAddressDeposit')
echo stakeAddressDeposit : ${stakeAddressDeposit}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Registering a stake address requires a deposit of 2000000 lovelace.
{% endhint %}

Run the build-raw transaction command

{% hint style="info" %}
The **invalid-hereafter** value must be greater than the current tip. In this example, we use current slot + 10000.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${stakeAddressDeposit} )) \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee 200000 \
    --out-file tx.tmp \
    --certificate stake.cert
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

{% hint style="info" %}
When calculating the fee for a transaction, the `--witness-count` option indicates the number of keys signing the transaction. You must sign a transaction submitting a stake address registration certificate to the blockchain using the secret—private—key for the payment address spending the input, as well as the secret key for the stake address to register.
{% endhint %}

{% hint style="info" %}
When creating the transaction, ensure that the funds the input contains are greater than the total of the transaction fee and stake address deposit. If funds are insufficient, then the transaction fails.
{% endhint %}

Calculate your change output.

{% tabs %}
{% tab title="block producer node" %}
```bash
txOut=$((${total_balance}-${stakeAddressDeposit}-${fee}))
echo Change Output: ${txOut}
```
{% endtab %}
{% endtabs %}

Build your transaction which will register your stake address.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee ${fee} \
    --certificate-file stake.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment**.

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

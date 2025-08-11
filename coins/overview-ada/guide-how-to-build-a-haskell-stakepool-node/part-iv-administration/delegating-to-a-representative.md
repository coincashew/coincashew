# Delegating to a Representative

In the Cardano ecosystem, Delegated Representatives (DReps) work to coordinate resources on behalf of ADA holders who delegate power to vote on governance actions.

{% hint style="info" %}
For more information on Cardano governance, visit [1694.IO](https://www.1694.io/en) or [GOV TOOL](https://gov.tools/)
{% endhint %}

Delegating to a representative involves generating a vote delegation certificate reflecting your delegation, and then submitting the certificate to the blockchain.

You can delegate your voting power to:

* **Registered DReps**—Members of the Cardano community who receive the delegation of voting power for voting on governance actions.
* **Always Abstain**—Opt out of the governance process.
* **Always Vote No Confidence**—Vote `No` on every proposal.
<!-- Source: https://cardanospot.io/news/participating-in-cardano-governance-0 -->

{% hint style="info" %}
Thanks to [Latin Stake Pools](https://latinstakepools.com/) :clap:
{% endhint %}

<!-- The following procedure is based on the procedure in the Registering Your Stake Address topic -->
**To delegate voting power:**

Create a certificate, `vote-deleg.cert`, using the `stake.vkey`

{% tabs %}
{% tab title="air-gapped offline machine" %}
To delegate your voting power to a DRep, type the following command where `<DRepID>` is the ID of the DRep receiving your delegation:

```
cardano-cli conway stake-address vote-delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --drep-key-hash <DRepID> \
    --out-file vote-deleg.cert
```

<center><b>OR</b></center>

To opt out of the governance process, type:

```
cardano-cli conway stake-address vote-delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --always-abstain \
    --out-file vote-deleg.cert
```

<center><b>OR</b></center>

To vote `No` on every proposal, type:

```
cardano-cli conway stake-address vote-delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --always-no-confidence \
    --out-file vote-deleg.cert
```
{% endtab %}
{% endtabs %}

Copy **vote-deleg.cert** to your **hot environment.**

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

Run the build-raw transaction command:

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
    --out-file tx.tmp \
    --certificate vote-deleg.cert
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
When calculating the fee for a transaction, the `--witness-count` option indicates the number of keys signing the transaction. You must sign a transaction submitting a vote delegation certificate to the blockchain using the secret—private—key for the payment address spending the input, as well as the secret key for the stake address delegating voting power.
{% endhint %}

Calculate your change output:

{% tabs %}
{% tab title="block producer node" %}
```bash
txOut=$((${total_balance}-${fee}))
echo Change Output: ${txOut}
```
{% endtab %}
{% endtabs %}

Build your transaction to delegate voting power:

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee ${fee} \
    --certificate-file vote-deleg.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment**.

Sign the transaction with both the payment and stake secret keys:

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

Send the signed transaction:

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}
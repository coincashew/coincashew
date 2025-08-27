# Retiring Your Stake Pool

If you no longer want to operate your stake pool, then you can deregister the pool. Deregistering the pool retires the pool.

{% hint style="info" %}
To retire your stake pool, your stake pool does NOT require valid KES keys. However, you must ensure that your nodes are fully synchronized with the blockchain.
{% endhint %}

**To retire your stake pool:**

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

Calculate the current epoch.

{% tabs %}
{% tab title="block producer node" %}
```bash
startTimeGenesis=$(cat $NODE_HOME/shelley-genesis.json | jq -r .systemStart)
startTimeSec=$(date --date=${startTimeGenesis} +%s)
currentTimeSec=$(date -u +%s)
epochLength=$(cat $NODE_HOME/shelley-genesis.json | jq -r .epochLength)
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
cardano-cli conway stake-pool deregistration-certificate \
--cold-verification-key-file $HOME/cold-keys/node.vkey \
--epoch <retirementEpoch> \
--out-file pool.dereg
```
{% endtab %}
{% endtabs %}

Copy **pool.dereg** to your **hot environment.**

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

Find the **tip** of the blockchain to set the **invalid-here** after parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli conway query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Run the build-raw transaction command.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee 200000 \
    --certificate-file pool.dereg \
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
    --witness-count 2 \
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
cardano-cli conway transaction sign \
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
cardano-cli conway transaction submit \
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
cardano-cli conway query ledger-state --mainnet > ledger-state.json
sudo systemctl stop cardano-node.service
jq -r '.stateBefore.esLState.delegationState.pstate.stakePoolParams."'"$(cat stakepoolid.txt)"'" // empty' ledger-state.json
sudo systemctl start cardano-node.service
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
In two epochs, after retirement completes:

1. Verify that your pool is retired using a block explorer such as [cardanoscan.io](https://cardanoscan.io)
2. Your pool deposit of 500 ADA is returned to your stake address (stake.addr) as a reward.
3. [Claim](claiming-stake-pool-rewards.md) your stake pool rewards.
4. As needed, [send](../part-v-tips/submitting-a-simple-transaction.md) funds to another wallet.
5. Optionally, de-register the stake key to re-claim your 2 ADA stake deposit.
{% endhint %}

{% hint style="danger" %}
Important:

* Do NOT de-register your stake key before your pool deposit of 500ADA is paid back to your rewards address. Nonreturnable pool deposits are sent to the Cardano treasury.
* If there are multiple pool owners, communicate your intention to retire the pool and ensure they do not remove pledge funds until the pool is retired.
* As a courtesy to your delegators, provide advanced notice of your intention to retire so that they may re-delegate their stake.
{% endhint %}

#### References

* [https://cardano-foundation.gitbook.io/stake-pool-course/stake-pool-guide/stake-pool/retire\_stakepool](https://cardano-foundation.gitbook.io/stake-pool-course/stake-pool-guide/stake-pool/retire\_stakepoolhttps:/forum.cardano.org/t/kes-key-expired/98936)
* [https://forum.cardano.org/t/kes-key-expired/98936](https://cardano-foundation.gitbook.io/stake-pool-course/stake-pool-guide/stake-pool/retire\_stakepoolhttps:/forum.cardano.org/t/kes-key-expired/98936)

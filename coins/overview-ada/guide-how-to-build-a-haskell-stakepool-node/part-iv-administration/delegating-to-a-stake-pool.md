# Delegating to a Stake Pool

## :white\_check\_mark: Prerequisites

* Both a payment and a stake key pair. Payment key should contain some ADA.

## :woman\_technologist: Registering Your Stake Address

Create a certificate, `stake.cert`, using the `stake.vkey`

```
cardano-cli conway stake-address registration-certificate \
    --stake-verification-key-file stake.vkey \
	--key-reg-deposit-amt 2000000 \
    --out-file stake.cert
```

You need to find the slot tip of the blockchain.

```
currentSlot=$(cardano-cli conway query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```

Find your balance and **UTXOs**.

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

Find the stakeAddressDeposit value.

```
stakeAddressDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakeAddressDeposit')
echo stakeAddressDeposit : $stakeAddressDeposit
```

{% hint style="info" %}
Registration of a stake address certificate (stakeAddressDeposit) costs 2000000 lovelace.
{% endhint %}

Run the build-raw transaction command

{% hint style="info" %}
The **invalid-hereafter** value must be greater than the current tip. In this example, we use current slot + 10000.
{% endhint %}

```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${stakeAddressDeposit} )) \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee 200000 \
    --out-file tx.tmp \
    --certificate stake.cert
```

Calculate the current minimum fee:

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

{% hint style="info" %}
Ensure your balance is greater than cost of fee + stakeAddressDeposit or this will not work.
{% endhint %}

Calculate your change output.

```bash
txOut=$((${total_balance}-${stakeAddressDeposit}-${fee}))
echo Change Output: ${txOut}
```

Build your transaction which will register your stake address.

```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee ${fee} \
    --certificate-file stake.cert \
    --out-file tx.raw
```

Sign the transaction with both the payment and stake secret keys.

```
cardano-cli conway transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```

Send the signed transaction.

```bash
cardano-cli conway transaction submit \
    --tx-file tx.signed \
    --mainnet
```

## :page\_facing\_up: Creating a Delegation Certificate

Given its **stake pool verification key file** `node.vkey` , from your stakepool should have generated (and published) a **stake pool ID**:

```
cardano-cli conway stake-pool id \
    --cold-verification-key-file node.vkey \
    --output-format 'hex'
```

Given the **stake pool ID** from your stakepool, run the following:

```bash
cardano-cli conway stake-address stake-delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --stake-pool-id <stake pool ID> \
    --out-file deleg.cert
```

You need to find the tip of the blockchain to set the ttl parameter properly.

```
currentSlot=$(cardano-cli conway query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```

Find your balance and **UTXOs**.

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

Run the build-raw transaction command.

```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee 200000 \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```

Calculate the minimum fee:

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

Calculate your change output.

```bash
txOut=$((${total_balance}-${fee}))
echo txOut: ${txOut}
```

Build the transaction.

```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee ${fee} \
    --certificate-file deleg.cert \
    --out-file tx.raw
```

Sign the transaction.

```bash
cardano-cli conway transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```

Send the transaction.

```
cardano-cli conway transaction submit \
    --tx-file tx.signed \
    --mainnet
```

{% hint style="success" %}
Congratulations! Your ADA is now successfully delegated to your chosen stakepool.
{% endhint %}

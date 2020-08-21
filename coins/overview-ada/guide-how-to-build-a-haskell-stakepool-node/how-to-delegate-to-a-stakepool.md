# How to delegate to a Stakepool

## ✅ 0. Prerequisites

* Both a payment and a stake key pair. Payment key should contain some ADA.

## 👩💻 1. Register Stake Address

Create a certificate, `stake.cert`, using the `stake.vkey`

```text
cardano-cli shelley stake-address registration-certificate \
    --stake-verification-key-file stake.vkey \
    --out-file stake.cert
```

You need to find the **slot tip** of the blockchain.

```
currentSlot=$(cardano-cli shelley query tip --testnet-magic 42 | jq -r '.slotNo')
echo Current Slot: $currentSlot
```

Find your balance and **UTXOs**.

```text
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 42 \
    --cardano-mode > fullUtxo.out

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

Find the keyDeposit value.

```text
keyDeposit=$(cat $NODE_HOME/params.json | jq -r '.keyDeposit')
echo keyDeposit: $keyDeposit
```

{% hint style="info" %}
Registration of a stake address certificate \(keyDeposit\) costs 2000000 lovelace.
{% endhint %}

Run the build-raw transaction command

{% hint style="info" %}
The **ttl** value must be greater than the current tip. In this example, we use current slot + 10000.
{% endhint %}

```text
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp \
    --certificate stake.cert
```

Calculate the current minimum fee:

```text
fee=$(cardano-cli shelley transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --testnet-magic 42 \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```

{% hint style="info" %}
Ensure your balance is greater than cost of fee + keyDeposit or this will not work.
{% endhint %}

Calculate your change output.

```text
txOut=$((${total_balance}-${keyDeposit}-${fee}))
echo Change Output: ${txOut}
```

Build your transaction which will register your stake address.

```text
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file stake.cert \
    --out-file tx.raw
```

Sign the transaction with both the payment and stake secret keys.

```text
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --testnet-magic 42 \
    --out-file tx.signed
```

Send the signed transaction.

```text
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --testnet-magic 42 \
    --cardano-mode
```

## 📄 2. Create a delegation certificate

Given the **stake pool verification key file** `node.vkey` from your stakepool, run the following:

```text
cardano-cli shelley stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --stake-pool-verification-key-file node.vkey \
    --out-file deleg.cert
```

You need to find the **tip** of the blockchain to set the **ttl** parameter properly.

```
currentSlot=$(cardano-cli shelley query tip --testnet-magic 42 | jq -r '.slotNo')
echo Current Slot: $currentSlot
```

Find your balance and **UTXOs**.

```text
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 42 \
    --cardano-mode > fullUtxo.out

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

Run the build-raw transaction command.

```text
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```

Calculate the minimum fee:

```text
fee=$(cardano-cli shelley transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --testnet-magic 42 \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```

Calculate your change output.

```text
txOut=$((${total_balance}-${fee}))
echo txOut: ${txOut}
```

Build the transaction.

```text
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file deleg.cert \
    --out-file tx.raw
```

Sign the transaction.

```text
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --testnet-magic 42 \
    --out-file tx.signed
```

Send the transaction.

```text
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --testnet-magic 42 \
    --cardano-mode
```

{% hint style="success" %}
Congratulations! Your ADA is now successfully delegated to your chosen stakepool.
{% endhint %}


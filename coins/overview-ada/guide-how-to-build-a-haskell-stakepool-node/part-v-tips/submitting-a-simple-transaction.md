# Submitting a Simple Transaction

The following procedures send 10 ADA to the CoinCashew tip address. :upside\_down:

{% hint style="info" %}
The minimum amount—the smallest Unspent Transaction Output (UTXO)—that you can send in a transaction is 1 ADA
{% endhint %}

**To prepare for submitting the transaction:**

1. On the computer hosting your block-producing node, to create and navigate to a folder where you want to save files for the transaction, type the following commands using a terminal window, where `<TransactionFolder>` is the path to the folder:
```bash
mkdir <TransactionFolder>
cd <TransactionFolder>
```

2. To find the tip of the blockchain, type the following commands using a terminal window:
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% hint style="info" %}
You need to know the tip of the blockchain to set the `invalid-hereafter` option for the transaction.
{% endhint %}

3. To set the amount that the transaction spends in Lovelace:sparkles:, type:
```bash
amountToSend=10000000
echo amountToSend: $amountToSend
```
{% hint style="info" %}
1 ADA is comprised of 1,000,000 Lovelace
{% endhint %}

3. To set the address receiving Lovelace in the transaction, type:
```bash
destinationAddress=addr1qxhazv2dp8yvqwyxxlt7n7ufwhw582uqtcn9llqak736ptfyf8d2zwjceymcq6l5gxht0nx9zwazvtvnn22sl84tgkyq7guw7q
echo destinationAddress: $destinationAddress
```

4. To set the address sending Lovelace in the transaction, type the following commands where `<paymentAddress>` is the address sending Lovelace:
```bash
paymentAddress=<PaymentAddress>
echo paymentAddress: $paymentAddress
```

5. To display the balance and UTXOs for the account sending Lovelace in the transaction, type:
```bash
 cardano-cli query utxo \
     --address $paymentAddress \
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
  
 echo Total ADA balance: $total_balance  
  
 echo Number of UTXOs: $txcnt
```

You can calculate the transaction fee manually or automatically. If you want to calculate the transaction fee automatically, then skip to the [appropriate procedure](./submitting-a-simple-transaction.md#auto) below.

**To calculate the transaction fee manually:**

1. To retrieve protocol parameters for the transaction, type:
```bash
cardano-cli query protocol-parameters \
    --mainnet \
    --out-file params.json
```

2. To build the raw transaction, type:
```bash
cardano-cli transaction build-raw \
    $tx_in \
    --tx-out $paymentAddress+0 \
    --tx-out $destinationAddress+0 \
    --invalid-hereafter $(( $currentSlot + 10000)) \
    --fee 0 \
    --out-file tx.tmp
```

3. To calculate the transaction fee, type:
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count $txcnt \
    --tx-out-count 2 \
    --mainnet \
    --witness-count 1 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```

4. To calculate the amount of change for the transaction, type:
```bash
txOut=$(($total_balance-$fee-$amountToSend))
echo Change Output: $txOut
```

5. To build the transaction, type:
```bash
cardano-cli transaction build-raw \
    $tx_in \
    --tx-out $paymentAddress+$txOut \
    --tx-out $destinationAddress+$amountToSend \
    --invalid-hereafter $(( $currentSlot + 10000)) \
    --fee $fee \
    --out-file tx.raw
```

Skip to the procedure to [sign and submit the transaction](./submitting-a-simple-transaction.md#submit).

<a name="auto"></a>**To calculate the transaction fee automatically:**

- To build the transaction, type:
```bash
cardano-cli transaction build \
    --mainnet \
    $tx_in \
	--tx-out $destinationAddress+$amountToSend \
    --change-address $paymentAddress \
    --invalid-hereafter $(( $currentSlot + 10000 )) \
    --out-file tx.raw
```

The `transaction build` command returns the estimated transaction fee, in Lovelace.

<!-- Reference:
https://forum.cardano.org/t/please-use-cardano-cli-transaction-build-instead-of-cardano-cli-transaction-build-raw/94919 -->

<a name="submit"></a>**To sign and submit the transaction:**

1. Copy the `tx.raw` file to your cold environment.

2. In your cold environment, type the following command using a terminal window to sign the transaction, where `<PaymentSKEY>` is the file path to the the secret key for your payment address:
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file <PaymentSKEY> \
    --mainnet \
    --out-file tx.signed
```

3. Copy the `tx.signed` file to the computer hosting your block-producing node.

4. To submit the signed transaction to the blockchain, type:
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% hint style="info" %}
If you submit the transaction successfully, then the `transaction submit` command displays `Transaction successfully submitted.`
{% endhint %}

5. To confirm that the funds arrived, type:
```bash
cardano-cli query utxo \
    --address $destinationAddress \
    --mainnet
```

Verify that the list of UTXOs includes a UTXO for your transaction. For example:

```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
100322a39d02c2ead....                                                0        10000000
```
# How to delegate to a Stakepool

## ✅ 0. Prerequisites

* Both a payment and a stake key pair. Payment key should contain some ADA.

## 👩💻 1. Register Stake Address

Create a certificate, `stake.cert`, using the `stake.vkey`

```text
cardano-cli shelley stake-address registration-certificate \
    --staking-verification-key-file stake.vkey \
    --out-file stake.cert
```

You need to find the **tip** of the blockchain to set the **ttl** parameter properly.

```
export CARDANO_NODE_SOCKET_PATH=~/cardano-my-node/db/socket
cardano-cli shelley query tip --testnet-magic 42 | grep -oP 'SlotNo = \K\d+'
```

Example **tip** output:

> `690000`

{% hint style="info" %}
You will want to set your **ttl** value greater than the current tip. In this example, we use 250000000. 
{% endhint %}

Calculate the current minimum fee:

```text
cardano-cli shelley transaction calculate-min-fee \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --ttl 250000000 \
    --testnet-magic 42 \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --certificate stake.cert \
    --protocol-params-file params.json
```

Example of **calculate-min-fee**:

> `runTxCalculateMinFee: 171309`

Build your transaction which will register your stake address.

```text
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 42
```

Example **utxo** output:

```text
                 TxHash                         Ix        Lovelace
--------------------------------------------------------------------
81acd93...                                        0      100000000000
```

{% hint style="info" %}
Notice the TxHash and Ix \(index\). Will use this data shortly.
{% endhint %}

Calculate your transaction's change

```text
expr 100000000000 - 400000 - 171309
```

Example **translocation change amount**:

> 99999428691

{% hint style="info" %}
Registration of a stake address certificate costs 400000 lovelace.
{% endhint %}

Run the build-raw transaction command

{% hint style="info" %}
Pay close attention to **tx-in**. The data should in the format`<TxHash>#<Ix number>`from above.
{% endhint %}

```text
cardano-cli shelley transaction build-raw \
    --tx-in <TxHash>#<Index number> \
    --tx-out $(cat payment.addr)+99999428691\
    --ttl 250000000 \
    --fee 171309 \
    --tx-body-file tx.raw \
    --certificate stake.cert
```

Sign the transaction with both the payment and stake secret keys.

```text
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --testnet-magic 42 \
    --tx-file tx.signed
```

Send the signed transaction.

```text
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --testnet-magic 42
```

## 📄 2. Create a delegation certificate

Given the **stake pool verification key file** `node.vkey` from your stakepool, run the following:

```text
cardano-cli shelley stake-address delegation-certificate \
    --staking-verification-key-file stake.vkey \
    --stake-pool-verification-key-file node.vkey \
    --out-file deleg.cert
```

Calculate the transaction fee.

```text
cardano-cli shelley transaction calculate-min-fee \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --ttl 250000000 \
    --testnet-magic 42 \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --certificate deleg.cert \
    --protocol-params-file params.json
```

Example of **calculate-min-fee**:

> `runTxCalculateMinFee: 172805`

Find your UTXO.

```text
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 42
```

> Sample Output:
>
> ```text
> TxHash                       TxIx        Lovelace
> --------------------------------------------------
> 32cd839...                       0       499243830
> ```

Calculate your change.

```text
expr 499243830 - 172805
```

Example of **change amount:**

> `> 499071025`

Build your transaction. Update `tx-in` with your `TxHash` and `TxIx`

```text
cardano-cli shelley transaction build-raw \
    --tx-in <TxHash>#<Index number> \
    --tx-out $(cat payment.addr)+499071025\
    --ttl 250000000 \
    --fee 172805 \
    --out-file tx.raw \
    --certificate deleg.cert
```

Sign your transaction.

```text
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --testnet-magic 42 \
    --tx-file tx.signed
```

Finally, submit your transaction.

```text
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --testnet-magic 42
```

{% hint style="success" %}
Congratulations! Your ADA is now successfully delegated to your chosen stakepool.
{% endhint %}


# Setting Up Payment and Stake Keys

First, obtain the protocol-parameters.

{% hint style="info" %}
Wait for the block-producing node to start syncing before continuing if you get this error message.

`cardano-cli: Network.Socket.connect: : does not exist (No such file or directory)`
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway query protocol-parameters \
    --mainnet \
    --out-file params.json
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Payment keys are used to send and receive payments and stake keys are used to manage stake delegations.
{% endhint %}

There are two ways to create your `payment` and `stake` key pair. Pick the one that best suits your needs.

{% hint style="danger" %}
:fire: **Critical Operational Security Advice:** `payment` and `stake` keys must be generated and used to build transactions in an cold environment. In other words, your **air-gapped offline machine**. Copy `cardano-cli` binary over to your offline machine and run the CLI method or mnemonic method. The only steps performed online in a hot environment are those steps that require live data. Namely the follow type of steps:

* querying the current slot tip
* querying the balance of an address
* submitting a transaction
{% endhint %}

{% tabs %}
{% tab title="CLI Method" %}
Create a new payment key pair: `payment.skey` & `payment.vkey`

```bash
###
### On air-gapped offline machine,
###
cd $NODE_HOME
cardano-cli conway address key-gen \
    --verification-key-file payment.vkey \
    --signing-key-file payment.skey
```

Create a new stake address key pair: `stake.skey` & `stake.vkey`

```bash
###
### On air-gapped offline machine,
###
cardano-cli conway stake-address key-gen \
    --verification-key-file stake.vkey \
    --signing-key-file stake.skey
```

Create your stake address from the stake address verification key and store it in `stake.addr`

```bash
###
### On air-gapped offline machine,
###
cardano-cli conway stake-address build \
    --stake-verification-key-file stake.vkey \
    --out-file stake.addr \
    --mainnet
```

Build a payment address for the payment key `payment.vkey` which will delegate to the stake address, `stake.vkey`

```bash
###
### On air-gapped offline machine,
###
cardano-cli conway address build \
    --payment-verification-key-file payment.vkey \
    --stake-verification-key-file stake.vkey \
    --out-file payment.addr \
    --mainnet
```
{% endtab %}

{% tab title="Mnemonic Method" %}
{% hint style="info" %}
Credits to [ilap](https://gist.github.com/ilap/3fd57e39520c90f084d25b0ef2b96894) for creating this process.
{% endhint %}

{% hint style="success" %}
**Benefits**: Track and control pool rewards from any wallet (Daedalus, Yoroi or any other wallet) that support stakings.
{% endhint %}

Create a 15-word or 24-word length shelley compatible mnemonic with [Daedalus](https://daedaluswallet.io) or [Yoroi](broken-reference) on a offline machine preferred.

Using your online block producer node, download `cardano-wallet`

```bash
###
### On block producer node,
###
cd $NODE_HOME
wget https://github.com/input-output-hk/cardano-wallet/releases/download/v2022-08-16/cardano-wallet-v2022-08-16-linux64.tar.gz
```



Transfer the **cardano-wallet** to your **air-gapped offline machine** via USB key or other removable media.

Extract the wallet files and cleanup.

```bash
###
### On air-gapped offline machine,
###
tar -xvf cardano-wallet-v2022-08-16-linux64.tar.gz
rm cardano-wallet-v2022-08-16-linux64.tar.gz
cd cardano-wallet-v2022-08-16-linux64
```

Create`extractPoolStakingKeys.sh` script.

```bash
###
### On air-gapped offline machine,
###
cat > extractPoolStakingKeys.sh << HERE
#!/bin/bash 

CADDR=\${CADDR:=\$( which cardano-address )}
[[ -z "\$CADDR" ]] && ( echo "cardano-address cannot be found, exiting..." >&2 ; exit 127 )

CCLI=\${CCLI:=\$( which cardano-cli )}
[[ -z "\$CCLI" ]] && ( echo "cardano-cli cannot be found, exiting..." >&2 ; exit 127 )

OUT_DIR="\$1"
[[ -e "\$OUT_DIR"  ]] && {
       	echo "The \"\$OUT_DIR\" is already exist delete and run again." >&2 
       	exit 127
} || mkdir -p "\$OUT_DIR" && pushd "\$OUT_DIR" >/dev/null

shift
MNEMONIC="\$*"

# Generate the master key from mnemonics and derive the stake account keys 
# as extended private and public keys (xpub, xprv)
echo "\$MNEMONIC" |\
"\$CADDR" key from-recovery-phrase Shelley > root.prv

cat root.prv |\
"\$CADDR" key child 1852H/1815H/0H/2/0 > stake.xprv

cat root.prv |\
"\$CADDR" key child 1852H/1815H/0H/0/0 > payment.xprv

TESTNET=0
MAINNET=1
NETWORK=\$MAINNET

cat payment.xprv |\
"\$CADDR" key public --with-chain-code | tee payment.xpub |\
"\$CADDR" address payment --network-tag \$NETWORK |\
"\$CADDR" address delegation \$(cat stake.xprv | "\$CADDR" key public --with-chain-code | tee stake.xpub) |\
tee base.addr_candidate |\
"\$CADDR" address inspect
echo "Generated from 1852H/1815H/0H/{0,2}/0"
cat base.addr_candidate
echo

# XPrv/XPub conversion to normal private and public key, keep in mind the 
# keypars are not a valid Ed25519 signing keypairs.
TESTNET_MAGIC="--testnet-magic 1097911063"
MAINNET_MAGIC="--mainnet"
MAGIC="\$MAINNET_MAGIC"

SESKEY=\$( cat stake.xprv | bech32 | cut -b -128 )\$( cat stake.xpub | bech32)
PESKEY=\$( cat payment.xprv | bech32 | cut -b -128 )\$( cat payment.xpub | bech32)

cat << EOF > stake.skey
{
    "type": "StakeExtendedSigningKeyShelley_ed25519_bip32",
    "description": "",
    "cborHex": "5880\$SESKEY"
}
EOF

cat << EOF > payment.skey
{
    "type": "PaymentExtendedSigningKeyShelley_ed25519_bip32",
    "description": "Payment Signing Key",
    "cborHex": "5880\$PESKEY"
}
EOF

"\$CCLI" key verification-key --signing-key-file stake.skey --verification-key-file stake.evkey
"\$CCLI" key verification-key --signing-key-file payment.skey --verification-key-file payment.evkey

"\$CCLI" key non-extended-key --extended-verification-key-file payment.evkey --verification-key-file payment.vkey
"\$CCLI" key non-extended-key --extended-verification-key-file stake.evkey --verification-key-file stake.vkey


"\$CCLI" stake-address build --stake-verification-key-file stake.vkey \$MAGIC > stake.addr
"\$CCLI" address build --payment-verification-key-file payment.vkey \$MAGIC > payment.addr
"\$CCLI" address build \
    --payment-verification-key-file payment.vkey \
    --stake-verification-key-file stake.vkey \
    \$MAGIC > base.addr

echo "Important the base.addr and the base.addr_candidate must be the same"
diff base.addr base.addr_candidate
popd >/dev/null
HERE
```

Add permissions and export PATH to use the binaries.

```bash
###
### On air-gapped offline machine,
###
chmod +x extractPoolStakingKeys.sh
export PATH=$PATH:$(pwd)
```

Extract your keys. Update the command with your mnemonic phrase.

```bash
###
### On air-gapped offline machine,
###
./extractPoolStakingKeys.sh extractedPoolKeys/ <15|24-word length mnemonic>
```

{% hint style="danger" %}
**Important**: The **base.addr** and the **base.addr\_candidate** must be the same. Review the screen output.
{% endhint %}

Your new staking keys are in the folder `extractedPoolKeys/`

Now move `payment/stake` key pair over to your `$NODE_HOME` for use with your stake pool.

```bash
###
### On air-gapped offline machine,
###
cd extractedPoolKeys/
cp stake.vkey stake.skey stake.addr payment.vkey payment.skey base.addr $NODE_HOME
cd $NODE_HOME
#Rename to base.addr file to payment.addr
mv base.addr payment.addr
```

{% hint style="info" %}
**payment.addr**, or also known as base.addr from this extraction script, will be the cardano address which holds your pool's pledge.
{% endhint %}

Clear the bash history in order to protect your mnemonic phrase and remove the `cardano-wallet` files.

```bash
###
### On air-gapped offline machine,
###
history -c && history -w
```

Finally close all your terminal windows and open new ones with zero history.

{% hint style="success" %}
Awesome. Now you can track your pool rewards in your wallet.
{% endhint %}
{% endtab %}
{% endtabs %}

Next step is to fund your payment address.

Copy **payment.addr** to your **hot environment**.

Payment address can be funded from your Daedalus / Yoroi wallet.

Run the following to find your payment address.

```bash
cat payment.addr
```

After funding your account, check your payment address balance.

{% hint style="danger" %}
Before continuing, your nodes must be fully synchronized to the blockchain. Otherwise, you won't see your funds.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway query utxo \
    --address $(cat payment.addr) \
    --mainnet
```
{% endtab %}
{% endtabs %}

You should see output similar to this. This is your unspent transaction output (UXTO).

```
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        1000000000
```

{% hint style="danger" %}
:fire: **Critical Backup Advice:** Make redundant copies of your **payment and staking keys** on offline USB keys or other offline data backups. Have a recovery plan in case of corrupted or lost keys.
{% endhint %}

{% hint style="info" %}
Named after the English mathematician and writer Ada Lovelace, the sub-unit of ADA is the Lovelace. 1 ADA is comprised of 1,000,000 Lovelace.
{% endhint %}


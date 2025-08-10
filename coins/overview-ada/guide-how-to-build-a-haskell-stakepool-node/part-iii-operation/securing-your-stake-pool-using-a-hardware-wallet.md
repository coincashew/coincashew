# Securing Your Stake Pool Using a Hardware Wallet

You can secure your **pool pledge account** and **pool reward account** using a [Trezor](https://trezor.io/) or [Ledger Nano S/X](https://www.ledger.com/) hardware wallet. Credits to [angelstakepool](https://github.com/angelstakepool/add-hw-wallet-owner-to-pool) for documenting the procedure.

{% hint style="danger" %}
**Critical Reminder**: After adding a 2nd pool owner using a hardware wallet, you **must wait 2 epochs** before you transfer pledge funds from your **CLI Method** or **Mnemonic Method** wallet to hardware wallet. Do not transfer any funds earlier because your pool pledge will not be met.
{% endhint %}

First, delegate your 2nd pool owner to your stake pool with Daedalus or Yoroi or Adalite.io

Install [cardano-hw-cli](https://github.com/vacuumlabs/cardano-hw-cli) to interact with your hardware wallet.

{% tabs %}
{% tab title="local PC or block producer node" %}
```bash
# Hardware Wallet works with Trezor and Ledger Nano S/X
# Reference https://github.com/vacuumlabs/cardano-hw-cli/blob/develop/docs/installation.md

cd $NODE_HOME
wget https://github.com/vacuumlabs/cardano-hw-cli/releases/download/v1.13.0/cardano-hw-cli_1.13.0-1.deb
sudo dpkg --install ./cardano-hw-cli_1.13.0-1.deb
```
{% endtab %}
{% endtabs %}

Connect and unlock your hardware wallet on your local PC or block producer node.

To generate the verification key and hardware wallet signing file, type:

{% tabs %}
{% tab title="local PC or block producer node" %}
```bash
cardano-hw-cli address key-gen \
  --path 1852H/1815H/0H/2/0 \
  --verification-key-file hw-stake.vkey \
  --hw-signing-file hw-stake.hwsfile
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
As needed, you can edit the value of the `--path` option to specify the derivation path to the key with which you want to sign. `hw-stake.vkey` is not sensitive and may be shared publicly. `hw-stake.hwsfile` does NOT contain the raw private key.
{% endhint %}
<!-- References:
https://githubhot.com/repo/vacuumlabs/cardano-hw-cli/issues/54
https://github.com/vacuumlabs/cardano-hw-cli -->

Copy **hw-stake.vkey** to your **cold environment.**

Update stake pool registration certificate to add your new hardware wallet owner, which will secure both your **pool pledge account** and **pool reward account**.

Tailor the below registration-certificate transaction with your pool's settings.

If you have **multiple relay nodes,** then [change your parameters accordingly](registering-your-stake-pool.md#multiplerelays).

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 1000000000 \
    --pool-cost 170000000 \
    --pool-margin 0.10 \
    --pool-reward-account-verification-key-file hw-stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file hw-stake.vkey \
    --mainnet \
    --single-host-pool-relay <dns based relay, example ~ relaynode1.pool.example.net> \
    --pool-relay-port 6000 \
    --metadata-url <url where you uploaded poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
:eyes: Notice the **pool-reward-account** and additional **pool-ownerstake-verification-key-file** lines point to **hw-stake.vkey**.

Example above is pledging 1000 ADA with a fixed pool cost of 170 ADA and a pool margin of 10%.
{% endhint %}

Copy **pool.cert** to your **hot environment.**

You need to find the **tip** of the blockchain to set the **invalid-hereafter** parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli conway query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Find your balance and **UTXOs**.

{% tabs %}
{% tab title="block producer node" %}
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
{% endtab %}
{% endtabs %}

Run the build-raw transaction command.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction build-raw \
    ${tx_in} \
    --mary-era \
    --tx-out $(cat payment.addr)+${total_balance} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee 200000 \
    --certificate-file pool.cert \
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
    --witness-count 4 \
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
    --mary-era \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000 )) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --out-file tx-pool.raw
```
{% endtab %}
{% endtabs %}

Copy **tx-pool.raw** to your **cold environment.**

This multi signature transaction will be signed using witnesses.

You need the following 4 witnesses.

* node.skey
* hw-stake.hwsfile
* stake.skey
* payment.skey

Create a witness using node.skey,

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli conway transaction witness \
  --tx-body-file tx-pool.raw \
  --signing-key-file $HOME/cold-keys/node.skey \
  --mainnet \
  --out-file node.witness
```
{% endtab %}
{% endtabs %}

Create a witness using stake.skey,

{% tabs %}
{% tab title="air-gapped offline machine" %}
```
cardano-cli conway transaction witness \
  --tx-body-file tx-pool.raw \
  --signing-key-file stake.skey \
  --mainnet \
  --out-file stake.witness
```
{% endtab %}
{% endtabs %}

Create a witness using payment.skey,

{% tabs %}
{% tab title="air-gapped offline machine" %}
```
cardano-cli conway transaction witness \
  --tx-body-file tx-pool.raw \
  --signing-key-file payment.skey \
  --mainnet \
  --out-file payment.witness
```
{% endtab %}
{% endtabs %}

Copy **tx-pool.raw** to local PC or block producer node, which is where your hardware wallet device is connected. Ensure your hardware wallet is unlocked and ready.

Create a witness using hw-stake.hwsfile

{% tabs %}
{% tab title="local PC or block producer node" %}
```
cardano-hw-cli transaction witness \
  --tx-file tx-pool.raw \
  --hw-signing-file hw-stake.hwsfile \
  --mainnet \
  --out-file hw-stake.witness
```
{% endtab %}
{% endtabs %}

Copy **hw-stake.witness** to your **cold environment.**

{% tabs %}
{% tab title="air-gapped offline machine" %}
```
cardano-cli conway transaction assemble \
  --tx-body-file tx-pool.raw \
  --witness-file node.witness \
  --witness-file stake.witness \
  --witness-file payment.witness \
  --witness-file hw-stake.witness \
  --out-file tx-pool.multisign
```
{% endtab %}
{% endtabs %}

Copy **tx-pool.multisign** to your **hot environment.**

Send the transaction.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli conway transaction submit \
    --tx-file tx-pool.multisign \
    --mainnet
```
{% endtab %}
{% endtabs %}

Check your updated pool information on [adapools.org](https://adapools.org) which should now show your hardware wallet as a pool owner.

{% hint style="danger" %}
**Important Reminder**:fire: These changes take effect in two epochs. Do **NOT** transfer pledge funds to your hardware wallet until at least two epochs later.
{% endhint %}

{% hint style="info" %}
After two epoch snapshots have passed, you can safely transfer pledge funds from your CLI Method or Mnemonic Method wallet to your new hardware wallet owner account. :rocket:
{% endhint %}

---
description: >-
  On Ubuntu/Debian, this guide will illustrate how to install and configure a
  Cardano stake pool from source code on a two node setup with 1 block producer
  node and 1 relay node.
---

# Guide: Setting Up a Cardano Stake Pool





## :lock\_with\_ink\_pen: 6. Configure the air-gapped offline machine

{% hint style="info" %}
An air-gapped offline machine is called your cold environment.&#x20;

* Protects against key-logging attacks, malware/virus based attacks and other firewall or security exploits.&#x20;
* Physically isolated from the rest of your network.&#x20;
* Must not have a network connection, wired or wireless.&#x20;
* Is not a VM on a machine with a network connection.
* Learn more about [air-gapping at wikipedia](https://en.wikipedia.org/wiki/Air\_gap\_\(networking\)).
{% endhint %}

{% hint style="info" %}
A note about **hardware requirements** for an air-gapped offline machine.

* Can be as basic as a Raspberry Pi or an upcycled older laptop/desktop.
* Uses an usb port to transport files back and forth.
{% endhint %}

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
echo export NODE_HOME=$HOME/cardano-my-node >> $HOME/.bashrc
source $HOME/.bashrc
mkdir -p $NODE_HOME
```
{% endtab %}
{% endtabs %}

Copy from your **hot environment**, also known as your block producer node, a copy of the **`cardano-cli` **to your **cold environment**, this air-gapped offline machine.&#x20;

Location of your cardano-cli.

```
/usr/local/bin/cardano-cli
```

{% hint style="danger" %}
In order to remain a true air-gapped environment, you must move files physically between your cold and hot environments with USB keys or other removable media.
{% endhint %}

After copying over to your cold environment, add execute permissions to the file.

```
sudo chmod +x /usr/local/bin/cardano-cli
```

## :robot: 7. Create startup scripts

The startup script contains all the variables needed to run a cardano-node such as directory, port, db path, config file, and topology file.

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
#!/bin/bash
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
/usr/local/bin/cardano-node run +RTS -N -A16m -qg -qb -RTS --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
cat > $NODE_HOME/startRelayNode1.sh << EOF 
#!/bin/bash
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
/usr/local/bin/cardano-node run +RTS -N -A16m -qg -qb -RTS --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```
{% endtab %}
{% endtabs %}

Add execute permissions to the startup script.

{% tabs %}
{% tab title="block producer node" %}
```bash
chmod +x $NODE_HOME/startBlockProducingNode.sh
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
chmod +x $NODE_HOME/startRelayNode1.sh 
```
{% endtab %}
{% endtabs %}

Run the following to create a **systemd unit file** to define your`cardano-node.service` configuration.

{% hint style="info" %}
#### :cake: Benefits of using systemd for your stake pool

1. Auto-start your stake pool when the computer reboots due to maintenance, power outage, etc.
2. Automatically restart crashed stake pool processes.
3. Maximize your stake pool up-time and performance.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > $NODE_HOME/cardano-node.service << EOF 
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service 

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = ${USER}
Type            = simple
WorkingDirectory= ${NODE_HOME}
ExecStart       = /bin/bash -c '${NODE_HOME}/startBlockProducingNode.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=300
LimitNOFILE=32768
Restart=always
RestartSec=5
SyslogIdentifier=cardano-node

[Install]
WantedBy	= multi-user.target
EOF
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
cat > $NODE_HOME/cardano-node.service << EOF 
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service 

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = ${USER}
Type            = simple
WorkingDirectory= ${NODE_HOME}
ExecStart       = /bin/bash -c '${NODE_HOME}/startRelayNode1.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=300
LimitNOFILE=32768
Restart=always
RestartSec=5
SyslogIdentifier=cardano-node

[Install]
WantedBy	= multi-user.target
EOF
```
{% endtab %}
{% endtabs %}

Move the unit file to `/etc/systemd/system` and give it permissions.

```bash
sudo mv $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
```

```bash
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

Run the following to enable auto-starting of your stake pool at boot time.

```
sudo systemctl daemon-reload
sudo systemctl enable cardano-node
```

{% hint style="success" %}
Your stake pool is now managed by the reliability and robustness of systemd. Below are some commands for using systemd.
{% endhint %}

#### :mag\_right: View the status of the node service

```
sudo systemctl status cardano-node
```

#### :arrows\_counterclockwise: Restarting the node service

```
sudo systemctl reload-or-restart cardano-node
```

#### :octagonal\_sign: Stopping the node service

```
sudo systemctl stop cardano-node
```

#### 🗄 Viewing and filter logs

```bash
journalctl --unit=cardano-node --follow
```

```bash
journalctl --unit=cardano-node --since=yesterday
```

```
journalctl --unit=cardano-node --since=today
```

```
journalctl --unit=cardano-node --since='2020-07-29 00:00:00' --until='2020-07-29 12:00:00'
```

## :white\_check\_mark: 8. Start the nodes

Start your stake pool with systemctl and begin syncing the blockchain!

{% tabs %}
{% tab title="block producer node" %}
```bash
sudo systemctl start cardano-node
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
sudo systemctl start cardano-node
```
{% endtab %}
{% endtabs %}

Install gLiveView, a monitoring tool.

{% hint style="info" %}
gLiveView displays crucial node status information and works well with systemd services. Credits to the [Guild Operators](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview) for creating this tool.
{% endhint %}

```bash
cd $NODE_HOME
sudo apt install bc tcptraceroute -y
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh
```

Run the following to modify **env** with the updated file locations.

```bash
sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```

{% hint style="warning" %}
A node must reach epoch 208 (Shelley launch) before **gLiveView.sh** can start tracking the node syncing. You can track the node syncing using `journalctl `before epoch 208.

```
journalctl --unit=cardano-node --follow
```
{% endhint %}

Run gLiveView to monitor the progress of the sync'ing of the blockchain.

```
./gLiveView.sh
```

Sample output of gLiveView.

![](../../../.gitbook/assets/glive-update2.jpg)

For more information, refer to the [official Guild Live View docs.](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview)

{% hint style="info" %}
****:sparkles: **Pro tip**: If you synchronize a node's database, you can copy the database directory over to your other node directly and save time.
{% endhint %}

{% hint style="success" %}
Congratulations! Your node is running successfully now. Let it sync up.
{% endhint %}

## :gear: 9. Generate block-producer keys

The block-producer node requires you to create 3 keys as defined in the [Shelley ledger specs](https://hydra.iohk.io/build/2473732/download/1/ledger-spec.pdf):

* stake pool cold key (node.cert)
* stake pool hot key (kes.skey)
* stake pool VRF key (vrf.skey)

First, make a KES key pair.

{% tabs %}
{% tab title="block producer node" %}
```bash
cd $NODE_HOME
cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
KES (key evolving signature) keys are created to secure your stake pool against hackers who might compromise your keys.&#x20;

**On mainnet, you will need to regenerate the KES key every 90 days.**
{% endhint %}

{% hint style="danger" %}
****:fire: **Cold keys** **must be generated and stored on your air-gapped offline machine.** The cold keys are the files stored in `$HOME/cold-keys.`
{% endhint %}

Make a directory to store your cold keys

{% tabs %}
{% tab title="Air-gapped offline machine" %}
```
mkdir $HOME/cold-keys
pushd $HOME/cold-keys
```
{% endtab %}
{% endtabs %}

Make a set of cold keys and create the cold counter file.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli node key-gen \
    --cold-verification-key-file node.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter node.counter
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
Be sure to **back up your all your keys** to another secure storage device. Make multiple copies.
{% endhint %}

Determine the number of slots per KES period from the genesis file.

{% tabs %}
{% tab title="block producer node" %}
```bash
pushd +1
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
echo slotsPerKESPeriod: ${slotsPerKESPeriod}
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
Before continuing, your node must be fully synchronized to the blockchain. Otherwise, you won't calculate the latest KES period. Your node is synchronized when the _epoch _and _slot# _is equal to that found on a block explorer such as [https://pooltool.io/](https://pooltool.io)
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo slotNo: ${slotNo}
```
{% endtab %}
{% endtabs %}

Find the kesPeriod by dividing the slot tip number by the slotsPerKESPeriod.

{% tabs %}
{% tab title="block producer node" %}
```bash
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
echo kesPeriod: ${kesPeriod}
startKesPeriod=${kesPeriod}
echo startKesPeriod: ${startKesPeriod}
```
{% endtab %}
{% endtabs %}

With this calculation, you can generate a operational certificate for your pool.&#x20;

Copy **kes.vkey** to your **cold environment**.&#x20;

Change the <**startKesPeriod> **value accordingly.

{% hint style="info" %}
Stake pool operators must provide an operational certificate to verify that the pool has the authority to run. The certificate includes the operator’s signature, and includes key information about the pool (addresses, keys, etc.). Operational certificates represent the link between the operator’s offline key and their operational key.
{% endhint %}

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period <startKesPeriod> \
    --out-file node.cert
```
{% endtab %}
{% endtabs %}

Copy **node.cert** to your **hot environment**.

Make a VRF key pair.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
```
{% endtab %}
{% endtabs %}

Update vrf key permissions to read-only. You must also copy **vrf.vkey** to your **cold environment.**

```
chmod 400 vrf.skey
```

Stop your** **stake pool by running the following:

{% tabs %}
{% tab title="block producer node" %}
```bash
sudo systemctl stop cardano-node
```
{% endtab %}
{% endtabs %}

Update your startup script with the new** KES, VRF and Operation Certificate.**

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
KES=\${DIRECTORY}/kes.skey
VRF=\${DIRECTORY}/vrf.skey
CERT=\${DIRECTORY}/node.cert
/usr/local/bin/cardano-node run +RTS -N -A16m -qg -qb -RTS --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG} --shelley-kes-key \${KES} --shelley-vrf-key \${VRF} --shelley-operational-certificate \${CERT}
EOF
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
To operate a stake pool, you need the KES, VRF key and Operational Certificate. Cold keys generate new operational certificates periodically.
{% endhint %}

Now start your block producer node.

{% tabs %}
{% tab title="block producer node" %}
```bash
sudo systemctl start cardano-node

# Monitor with gLiveView
./gLiveView.sh
```
{% endtab %}
{% endtabs %}

## :closed\_lock\_with\_key: 10. Setup payment and stake keys

First, obtain the protocol-parameters.

{% hint style="info" %}
Wait for the block-producing node to start syncing before continuing if you get this error message.

`cardano-cli: Network.Socket.connect: : does not exist (No such file or directory)`
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query protocol-parameters \
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
:fire: **Critical Operational Security Advice:** `payment `and `stake `keys must be generated and used to build transactions in an cold environment. In other words, your **air-gapped offline machine**. Copy `cardano-cli` binary over to your offline machine and run the CLI method or mnemonic method. The only steps performed online in a hot environment are those steps that require live data. Namely the follow type of steps:

* querying the current slot tip
* querying the balance of an address
* submitting a transaction
{% endhint %}

{% tabs %}
{% tab title="CLI Method" %}
Create a new payment key pair:  `payment.skey` & `payment.vkey`

```bash
###
### On air-gapped offline machine,
###
cd $NODE_HOME
cardano-cli address key-gen \
    --verification-key-file payment.vkey \
    --signing-key-file payment.skey
```

&#x20;Create a new stake address key pair: `stake.skey` & `stake.vkey`

```bash
###
### On air-gapped offline machine,
###
cardano-cli stake-address key-gen \
    --verification-key-file stake.vkey \
    --signing-key-file stake.skey
```

Create your stake address from the stake address verification key and store it in `stake.addr`

```bash
###
### On air-gapped offline machine,
###
cardano-cli stake-address build \
    --stake-verification-key-file stake.vkey \
    --out-file stake.addr \
    --mainnet
```

Build a payment address for the payment key `payment.vkey` which will delegate to the stake address, `stake.vkey`

```bash
###
### On air-gapped offline machine,
###
cardano-cli address build \
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

Create a 15-word or 24-word length shelley compatible mnemonic with [Daedalus](https://daedaluswallet.io) or [Yoroi](../../../wallets/browser-wallets/yoroi-wallet-cardano.md) on a offline machine preferred.

Using your online block producer node, download `cardano-wallet`

```bash
###
### On block producer node,
###
cd $NODE_HOME
wget https://hydra.iohk.io/build/3662127/download/1/cardano-wallet-shelley-2020.7.28-linux64.tar.gz
```

Verify the legitimacy of `cardano-wallet` by checking the [sha256 hash found in the **Details **button.](https://hydra.iohk.io/build/3662127/)

```bash
echo "f75e5b2b4cc5f373d6b1c1235818bcab696d86232cb2c5905b2d91b4805bae84 *cardano-wallet-shelley-2020.7.28-linux64.tar.gz" | shasum -a 256 --check
```

Example valid output:

> cardano-wallet-shelley-2020.7.28-linux64.tar.gz: OK

{% hint style="danger" %}
Only proceed if the sha256 check passes with **OK**!
{% endhint %}

Transfer the **cardano-wallet** to your **air-gapped offline machine** via USB key or other removable media.

Extract the wallet files and cleanup.

```bash
###
### On air-gapped offline machine,
###
tar -xvf cardano-wallet-shelley-2020.7.28-linux64.tar.gz
rm cardano-wallet-shelley-2020.7.28-linux64.tar.gz
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
"\$CADDR" key public | tee payment.xpub |\
"\$CADDR" address payment --network-tag \$NETWORK |\
"\$CADDR" address delegation \$(cat stake.xprv | "\$CADDR" key public | tee stake.xpub) |\
tee base.addr_candidate |\
"\$CADDR" address inspect
echo "Generated from 1852H/1815H/0H/{0,2}/0"
cat base.addr_candidate
echo

# XPrv/XPub conversion to normal private and public key, keep in mind the 
# keypars are not a valind Ed25519 signing keypairs.
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

"\$CCLI" shelley key verification-key --signing-key-file stake.skey --verification-key-file stake.evkey
"\$CCLI" shelley key verification-key --signing-key-file payment.skey --verification-key-file payment.evkey

"\$CCLI" shelley key non-extended-key --extended-verification-key-file payment.evkey --verification-key-file payment.vkey
"\$CCLI" shelley key non-extended-key --extended-verification-key-file stake.evkey --verification-key-file stake.vkey


"\$CCLI" shelley stake-address build --stake-verification-key-file stake.vkey \$MAGIC > stake.addr
"\$CCLI" shelley address build --payment-verification-key-file payment.vkey \$MAGIC > payment.addr
"\$CCLI" shelley address build \
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
export PATH="$(pwd)/cardano-wallet-shelley-2020.7.28:$PATH"
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
rm -rf $NODE_HOME/cardano-wallet-shelley-2020.7.28
```

Finally close all your terminal windows and open new ones with zero history.

{% hint style="success" %}
Awesome. Now you can track your pool rewards in your wallet.
{% endhint %}
{% endtab %}
{% endtabs %}

Next step is to fund your payment address.&#x20;

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
cardano-cli query utxo \
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

## :woman\_technologist: 11. Register your stake address

Create a certificate, `stake.cert`, using the `stake.vkey`

{% tabs %}
{% tab title="air-gapped offline machine" %}
```
cardano-cli stake-address registration-certificate \
    --stake-verification-key-file stake.vkey \
    --out-file stake.cert
```
{% endtab %}
{% endtabs %}

Copy **stake.cert **to your **hot environment.**

You need to find the **tip **of the blockchain to set the **invalid-hereafter **parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Find your balance and **UTXOs**.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
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
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
{% endtab %}
{% endtabs %}

Find the stakeAddressDeposit value.

{% tabs %}
{% tab title="block producer node" %}
```bash
stakeAddressDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakeAddressDeposit')
echo stakeAddressDeposit : $stakeAddressDeposit
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Registration of a stake address certificate (stakeAddressDeposit) costs 2000000 lovelace.
{% endhint %}

Run the build-raw transaction command

{% hint style="info" %}
The **invalid-hereafter** value must be greater than the current tip. In this example, we use current slot + 10000.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp \
    --certificate stake.cert
```
{% endtab %}
{% endtabs %}

Calculate the current minimum fee:

{% tabs %}
{% tab title="block producer node" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
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
Ensure your balance is greater than cost of fee + stakeAddressDeposit or this will not work.
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

Build your transaction which will register your stake address.&#x20;

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file stake.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment**.

Sign the transaction with both the payment and stake secret keys.&#x20;

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli transaction sign \
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
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

## :page\_facing\_up: 12. Register your stake pool

Create your pool's metadata with a JSON file. Update with your pool information.

{% hint style="warning" %}
**ticker **must be between 3-5 characters in length. Characters must be A-Z and 0-9 only.
{% endhint %}

{% hint style="warning" %}
**description **cannot exceed 255 characters in length.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cat > poolMetaData.json << EOF
{
"name": "MyPoolName",
"description": "My pool description",
"ticker": "MPN",
"homepage": "https://myadapoolnamerocks.com"
}
EOF
```
{% endtab %}
{% endtabs %}

Calculate the hash of your metadata file. It's saved to **poolMetaDataHash.txt**

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

Copy **poolMetaDataHash.txt** to your air-gapped offline machine, cold environment.

Now upload your **poolMetaData.json** to your website or a public website such as [https://pages.github.com/](https://pages.github.com)

Refer to [this quick guide](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node/how-to-upload-poolmetadata.json-to-github) if you need help hosting your metadata on github.com

Verify the metadata hashes by comparing your uploaded .json file and your local .json file's hash.&#x20;

{% tabs %}
{% tab title="block producer node" %}
Get the metadata hash from your metadata json URL. Replace **\<https://REPLACE WITH YOUR METADATA\_URL>** with your actual URL.

```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file <(curl -s -L <https://REPLACE WITH YOUR METADATA_URL>)
```

This above hash must equal the local metadata hash.

```
cat poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
If the hashes do no match, then the uploaded .json file likely was truncated or extra whitespace caused issues. Upload the .json again or to a different web host.
{% endhint %}

Find the minimum pool cost.

{% tabs %}
{% tab title="block producer node" %}
```bash
minPoolCost=$(cat $NODE_HOME/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
minPoolCost is 340000000 lovelace or 340 ADA. Therefore, your `--pool-cost` must be at a minimum this amount.
{% endhint %}

Create a registration certificate for your stake pool. Update with your **metadata URL** and your **relay node information**. Choose one of the three options available to configure relay nodes -- DNS based, Round Robin DNS based, or IP based.&#x20;

{% hint style="info" %}
DNS based relays are recommended for simplicity of node management. In other words, you don't need to re-submit this **registration certificate** transaction every time your IP changes. Also you can easily update the DNS to point towards a new IP should you re-locate or re-build a relay node, for example.
{% endhint %}

{% hint style="info" %}
#### ****:sparkles: **How to configure multiple relay nodes. **

Update the next operation

`cardano-cli stake-pool registration-certificate`

to be run on your air-gapped offline machine appropriately. Replace with your proper domain names or IP addresses.

**DNS based relays, 1 entry per DNS record**

```bash
    --single-host-pool-relay <relaynode1.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
    --single-host-pool-relay <relaynode2.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
```

**Round Robin DNS based relays, 1 entry per **[**SRV DNS record**](https://support.dnsimple.com/articles/srv-record/)****

```bash
    --multi-host-pool-relay <relayNodes.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
```

**IP based relays, 1 entry per IP address**

```bash
    --pool-relay-port 6000 \
    --pool-relay-ipv4 <your first relay node public IP address> \
    --pool-relay-port 6000 \
    --pool-relay-ipv4 <your second relay node public IP address> \
```
{% endhint %}

{% hint style="warning" %}
**metadata-url** must be no longer than 64 characters.
{% endhint %}

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000 \
    --pool-cost 345000000 \
    --pool-margin 0.15 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --single-host-pool-relay <dns based relay, example ~ relaynode1.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
    --metadata-url <url where you uploaded poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Here we are pledging 100 ADA with a fixed pool cost of 345 ADA and a pool margin of 15%.&#x20;
{% endhint %}

Copy **pool.cert** to your **hot environment.**

Pledge stake to your stake pool.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
```
{% endtab %}
{% endtabs %}

Copy **deleg.cert** to your **hot environment**.

{% hint style="info" %}
This operation creates a delegation certificate which delegates funds from all stake addresses associated with key `stake.vkey` to the pool belonging to cold key `node.vkey`
{% endhint %}

{% hint style="info" %}
A stake pool owner's promise to fund their own pool is called **Pledge**.

* Your balance needs to be greater than the pledge amount.
* You pledge funds are not moved anywhere. In this guide's example, the pledge remains in the stake pool's owner keys, specifically `payment.addr`
* Failing to fulfill pledge will result in missed block minting opportunities and your delegators would miss rewards.&#x20;
* Your pledge is not locked up. You are free to transfer your funds.
{% endhint %}

You need to find the **tip **of the blockchain to set the **invalid-hereafter **parameter properly.

{% tabs %}
{% tab title="block producer node" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Find your balance and **UTXOs**.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
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
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
{% endtab %}
{% endtabs %}

Find the deposit fee for a pool.

{% tabs %}
{% tab title="block producer node" %}
```bash
stakePoolDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakePoolDeposit')
echo stakePoolDeposit: $stakePoolDeposit
```
{% endtab %}
{% endtabs %}

Run the build-raw transaction command.

{% hint style="info" %}
The **invalid-hereafter **value must be greater than the current tip. In this example, we use current slot + 10000.&#x20;
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${stakePoolDeposit}))  \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

Calculate the minimum fee:

{% tabs %}
{% tab title="block producer node" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Ensure your balance is greater than cost of fee + minPoolCost or this will not work.
{% endhint %}

Calculate your change output.

{% tabs %}
{% tab title="block producer node" %}
```bash
txOut=$((${total_balance}-${stakePoolDeposit}-${fee}))
echo txOut: ${txOut}
```
{% endtab %}
{% endtabs %}

Build the transaction.&#x20;

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copy **tx.raw** to your **cold environment.**

Sign the transaction.&#x20;

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --signing-key-file stake.skey \
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
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

## :hatching\_chick: 13. Locate your Stake pool ID and verify everything is working&#x20;

Your stake pool ID can be computed with:

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-pool id --cold-verification-key-file $HOME/cold-keys/node.vkey --output-format hex > stakepoolid.txt
cat stakepoolid.txt
```
{% endtab %}
{% endtabs %}

Copy **stakepoolid.txt **to your **hot environment.**

Now that you have your stake pool ID,  verify it's included in the blockchain.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli query stake-snapshot --stake-pool-id $(cat stakepoolid.txt) --mainnet 
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
A non-empty string return means you're registered! :clap:&#x20;
{% endhint %}

With your stake pool ID, now you can find your data on block explorers such as [https://pooltool.io/](https://pooltool.io)

## :gear: 14. Configure your topology files

{% hint style="info" %}
Shelley has been launched without peer-to-peer (p2p) node discovery so that means we will need to manually add trusted nodes in order to configure our topology. This is a **critical step** as skipping this step will result in your minted blocks being orphaned by the rest of the network.
{% endhint %}

#### :rocket: Publishing your Relay Node with topologyUpdater.sh

{% hint style="info" %}
Credits to [GROWPOOL](https://twitter.com/PoolGrow) for this addition and credits to [CNTOOLS Guild OPS](https://cardano-community.github.io/guild-operators/Scripts/topologyupdater.html) on creating this process.
{% endhint %}

{% hint style="info" %}
**How Topology API works**

1. Your relay node pings an API server.
2. When the API server is convinced that your relay node is stable and is actually a running Cardano node, based on the ability to report the current block number accurately a number of times over a period of time, then the domain name or IP address of your node is automatically added to a list of other nodes that have been vetted similarly for quality and stability.
3. When your relay node is on the list, the relay node can request from the API server a list of other active Cardano nodes with which your node can synchronize in order to participate in the network of nodes as a peer. Also, the domain name or IP address of your relay node is distributed on lists that other active Cardano nodes may request from the same API server. **NOTE**: Other nodes refreshing their list of peer nodes with a list that may include the domain name or IP address of your relay node is dependent on how often other nodes request an updated list from the API server. Request an updated list of nodes from the API server for your relay regularly so that your list of peers remains accurate.
4. In order to stay on the list of active nodes, your relay node must ping the API server once every hour. If your relay node stops pinging the API server, then your relay node is removed from the list of active nodes after three hours.

Credits for the high level explanation: [Oliver Sterzik - Change (CHG) Cardano Stake Pool Operator](https://change.paradoxicalsphere.com)
{% endhint %}

Create the `topologyUpdater.sh` script which publishes your node information to a topology fetch list.

```bash
###
### On relaynode1
###
cat > $NODE_HOME/topologyUpdater.sh << EOF
#!/bin/bash
# shellcheck disable=SC2086,SC2034
 
USERNAME=$(whoami)
CNODE_PORT=6000 # must match your relay node port as set in the startup command
CNODE_HOSTNAME="CHANGE ME"  # optional. must resolve to the IP you are requesting from
CNODE_BIN="/usr/local/bin"
CNODE_HOME=$NODE_HOME
CNODE_LOG_DIR="\${CNODE_HOME}/logs"
GENESIS_JSON="\${CNODE_HOME}/${NODE_CONFIG}-shelley-genesis.json"
NETWORKID=\$(jq -r .networkId \$GENESIS_JSON)
CNODE_VALENCY=1   # optional for multi-IP hostnames
NWMAGIC=\$(jq -r .networkMagic < \$GENESIS_JSON)
[[ "\${NETWORKID}" = "Mainnet" ]] && HASH_IDENTIFIER="--mainnet" || HASH_IDENTIFIER="--testnet-magic \${NWMAGIC}"
[[ "\${NWMAGIC}" = "764824073" ]] && NETWORK_IDENTIFIER="--mainnet" || NETWORK_IDENTIFIER="--testnet-magic \${NWMAGIC}"
 
export PATH="\${CNODE_BIN}:\${PATH}"
export CARDANO_NODE_SOCKET_PATH="\${CNODE_HOME}/db/socket"
 
blockNo=\$(/usr/local/bin/cardano-cli query tip \${NETWORK_IDENTIFIER} | jq -r .block )
 
# Note:
# if you run your node in IPv4/IPv6 dual stack network configuration and want announced the
# IPv4 address only please add the -4 parameter to the curl command below  (curl -4 -s ...)
if [ "\${CNODE_HOSTNAME}" != "CHANGE ME" ]; then
  T_HOSTNAME="&hostname=\${CNODE_HOSTNAME}"
else
  T_HOSTNAME=''
fi

if [ ! -d \${CNODE_LOG_DIR} ]; then
  mkdir -p \${CNODE_LOG_DIR};
fi
 
curl -s "https://api.clio.one/htopology/v1/?port=\${CNODE_PORT}&blockNo=\${blockNo}&valency=\${CNODE_VALENCY}&magic=\${NWMAGIC}\${T_HOSTNAME}" | tee -a \$CNODE_LOG_DIR/topologyUpdater_lastresult.json
EOF
```

Add permissions and run the updater script.

```bash
###
### On relaynode1
###
cd $NODE_HOME
chmod +x topologyUpdater.sh
./topologyUpdater.sh
```

When the `topologyUpdater.sh` runs successfully, you will see

> `{ "resultcode": "201", "datetime":"2020-07-28 01:23:45", "clientIp": "1.2.3.4", "iptype": 4, "msg": "nice to meet you" }`

{% hint style="info" %}
Every time the script runs and updates your IP, a log is created in **`$NODE_HOME/logs`**&#x20;
{% endhint %}

Add a crontab job to automatically run `topologyUpdater.sh` every hour on the 33rd minute. You can change the 33 value to your own preference.

```bash
###
### On relaynode1
###
cat > $NODE_HOME/crontab-fragment.txt << EOF
33 * * * * ${NODE_HOME}/topologyUpdater.sh
EOF
crontab -l | cat - ${NODE_HOME}/crontab-fragment.txt > ${NODE_HOME}/crontab.txt && crontab ${NODE_HOME}/crontab.txt
rm ${NODE_HOME}/crontab-fragment.txt
```

{% hint style="success" %}
After four hours and four updates, your node IP will be registered in the topology fetch list.
{% endhint %}

#### Update your relay node topology files

{% hint style="danger" %}
Complete this section after **four hours** when your relay node IP is properly registered.
{% endhint %}

Create `relay-topology_pull.sh` script which fetches your relay node buddies and updates your topology file. **Update with your block producer's IP address.**

{% tabs %}
{% tab title="mainnet" %}
```bash
###
### On relaynode1
###
cat > $NODE_HOME/relay-topology_pull.sh << EOF
#!/bin/bash
BLOCKPRODUCING_IP=<BLOCK PRODUCERS IP ADDRESS>
BLOCKPRODUCING_PORT=6000
curl -s -o $NODE_HOME/${NODE_CONFIG}-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=\${BLOCKPRODUCING_IP}:\${BLOCKPRODUCING_PORT}:1|relays-new.cardano-mainnet.iohk.io:3001:2"
EOF
```
{% endtab %}

{% tab title="testnet" %}
```bash
###
### On relaynode1
###
cat > $NODE_HOME/relay-topology_pull.sh << EOF
#!/bin/bash
BLOCKPRODUCING_IP=<BLOCK PRODUCERS IP ADDRESS>
BLOCKPRODUCING_PORT=6000
curl -s -o $NODE_HOME/testnet-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&magic=1097911063&customPeers=${BLOCKPRODUCING_IP}:${BLOCKPRODUCING_PORT}:1|relays-new.cardano-testnet.iohkdev.io:3001:2"
EOF
```
{% endtab %}
{% endtabs %}

Add permissions and pull new topology files.

```bash
###
### On relaynode1
###
chmod +x relay-topology_pull.sh
./relay-topology_pull.sh
```

The new topology takes after after restarting your stake pool.

```bash
###
### On relaynode1
###
sudo systemctl restart cardano-node
```

{% hint style="warning" %}
Don't forget to restart your relay nodes after every time you fetch the topology!&#x20;
{% endhint %}

{% hint style="danger" %}
****:octagonal\_sign: **Critical Key Security Reminde**r: The only stake pool **keys **and **certs **that are required to run a stake pool are those required by the block producer. Namely, the following three files.

```bash
###
### On block producer node
###
KES=${NODE_HOME}/kes.skey
VRF=${NODE_HOME}/vrf.skey
CERT=${NODE_HOME}/node.cert
```

**All other keys must remain offline in your air-gapped offline cold environment.**
{% endhint %}

{% hint style="danger" %}
****:fire: **Relay Node Security Reminder:** Relay nodes must not contain any **`operational certifications`, `vrf`, `skey` or `cold`**` `**keys**.
{% endhint %}

{% hint style="success" %}
Congratulations! Your stake pool is registered and ready to produce blocks.



Continue to the next section 15 - Checking stake pool rewards.
{% endhint %}

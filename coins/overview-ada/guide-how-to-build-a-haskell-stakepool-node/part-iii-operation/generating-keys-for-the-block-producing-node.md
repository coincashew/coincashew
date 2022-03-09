# Generating Keys for the Block-producing Node

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
KES (key evolving signature) keys are created to secure your stake pool against hackers who might compromise your keys.

**On mainnet, you will need to regenerate the KES key every 90 days.**
{% endhint %}

{% hint style="danger" %}
:fire: **Cold keys** **must be generated and stored on your air-gapped offline machine.** The cold keys are the files stored in `$HOME/cold-keys.`
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
Before continuing, your node must be fully synchronized to the blockchain. Otherwise, you won't calculate the latest KES period. Your node is synchronized when the \_epoch \_and \_slot# \_is equal to that found on a block explorer such as [https://pooltool.io/](https://pooltool.io)
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

With this calculation, you can generate a operational certificate for your pool.

Copy **kes.vkey** to your **cold environment**.

Change the <**startKesPeriod**> value accordingly.

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

Stop your\*\* \*\*stake pool by running the following:

{% tabs %}
{% tab title="block producer node" %}
```bash
sudo systemctl stop cardano-node
```
{% endtab %}
{% endtabs %}

Update your startup script with the new **KES, VRF and Operation Certificate.**

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

# Issuing a New Operational Certificate

Your stake pool requires a valid operational certificate to verify that the pool has the authority to run.

A current KES key pair is required to establish an operational certificate for your stake pool. A KES period indicates the time span when an operational certificate is valid. An operational certificate expires 90 days after the KES period defined in the operational certificate. You must generate a new KES key pair and operational certificate every 90 days, or sooner, for your stake pool to mint blocks.

The private KES key is required to start the block producing node for your stake pool. The public KES key is not sensitive.

Issuing an operational certificate also uses a counter that increments by exactly one (1) for each unique operational certificate that a stake pool uses to mint blocks. In a valid operational certificate, the counter value that you use to issue the operational certificate must be consistent with the current counter value for your stake pool registered on the Cardano blockchain by the protocol.

## Determining the Counter Value

**To retrieve the current counter value for your stake pool registered by the blockchain protocol:**

* In a terminal window on your block producer node, type:

```bash
cd $NODE_HOME
cardano-cli query kes-period-info \
    --${NODE_CONFIG} \
    --op-cert-file node.cert
```

The `cardano-cli query kes-period-info` command returns output similar to:

```bash
✓ Operational certificate's KES period is within the correct KES period interval
✓ The operational certificate counter agrees with the node protocol state counter
{
    "qKesCurrentKesPeriod": 15,
    "qKesEndKesInterval": 18,
    "qKesKesKeyExpiry": null,
    "qKesMaxKESEvolutions": 6,
    "qKesNodeStateOperationalCertificateNumber": 3,
    "qKesOnDiskOperationalCertificateNumber": 3,
    "qKesRemainingSlotsInKesPeriod": 690,
    "qKesSlotsPerKesPeriod": 300,
    "qKesStartKesInterval": 12
}
```

The value of the `qKesNodeStateOperationalCertificateNumber` key indicates the current counter value for your stake pool registered by the blockchain protocol. The value of the `qKesOnDiskOperationalCertificateNumber` key indicates the counter value of the current operational certificate that your stake pool uses.

For a new operational certificate, the counter value must be exactly one (1) greater than the current value of the `qKesNodeStateOperationalCertificateNumber` key.

{% hint style="warning" %}
If `qKesOnDiskOperationalCertificateNumber` is more than one (1) greater than `qKesNodeStateOperationalCertificateNumber` then the operational certificate is invalid. Your stake pool cannot mint blocks using an invalid operational certificate.
{% endhint %}

## Minting Your First Block

When your stake pool has minted zero (0) blocks, then no value for `qKesNodeStateOperationalCertificateNumber` is registered by the blockchain protocol. Therefore, retrieving the current counter value for your stake pool returns the value `null` for the `qKesNodeStateOperationalCertificateNumber` key.

After minting your first block, then retrieving the current counter value returns the value zero (0) for the `qKesNodeStateOperationalCertificateNumber` key.

Therefore, when your stake pool has minted zero (0) blocks, then you MUST set the value zero (`0`) for the `qKesOnDiskOperationalCertificateNumber` key so that your stake pool creates a block successfully when elected to mint a block for the first time.
<!-- Source: https://forum.cardano.org/t/qkesnodestateoperationalcertificatenumber-null/106046 -->

## Setting the Counter Value

When you issue a new operational certificate, a `node.counter` file sets the counter value for the new certificate.

{% hint style="info" %}
If you follow the Coin Cashew instructions, then you created a `node.counter` file when [Generating Keys for the Block-producing Node](../part-iii-operation/generating-keys-for-the-block-producing-node.md)
{% endhint %}

When you run the `cardano-cli query kes-period-info` command on your block producer node, if the value of the `qKesOnDiskOperationalCertificateNumber` key equals the value of the `qKesNodeStateOperationalCertificateNumber` key, then your stake pool minted at least one block using the current operational certificate and you do **not** need to set the counter value manually.

If the value of the `qKesOnDiskOperationalCertificateNumber` key is greater than the value of the `qKesNodeStateOperationalCertificateNumber` key, then prior to issuing a new operational certificate you need to set the counter value using the following procedure.

**To set the counter value for issuing a new operational certificate:**

1. To create a new `node.counter` file having the required counter value, type the following command in a terminal window on your air-gapped, offline computer where `<NodeCertificateNumber>` is the current value of the `qKesNodeStateOperationalCertificateNumber` key for your stake pool:

```bash
cd $HOME/cold-keys
cardano-cli node new-counter \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --counter-value $(( <NodeCertificateNumber> + 1 )) \
    --operational-certificate-issue-counter-file node.counter
```

{% hint style="info" %}
If the current value of the `qKesNodeStateOperationalCertificateNumber` key for your stake pool is `null`, then set the `--counter-value` option to zero (`0`)
{% endhint %}

1. To display the contents of the `node.counter` file that you created in step 1, type:

```bash
cat $HOME/cold-keys/node.counter
```

{% hint style="info" %}
When you generate a new `node.counter` file, the value of the `description` key is empty until you issue a new operational certificate.
{% endhint %}

## Issuing a New Operational Certificate

**To issue a new operational certificate:**

1. In a terminal window on your block producer node, type the following commands to generate a new KES key pair:

```bash
cd $NODE_HOME
cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```

1. Copy the `kes.vkey` file that you generated in step 1 to your air-gapped, offline computer.
2. To issue a new operational certificate, you must set a starting KES period. To calculate the starting KES period for your new operational certificate, type the following commands in a terminal window on your block producer node:

```bash
cd $NODE_HOME
# Query the current slot height of the blockchain, and then
# retrieve the value of the slot key in the results
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slot')
# Retrieve the number of slots per KES period from the key named slotsPerKESPeriod 
# in the Shelley Genesis JSON configuration file that your stake pool uses
slotsPerKESPeriod=$(cat $NODE_HOME/shelley-genesis.json | jq -r '.slotsPerKESPeriod')
# To calculate the current KES period, divide the current slot height by
# the number of slots per KES period
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
StartingKESPeriod=${kesPeriod}
echo StartingKESPEriod: ${StartingKESPeriod}
```

1. To issue a new operational certificate, type the following command in a terminal window on your air-gapped, offline computer where `<KESvkeyFile>` is the path to the `kes.vkey` file that you copied in step 2 and `<StartingKESPeriod>` is the starting KES period that you calculated in step 3:

```bash
cd $NODE_HOME
chmod u+rwx $HOME/cold-keys
cardano-cli node issue-op-cert \
    --kes-verification-key-file <KESvkeyFile> \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period <StartingKESPeriod> \
    --out-file node.cert
chmod a-rwx $HOME/cold-keys
```

{% hint style="info" %}
Issuing a new operational certificate increments the value of the `node.counter` file by one (1) To display the contents of the `node.counter` file, type `cat $HOME/cold-keys/node.counter`
{% endhint %}

1. Copy the `node.cert` file that you created in step 4 to replace the current `node.cert` file on your block producer node.
2. To restart your block producer node, type:

```
sudo systemctl restart cardano-node
```

1. To verify the operational certificate that you issued in step 4, wait until your block producer node starts, and then type:

```bash
cd $NODE_HOME
cardano-cli query kes-period-info \
    --${NODE_CONFIG} \
    --op-cert-file node.cert
```

{% hint style="info" %}
In the results of the `cardano-cli query kes-period-info` command, prior to your stake pool minting a block using the operational certificate that you issued in step 4, in a valid operational certificate the value of the `qKesOnDiskOperationalCertificateNumber` key is greater than the value of the `qKesNodeStateOperationalCertificateNumber` key by exactly one (1) The first time your stake pool mints a block using the operational certificate that you issued in step 4, the value of the `qKesNodeStateOperationalCertificateNumber` increments by one (1) to equal the value of the `qKesOnDiskOperationalCertificateNumber` key.
{% endhint %}

1. In a secure location, create backup copies of the KES key files that you generated in step 1; the current `node.counter` file for your stake pool; and, the `node.cert` file that you generated in step 4

{% hint style="success" %}
If you want to support this free educational Cardano content or found the content helpful, visit [cointr.ee](https://cointr.ee/coincashew) to find our donation addresses. Much appreciated in advance. :pray:

:ledger:Technical writing by [Change Pool \[CHG\]](https://change.paradoxicalsphere.com)
{% endhint %}

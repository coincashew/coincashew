# :robot: Rotating KES Keys

Prior to the KES keys for your stake pool expiring every 90 days, you must generate new KES keys and issue a new operational certificate.

**To generate new KES keys and issue a new operational certificate:**

1. In a terminal window on your block producer node, type:
```bash
cd $NODE_HOME
cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```

2. Copy the `kes.vkey` file that you generated in step 1 to your air-gapped, offline computer.

3. To issue a new operational certificate, you must set a starting KES period. To calculate the starting KES period for your new operational certificate, type the following commands in a terminal window on your block producer node:
```bash
cd $NODE_HOME
# Query the current slot height of the blockchain, and then
# retrieve the value of the slot key in the results
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slot')
# Retrieve the number of slots per KES period from the key named slotsPerKESPeriod 
# in the Shelley Genesis JSON configuration file that your stake pool uses
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
# To calculate the current KES period, divide the current slot height by
# the number of slots per KES period
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
StartingKESPeriod=${kesPeriod}
echo StartingKESPEriod: ${StartingKESPeriod}
```

4. Each time you generate a new operational certificate, you must increment the value of `Next certificate issue number` for the `description` key in the `node.counter` JSON file on your air-gapped, offline computer. To edit the `node.counter` file, use a text editor.

5. To verify the current `description` value in the `node.counter` file, type:
```bash
cat $HOME/cold-keys/node.counter
{
    ...
    "description": "Next certificate issue number: <CertificateIssueNumber>",
    ...
}
```  
{% hint style="warning" %}
Ensure that `<CertificateIssueNumber>` is a higher value than the values you used to generate operational certificates previously. If your stake pool mints blocks, then you can find the current `<CertificateIssueNumber>` value for your pool on [ADApools](https://adapools.org). To find your current `<CertificateIssueNumber>` on ADApools, navigate to the page for your stake pool, and then click the **Blocks** tab. ADApools displays the `<CertificateIssueNumber>` for your current operational certificate in the first row of the `OpCertC` column.
{% endhint %}

6. To issue a new operational certificate, type the following command in a terminal window on your air-gapped, offline computer where `<KESvkeyFile>` is the path to the `kes.vkey` file that you copied in step 2, `<StartingKESPeriod>` is the starting KES period that you calculated in step 3, and `<NodeCounterFile>` is the path to the `node.counter` file that you edited in step 4:
```bash
cd $NODE_HOME
chmod u+rwx $HOME/cold-keys
cardano-cli node issue-op-cert \
    --kes-verification-key-file <KESvkeyFile> \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter <NodeCounterFile> \
    --kes-period <StartingKESPeriod> \
    --out-file node.cert
chmod a-rwx $HOME/cold-keys
```

7. Copy the `node.cert` file that you created in step 6 to replace the current `node.cert` file on your block producer node.

8. To restart your block producer node, type:
```
sudo systemctl restart cardano-node
```

9. In a secure location, create backup copies of the KES key files that you generated in step 1, `node.counter` file you edited in step 4, and `node.cert` file that you generated in step 6.

{% hint style="success" %}
If you want to support this free educational Cardano content or found the content helpful, visit [cointr.ee](https://cointr.ee/coincashew) to find our donation addresses. Much appreciated in advance. :pray:

:ledger:Technical writing by [Change Pool \[CHG\]](https://change.paradoxicalsphere.com)
{% endhint %}
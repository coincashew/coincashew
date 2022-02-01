# :robot: Rotating KES Keys

{% hint style="info" %}
You are required to regenerate the hot keys and issue a new operational certificate, a process called rotating the KES keys, when the hot keys expire.

**Mainnet**: KES keys will be valid for 120 rotations or 90 days
{% endhint %}

When it's time to issue a new operational certificate, run the following to find the starting KES period.

{% tabs %}
{% tab title="block producer node" %}
```bash
cd $NODE_HOME
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slot')
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
startKesPeriod=${kesPeriod}
echo startKesPeriod: ${startKesPeriod}
```
{% endtab %}
{% endtabs %}

Make a new KES key pair.

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

Copy **kes.vkey** to your **cold environment.**

Verify the current value of your **node.counter** is valid.

```bash
cat $HOME/cold-keys/node.counter

# Example where value is 6
# "Next certificate issue number: 6"
```

{% hint style="warning" %}
A valid value of your **node.counter** MUST be greater than a recently created block's **OpCertC** value.&#x20;

To find your pool's current **OpCertC **value, search for your pool on [https://adapools.org/](https://adapools.org) and check the **Blocks** tab, then look at the **OpCertC **column.

For example, if your **OpCerC **value is 5, then your node.counter should be`"Next certificate issue number: 6"`

If not, then you need to increment the counter by running the below command with issue-op-cert.
{% endhint %}

Create the new `node.cert` file with the following command. Update `<startKesPeriod>` with the value from above.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cd $NODE_HOME
chmod u+rwx $HOME/cold-keys
cardano-cli node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period <startKesPeriod> \
    --out-file node.cert
chmod a-rwx $HOME/cold-keys
```
{% endtab %}
{% endtabs %}

{% hint style="danger" %}
Copy **node.cert** back to your block producer node.
{% endhint %}

Stop and restart your block producer node to complete this procedure.

{% tabs %}
{% tab title="block producer node" %}
```
sudo systemctl restart cardano-node
```
{% endtab %}

{% tab title="manual" %}
```bash
cd $NODE_HOME
killall -s 2 cardano-node
./startBlockProducingNode.sh
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
****:bulb: **Best practice recommendation**: It's now a good time to make a new backup of your new `node.counter` file and `cold-keys` directory to another USB drive or other offline location.
{% endhint %}
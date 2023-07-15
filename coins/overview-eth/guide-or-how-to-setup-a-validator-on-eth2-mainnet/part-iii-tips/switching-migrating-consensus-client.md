# Switching / Migrating Consensus Client

{% hint style="info" %}
The key takeaway in this process is to avoid running two validator clients simultaneously. You want to avoid being punished by a slashing penalty, which causes a loss of ether.
{% endhint %}

#### :octagonal\_sign: 1 Stop old consensus and old validator.

In order to export the slashing database, the validator needs to be stopped.

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl stop consensus validator
```
{% endtab %}

{% tab title="Nimbus | Teku" %}
```
sudo systemctl stop consensus
```
{% endtab %}
{% endtabs %}

#### :minidisc: 2 Export slashing database (Optional)

{% hint style="info" %}
[EIP-3076](https://eips.ethereum.org/EIPS/eip-3076) implements a standard to safety migrate validator keys between consensus clients. This is the exported contents of the slashing database.
{% endhint %}

Update the export .json file location and name.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
sudo -u consensus /usr/local/bin/lighthouse account validator slashing-protection export <lighthouse_interchange.json>
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
sudo -u consensus /usr/local/bin/nimbus_beacon_node slashingdb export slashing-protection.json

```
{% endtab %}

{% tab title="Teku" %}
```bash
sudo -u consensus /usr/local/bin/teku/bin/teku slashing-protection export --to=<FILE>
```
{% endtab %}

{% tab title="Prysm" %}
```bash
sudo -u validator /usr/local/bin/validator slashing-protection export --datadir=/path/to/your/wallet --slashing-protection-export-dir=/path/to/desired/outputdir
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
sudo -u validator /usr/local/bin/lodestar/lodestar validator slashing-protection export --network mainnet --file interchange.json
```
{% endtab %}
{% endtabs %}

#### :construction: 3 Setup and install new validator / consensus client

Now you need to setup/install your new validator **but do not start running the systemd processes**. Be sure to thoroughly follow your new consensus client and validator in steps 4 and 5. You will need to build/install the client, configure port forwarding/firewalls, and new systemd unit files.

{% hint style="warning" %}
:sparkles: **Pro Tip**: During the process of re-importing validator keys, **wait at least 13 minutes** or two epochs to prevent slashing penalties. You must avoid running two consensus clients with same validator keys at the same time.
{% endhint %}

{% hint style="danger" %}
:octagonal\_sign: **Critical Step**: Do not start any **systemd processes** until either you have imported the slashing database or you have **waited at least 13 minutes or two epochs**.
{% endhint %}

#### :open\_file\_folder: 4 Import slashing database (Optional)

Using your new consensus client, run the following command and update the relevant path to import your slashing database from 2 steps ago.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
sudo -u consensus /usr/local/bin/lighthouse account validator slashing-protection import <my_interchange.json>
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
sudo -u consensus /usr/local/bin/nimbus_beacon_node slashingdb import path/to/export_dir/slashing-protection.json
```
{% endtab %}

{% tab title="Teku" %}
```bash
sudo -u consensus /usr/local/bin/teku/bin/teku slashing-protection import --from=<FILE>
```
{% endtab %}

{% tab title="Prysm" %}
```bash
sudo -u validator /usr/local/bin/validator slashing-protection import --datadir=/path/to/your/wallet --slashing-protection-json-file=/path/to/desiredimportfile
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
sudo -u validator /usr/local/bin/lodestar/lodestar validator slashing-protection import --network mainnet --file interchange.json
```
{% endtab %}
{% endtabs %}

#### :stars: 5 Start new validator and new beacon chain

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl start consensus validator
```
{% endtab %}

{% tab title="Nimbus | Teku" %}
```
sudo systemctl start consensus
```
{% endtab %}
{% endtabs %}

#### :fire: 6 Verify functionality

Check the logs to verify the services are working properly and ensure there are no errors.

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl status consensus validator
```
{% endtab %}

{% tab title="Nimbus | Teku" %}
```
sudo systemctl status consensus
```
{% endtab %}
{% endtabs %}

Finally, verify your validator's attestations are working with public block explorer such as

[https://beaconcha.in/](https://beaconcha.in)

Enter your validator's pubkey to view its status.

#### :fire\_extinguisher: 7 Update Monitoring with Prometheus and Grafana

[Review section 6](../part-i-installation/monitoring-your-validator-with-grafana-and-prometheus.md) and change your `prometheus.yml`. Ensure prometheus is connected to your new consensus client's metrics port. You will also want to import your new consensus client's dashboard.

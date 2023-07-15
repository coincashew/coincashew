# Teku

{% hint style="info" %}
**Note**: Teku is configured to run both **validator client** and **beacon chain client** in one process.
{% endhint %}

First, copy your `validator_keys` to the data directory.

```bash
sudo mkdir -p /var/lib/teku/validator_keys
sudo cp $HOME/staking-deposit-cli/validator_keys/keystore* /var/lib/teku/validator_keys
```

{% hint style="danger" %}
WARNING: Do not import your validator keys into multiple validator clients and run them at the same time, or you might get slashed. If moving validators to a new setup or different validator client, ensure deletion of the previous validator keys before continuing.
{% endhint %}

Storing your **keystore password** in a text file is required so that Teku can decrypt and load your validators automatically.

Create a temporary file to store your **keystore password**. Type your password in this file.

```bash
sudo nano $HOME/validators-password.txt
```

To exit and save, press `Ctrl` + `X`, then `Y`, then `Enter`.

Confirm that your **keystore password** is correct.

```bash
sudo cat $HOME/validators-password.txt
```

When specifying directories for your validator-keys, Teku expects to find identically named keystore and password files.

For example `keystore-m_12221_3600_1_0_0-11222333.json` and `keystore-m_12221_3600_1_0_0-11222333.txt`

Run the following command to create a corresponding password file for every one of your validators.

```bash
for f in /var/lib/teku/validator_keys/keystore*.json; do sudo cp $HOME/validators-password.txt /var/lib/teku/validator_keys/$(basename $f .json).txt; done
```

Verify that your validator's keystore .json files and validator's passwords .txt files are present by checking the following directory.

```bash
sudo ls -l /var/lib/teku/validator_keys
```

Setup ownership permissions, including hardening the access to this directory.

<pre class="language-bash"><code class="lang-bash">sudo chown -R consensus:consensus /var/lib/teku/
<strong>sudo chmod -R 700 /var/lib/teku/validator_keys
</strong></code></pre>

Delete the temporary **keystore password** file.

```bash
sudo rm $HOME/validators-password.txt
```

Finally, restart Teku to use the new validators.

```bash
sudo systemctl restart consensus
```

Check your logs to confirm that the validators are up and functioning.

```bash
sudo journalctl -fu consensus | ccze
```

For example when using 2 validators, logs will show the following:

```bash
INFO  - Loading 2 validator keys...
INFO  - Loaded 2 Validators: 95d3986, 82b225f
```

Press `Ctrl` + `C` to exit the logs.

**Example of Synced Teku Validator Client Logs**

* Once the validator is active and proceeded through the validator activation queue, attestation messages will appear indicating successful attestations.
* Notice the key words "`Validator *** Published attestation`".

```bash
teku[65367]: 03:50:51.761 INFO  - Validator cc1f3ade status is active_ongoing.
teku[65367]: 03:50:52.203 INFO  - Validator   *** Published attestation        Count: 1, Slot: 31362, Root: 90FC0DF4D5958E469134A015203B53B3FB94A0FC1038FB2462882906D4A729A2
```

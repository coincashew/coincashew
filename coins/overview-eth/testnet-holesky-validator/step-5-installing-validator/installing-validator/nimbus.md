# Nimbus

{% hint style="info" %}
**Note**: Nimbus is configured to run both **validator client** and **beacon chain client** in one process.
{% endhint %}

The following command will import your validator keys.

Enter your **keystore password** to import accounts.

```bash
sudo /usr/local/bin/nimbus_beacon_node deposits import \
  --data-dir=/var/lib/nimbus $HOME/staking-deposit-cli/validator_keys
```

{% hint style="danger" %}
WARNING: Do not import your validator keys into multiple validator clients and run them at the same time, or you might get slashed. If moving validators to a new setup or different validator client, ensure deletion of the previous validator keys before continuing.
{% endhint %}

Now you can verify the accounts were imported successfully by doing a directory listing.

```bash
sudo ls -l /var/lib/nimbus/validators
```

You should see a folder named for each of your validator's pubkey.

Setup ownership permissions, including hardening the access to this directory.

```bash
sudo chown -R consensus:consensus /var/lib/nimbus
sudo chmod -R 700 /var/lib/nimbus
```

Finally, restart Nimbus to use the new validators.

```bash
sudo systemctl restart consensus
```

Check your logs to confirm that the validators are up and functioning.

```bash
sudo journalctl -fu consensus | ccze
```

For example when using 2 validators, logs will show the following:

```bash
Loading validators             topics="beacval" validatorsDir=/var/lib/nimbus/validators keystore_cache_available=true
Local validator attached       topics="val_pool" pubkey=95d39860a0d6ea3b92cba78069d21f3a validator=95d39860 initial_fee_recipient=81ba8d5c4ae850
Local validator attached       topics="val_pool" pubkey=82b225f66476962b161ed015786df00f validator=82b225f6 initial_fee_recipient=81ba8d5c4ae850
```

Press `Ctrl` + `C` to exit the logs.

**Example of Synced Nimbus Validator Client Logs**

* Once the validator is active and proceeded through the validator activation queue, attestation messages will appear indicating successful attestations.
* Notice the key words "`Attestation sent`".

```bash
nimbus_beacon_node[292966]: INF 2023-02-05 01:25:26.263+00:00 Attestation sent      attestation="(aggregation_bits: 0b00000000000000000000000000000000000000000000000000000000, data: (slot: 31235, index: 3, beacon_block_root: \"ca3213f1\", source: \"1901:9deza1289\", target: \"1901:6ab1fafff\"), signature: \"32173064\")" delay=46ms543us294ns subnet_id=20
```

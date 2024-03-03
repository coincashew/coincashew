# Nimbus

Select a configuration for Nimbus. Running a standalone validator configuration is recommended for best modularity and redundancy.

{% tabs %}
{% tab title="Standalone Validator (Recommended)" %}
Create a service user for the validator service, as this improves security, then create data directories.

<pre class="language-bash"><code class="lang-bash">sudo adduser --system --no-create-home --group validator
<strong>sudo mkdir -p /var/lib/nimbus_validator
</strong></code></pre>

The following command will import your validator keys.

Enter your **keystore password** to import accounts.

```bash
sudo /usr/local/bin/nimbus_beacon_node deposits import \
  --data-dir=/var/lib/nimbus_validator $HOME/staking-deposit-cli/validator_keys
```

{% hint style="danger" %}
WARNING: Do not import your validator keys into multiple validator clients and run them at the same time, or you might get slashed. If moving validators to a new setup or different validator client, ensure deletion of the previous validator keys before continuing.
{% endhint %}

Now you can verify the accounts were imported successfully by doing a directory listing.

```bash
sudo ls -l /var/lib/nimbus_validator/validators
```

You should see a folder named for each of your validator's pubkey.

Create a **systemd unit file** to define your `validator.service` configuration.

```bash
sudo nano /etc/systemd/system/validator.service
```

Paste the following configuration into the file.

```bash
[Unit]
Description=Nimbus Validator Client service for Holeksy
Wants=network-online.target
After=network-online.target
Documentation=https://www.coincashew.com

[Service]
Type=simple
User=validator
Group=validator
Restart=on-failure
RestartSec=3
KillSignal=SIGINT
TimeoutStopSec=900
ExecStart=/usr/local/bin/nimbus_validator_client \
  --data-dir=/var/lib/nimbus_validator \
  --metrics \
  --metrics-port=8009 \
  --beacon-node=http://127.0.0.1:5052 \
  --graffiti="🏠🥩🪙🛡️" \
  --suggested-fee-recipient=<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>
  
[Install]
WantedBy=multi-user.target
```

* Replace`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>` with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
* If you wish to customize a short message that is included when you produce a block, add your message to the `--graffiti`. Maximum length is 16 characters.

To exit and save, press `Ctrl` + `X`, then `Y`, then `Enter`.

Setup ownership permissions, including hardening the access to this directory.

```bash
sudo chown -R validator:validator /var/lib/nimbus_validator
sudo chmod -R 700 /var/lib/nimbus_validator
```

Run the following to enable auto-start at boot time.

```bash
sudo systemctl daemon-reload
sudo systemctl enable validator
```

Finally, start your validator client and check it's status.

```bash
sudo systemctl start validator
sudo systemctl status validator
```

Check your logs to confirm that the validator clients are up and functioning.

```bash
sudo journalctl -fu validator | ccze
```
{% endtab %}

{% tab title="Combined (BN+VC)" %}
{% hint style="info" %}
**Note**: In the combined configuration, Nimbus runs both **validator client** and **beacon chain client** in one systemd service process.
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
{% endtab %}
{% endtabs %}

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

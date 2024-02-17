# Teku

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
for f in $HOME/staking-deposit-cli/validator_keys/keystore*.json; do sudo cp $HOME/validators-password.txt $HOME/staking-deposit-cli/validator_keys/$(basename $f .json).txt; done
```

Select a tab for your Teku configuration, either **Standalone Validator (Recommended)** or **Combined Beacon Node with Validator**. Running a standalone validator configuration is recommended for best modularity and redundancy.

{% tabs %}
{% tab title="Standalone Validator (Recommended)" %}
Copy your `validator_keys` to the data directory.

```bash
sudo mkdir -p /var/lib/teku_validator/validator_keys
sudo cp $HOME/staking-deposit-cli/validator_keys/keystore* /var/lib/teku_validator/validator_keys
```

Create a service user for the validator service, then create data directories and setup ownership permissions, including hardening the access to this directory.

```bash
sudo adduser --system --no-create-home --group validator
sudo chown -R validator:validator /var/lib/teku_validator
sudo chmod -R 700 /var/lib/teku_validator
```

Verify that your validator's keystore .json files and validator's passwords .txt files are present by checking the following directory.

```bash
sudo ls -l /var/lib/teku_validator/validator_keys
```

Example output of two validator's keystore.json files with matching password.txt files.

```
-rwx------ 1 validator validator 710 Sep 19 23:39 keystore-m_12381_3600_1_0_0-1695165818.json
-rwx------ 1 validator validator  43 Sep 19 23:39 keystore-m_12381_3600_1_0_0-1695165818.txt
-rwx------ 1 validator validator 710 Sep 19 23:39 keystore-m_12381_3600_2_0_0-1695165819.json
-rwx------ 1 validator validator  43 Sep 19 23:39 keystore-m_12381_3600_2_0_0-1695165819.txt
```

Create a **systemd unit file** to define your `validator.service` configuration.

```bash
sudo nano /etc/systemd/system/validator.service
```

Paste the following configuration into the file.&#x20;

```bash
[Unit]
Description=Teku Validator Client service for Holesky
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
ExecStart=/usr/local/bin/teku/bin/teku validator-client \
  --network=holesky \
  --data-path=/var/lib/teku_validator \
  --validator-keys=/var/lib/teku_validator/validator_keys:/var/lib/teku_validator/validator_keys \
  --beacon-node-api-endpoint=http://localhost:5052 \
  --validators-proposer-default-fee-recipient=<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS> \
  --validators-graffiti="🏠🥩🪙🛡️" \
  --metrics-enabled=true \
  --metrics-port=8008

[Install]
WantedBy=multi-user.target
```

* Replace**`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>`** with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
* If you wish to customize a short message that is included when you produce a block, add your message to the `--graffiti`.

To exit and save, press `Ctrl` + `X`, then `Y`, then `Enter`.

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

{% tab title="Combined BN+VC" %}
{% hint style="info" %}
**Note**: Teku is configured to run both **validator client** and **beacon chain client** in one process.
{% endhint %}

Setup ownership permissions, including hardening the access to this directory.

```bash
sudo chown -R consensus:consensus /var/lib/teku/
sudo chmod -R 700 /var/lib/teku/validator_keys
```

Copy your `validator_keys` to the data directory.

```bash
sudo mkdir -p /var/lib/teku/validator_keys
sudo cp $HOME/staking-deposit-cli/validator_keys/keystore* /var/lib/teku/validator_keys
```

Verify that your validator's keystore .json files and validator's passwords .txt files are present by checking the following directory.

```bash
sudo ls -l /var/lib/teku/validator_keys
```

Example output of two validator's keystore.json files with matching password.txt files.

```
-rwx------ 1 consensus consensus 710 Sep 19 23:39 keystore-m_12381_3600_1_0_0-1695165818.json
-rwx------ 1 consensus consensus  43 Sep 19 23:39 keystore-m_12381_3600_1_0_0-1695165818.txt
-rwx------ 1 consensus consensus 710 Sep 19 23:39 keystore-m_12381_3600_2_0_0-1695165819.json
-rwx------ 1 consensus consensus  43 Sep 19 23:39 keystore-m_12381_3600_2_0_0-1695165819.txt
```

Finally, restart Teku to use the new validators.

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

Delete the temporary **keystore password** file.

```bash
sudo rm $HOME/validators-password.txt
```

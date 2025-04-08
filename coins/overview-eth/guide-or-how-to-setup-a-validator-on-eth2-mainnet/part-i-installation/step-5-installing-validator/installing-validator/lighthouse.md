# Lighthouse

Create a service user for the validator service and create data directories.

```bash
sudo adduser --system --no-create-home --group validator
sudo mkdir -p /var/lib/lighthouse/validators
```

Import your validator keys by importing your **keystore file**. Be sure to enter your **keystore password** correctly.

```bash
sudo lighthouse account validator import \
  --network mainnet \
  --datadir /var/lib/lighthouse \
  --directory=$HOME/ethstaker_deposit-cli/validator_keys \
  --reuse-password
```

{% hint style="danger" %}
WARNING: Do not import your validator keys into multiple validator clients and run them at the same time, or you might get slashed. If moving validators to a new setup or different validator client, ensure deletion of the previous validator keys before continuing.
{% endhint %}

Verify that your keystore file was imported successfully.

<pre class="language-bash"><code class="lang-bash"><strong>sudo lighthouse account_manager validator list \
</strong><strong>  --network mainnet \
</strong>  --datadir /var/lib/lighthouse
</code></pre>

Once successful, you will be shown your **validator's public key**.

For example, `0x8d9138fcf5676e2031dc4eae30a2c92e3306903eeec83ca83f4f851afbd4cb3b33f710e6f4ac516b4598697b30b04302`

Setup ownership permissions, including hardening the access to this directory.

```bash
sudo chown -R validator:validator /var/lib/lighthouse/validators
sudo chmod 700 /var/lib/lighthouse/validators
```

Create a **systemd unit file** to define your `validator.service` configuration.

```bash
sudo nano /etc/systemd/system/validator.service
```

Paste the following configuration into the file.&#x20;

```bash
[Unit]
Description=Lighthouse Validator Client service for mainnet
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
ExecStart=/usr/local/bin/lighthouse vc \
  --network mainnet \
  --beacon-nodes http://localhost:5052 \
  --datadir /var/lib/lighthouse \
  --graffiti="🏠🥩🪙🛡️" \
  --metrics \
  --metrics-port 8009 \
  --suggested-fee-recipient=<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
```

* Replac&#x65;**`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>`** with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
* If you wish to customize a graffiti message that is included when you produce a block, add your message between the double quotes after `--graffiti`. Maximum length is 16 characters.

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

For example when using 2 validators, logs will show the following:

```bash
INFO Enabled validator          voting_pubkey: 0x82b225f66476962b161ed015786df00a0b7b28231915e6d09e81ba8d5c4ae8502b6d5337e3bf101ad72741dc69f0a7cf, signing_method: local_keystore
INFO Enabled validator          voting_pubkey: 0x95d39860a0d6ea3b92cba78069d21f3a987988f3b8417b14f0945353d79ed9e338bbe6e9d63d487abc044a710ce34866, signing_method: local_keystore
INFO Initialized validators     enabled: 2, disabled: 0
```

Press `Ctrl` + `C` to exit the logs.

**Example of Synced Lighthouse Validator Client Logs**

* Once the validator is active and proceeded through the validator activation queue, attestation messages will appear indicating successful attestations.
* Notice the key words "`INFO Successfully published attestations`".

```
Feb 08 01:01:0 INFO Successfully published attestations type: unaggregated, slot: 12422, committee_index: 3, head_block: 0xabc111daedf1281..., validator_indices: [12345], count:1, service: attestation 
Feb 08 01:01:30 INFO Connected to beacon node(s) synced: 1, available: 1, total: 1, service: notifier
```

#### Cleanup leftover validator\_keys <a href="#optional-step-0-cleanup-leftover-validator_keys" id="optional-step-0-cleanup-leftover-validator_keys"></a>

Verify that you have backups of validator\_keys directory. The contents are the keystore files.

Having backup copies of your validator\_keys directory on USB media can make recovery from node problems quicker. Validator keys can always be regenerated from secret recovery mnemonic phrase.

You may safely delete the directory.

```bash
# Remove default validator_key directory
sudo rm -r $HOME/staking-deposit-cli/validator_keys
```

---
description: Setup a Lodestar validator client
---

# Lodestar

Create a service user for the validator service, as this improves security, then create data directories.

<pre class="language-bash"><code class="lang-bash">sudo adduser --system --no-create-home --group validator
<strong>sudo mkdir -p /var/lib/lodestar/validators
</strong></code></pre>

Import your validator keys by importing your **keystore file**. Be sure to enter your **keystore password** correctly.

```bash
cd /usr/local/bin/lodestar
sudo ./lodestar validator import \
  --network hoodi \
  --dataDir="/var/lib/lodestar/validators" \
  --keystore=$HOME/ethstaker_deposit-cli/validator_keys
```

{% hint style="danger" %}
WARNING: Do not import your validator keys into multiple validator clients and run them at the same time, or you might get slashed. If moving validators to a new setup or different validator client, ensure deletion of the previous validator keys before continuing.
{% endhint %}

Verify that your keystore file was imported successfully.

```bash
sudo ./lodestar validator list \
  --network hoodi \
  --dataDir="/var/lib/lodestar/validators"
```

Once successful, you will be shown your **validator's public key**.

For example, `0x8d9138fcf5676e2031dc4eae30a2c92e3306903eeec83ca83f4f851afbd4cb3b33f710e6f4ac516b4598697b30b04302`

Setup ownership permissions, including hardening the access to this directory.

```bash
sudo chown -R validator:validator /var/lib/lodestar/validators
sudo chmod 700 /var/lib/lodestar/validators
```

Create a **systemd unit file** to define your `validator.service` configuration.

```bash
sudo nano /etc/systemd/system/validator.service
```

Paste the following configuration into the file.

```bash
[Unit]
Description=Lodestar Validator Client service for Hoodi
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
TimeoutStopSec=300
WorkingDirectory=/usr/local/bin/lodestar
ExecStart=/usr/local/bin/lodestar/lodestar validator \
  --network hoodi \
  --dataDir /var/lib/lodestar/validators \
  --beaconNodes http://127.0.0.1:5052 \
  --metrics true \
  --metrics.port 8009 \
  --graffiti "🏠🥩🪙🛡️" \
  --suggestedFeeRecipient <0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>
  
[Install]
WantedBy=multi-user.target
```

* Replace\*\*`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>`\*\* with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
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
info: 100% of local keystores imported. current=2 total=2 rate=975.61keys/m
info: 2 local keystores
info: 0x82b225f66476962b161ed015786df00a0b7b28231915e6d09e81ba8d5c4ae8502b6d5337e3bf101ad72741dc69f0a7cf
info: 0x95d39860a0d6ea3b92cba78069d21f3a987988f3b8417b14f0945353d79ed9e338bbe6e9d63d487abc044a710ce34866
```

Press `Ctrl` + `C` to exit the logs.

**Example of Synced Lodestar Validator Client Logs**

* Once the validator is active and proceeded through the validator activation queue, attestation messages will appear indicating successful attestations.
* Notice the key words "`info: Published attestations`".

```bash
Feb-1  03:33:30.228     info: Published aggregateAndProofs slot=2662, index=13, count=1
Feb-1  03:37:48.393     info: Published attestations slot=2699, index=20, count=1
Feb-1  03:46:36.450     info: Published attestations slot=2713, index=2, count=1
Feb-1  03:53:48.944     info: Published attestations slot=2765, index=21, count=1
Feb-1  04:01:48.812     info: Published attestations slot=2809, index=17, count=1
```

#### Cleanup leftover validator\_keys <a href="#optional-step-0-cleanup-leftover-validator_keys" id="optional-step-0-cleanup-leftover-validator_keys"></a>

Verify that you have backups of validator\_keys directory. The contents are the keystore files.

Having backup copies of your validator\_keys directory on USB media can make recovery from node problems quicker. Validator keys can always be regenerated from secret recovery mnemonic phrase.

You may safely delete the directory.

```bash
# Remove default validator_key directory
sudo rm -r $HOME/staking-deposit-cli/validator_keys
```

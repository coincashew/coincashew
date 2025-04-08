# Prysm

Create a service user for the validator service, as this improves security, then create data directories.

<pre class="language-bash"><code class="lang-bash">sudo adduser --system --no-create-home --group validator
<strong>sudo mkdir -p /var/lib/prysm/validators
</strong></code></pre>

Storing your **keystore password** in a text file is required so that Prysm can decrypt and load your validators automatically.

Create a file to store your **keystore password**. Type your password in this file.

<pre class="language-bash"><code class="lang-bash"><strong>sudo nano /var/lib/prysm/validators/password.txt
</strong></code></pre>

To exit and save, press `Ctrl` + `X`, then `Y`, then `Enter`.

Confirm that your **keystore password** is correct.

```bash
sudo cat /var/lib/prysm/validators/password.txt
```

Import your validator keys by importing your **keystore file**. When asked to create a new wallet password, enter your **keystore password**. When prompted for the imported accounts password, enter your **keystore password** again.

```bash
sudo /usr/local/bin/validator accounts import \
  --accept-terms-of-use \
  --hoodi \
  --wallet-dir=/var/lib/prysm/validators \
  --keys-dir=$HOME/ethstaker_deposit-cli/validator_keys
```

{% hint style="danger" %}
WARNING: Do not import your validator keys into multiple validator clients and run them at the same time, or you might get slashed. If moving validators to a new setup or different validator client, ensure deletion of the previous validator keys before continuing.
{% endhint %}

Verify that your keystore file was imported successfully.

<pre class="language-bash"><code class="lang-bash"><strong>sudo /usr/local/bin/validator accounts list \
</strong>  --wallet-dir=/var/lib/prysm/validators \
  --hoodi
</code></pre>

Once successful, you will be shown your **validator's public key**. For example:

```
Showing 2 validator accounts
View the eth1 deposit transaction data for your accounts by running `validator accounts list --show-deposit-data`

Account 0 | gently-learning-chamois
[validating public key] 0x95d39860a0d6ea3b92cba78069d21f3a987988f3b8417b14f0945353d79ed9e338bbe6e9d63d487abc044a710ce34866

Account 1 | presumably-powerful-lynx
[validating public key] 0x82b225f66476962b161ed015786df00a0b7b28231915e6d09e81ba8d5c4ae8502b6d5337e3bf101ad72741dc69f0a7cf
```

Setup ownership permissions, including hardening the access to this directory.

```bash
sudo chown -R validator:validator /var/lib/prysm/validators
sudo chmod 700 /var/lib/prysm/validators
```

Create a **systemd unit file** to define your `validator.service` configuration.

```bash
sudo nano /etc/systemd/system/validator.service
```

Paste the following configuration into the file.

```bash
[Unit]
Description=Prysm Validator Client service for Hoodi
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
ExecStart=/usr/local/bin/validator \
  --hoodi \
  --accept-terms-of-use \
  --datadir=/var/lib/prysm/validators \
  --beacon-rpc-provider=localhost:4000 \
  --beacon-rpc-gateway-provider=localhost:5052 \
  --wallet-dir=/var/lib/prysm/validators \
  --wallet-password-file=/var/lib/prysm/validators/password.txt \
  --graffiti="🏠🥩🪙🛡️" \
  --monitoring-port=8009 \
  --suggested-fee-recipient=<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>

[Install]
WantedBy=multi-user.target
```

* Replace`<0x_CHANGE_THIS_TO_MY_ETH_FEE_RECIPIENT_ADDRESS>` with your own Ethereum address that you control. Tips are sent to this address and are immediately spendable.
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
level=info msg="Validating for public key" prefix=validator publicKey=0x95d39860a0d6
level=info msg="Validating for public key" prefix=validator publicKey=0x82b225f66476
```

Press `Ctrl` + `C` to exit the logs.

**Example of Synced Prysm Validator Client Logs**

* Once the validator is active and proceeded through the validator activation queue, attestation messages will appear indicating successful attestations.
* Notice the key words "`INFO validator: Submitted new attestations`".

```bash
[2022-11-21 1:21:21]  INFO validator: Submitted new attestations AggregatorIndices=[12412] AttesterIndices=[73613] BeaconBlockRoot=0xca3213f1a3 CommitteeIndex=12 Slot=12422 SourceEpoch=12318 SourceRoot=0xd9ddeza1289 TargetEpoch=121231 TargetRoot=0xff313419acaa1
```

#### Cleanup leftover validator\_keys <a href="#optional-step-0-cleanup-leftover-validator_keys" id="optional-step-0-cleanup-leftover-validator_keys"></a>

Verify that you have backups of validator\_keys directory. The contents are the keystore files.

Having backup copies of your validator\_keys directory on USB media can make recovery from node problems quicker. Validator keys can always be regenerated from secret recovery mnemonic phrase.

You may safely delete the directory.

```bash
# Remove default validator_key directory
sudo rm -r $HOME/staking-deposit-cli/validator_keys
```

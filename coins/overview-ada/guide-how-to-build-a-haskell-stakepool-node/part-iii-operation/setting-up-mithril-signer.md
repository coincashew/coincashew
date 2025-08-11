# Setting up a Mithril Signer

The [Mithril](https://mithril.network/doc/mithril/intro/) project implements Stake-based Threshold Multisignatures on the Cardano network. The Mithril protocol allows individual stakeholders in the Cardano blockchain network to sign messages aggregated into a multi-signature, guaranteeing that the stakeholders represent a minimum share of the total stake.

To set up a Mithril Signer, you need to:

1. Install Mithril Signer on the block-producing node for your stake pool.

2. Implement [Squid](https://www.squid-cache.org/) as a forward proxy on one the relays for your stake pool.

Implementing a Mithril Signer and Relay enables your stake pool to contribute to securing the integrity of Mithril snapshots available on the Cardano network.

{% hint style="info" %}
Mithril has numerous potential applications, including synchronizing data for both light and full-node wallets, as well as facilitating data exchanges with layer 2 solutions such as bridges, sidechains, rollups and state channels. For most stake pools, implementing a Mithril client to bootstrap a Cardano Node using a Mithril snapshot is not necessary.
{% endhint %}

## Installing Mithril Signer on Your Block Producer

**To install Rust:**

1. Using a terminal window on your block producer, type the following command:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2. When prompted, press **1** to proceed with a standard installation

3. To set up the current shell session, type:

```bash
source "$HOME/.cargo/env"
```

4. To verify the Rust version, type:

```bash
rustc --version
```

**To install Mithril:**

1. To download Mithril, using a terminal window on your block producer, type:

```bash
cd $HOME/git
git clone https://github.com/input-output-hk/mithril.git ./mithril
```

2. To identify the latest Mithril version available, visit the [Latest Release](https://github.com/input-output-hk/mithril/releases/latest) page in the Mithril GitHub repository.

3. To select the latest version, type the following command where <ReleaseVersion> is the version that you identified in step 2

```bash
cd $HOME/git/mithril
git checkout <ReleaseVersion>
```

4. To build Mithril Signer, type:

```bash
cd $HOME/git/mithril/mithril-signer
make test
```

```bash
make build
```

5. To verify that Mithril compiled successfully, type:

```bash
cd $HOME/git/mithril/mithril-signer
./mithril-signer -V
./mithril-signer -h
```

6. To move the mithril-signer binary to a dedicated folder, type:

```bash
mkdir $NODE_HOME/mithril-signer
cd $HOME/git/mithril/mithril-signer
sudo mv -f mithril-signer $NODE_HOME/mithril-signer
```

7. To configure environment variables, type the following command where `<SquidRelayIPAddress>` is the IP address of the relay in your stake pool configuration where you plan to implement the Squid forward proxy:

```bash
sudo cat > $NODE_HOME/mithril-signer/mithril-signer.env << EOF
KES_SECRET_KEY_PATH=$NODE_HOME/kes.skey
OPERATIONAL_CERTIFICATE_PATH=$NODE_HOME/node.cert
NETWORK=mainnet
AGGREGATOR_ENDPOINT=https://aggregator.release-mainnet.api.mithril.network/aggregator
RUN_INTERVAL=60000
DB_DIRECTORY=$NODE_HOME/db
CARDANO_NODE_SOCKET_PATH=$NODE_HOME/db/socket
CARDANO_CLI_PATH=/usr/local/bin/cardano-cli
DATA_STORES_DIRECTORY=/opt/mithril/stores
STORE_RETENTION_LIMIT=5
ERA_READER_ADAPTER_TYPE=cardano-chain
ERA_READER_ADAPTER_PARAMS=$(jq -nc --arg address $(wget -q -O - https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/release-mainnet/era.addr) --arg verification_key $(wget -q -O - https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/release-mainnet/era.vkey) '{"address": $address, "verification_key": $verification_key}')
RELAY_ENDPOINT=<SquidRelayIPAddress>:3132
EOF
```

8. To create a systemd service to manage Mithril, type:

```bash
sudo nano mithril-signer.service
```

9. In the `mithril-signer.service` file, copy and paste the following lines where `<UserName>` is the user under which to execute the processes of the service, `<EnvFilePath>` is the full path to the `mithril-signer.env` file, and `<ExecFilePath>` is the full path to the `mithril-signer` binary executable file.

```bash
[Unit]
Description=Mithril signer service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=60
User=<UserName>
EnvironmentFile=<EnvFilePath>
ExecStart=<ExecFilePath> -vvv

[Install]
WantedBy=multi-user.target
```

10. To move the `mithril-signer.service` file and set file permissions, type:

```bash
sudo mv mithril-signer.service /etc/systemd/system/mithril-signer.service
sudo chmod 644 /etc/systemd/system/mithril-signer.service
```

11. To enable the service to start when the block producer boots, type:

```bash
sudo systemctl enable mithril-signer
sudo systemctl daemon-reload
```

12. To start the service, type:

```bash
sudo systemctl start mithril-signer
```

13. To verify that the service is running, type:

```bash
systemctl status mithril-signer.service
```

14. Optionally, to remove the Mithril source files, type:

```bash
cd $HOME/git/
rm -rf ./mithril
```

## Implementing Squid on a Relay Node

Configuring Squid as a forward proxy on a relay node in your stake pool configuration handles network traffic between a Mithril Signer and Mithril Aggregator securely. Mithril Aggregator is responsible for collecting and aggregating individual signatures from Mithril Signers into a multi-signature. To protect the security of your block-producing node, use the following Squid configuration.

**To configure Squid:**

1. On the relay node where you want to set up a forward proxy to protect your Mithril Signer, type:

```bash
sudo apt-get install squid
sudo systemctl enable squid
sudo systemctl daemon-reload
sudo systemctl start squid
```

2. To configure Squid, type:

```bash
cd /etc/squid/
sudo cp ./squid.conf ./squid.conf.bak
sudo nano squid.conf
```

3. In the `squid.conf` file, copy and paste the following lines where `<SquidRelayIPAddress>` is the IP address where the relay hosting Squid listens, and `<BlockProducerIPAddress>` is the IP address of the block-producing node hosting Mithril Signer:

```bash
# Listening port (port 3132 is recommended)
http_port <SquidRelayIPAddress>:3132

# ACL for internal IP of your block producer node
acl block_producer_internal_ip src <BlockProducerIPAddress>

# ACL for aggregator endpoint
acl aggregator_domain dstdomain .mithril.network

# ACL for SSL port only
acl SSL_port port 443

# Allowed traffic
http_access allow block_producer_internal_ip aggregator_domain SSL_port

# Do not disclose block producer internal IP
forwarded_for delete

# Turn off via header
via off
 
# Deny request for original source of a request
follow_x_forwarded_for deny all
 
# Anonymize request headers
request_header_access Authorization allow all
request_header_access Proxy-Authorization allow all
request_header_access Cache-Control allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Connection allow all
request_header_access All deny all

# Disable cache
cache deny all

# Deny everything else
http_access deny all
```

4. To configure UFW firewall rules for Squid, type the following command where `<BlockProducerIPAddress>` is the IP address of your block-producing node hosting Mithril Signer, and `<SquidRelayIPAddress>` is the IP address of the relay node hosting Squid:

```bash
sudo ufw allow from <BlockProducerIPAddress> to <SquidRelayIPAddress> port 3132 proto tcp
```

5. To restart Squid, type:

```bash
sudo systemctl restart squid
```

## Verifying Your Mithril Signer Implementation

**To verify that your Mithril Signer is registered:**

1. Type the following commands to download the `verify_signer_registration.sh` script:

```bash
cd $NODE_HOME/mithril-signer
wget https://mithril.network/doc/scripts/verify_signer_registration.sh
chmod +x verify_signer_registration.sh
```

2. To run the script, type the following command where <PoolID> is your stake pool ID using Bech32 format:

```bash
cd $NODE_HOME/mithril-signer
PARTY_ID=<PoolID> AGGREGATOR_ENDPOINT=https://aggregator.release-mainnet.api.mithril.network/aggregator ./verify_signer_registration.sh
```

If your Mithril Signer is registered, then the script displays:

```bash
>> Congrats, your signer node is registered!
```

{% hint style="info" %}
To verify manually that your Mithril Signer is registered, visit the URL `https://aggregator.release-mainnet.api.mithril.network/aggregator/signers/registered/<CurrentEpoch>` using a Web browser, where <CurrentEpoch> is the current Cardano epoch, and then search the Web page for your stake pool ID in Bech32 format.
{% endhint %}

After waiting two epochs, you can verify that your Mithril Signer signs certificates.

**To verify that your Mithril Signer signs certificates:**

1. Type the following commands to download the `verify_signer_signature.sh` script:

```bash
cd $NODE_HOME/mithril-signer
wget https://mithril.network/doc/scripts/verify_signer_signature.sh
chmod +x verify_signer_signature.sh
```

2. To run the script, type the following command where <PoolID> is your stake pool ID using Bech32 format:

```bash
cd $NODE_HOME/mithril-signer
PARTY_ID=<PoolID> AGGREGATOR_ENDPOINT=https://aggregator.release-mainnet.api.mithril.network/aggregator ./verify_signer_signature.sh
```

If your Mithril signer signs certificates, then the `verify_signer_signature.sh` script displays a list of certificates that your Mithril Signer signed.
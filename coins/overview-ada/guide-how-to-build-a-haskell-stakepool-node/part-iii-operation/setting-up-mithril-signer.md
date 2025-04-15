# Setting up a Mithril Signer

{% hint style="info" %}
**Mithril** is a research project whose goal is to provide Stake-based Threshold Multisignatures on top of the Cardano network. In a nutshell, Mithril can be summarized as: A protocol that allows stakeholders in a proof-of-stake blockchain network to individually sign messages that are aggregated into a multi-signature, which guarantees that they represent a minimum share of the total stake. [Official documentation is available here.](https://mithril.network/doc/mithril/intro/)
{% endhint %}

2 components need to be installed :

* A Mithril Signer on your Cardano block producer
* A Mithril Relay on one of your Cardano relays

## Installing Mithril Signer on Block Producer

### Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

(Proceed with standard - default installation)

Source your env file under $HOME/.cargo. :

```bash
. "$HOME/.cargo/env"
```

Check Rust Version :

```bash
rustc --version
```

### Install Mithril from github

Download from github

```bash
cd $HOME/git
git clone https://github.com/input-output-hk/mithril.git mithril
```

Find the latest version available : https://github.com/input-output-hk/mithril/releases/latest

This guide is based on version v2437.1. Change accordingly to the latest version available and compatible with cardano mainnet.

```bash
cd $HOME/git/mithril
git checkout 2437.1
```

Build Mithril Signer :

```bash
cd $HOME/git/mithril/mithril-signer
make test
```

```bash
make build
```

Verify the Build Version

```bash
cd $HOME/git/mithril/mithril-signer
./mithril-signer -V
```

Verify the build is working correctly

```bash
./mithril-signer -h
```

Move mithril-signer to a dedicated folder :

```bash
mkdir $NODE_HOME/mithril-signer
cd $HOME/git/mithril/mithril-signer
sudo mv -f mithril-signer $NODE_HOME/mithril-signer
```

### Setup Mithril Signer ENV variables

Adjust **RELAY\_ENDPOINT** with your Relay IP that will host Mithril Relay

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
RELAY_ENDPOINT=<YOUR RELAY IP THAT WILL RUN SQUID PROXY>:3132
EOF
```

### Service creation

```bash
sudo nano mithril-signer.service
```

```bash
[Unit]
Description=Mithril signer service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=60
User=kirael
EnvironmentFile=<FULL PATH TO YOUR mithril-signer.env ENV FILE>
ExecStart=<FULL PATH TO YOUR mithril-signer EXE FILE> -vvv

[Install]
WantedBy=multi-user.target
```

Move the service file and set permissions

```bash
sudo mv mithril-signer.service /etc/systemd/system/mithril-signer.service
sudo chmod 644 /etc/systemd/system/mithril-signer.service
```

Enable service start on boot

```bash
sudo systemctl enable mithril-signer
sudo systemctl daemon-reload
```

Start the service

```bash
sudo systemctl start mithril-signer
```

Check the service

```bash
systemctl status mithril-signer.service
```

### Clean

```bash
cd $HOME/git/
rm -rf mithril
```

## Installing Mithril Relay on your Cardano Relay

{% hint style="info" %}
The Mithril relay node serves as a forward proxy, relaying traffic between the Mithril signer and the Mithril aggregator. When appropriately configured, it facilitates the security of the block-producing node. You can use squid to operate this forward proxy, and this section presents a recommended configuration.
{% endhint %}

### Install Squid and set service start

```bash
sudo apt-get install squid
sudo systemctl enable squid
sudo systemctl daemon-reload
sudo systemctl start squid
```

Make a copy of the squid original conf

```bash
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
```

### Create a Squid configuration

Create a new squid configuration file for Mithril

```bash
sudo nano squid.conf 
```

Adjust with your Relay Listening IP and your Block Producer IP

```bash
# Listening port (port 3132 is recommended)
http_port <YOUR RELAY LISTENING IP>:3132

# ACL for internal IP of your block producer node
acl block_producer_internal_ip src <YOUR BP MITHRIL SIGNER IP>

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

Move the new squid.conf

```bash
sudo mv -f squid.conf /etc/squid/squid.conf
```

### Configure your UFW Firewall rule

```bash
sudo ufw allow from <YOUR BP MITHRIL SIGNER IP> to <YOUR RELAY IP> port 3132 proto tcp
```

### Restart Squid

```bash
sudo systemctl restart squid
```

## Verify that your Mithril Signer works

You can check if your signer is registered and contributes with individual signatures :

### Verify your signer is registered

Download the script into the mithril-signer directory

```bash
cd $NODE_HOME/mithril-signer
wget https://mithril.network/doc/scripts/verify_signer_registration.sh
```

Make the script executable:

```bash
chmod +x verify_signer_registration.sh
```

Run Script (replace POOL\_ID sith your stakepool ID

```bash
cd $NODE_HOME/mithril-signer
PARTY_ID=<POOL_ID> AGGREGATOR_ENDPOINT=https://aggregator.release-mainnet.api.mithril.network/aggregator ./verify_signer_registration.sh
```

If your signer is registered, you should see this message:

```bash
>> Congrats, your signer node is registered!
```

Otherwise, you should see this error message:

```bash
>> Oops, your signer node is not registered. Party ID not found among the signers registered at epoch XXX.
```

### Verify your signer contributes with individual signatures

After waiting for two epochs, you will be able to verify that your signer is contributing with individual signatures. First, download the script into the mithril-signer directory

```bash
cd $NODE_HOME/mithril-signer
wget https://mithril.network/doc/scripts/verify_signer_signature.sh
```

Make the script executable:

```bash
chmod +x verify_signer_signature.sh
```

Run Script (replace POOL\_ID sith your stakepool ID

```bash
cd $NODE_HOME/mithril-signer
PARTY_ID=<POOL_ID> AGGREGATOR_ENDPOINT=https://aggregator.release-mainnet.api.mithril.network/aggregator ./verify_signer_signature.sh
```

If your signer is contributing, you should see this message:

```bash
>> Congrats, you have signed this certificate: ...
```

Otherwise, you should see this error message:

```bash
>> Oops, your party id was not found in the last 20 certificates. Please try again later.
```

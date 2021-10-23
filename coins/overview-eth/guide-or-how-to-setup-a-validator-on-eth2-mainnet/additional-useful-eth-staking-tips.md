# Additional Useful ETH Staking Tips

### 8.1 Voluntary exit a validator

{% hint style="info" %}
Use this command to signal your intentions to stop validating with your validator. This means you no longer want to stake with your validator and want to turn off your node.

* Voluntary exiting takes a minimum of 2048 epochs (or \~9days). There is a queue to exit and a delay before your validator is finally exited.
* Once a validator is exited in phase 0, this is non-reversible and you can no longer restart validating again.
* Your funds will not be available for withdrawal until phase 1.5 or later.
* After your validator leaves the exit queue and is truely exited, it is safe to turn off your beacon node and validator.
{% endhint %}

{% tabs %}
{% tab title="Lighthouse" %}
```bash
lighthouse account validator exit \
--keystore $HOME/.lighthouse/mainnet/validators/<0x validator>/<keystore.json file> \
--beacon-node http://localhost:5052 \
--network mainnet
```
{% endtab %}

{% tab title="Teku" %}
```bash
teku voluntary-exit \
--epoch=<epoch number to exit> \
--beacon-node-api-endpoint=http://127.0.0.1:5051 \
--validator-keys=<path to keystore.json>:<path to password.txt file>
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
build/nimbus_beacon_node deposits exit --validator=<VALIDATOR_PUBLIC_KEY> --data-dir=/var/lib/nimbus
```
{% endtab %}

{% tab title="Prysm" %}
```bash
$HOME/prysm/prysm.sh validator accounts voluntary-exit
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
./lodestar account validator voluntary-exit --publicKey 0xF00
```
{% endtab %}
{% endtabs %}

### :key2: 8.2 Verify your mnemonic phrase

Using the eth2deposit-cli tool, ensure you can regenerate the same eth2 key pairs by restoring your `validator_keys`

```bash
cd $HOME/eth2deposit-cli 
./deposit.sh existing-mnemonic --chain mainnet
```

{% hint style="info" %}
When the **pubkey** in both \*\*keystore files \*\*are \*\*identical, \*\*this means your mnemonic phrase is veritably correct. Other fields will be different because of salting.
{% endhint %}

### :robot:8.3 Add additional validators

Backup and move your existing `validator_key` directory and append the date to the end.

```bash
# Adjust your eth2deposit-cli directory accordingly
cd $HOME/eth2deposit-cli
# Renames and append the date to the existing validator_key directory
mv validator_key validator_key_$(date +"%Y%d%m-%H%M%S")
# Optional: you can also delete this folder since it can be regenerated.
```

{% hint style="info" %}
Using the eth2deposit-cli tool, you can add more validators by creating a new deposit data file and `validator_keys`
{% endhint %}

2\. For example, in case we originally created **3 validators** but now wish to **add 5 more validators**, we could use the following command. Select the tab depending on how you acquired [**eth2deposit tool**](https://github.com/ethereum/eth2.0-deposit-cli).

{% hint style="warning" %}
**Security recommendation reminder**: For best security practices, key management and other activities where you type your 24 word mnemonic seed should be completed on an air-gapped offline cold machine booted from USB drive.
{% endhint %}

{% hint style="danger" %}
Reminder to use the same **keystore password.**
{% endhint %}

{% tabs %}
{% tab title="Build from source code" %}
```bash
# Generate from an existing mnemonic 5 more validators when 3 were previously already made
./deposit.sh existing-mnemonic --validator_start_index 3 --num_validators 5 --chain mainnet
```
{% endtab %}

{% tab title="Pre-built eth2deposit-cli binaries" %}
```bash
# Generate from an existing mnemonic 5 more validators when 3 were previously already made
./deposit existing-mnemonic --validator_start_index 3 --num_validators 5 --chain mainnet
```
{% endtab %}
{% endtabs %}

3\. Complete the steps of uploading the `deposit_data-#########.json` to the [official Eth2 launch pad site](https://launchpad.ethereum.org) and making your corresponding 32 ETH deposit transactions.

4\. Finish by stopping your validator, importing the new validator key(s), restarting your validator and verifying the logs ensuring everything still works without error. [Review steps 2 and onward of the main guide if you need a refresher.](additional-useful-eth-staking-tips.md#2-signup-to-be-a-validator-at-the-launchpad)

5\. Finally, verify your **existing **validator's attestations are working with public block explorer such as

[https://beaconcha.in/](https://beaconcha.in) or [https://beaconscan.com/](https://beaconscan.com)

Enter your validator's pubkey to view its status.

{% hint style="info" %}
Your additional validators are now in the activation queue waiting their turn. Check your estimated activation time at [https://eth2-validator-queue.web.app/](https://eth2-validator-queue.web.app)
{% endhint %}

### :money\_with\_wings: 8.4 Switch / migrate consensus client (Eth2 client) with slash protection

{% hint style="info" %}
The key takeaway in this process is to avoid running two consensus clients simultaneously. You want to avoid being punished by a slashing penalty, which causes a loss of ether.
{% endhint %}

#### :octagonal\_sign: 8.4.1 Stop old beacon chain and old validator.

In order to export the slashing database, the validator needs to be stopped.

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl stop beacon-chain validator
```
{% endtab %}

{% tab title="Nimbus | Teku" %}
```
sudo systemctl stop beacon-chain
```
{% endtab %}
{% endtabs %}

#### :minidisc: 8.4.2 Export slashing database (Optional)

{% hint style="info" %}
[EIP-3076](https://eips.ethereum.org/EIPS/eip-3076) implements a standard to safety migrate validator keys between consensus clients. This is the exported contents of the slashing database.
{% endhint %}

Update the export .json file location and name.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
lighthouse account validator slashing-protection export <lighthouse_interchange.json>
```
{% endtab %}

{% tab title="Nimbus" %}
To be implemented
{% endtab %}

{% tab title="Teku" %}
```bash
teku slashing-protection export --to=<FILE>
```
{% endtab %}

{% tab title="Prysm" %}
```bash
prysm.sh validator slashing-protection export --datadir=/path/to/your/wallet --slashing-protection-export-dir=/path/to/desired/outputdir
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
./lodestar account validator slashing-protection export --network mainnet --file interchange.json
```
{% endtab %}
{% endtabs %}

#### :construction: 8.4.3 Setup and install new validator / beacon chain

Now you need to setup/install your new validator **but do not start running the systemd processes**. Be sure to thoroughly follow your new validator's [Section 4. Configure a ETH2 beacon chain and validator.](../guide-or-how-to-setup-a-validator-on-eth2-testnet.md#4-configure-a-eth2-beacon-chain-node-and-validator) You will need to build/install the client, configure port forwarding/firewalls, and new systemd unit files.

{% hint style="warning" %}
:sparkles: **Pro Tip**: During the process of re-importing validator keys, **wait at least 13 minutes** or two epochs to prevent slashing penalties. You must avoid running two consensus clients with same validator keys at the same time.
{% endhint %}

{% hint style="danger" %}
:octagonal\_sign: **Critical Step**: Do not start any **systemd processes** until either you have imported the slashing database or you have **waited at least 13 minutes or two epochs**.
{% endhint %}

#### :open\_file\_folder: 8.4.4 Import slashing database (Optional)

Using your new consensus client, run the following command and update the relevant path to import your slashing database from 2 steps ago.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
lighthouse account validator slashing-protection import <my_interchange.json>
```
{% endtab %}

{% tab title="Nimbus" %}
To be implemented
{% endtab %}

{% tab title="Teku" %}
```bash
teku slashing-protection import --from=<FILE>
```
{% endtab %}

{% tab title="Prysm" %}
```bash
prysm.sh validator slashing-protection import --datadir=/path/to/your/wallet --slashing-protection-json-file=/path/to/desiredimportfile
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
./lodestar account validator slashing-protection import --network mainnet --file interchange.json
```
{% endtab %}
{% endtabs %}

#### :stars: 8.4.5 Start new validator and new beacon chain

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl start beacon-chain validator
```
{% endtab %}

{% tab title="Nimbus | Teku" %}
```
sudo systemctl start beacon-chain
```
{% endtab %}
{% endtabs %}

#### :fire: 8.4.6 Verify functionality

Check the logs to verify the services are working properly and ensure there are no errors.

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl status beacon-chain validator
```
{% endtab %}

{% tab title="Nimbus | Teku" %}
```
sudo systemctl status beacon-chain
```
{% endtab %}
{% endtabs %}

Finally, verify your validator's attestations are working with public block explorer such as

[https://beaconcha.in/](https://beaconcha.in)

Enter your validator's pubkey to view its status.

#### :fire\_extinguisher: 8.4.7 Update Monitoring with Prometheus and Grafana

[Review section 6](../guide-or-how-to-setup-a-validator-on-eth2-testnet.md#6-monitoring-your-validator-with-grafana-and-prometheus) and change your `prometheus.yml`. Ensure prometheus is connected to your new consensus client's metrics port. You will also want to import your new consensus client's dashboard.

### :desktop: 8.5 Use all available LVM disk space

During installation of Ubuntu Server, a common issue arises where your hard drive's space is not fully available for use.

```bash
# View your disk drives
sudo -s lvm

# Change the logical volume filesystem path if required
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

#exit lvextend
exit

# Resize file system to use the new available space in the logical volume
resize2fs /dev/ubuntu-vg/ubuntu-lv

## Verify new available space
df -h

# Example output of a 2TB drive where 25% is used
# Filesystem                         Size   Used Avail Use% Mounted on
# /dev/ubuntu-vg/ubuntu-lv           2000G  500G  1500G  25% /
```

**Source reference**: [https://askubuntu.com/questions/1106795/ubuntu-server-18-04-lvm-out-of-space-with-improper-default-partitioning](https://askubuntu.com/questions/1106795/ubuntu-server-18-04-lvm-out-of-space-with-improper-default-partitioning)

### :vertical\_traffic\_light: 8.6 Reduce network bandwidth usage

{% hint style="info" %}
Hosting your own execution client can consume hundreds of gigabytes of data per day. Because data plans can be limited or costly, you might desire to slow down data usage but still maintain good connectivity to the network.
{% endhint %}

Edit your eth1.service unit file.

```bash
sudo nano /etc/systemd/system/eth1.service
```

Add the following flag to limit the number of peers on the `ExecStart` line.

{% tabs %}
{% tab title="Geth" %}
```bash
--maxpeers 10
# Example
# ExecStart       = /usr/bin/geth --maxpeers 10 --http --ws
```
{% endtab %}

{% tab title="OpenEthereum (Parity)" %}
```bash
--max-peers 10
# Example
# ExecStart       = <home directory>/openethereum/openethereum --max-peers 10
```
{% endtab %}

{% tab title="Besu" %}
```bash
--max-peers 10
# Example
# ExecStart       = <home directory>/besu/bin/besu --max-peers 10 --rpc-http-enabled
```
{% endtab %}

{% tab title="Nethermind" %}
```bash
--Network.ActivePeersMaxCount 10
# Example
# ExecStart       = <home directory>/nethermind/Nethermind.Runner --Network.ActivePeersMaxCount 10 --JsonRpc.Enabled true
```
{% endtab %}

{% tab title="Erigon" %}
```
--maxpeers 10
```
{% endtab %}
{% endtabs %}

Finally, reload the new unit file and restart the execution client.

```bash
sudo systemctl daemon-reload
sudo systemctl restart eth1
```

### :open\_file\_folder: 8.7 Important directory locations

{% hint style="info" %}
In case you need to locate your validator keys, database directories or other important files.
{% endhint %}

#### Consensus engine files and locations

{% tabs %}
{% tab title="Lighthouse" %}
```bash
# Validator Keys
~/.lighthouse/mainnet/validators

# Beacon Chain Data
~/.lighthouse/mainnet/beacon

# List of all validators and passwords
~/.lighthouse/mainnet/validators/validator_definitions.yml

#Slash protection db
~/.lighthouse/mainnet/validators/slashing_protection.sqlite
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
# Validator Keys
/var/lib/nimbus/validators

# Beacon Chain Data
/var/lib/nimbus/db

#Slash protection db
/var/lib/nimbus/validators/slashing_protection.sqlite3

#Logs
/var/lib/nimbus/beacon.log
```
{% endtab %}

{% tab title="Teku" %}
```bash
# Validator Keys
/var/lib/teku

# Beacon Chain Data
/var/lib/teku/beacon

#Slash protection db
/var/lib/teku/validator/slashprotection
```
{% endtab %}

{% tab title="Prysm" %}
```bash
# Validator Keys
~/.eth2validators/prysm-wallet-v2/direct

# Beacon Chain Data
~/.eth2/beaconchaindata
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
# Validator Keystores
$rootDir/keystores

# Validator Secrets
$rootDir/secrets

# Validator DB Data
$rootDir/validator-db
```
{% endtab %}
{% endtabs %}

#### Execution engine files and locations

{% tabs %}
{% tab title="Geth" %}
```bash
# database location
$HOME/.ethereum
```
{% endtab %}

{% tab title="OpenEthereum (Parity)" %}
```bash
# database location
$HOME/.local/share/openethereum
```
{% endtab %}

{% tab title="Besu" %}
```bash
# database location
$HOME/.besu/database
```
{% endtab %}

{% tab title="Nethermind" %}
```bash
#database location
$HOME/.nethermind/nethermind_db/mainnet
```
{% endtab %}

{% tab title="Erigon" %}
```bash
#database location
/var/lib/erigon
```
{% endtab %}
{% endtabs %}

### :earth\_asia: 8.8 Hosting execution client on a different machine

{% hint style="info" %}
Hosting your own execution client on a different machine than where your beacon-chain and validator resides, can allow some extra modularity and flexibility.
{% endhint %}

On the execution client machine, edit your eth1.service unit file.

```bash
sudo nano /etc/systemd/system/eth1.service
```

Add the following flag to allow remote incoming http and or websocket api requests on the `ExecStart` line.

{% hint style="info" %}
If not using websockets, there's no need to include ws parameters. Only Nimbus requires websockets.
{% endhint %}

{% tabs %}
{% tab title="Geth" %}
```bash
--http.addr 0.0.0.0 --ws.addr 0.0.0.0
# Example
# ExecStart       = /usr/bin/geth --http.addr 0.0.0.0 --ws.addr 0.0.0.0 --http --ws
```
{% endtab %}

{% tab title="OpenEthereum (Parity)" %}
```bash
--jsonrpc-interface=all --ws-interface=all
# Example
# ExecStart       = <home directory>/openethereum/openethereum --jsonrpc-interface=all --ws-interface=all
```
{% endtab %}

{% tab title="Besu" %}
```bash
--rpc-http-host=0.0.0.0 --rpc-ws-enabled --rpc-ws-host=0.0.0.0
# Example
# ExecStart       = <home directory>/besu/bin/besu --rpc-http-host=0.0.0.0 --rpc-ws-enabled --rpc-ws-host=0.0.0.0 --rpc-http-enabled
```
{% endtab %}

{% tab title="Nethermind" %}
```bash
--JsonRpc.Host 0.0.0.0 --WebSocketsEnabled
# Example
# ExecStart       = <home directory>/nethermind/Nethermind.Runner --JsonRpc.Host 0.0.0.0 --WebSocketsEnabled --JsonRpc.Enabled true
```
{% endtab %}
{% endtabs %}

Reload the new unit file and restart the execution client.

```bash
sudo systemctl daemon-reload
sudo systemctl restart eth1
```

On the separate machine hosting the beacon-chain, update the beacon-chain unit file with the execution client's IP address.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
# edit beacon-chain unit file
nano /etc/systemd/system/beacon-chain.service
# add the --eth1-endpoints parameter
# example
# --eth1-endpoints=http://192.168.10.22
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
# edit beacon chain unit file
nano /etc/systemd/system/beacon-chain.service
# modify the --web-url parameter
# example
# --web3-url=ws://192.168.10.22
```
{% endtab %}

{% tab title="Teku" %}
```bash
# edit teku.yaml
nano /etc/teku/teku.yaml
# change the eth1-endpoint
# example
# eth1-endpoint: "http://192.168.10.20:8545"
```
{% endtab %}

{% tab title="Prysm" %}
```bash
# edit beacon-chain unit file
nano /etc/systemd/system/beacon-chain.service
# add the --http-web3provider parameter
# example
# --http-web3provider=http://192.168.10.20:8545
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
# edit beacon-chain unit file
nano /etc/systemd/system/beacon-chain.service
# add the --eth1.providerUrl parameter
# example
# --eth1.providerUrl http://192.168.10.20:8545
```
{% endtab %}
{% endtabs %}

Reload the updated unit file and restart the beacon-chain.

```bash
sudo systemctl daemon-reload
sudo systemctl restart beacon-chain
```

### :confetti\_ball: 8.9 Add or change POAP graffiti flag

Setup your `graffiti`, a custom message included in blocks your validator successfully proposes, and earn an early beacon chain validator POAP token. [Generate your POAP string by supplying an Ethereum 1.0 address here.](https://beaconcha.in/poap)

{% hint style="info" %}
Learn more about [POAP - The Proof of Attendance token.](https://www.poap.xyz)
{% endhint %}

{% tabs %}
{% tab title="Lighthouse" %}
Change the **--graffiti** value on ExecStart line. Save your file.

```bash
sudo nano /etc/systemd/system/validator.service
```
{% endtab %}

{% tab title="Nimbus" %}
Change the **--graffiti** value on ExecStart line. Save your file.

```bash
sudo nano /etc/systemd/system/beacon-chain.service
```
{% endtab %}

{% tab title="Teku" %}
Change the **validators-graffiti** value. Save your file.

```bash
sudo nano /etc/teku/teku.yaml
```
{% endtab %}

{% tab title="Prysm" %}
Change the **--graffiti** value on ExecStart line. Save your file.

```bash
sudo nano /etc/systemd/system/validator.service
```
{% endtab %}

{% tab title="Lodestar" %}
Change the **--graffiti** value on ExecStart line. Save your file.

```bash
sudo nano /etc/systemd/system/validator.service
```
{% endtab %}
{% endtabs %}

Reload the updated unit file and restart the validator process for your graffiti to take effect.

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl daemon-reload
sudo systemctl restart validator
```
{% endtab %}

{% tab title="Teku | Nimbus" %}
```
sudo systemctl daemon-reload
sudo systemctl restart beacon-chain
```
{% endtab %}
{% endtabs %}

### :package: 8.10 Update execution client - Geth / OpenEthereum / Besu / Nethermind / Erigon

Refer to [this quick guide.](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/how-to-update-your-eth1-node)

### :sparkles: 8.11 How to improve validator attestation effectiveness

{% hint style="info" %}
Learn about [attestation effectiveness from Attestant.io](https://www.attestant.io/posts/defining-attestation-effectiveness/)
{% endhint %}

#### :family\_mwgg: Strategy #1: Increase beacon chain peer count

{% hint style="info" %}
This change will result in increased bandwidth and memory usage. Tweak and tailor appropriately for your hardware.

_Kudos to _[_Rémy Roy_](https://www.reddit.com/user/remyroy/)_ for this strat._
{% endhint %}

Edit your `beacon-chain.service` unit file (except for Teku).

```bash
sudo nano /etc/systemd/system/beacon-chain.service
```

Add the following flag to increase peers on the `ExecStart` line.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
--target-peers 100
# Example
# lighthouse bn --target-peers 100 --staking --metrics --network mainnet
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
--max-peers=100
# Example
# /usr/bin/nimbus_beacon_node --network=mainnet --max-peers=100
```
{% endtab %}

{% tab title="Teku" %}
```bash
# Edit teku.yaml
sudo nano /etc/teku/teku.yaml

# add the following line to teku.yaml and save the file
p2p-peer-upper-bound: 100
```
{% endtab %}

{% tab title="Prysm" %}
```bash
--p2p-max-peers=100
# Example
# prysm.sh beacon-chain --mainnet --p2p-max-peers=100 --http-web3provider=http://127.0.0.1:8545 --accept-terms-of-use 
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
--network.maxPeers 100
# Example
# ./lodestar beacon --network.maxPeers 100 --network mainnet
```
{% endtab %}
{% endtabs %}

Reload the updated unit file and restart the beacon-chain process to complete this change.

```bash
sudo systemctl daemon-reload
sudo systemctl restart beacon-chain
```

#### :man\_technologist: Strategy #2: Execution Client (Eth1) redundancy

{% hint style="info" %}
Especially useful during eth1 upgrades, when your primary node is temporarily unavailable.
{% endhint %}

Edit your `beacon-chain.service` unit file.

```bash
sudo nano /etc/systemd/system/beacon-chain.service
```

Add the following flag on the `ExecStart` line.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
--eth1-endpoints <http://alternate eth1 endpoints>
# Example, separate endpoints with commas.
# --eth1-endpoints http://localhost:8545,https://nodes.mewapi.io/rpc/eth,https://mainnet.eth.cloud.ava.do,https://mainnet.infura.io/v3/xxx
```
{% endtab %}

{% tab title="Prysm" %}
```bash
--fallback-web3provider=<http://<alternate eth1 provider one> --fallback-web3provider=<http://<alternate eth1 provider two>
# Example, repeat flag for multiple eth1 providers
# --fallback-web3provider=https://nodes.mewapi.io/rpc/eth --fallback-web3provider=https://mainnet.infura.io/v3/YOUR-PROJECT-ID
```
{% endtab %}

{% tab title="Teku" %}
```bash
--eth1-endpoints <http://alternate eth1 endpoints>,<http://alternate eth1 endpoints>
# Support for automatic fail-over of eth1-endpoints. Multiple endpoints can be specified with the new --eth1-endpoints CLI option.
# Example
# --eth1-endpoints http://localhost:8545,https://infura.io/
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
--web3-url <http://alternate eth1 endpoint>
# Multiple endpoints can be specified with additional parameters of --web3-url
# Example
# --web3-url http://localhost:8545 --web3-url wss://mainnet.infura.io/ws/v3/...
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
:money\_with\_wings: Find free ethereum fallback nodes at [https://ethereumnodes.com/](https://ethereumnodes.com)
{% endhint %}

Reload the updated unit file and restart the beacon-chain process to complete this change.

```bash
sudo systemctl daemon-reload
sudo systemctl restart beacon-chain
```

#### :gear: Strategy #3: Perform updates or reboots during the longest attestation gap

Learn how to at [this quick guide.](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/how-to-find-longest-attestation-slot-gap)

#### :chains: Strategy #4: Beacon node redundancy

{% hint style="info" %}
Allows the VC (validator client) to connect to multiple BN (beacon nodes). This means your validator client can use multiple BNs. Whenever a BN fails to respond, the VC will try again with the next BN.

Must install a BN of the same consensus client on another server.

Currently only works for Lighthouse.
{% endhint %}

Edit your `validator.service` unit file.

```bash
sudo nano /etc/systemd/system/validator.service
```

Add the following flag on the `ExecStart` line.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
--beacon-nodes <BEACON-NODE ENDPOINTS>
# Example, separate endpoints with commas.
# lighthouse vc --beacon-nodes http://localhost:5052,http://192.168.1.100:5052
# If localhost is not responsive (perhaps during an update), the VC will attempt to use 192.168.1.100 instead.
```
{% endtab %}

{% tab title="Nimbus" %}
```
--web3-url=ws://127.0.0.1:8546 --web3-url=<update with your wss://mainnet.infura.io/ws/v3/nnnnn>
# Example, separate endpoints with commas.
# nimbus_beacon_node --data-dir=/var/lib/nimbus --web3-url=ws://127.0.0.1:8546 --web3-url=wss://mainnet.infura.io/ws/v3/zzz --
# If localhost is not responsive (perhaps during an update), the VC will attempt to use 192.168.1.100 instead.
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
[Infura.io](https://infura.io) offers beacon-node endpoints.
{% endhint %}

Reload the updated unit file and restart the validator process to complete this change.

```bash
sudo systemctl daemon-reload
sudo systemctl restart validator
```

### :jigsaw: 8.12 EIP2333 Key Generator by iancoleman.io

A [key generator tool by iancoleman](https://iancoleman.io/eip2333/) can generate EIP2333 keys from a BIP39 mnemonic, or a seed, or a master secret key.

This tool should be used **offline** and is useful for extracting **withdrawal keys** and **signing keys**.

Link: [https://iancoleman.io/eip2333/](https://iancoleman.io/eip2333/)

{% hint style="info" %}
For more info see the [EIP2333 spec](https://eips.ethereum.org/EIPS/eip-2333).
{% endhint %}

### :dvd: 8.13 Dealing with storage issues on the execution client

{% hint style="info" %}
It is currently recommended to use a minimum 1TB hard disk.

_Kudos to _[_angyts_](https://github.com/angyts)_ for this contribution._
{% endhint %}

After running the execution client for a while, you will notice that it will start to fill up the hard disk. The following steps might be helpful for you.

Firstly make sure you have a fallback execution client: see [8.11 Strategy 2](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet#strategy-2-eth1-redundancy).

{% tabs %}
{% tab title="Manually Pruning Geth" %}
{% hint style="info" %}
Since Geth 1.10x version, the blockchain data can be regularly pruned to reduce it's size.
{% endhint %}

Reference: [https://gist.github.com/yorickdowne/3323759b4cbf2022e191ab058a4276b2](https://gist.github.com/yorickdowne/3323759b4cbf2022e191ab058a4276b2)

You will need to upgrade Geth to at least 1.10x. Other prerequisites are a fully synced execution engine and that a snapshot has been created.

Stop your execution engine

```
sudo systemctl stop eth1
```

Prune the blockchain data

```
geth --datadir ~/.ethereum snapshot prune-state
```

{% hint style="warning" %}
:fire: **Geth pruning Caveats**:

* Pruning can take a few hours or longer (typically 2 to 10 hours is common) depending on your node's disk performance.
* There are three stages to pruning: **iterating state snapshot, pruning state data and compacting database.**
* "**Compacting database**" will stop updating status and appear hung. **Do not interrupt or restart this process.** Typically after an hour, pruning status messages will reappear.
{% endhint %}

Restart execution engine

```
sudo systemctl start eth1
```
{% endtab %}

{% tab title="Adding new hard disks and changing the data directory" %}
After you have installed your hard disk, you will need to properly format it and automount it. Consult the ubuntu guides on this.

I will assume that the new disk has been mounted onto `/mnt/eth1-data`. (The name of the mount point is up to you)

Handling file permissions.

You need to change ownership of the folder to be accessible by your `eth1 service`. If your folder is a different name, please change the `/mnt/eth1-data` accordingly.

```
sudo chown $whoami:$whoami /mnt/eth1-data
```

```
sudo chmod 755 /mnt/eth1-data
```

Stop your Eth1 node.

```
sudo systemctl stop eth1
```

Edit the system service file to point to a new data directory.

```
sudo nano /etc/systemd/system/eth1.service
```

At the end of this command starting with `/usr/bin/geth --http --metrics .... `add a space and the following flag `--datadir "/mnt/eth1-data"`.

`Ctrl-X` to save your settings.

Refresh the system service daemon to load the new configurations.

```
sudo systemctl daemon-reload
```

Restart the Eth1 node.

```
sudo systemctl start eth1
```

Make sure it is up and running by viewing the running logs.

```
journalctl -fu eth1
```

(**Optional**) Delete original data directory

```
rm -r ~/.ethereum
```
{% endtab %}
{% endtabs %}

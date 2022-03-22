# Configuring Slot Leader Calculations

{% hint style="info" %}
:fire: **Hot tip**: You can calculate your slot leader schedule, which tells you when it's your stake pools turn to mint a block. This can help you know what time is best to schedule maintenance on your stake pool. It can also help verify your pool is minting blocks correctly when it is your pool's turn. This is to be setup and run on the block producer node.
{% endhint %}

{% tabs %}
{% tab title="Cardano-CLI Query" %}
Since version 1.34, it is possible to check the slot leadership schedule for the **current** and  **next** epoch using cardano-cli.&#x20;



{% hint style="info" %}
Next epoch's leadership schedule becomes available 1.5 days (36 hours) before the end of the current epoch.
{% endhint %}

****

**Next epoch's leadership schedule** is obtained with the following:

```bash
cardano-cli query leadership-schedule \
--mainnet \
--genesis $NODE_HOME/mainnet-shelley-genesis.json \
--stake-pool-id $(cat $NODE_HOME/stakepoolid.txt) \
--vrf-signing-key-file $NODE_HOME/vrf.skey \
--next
```



**Current epoch's leadership schedule** is obtained with the following:

```bash
cardano-cli query leadership-schedule \
--mainnet \
--genesis $NODE_HOME/mainnet-shelley-genesis.json \
--stake-pool-id $(cat $NODE_HOME/stakepoolid.txt) \
--vrf-signing-key-file $NODE_HOME/vrf.skey \
--current
```



Example leadership schedule output:

```ada
SlotNo                          UTC Time
-------------------------------------------------------------
     4073                   2021-12-29 17:26:54.998001755 UTC
     4126                   2021-12-29 17:27:00.298001755 UTC
     4206                   2021-12-29 17:27:08.298001755 UTC
     4256                   2021-12-29 17:27:13.298001755 UTC
     4309                   2021-12-29 17:27:18.598001755 UTC
     4376                   2021-12-29 17:27:25.298001755 UTC
     4423                   2021-12-29 17:27:29.998001755 UTC
     4433                   2021-12-29 17:27:30.998001755 UTC
```
{% endtab %}

{% tab title="CNCLI Tool" %}
{% hint style="info" %}
### [CNCLI](https://github.com/AndrewWestberg/cncli) by [BCSH](https://bluecheesestakehouse.com), [SAND](https://www.sandstone.io), [SALAD](https://insalada.io)

A community-based `cardano-node` CLI tool. It's a collection of utilities to enhance and extend beyond those available with the `cardano-cli`.
{% endhint %}

### :dna: Installing the Binary

```bash
###
### On blockproducer
###
RELEASETAG=$(curl -s https://api.github.com/repos/AndrewWestberg/cncli/releases/latest | jq -r .tag_name)
VERSION=$(echo ${RELEASETAG} | cut -c 2-)
echo "Installing release ${RELEASETAG}"
curl -sLJ https://github.com/AndrewWestberg/cncli/releases/download/${RELEASETAG}/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -o /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz
```

```bash
sudo tar xzvf /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/bin/
```

### Confirming That CNCLI is Properly Installed

Run the following command to check if cncli is correctly installed and available in your system `PATH` variable:

```
command -v cncli
```

It should return `/usr/local/bin/cncli`

### :pick: **Running LeaderLog with stake-snapshot**

This command calculates a stake pool's expected slot list.

* `prev` and `current` logs are available as long as you have a synchronized database.
* `next` logs are only available 1.5 days (36 hours) before the end of the epoch.
* You need to use `poolStakeMark` and `activeStakeMark` for `next`, `poolStakeSet` and `activeStakeSet` for `current`, `poolStakeGo` and `activeStakeGo` for `prev`.

Example usage with the `stake-snapshot` approach for `next` epoch:

{% hint style="info" %}
Run this command 1.5 days (36 hours) before the next epoch begins.
{% endhint %}

```bash
/usr/local/bin/cncli sync --host 127.0.0.1 --port 6000 --no-service

MYPOOLID=$(cat $NODE_HOME/stakepoolid.txt)
echo "LeaderLog - POOLID $MYPOOLID"

SNAPSHOT=$(/usr/local/bin/cardano-cli query stake-snapshot --stake-pool-id $MYPOOLID --mainnet)
POOL_STAKE=$(echo "$SNAPSHOT" | grep -oP '(?<=    "poolStakeMark": )\d+(?=,?)')
ACTIVE_STAKE=$(echo "$SNAPSHOT" | grep -oP '(?<=    "activeStakeMark": )\d+(?=,?)')
MYPOOL=`/usr/local/bin/cncli leaderlog --pool-id $MYPOOLID --pool-vrf-skey ${NODE_HOME}/vrf.skey --byron-genesis ${NODE_HOME}/mainnet-byron-genesis.json --shelley-genesis ${NODE_HOME}/mainnet-shelley-genesis.json --pool-stake $POOL_STAKE --active-stake $ACTIVE_STAKE --ledger-set next`
echo $MYPOOL | jq .

EPOCH=`echo $MYPOOL | jq .epoch`
echo "\`Epoch $EPOCH\` 🧙🔮:"

SLOTS=`echo $MYPOOL | jq .epochSlots`
IDEAL=`echo $MYPOOL | jq .epochSlotsIdeal`
PERFORMANCE=`echo $MYPOOL | jq .maxPerformance`

echo "\`MYPOOL - $SLOTS \`🎰\`,  $PERFORMANCE% \`🍀max, \`$IDEAL\` 🧱ideal"
```

Example usage with the `stake-snapshot` approach for `current` epoch:

```bash
/usr/local/bin/cncli sync --host 127.0.0.1 --port 6000 --no-service

MYPOOLID=$(cat $NODE_HOME/stakepoolid.txt)
echo "LeaderLog - POOLID $MYPOOLID"

SNAPSHOT=$(/usr/local/bin/cardano-cli query stake-snapshot --stake-pool-id $MYPOOLID --mainnet)
POOL_STAKE=$(echo "$SNAPSHOT" | grep -oP '(?<=    "poolStakeSet": )\d+(?=,?)')
ACTIVE_STAKE=$(echo "$SNAPSHOT" | grep -oP '(?<=    "activeStakeSet": )\d+(?=,?)')
MYPOOL=`/usr/local/bin/cncli leaderlog --pool-id $MYPOOLID --pool-vrf-skey ${NODE_HOME}/vrf.skey --byron-genesis ${NODE_HOME}/mainnet-byron-genesis.json --shelley-genesis ${NODE_HOME}/mainnet-shelley-genesis.json --pool-stake $POOL_STAKE --active-stake $ACTIVE_STAKE --ledger-set current`
echo $MYPOOL | jq .

EPOCH=`echo $MYPOOL | jq .epoch`
echo "\`Epoch $EPOCH\` 🧙🔮:"

SLOTS=`echo $MYPOOL | jq .epochSlots`
IDEAL=`echo $MYPOOL | jq .epochSlotsIdeal`
PERFORMANCE=`echo $MYPOOL | jq .maxPerformance`

echo "\`MYPOOL - $SLOTS \`🎰\`,  $PERFORMANCE% \`🍀max, \`$IDEAL\` 🧱ideal"
```

Example usage with the `stake-snapshot` approach for `previous` epoch:

```bash
/usr/local/bin/cncli sync --host 127.0.0.1 --port 6000 --no-service

MYPOOLID=$(cat $NODE_HOME/stakepoolid.txt)
echo "LeaderLog - POOLID $MYPOOLID"

SNAPSHOT=$(/usr/local/bin/cardano-cli query stake-snapshot --stake-pool-id $MYPOOLID --mainnet)
POOL_STAKE=$(echo "$SNAPSHOT" | grep -oP '(?<=    "poolStakeGo": )\d+(?=,?)')
ACTIVE_STAKE=$(echo "$SNAPSHOT" | grep -oP '(?<=    "activeStakeGo": )\d+(?=,?)')
MYPOOL=`/usr/local/bin/cncli leaderlog --pool-id $MYPOOLID --pool-vrf-skey ${NODE_HOME}/vrf.skey --byron-genesis ${NODE_HOME}/mainnet-byron-genesis.json --shelley-genesis ${NODE_HOME}/mainnet-shelley-genesis.json --pool-stake $POOL_STAKE --active-stake $ACTIVE_STAKE --ledger-set prev`
echo $MYPOOL | jq .

EPOCH=`echo $MYPOOL | jq .epoch`
echo "\`Epoch $EPOCH\` 🧙🔮:"

SLOTS=`echo $MYPOOL | jq .epochSlots`
IDEAL=`echo $MYPOOL | jq .epochSlotsIdeal`
PERFORMANCE=`echo $MYPOOL | jq .maxPerformance`

echo "\`MYPOOL - $SLOTS \`🎰\`,  $PERFORMANCE% \`🍀max, \`$IDEAL\` 🧱ideal"
```

#### <a name="ptintegration"></a>Integrating with PoolTool

[PoolTool](https://pooltool.io) provides [example scripts](https://github.com/papacarp/pooltool.io) to submit the following data for your stake pool:

- Current block height
- The number of slots in which your stake pool is currently elected to mint blocks

The following figure shows the green badge that PoolTool displays next to your stake pool when your node is fully synchronized with the blockchain (credit to [QCPOL](https://cardano.stakepool.quebec) for the image):

![Your pool's tip on pooltool.io](../../../../.gitbook/assets/tip.png)

You can also use Andrew Westberg's [CNCLI](https://github.com/AndrewWestberg/cncli) utilities to send the block height and slot count to PoolTool.

[Guild Operators](https://cardano-community.github.io/guild-operators/) maintain the [`cncli.sh`](https://cardano-community.github.io/guild-operators/Scripts/cncli/) companion script to help stake pool operators use Andrew Westberg's CNCLI utilities.

To send data to PoolTool using CNCLI utilities without using the `cncli.sh` script, create a configuration file containing your PoolTool API key and stake pool details.

{% hint style="info" %}
For details on requesting an API key from PoolTool, see the topic [Obtaining a PoolTool API Key](../part-v-tips/obtaining-a-pooltool-api-key.md).
{% endhint %}

To create a configuration file, update values in the following example with your pool information. To follow the example, save the configuration file at `$NODE_HOME/scripts/pooltool.json`

```bash
cat > ${NODE_HOME}/scripts/pooltool.json << EOF
{
    "api_key": "<UPDATE WITH YOUR API KEY FROM POOLTOOL PROFILE PAGE>",
    "pools": [
        {
            "name": "<UPDATE TO MY POOL TICKER>",
            "pool_id": "$(cat ${NODE_HOME}/stakepoolid.txt)",
            "host" : "127.0.0.1",
            "port": 6000
        }
    ]
}
EOF
```

#### Creating systemd Services

CNCLI `sync` and `sendtip` can be easily enabled as `systemd` services. When enabled as `systemd` services:

* `sync` will continuously keep the `cncli.db` database synchronized.
* `sendtip` will continuously send your stake pool `tip` to PoolTool.

To set up `systemd`:

* Create the following and move to`/etc/systemd/system/cncli-sync.service`

```bash
cat > ${NODE_HOME}/cncli-sync.service << EOF
[Unit]
Description=CNCLI Sync
After=multi-user.target

[Service]
User=$USER
Type=simple
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/usr/local/bin/cncli sync --host 127.0.0.1 --port 6000 --db ${NODE_HOME}/scripts/cncli.db
KillSignal=SIGINT
SuccessExitStatus=143
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=cncli-sync

[Install]
WantedBy=multi-user.target
EOF
```

```bash
sudo mv ${NODE_HOME}/cncli-sync.service /etc/systemd/system/cncli-sync.service
```

* Create the following and move to `/etc/systemd/system/cncli-sendtip.service`

```bash
cat > ${NODE_HOME}/cncli-sendtip.service << EOF
[Unit]
Description=CNCLI Sendtip
After=multi-user.target

[Service]
User=$USER
Type=simple
Restart=always
RestartSec=5
LimitNOFILE=131072
ExecStart=/usr/local/bin/cncli sendtip --cardano-node /usr/local/bin/cardano-node --config ${NODE_HOME}/scripts/pooltool.json
KillSignal=SIGINT
SuccessExitStatus=143
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=cncli-sendtip

[Install]
WantedBy=multi-user.target
EOF
```

```bash
sudo mv ${NODE_HOME}/cncli-sendtip.service /etc/systemd/system/cncli-sendtip.service
```

* To enable and run the above services, run:

```
sudo systemctl daemon-reload
```

```
sudo systemctl start cncli-sync.service
```

```
sudo systemctl start cncli-sendtip.service
```

### :tools: Upgrading CNCLI

```bash
RELEASETAG=$(curl -s https://api.github.com/repos/AndrewWestberg/cncli/releases/latest | jq -r .tag_name)
VERSION=$(echo ${RELEASETAG} | cut -c 2-)
echo "Installing release ${RELEASETAG}"
curl -sLJ https://github.com/AndrewWestberg/cncli/releases/download/${RELEASETAG}/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -o /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz
```

```bash
sudo tar xzvf /tmp/cncli-${VERSION}-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/bin/
```

#### Confirming CNCLI Upgrades

```
cncli -V
```

It should return the updated version number.
{% endtab %}

{% tab title="[Deprecated] Python Method" %}
{% hint style="info" %}
Credits for inventing this process goes to the hard work by [Andrew Westberg @amw7](https://twitter.com/amw7) (developer of JorManager and operator of BCSH family of stake pools).
{% endhint %}

Check if you have python installed.

```bash
python3 --version
```

Otherwise, install python3.

```
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.9
```

Check if you have pip installed.

```bash
pip3 --version
```

Install pip3 if needed.

```bash
sudo apt-get install -y python3-pip
```

Install pytz which handles timezones.

```bash
pip3 install pytz
```

Verify python and pip are setup correctly before continuing.

```bash
python3 --version
pip3 --version
```

Clone the leaderLog scripts from [papacarp/pooltool.io](https://github.com/papacarp/pooltool.io) git repo.

{% hint style="info" %}
Official documentation for this LeaderLogs tool can be [read here.](https://github.com/papacarp/pooltool.io/blob/master/leaderLogs/README.md)
{% endhint %}

```bash
cd $HOME/git
git clone https://github.com/papacarp/pooltool.io
cd pooltool.io/leaderLogs
```

Calculate your slot leader schedule for the latest current epoch.

```bash
python3 leaderLogs.py \
--pool-id $(cat ${NODE_HOME}/stakepoolid.txt) \
--tz America/Los_Angeles \
--vrf-skey ${NODE_HOME}/vrf.skey
```

{% hint style="info" %}
Set the timezone name to format the schedule's times properly. Use the --tz option. \[Default: America/Los\_Angeles]') [Refer to the official documentation for more info.](https://github.com/papacarp/pooltool.io/blob/master/leaderLogs/README.md#arguments-1)
{% endhint %}

{% hint style="success" %}
:robot: **Pro Tip**: 1.5 days before the end of the current epoch, you can find the next epoch's schedule.

:robot: **Pro Tip #2**: Add the flag **--epoch \<INTEGER #>** to find a specific epoch's slot schedule.

:robot: **Pro Tip #3**: Ensure your slot leader scripts are up to date.

```bash
cd $HOME/git/pooltool.io/leaderLogs
git pull
```
{% endhint %}

If your pool is scheduled to mint blocks, you should hopefully see output similar to this. Listed by date and time, this is your slot leader schedule or in other words, when your pool is eligible to mint a block.

```bash
Checking leadership log for Epoch 222 [ d Param: 0.6 ]
2020-10-01 00:11:10 ==> Leader for slot 121212, Cumulative epoch blocks: 1
2020-10-01 00:12:22 ==> Leader for slot 131313, Cumulative epoch blocks: 2
2020-10-01 00:19:55 ==> Leader for slot 161212, Cumulative epoch blocks: 3
```
{% endtab %}
{% endtabs %}



{% hint style="danger" %}
Your slot leader log should remain confidential. If you share this information publicly, an attacker could use this information to attack your stake pool.
{% endhint %}

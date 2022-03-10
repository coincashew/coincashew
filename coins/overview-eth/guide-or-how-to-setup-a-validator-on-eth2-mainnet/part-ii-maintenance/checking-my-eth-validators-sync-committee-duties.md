---
description: >-
  Avoid missing extra ETH income and get rewarded for 24hours of sync committee
  duties.
---

# Checking my eth validator's sync committee duties

## Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](./). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

### :dagger: Why do I want to check my sync committee duties ?

* Since the Altair Hard Fork, checking sync committee membership is a must before performing any maintenance. This will give you up to [\~27 hours of advanced notice](https://github.com/ethereum/consensus-specs/pull/2453) in case your validators have been selected for sync committee duties.
* Understanding the schedule of your validator's duties better, you can find the best time to plan consensus/execution client updates, system reboots or outages.

### :robot: Pre-requisites

* Linux bash shell or command line
* your eth staking validator index number(s) -- Lookup on [https://beaconcha.in/](https://beaconcha.in) or [https://beaconscan.com/](https://beaconscan.com)

{% hint style="success" %}
:sparkles: Kudos to [**2038**](https://www.reddit.com/user/2038/) **** on Reddit for [authoring this process.](https://www.reddit.com/r/ethstaker/comments/qjlfsf/how\_to\_check\_upcoming\_sync\_committee\_membership/)
{% endhint %}

### :construction: How to Check Sync Committee Duties script

1\. Create a `check_sync_committee.sh` script with a text editor, nano.

```
nano check_sync_committee.sh
```

2\. Paste the following script content and then save your file. CTRL+O, enter, then CTRL+X.

```
#!/bin/sh

BEACON_NODE="http://localhost:5052"
VALIDATOR_LIST=$(echo "$@" | tr ' ' '|')

epoch_to_time(){
    expr 1606824000 + \( $1 \* 384 \)
    }

time_to_epoch(){
    expr \( $1 - 1606824000 \) / 384
    }

get_committee(){
    URLSTEM="${BEACON_NODE}/eth/v1/beacon/states/finalized"
    curl -X GET "${URLSTEM}/sync_committees?epoch=$1" 2> /dev/null \
    | sed -e 's/["]/''/g' | cut -d'[' -f2 | cut -d']' -f1 | tr ',' '\n'
    }

search_committee(){
    get_committee $2 | grep -Ex $VALIDATOR_LIST \
    | awk -v c=$1 '{print "validator:", $1, "found in", c, "sync committee"}'
    }

display_epoch(){
    echo "epoch: $1 : $(date -d@$(epoch_to_time $1)) <-- $2"
    }

CURR_EPOCH=$(time_to_epoch $(date +%s))
CURR_START_EPOCH=`expr \( $CURR_EPOCH / 256 \) \* 256`
NEXT_START_EPOCH=`expr $CURR_START_EPOCH + 256`
NEXTB1_START_EPOCH=`expr $NEXT_START_EPOCH + 256`

echo
display_epoch $CURR_START_EPOCH   "current sync committee start"
display_epoch $CURR_EPOCH         "now"
display_epoch $NEXT_START_EPOCH   "next sync committee start"
display_epoch $NEXTB1_START_EPOCH "next-but-one sync committee start"
echo

if [ "$#" -gt 0 ]
then
    search_committee "current" $CURR_EPOCH
    search_committee "next"    $NEXT_START_EPOCH
fi
```

3\. Add execute permissions to the script.

```
 chmod +x check_sync_committee.sh
```

4\. Enter your validator index numbers as parameters to the script.

```bash
./check_sync_committee.sh <validator index number(s)>
# Example
# ./check_sync_committee.sh 1000 1001 1002 1003
```

Sample Output:

> ```
> ./check_sync_committee.sh 123511 124216 
>
> epoch: 75008 : Sat 30 Oct 21:51:12 BST 2021 <-- current sync committee start
> epoch: 75115 : Sun 31 Oct 08:16:00 GMT 2021 <-- now
> epoch: 75264 : Mon  1 Nov 00:09:36 GMT 2021 <-- next sync committee start
> epoch: 75520 : Tue  2 Nov 03:28:00 GMT 2021 <-- next-but-one sync committee start
>
> validator: 123511 found in current sync committee
> validator: 124216 found in next sync committee
> ```

{% hint style="warning" %}
****:fire: **Script Usage Caveats**:&#x20;

* Sync commitee duties are only known for the current AND next epoch.
{% endhint %}

# Fixing the Mnemonic Staking Balance Bug

## :octagonal_sign: Who Is Affected?

If you created your [payment and stake keys](../part-iii-operation/setting-up-payment-and-stake-keys.md) using the **mnemonic method** in Daedalus 2.0 before July 30, 2020, then you may be affected.

Run the following to see if you're affected

```
cd $NODE_HOME
wc -m payment.addr
```

If this returns **`59 payment.addr`**`,` then continue reading. If this returns **`104 payment.addr,`** you are not affected!

## :tools: What Is the Problem?

* The balance towards your stake is not being counted because the script's default, **`payment.addr`**, is also known as the enterprise address.
* By design, enterprise address balances are not counted as stake.
* The public address found in **`base.addr`** should have been funded. In other words, `base.addr` should have been the real `payment.addr`.

## :robot: Verifying That the Problem Exists

Check your stake balance by running the following query to find all your stake pool's delegators.

```
cd $NODE_HOME
pool_id=$(cat stakepoolid.txt)
timeout -k 5 60 cardano-cli shelley query ledger-state ${NETWORK_IDENTIFIER} --out-file ledger-state.json
echo "Ledger state dumped, parsing data..."
non_myopic_delegators=$(jq -r -c ".esNonMyopic.snapNM._delegations | .[] | select(.[1] == \"${pool_id}\") | .[0][\"key hash\"]" ledger-state.json)
snapshot_delegators=$(jq -r -c ".esSnapshots._pstakeSet._delegations | .[] | select(.[1] == \"${pool_id}\") | .[0][\"key hash\"]" ledger-state.json)
lstate=$(jq -r -c ".esLState" ledger-state.json)
lstate_dstate=$(jq -r -c "._delegationState._dstate" <<< "${lstate}")
ledger_pool_state=$(jq -r -c '._delegationState._pstate._pParams."'"${pool_id}"'" // empty' <<< "${lstate}")
lstate_rewards=$(jq -r -c "._rewards" <<< "${lstate_dstate}")
lstate_utxo=$(jq -r -c "._utxoState._utxo" <<< "${lstate}")
lstate_delegators=$(jq -r -c "._delegations | .[] | select(.[1] == \"${pool_id}\") | .[0][\"key hash\"]" <<< "${lstate_dstate}")
delegators=$(echo "${non_myopic_delegators}" "${snapshot_delegators}" "${lstate_delegators}" | tr ' ' '\n' | sort -u)
echo "$(wc -w <<< "${delegators}") delegators found, gathering data for each:"
pledge="$(jq -c -r '.pledge // 0' <<< "${ledger_pool_state}" | tr '\n' ' ')"
owners="$(jq -c -r '.owners[] // empty' <<< "${ledger_pool_state}" | tr '\n' ' ')"
owner_nbr=$(jq -r '(.owners | length) // 0' <<< "${ledger_pool_state}")
delegators_array=()
delegator_nbr=0
total_stake=0
total_pledged=0
for key in ${delegators}; do
    stake=$(jq -r -c ".[] | select(.address | contains(\"${key}\")) | .amount" <<< "${lstate_utxo}" | awk 'BEGIN{total = 0} {total = total + $1} END{printf "%.0f", total}')
    rewards=$(jq -r -c ".[] | select(.[0][\"key hash\"] == \"${key}\") | .[1]" <<< "${lstate_rewards}")
    total_stake=$((total_stake + stake + reward))
    echo "Delegator $((++delegator_nbr)) processed"
    if echo "${owners}" | grep -q "${key}"; then
      key="${key} (owner)"
      total_pledged=$((total_pledged + stake + reward))
    fi
  delegators_array+=( "hex_key" "${key}" "stake" "${stake}" "rewards" "${rewards})" )
done
echo total_stake $total_stake
echo total_pledged $total_pledged
echo delegator_nbr $delegator_nbr

printf '{"%s":"%s","%s":"%s","%s":"%s"},\n' "${delegators_array[@]}" | sed '$s/,$//'
```

If you see stake is 0 for the owner, then the issue exists.

**Example output:**

> {"hex_key":"70f2... (owner)","stake":"0","rewards":"0)"},

## :jigsaw: Fixing the Problem

1\) Find your `base.addr` public address.

```
cat $NODE_HOME/extractedPoolKeys/base.addr
```

2\) Open Daedalus wallet which is where your mnemonic was originally created from.

3\) Send a small test amount to the `base.addr` public address.

4\) Re-run the above query to check your delegator's balances. Your owner's stake balance should have increased.

5\) Send the remaining balance to `base.addr` public address.

6\) Re-run the above query to verify your stake is correctly counted.

7\) Replace the old `payment.addr` with `base.addr`

```
cd $NODE_HOME
cp extractedPoolKeys/base.addr payment.addr
```

If you need assistance, please visit our [Telegram Channel.](https://t.me/coincashew)

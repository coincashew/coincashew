# How to re-sync using checkpoint sync

{% hint style="info" %}
Common reasons for re-syncing include:

:owl: **Missed upgrade**: Hard fork occurred and I forgot to update my consensus client

:floppy\_disk: **Low disk space**: I'm running low on disk space and would like to recover space
{% endhint %}

<details>

<summary>Step 1: Stop consensus client</summary>

```
sudo systemctl stop consensus
```

</details>

<details>

<summary>Step 2: Remove consensus client database directory</summary>

Prysm

```
sudo rm -r /var/lib/prysm/beacon/beaconchaindata
```

Lodestar

```
sudo rm -r /var/lib/lodestar/chain-db
```

Teku

```
sudo rm -r /var/lib/teku/beacon
```

Nimbus

```
sudo rm -r /var/lib/nimbus/db
```

Lighthouse

```
sudo rm -r /var/lib/lighthouse/beacon
```

</details>

<details>

<summary>Step 3: Ensure a checkpoint sync server is configured</summary>

* Below examples use the default checkpoint sync endpoint https://beaconstate.info
* Refer to [https://eth-clients.github.io/checkpoint-sync-endpoints](https://eth-clients.github.io/checkpoint-sync-endpoints/) and pick another random state providers from the list, if desired.
* Do not trust any single checkpoint provider. Verify the state root and block root against multiple checkpoints to ensure you're on the correct chain.

### **Nimbus**:

Run the following to start the checkpoint sync.

```bash
sudo -u consensus /usr/bin/nimbus_beacon_node trustedNodeSync \
--network=mainnet  \
--trusted-node-url=https://beaconstate.info \
--data-dir=/var/lib/nimbus \
--network=mainnet \
--backfill=false
```

When the nimbus checkpoint sync is complete, you'll see the following message:

```
Done, your beacon node is ready to serve you! Don't forget to check that you're on the canonical chain by comparing the checkpoint root with other online sources. See https://nimbus.guide/trusted-node-sync.html for more information.
```

### **Teku**:

Edit your config file

```
sudo nano /etc/systemd/system/consensus.service
```

Ensure the following line is listed

```
--initial-state="https://beaconstate.info/eth/v2/debug/beacon/states/finalized"
```

To exit and save, press `Ctrl` + `X`, then `Y`, then`Enter`.

### **Lighthouse**:

Edit your service file

```
sudo nano /etc/systemd/system/consensus.service
```

Ensure the following line is listed on your `ExecStart` line

```
--checkpoint-sync-url=https://beaconstate.info
```

To exit and save, press `Ctrl` + `X`, then `Y`, then`Enter`.

### **Prysm**:

Edit your service file

```
sudo nano /etc/systemd/system/consensus.service
```

Ensure the following line is listed on your `ExecStart` line

```
--checkpoint-sync-url=https://beaconstate.info
--genesis-beacon-api-url=https://beaconstate.info
```

To exit and save, press `Ctrl` + `X`, then `Y`, then`Enter`.

### **Lodestar**:

Edit your service file

```
sudo nano /etc/systemd/system/consensus.service
```

Ensure the following line is listed on your `ExecStart` line

```
--checkpointSyncUrl https://lodestar-mainnet.chainsafe.io
```

To exit and save, press `Ctrl` + `X`, then `Y`, then`Enter`.

</details>

<details>

<summary>Step 4: Start consensus client</summary>

```
sudo systemctl daemon-reload
sudo systemctl restart consensus
```

</details>

<details>

<summary>Step 5: Check the beacon chain logs and ensure sync is on right chain</summary>

Verify that you are on the correct chain by visiting [https://eth-clients.github.io/checkpoint-sync-endpoints](https://eth-clients.github.io/checkpoint-sync-endpoints/) and selecting a **different** endpoint link. Verify that your log's are in agreement with the other endpoint's `epoch / slot / state root / block root`

View your logs:

```
sudo journalctl -fu consensus
```

Checkpoint sync should take no more than a few minutes to re-sync. Your execution client may take longer to catch up.

</details>

{% hint style="success" %}
Congrats! You've successfully re-synced your consensus client.
{% endhint %}

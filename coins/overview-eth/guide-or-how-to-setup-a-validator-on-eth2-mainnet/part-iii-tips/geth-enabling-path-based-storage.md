---
description: No more offline pruning, save time and disk space!
---

# 😁 Geth - Enabling path-based storage

{% hint style="info" %}
As of [Geth v1.13.0](https://blog.ethereum.org/2023/09/12/geth-v1-13-0), a new database model for storing the Ethereum state, which is both faster than the previous scheme, and also has proper pruning implemented.&#x20;



No more junk accumulating on disk and no more guerilla (offline) pruning!
{% endhint %}

### :tada: Enjoy performance improvements

<figure><img src="../../../../.gitbook/assets/geth-v1.13.0-sync-bench.png" alt=""><figcaption></figcaption></figure>

### :robot: How to enable PBS for existing installations

{% tabs %}
{% tab title="V2 Staking Setup (Current)" %}
```bash
# Stop geth
sudo systemctl stop execution

#(add --state.scheme=path to the ExecStart line)
sudo nano /etc/systemd/system/execution.service

# reload changes
sudo systemctl daemon-reload

# Delete the old db
# and when asked, delete the state database, but keep the ancient database
# Yes to state db, no to ancient db.
sudo -u execution /usr/local/bin/geth --datadir /var/lib/geth removedb

# Start geth
sudo systemctl start execution
```
{% endtab %}

{% tab title="V1 Staking Setup" %}
```bash
# Stop geth
sudo systemctl stop eth1

#(add --state.scheme=path to the ExecStart line)
sudo nano /etc/systemd/system/eth1.service

# reload changes
sudo systemctl daemon-reload

# Delete the old db
# and when asked, delete the state database, but keep the ancient database
# Yes to state db, no to ancient db.
sudo /usr/bin/geth --datadir ~/.ethereum removedb

# Start geth
sudo systemctl start eth1
```
{% endtab %}
{% endtabs %}

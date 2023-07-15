# Dealing with Storage Issues on the Execution Client

{% hint style="info" %}
It is currently recommended to use a minimum 1TB hard disk.

_Kudos to_ [_angyts_](https://github.com/angyts) _for this contribution._
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

At the end of this command starting with `/usr/bin/geth --http --metrics ....` add a space and the following flag `--datadir "/mnt/eth1-data"`.

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

# Dealing with Storage Issues on the Execution Client

{% hint style="info" %}
It is currently recommended to use a minimum 1TB hard disk.

_Kudos to_ [_angyts_](https://github.com/angyts) _for this contribution._
{% endhint %}

After running the execution client for a while, you will notice that it will start to fill up the hard disk. The following steps might be helpful for you.



{% tabs %}
{% tab title="Manually Pruning Geth" %}
{% hint style="info" %}
Since Geth 1.10x version, the blockchain data can be regularly pruned to reduce it's size.
{% endhint %}

Reference: [https://gist.github.com/yorickdowne/3323759b4cbf2022e191ab058a4276b2](https://gist.github.com/yorickdowne/3323759b4cbf2022e191ab058a4276b2)

You will need to upgrade Geth to at least 1.10x. Other prerequisites are a fully synced execution engine and that a snapshot has been created.

Stop your execution engine

```
sudo systemctl stop execution
```

Prune the blockchain data

```
sudo -u execution geth --datadir /var/lib/geth snapshot prune-state
```

{% hint style="warning" %}
:fire: **Geth pruning Caveats**:

* Pruning can take a few hours or longer (typically 2 to 10 hours is common) depending on your node's disk performance.
* There are three stages to pruning: **iterating state snapshot, pruning state data and compacting database.**
* "**Compacting database**" will stop updating status and appear hung. **Do not interrupt or restart this process.** Typically after an hour, pruning status messages will reappear.
{% endhint %}

Restart execution engine

```
sudo systemctl start execution
```
{% endtab %}

{% tab title="Adding new hard disks and changing the data directory" %}
After you have installed your hard disk, you will need to properly format it and automount it. Consult the ubuntu guides on this.

I will assume that the new disk has been mounted onto `/mnt/`execution`-data`. (The name of the mount point is up to you)

Handling file permissions.

You need to change ownership of the folder to be accessible by your execution`service`. If your folder is a different name, please change the `/mnt/`execution`-data` accordingly.

```
sudo chown execution:execution /mnt/execution-data
```

```
sudo chmod 755 /mnt/execution-data
```

Stop your execution client.

```
sudo systemctl stop execution
```

Edit the system service file to point to a new data directory.

```
sudo nano /etc/systemd/system/execution.service
```

At the end of this command starting with `/usr/bin/geth --http --metrics ....` add a space and the following flag `--datadir "/mnt/`execution`-data"`.

`Ctrl-X` to save your settings.

Refresh the system service daemon to load the new configurations.

```
sudo systemctl daemon-reload
```

Restart the execution client.

```
sudo systemctl start execution
```

Make sure it is up and running by viewing the running logs.

```
sudo journalctl -fu execution
```

(**Optional**) Delete original data directory

```
sudo rm -r /var/lib/geth
```
{% endtab %}
{% endtabs %}

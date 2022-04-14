# 7. Updating a node

## :satellite: 1. How to perform an update

From time to time, there will be new versions of Tezos. Follow [Tezos Foundation](https://twitter.com/TezosFoundation) on twitter and the [Official Tezos Gitlab](https://gitlab.com/tezos/tezos/-/releases) to ensure you don't miss any important releases.

{% hint style="success" %}
****:sparkles: **Tip:** When picking some downtime for maintenance like updating your node, choose a time where your baker has a longer break until next baking or next endorsing.
{% endhint %}

To update with `~/tezos` as the current binaries directory, copy the whole Tezos directory to a new place so that you have a backup and can also leave the current processes running.

```
cd
git clone https://gitlab.com/tezos/tezos tezos2
```

{% hint style="info" %}
Tezos Version 8.0 aka Edo requires the installation of the Rust framework and zcash params. Install with the following.

```bash
wget https://sh.rustup.rs/rustup-init.sh
chmod +x rustup-init.sh
./rustup-init.sh --profile minimal --default-toolchain 1.44.0 -y

source $HOME/.cargo/env

wget https://raw.githubusercontent.com/zcash/zcash/master/zcutil/fetch-params.sh
chmod +x fetch-params.sh
./fetch-params.sh
```
{% endhint %}

Change to the new directory and rebuild the latest binaries. Run the following command to pull and build the latest Tezos binaries.

```
cd ~/tezos2
git checkout latest-release
make build-deps && eval $(opam env) && make
```

{% hint style="danger" %}
Stop your node by Ctrl-C. If you stop your node first, then baker, accuser and endorser will automatically stop. Or, if you're using auto-start scripts with systemd, use the command `sudo systemctl stop tezos-node.service`
{% endhint %}

The following commands will quickly switch-over to your newly built Tezos binaries while keeping the old directory for backup.

```
cd
mv tezos/ tezos-old/
mv tezos2/ tezos/
```

{% hint style="success" %}
Now restart your node, baker, endorser, and accuser processes.&#x20;
{% endhint %}

## :safety\_pin: 2. Handling updates with new protocols

Tezos performs regular on-chain governance by election. These elections progress through four stages and can conclude with a protocol upgrade which results in a new set of binaries. This is what makes Tezos self-amending.

{% hint style="info" %}
When a new protocol is successfully promoted and scheduled to occur at a later date, you run both the current protocol and future protocol binaries.&#x20;

For example, you would expect to run 7 binaries

`./tezos-node`

`./tezos-endorser-006`

`./tezos-baker-006`

`./tezos-accuser-006`

`./tezos-endorser-007`

`./tezos-baker-007`

`./tezos-accuser-007`

After the future protocol`"007"`activates on a later date, you can stop the previous binaries. In this example, you would stop all the`006` binaries.
{% endhint %}

## :heavy\_check\_mark: 3. Update auto-start and monitoring systemctl configs

First, stop all tezos services and ensure the services are truly stopped.

```
sudo systemctl stop tezos-node.service
sudo systemctl status 'tezos-*.service'
```

You need to update the binaries names for the `ExecStart` variable. The path must reflect the new binaries.

The files to update are:

* /etc/systemd/system/tezos-node.service
* /etc/systemd/system/tezos-endorser.service
* /etc/systemd/system/tezos-baker.service
* /etc/systemd/system/tezos-accuser.service

```
#Example, change "tezos-endorser-006-PsCARTHA"
ExecStart       = /home/replaceUsername/tezos-endorser-006-PsCARTHA run ledger_mybaker
```

{% hint style="info" %}
Typically you only need to update 3 filenames: the endorser, baker, and accuser filename.
{% endhint %}

Now reload the new config with the following command:

```
systemctl --user daemon-reload
```

And restart services,

```
sudo systemctl reload-or-restart tezos-node.service
```

Verify the node, baker, endorser, accuser processes are all running.

```
sudo systemctl status 'tezos-*.service'
```

## :exploding\_head: 4. In case of problems

### :motorway: 4.1 Forked off

Forget to update your node and now your node is stuck on an old chain?

Run this command to resume validating blocks.

```
./tezos-admin-client unmark all invalid blocks
```

### :open\_file\_folder: 4.2 Roll back to previous version from backup

Following the above guide, you can simply restore the old Tezos directory.

Then try the update procedure again.

```
mv tezos/ tezos-rolled-back/
mv tezos-old/ tezos/
```

### :robot: 4.3 Last resort: Rebuild from source code

Follow the steps in section [`2. Getting and building Tezos from source`](install-a-tezos-node.md#2-getting-and-building-tezos-from-source)

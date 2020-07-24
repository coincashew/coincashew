# How to update a Stakepool

## 📡 1. How to perform an update

From time to time, there will be new versions of Cardano-Node. Follow the [Official Cardano-Node Github Repo](https://github.com/input-output-hk/cardano-node) by enabling **notifications** with the watch functionality.

To update with `~/cardano-node` as the current binaries directory, copy the whole cardano-node directory to a new place so that you have a backup.

```text
cd ~/git
rsync -av cardano-node/ cardano-node2/
cd cardano-node2/
```

{% hint style="danger" %}
Read the patch notes for any other special updates or dependencies that may be required for the latest release.
{% endhint %}

Rebuild the latest binaries. Run the following command to pull and build the latest Cardano-Node binaries. Change the **tag** or **branch** as needed.

```text
rm -rf $HOME/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.6.5
git clean -fd
git fetch --all && git checkout tags/1.17.0 && git pull
cabal build cardano-node cardano-cli
```

{% hint style="info" %}
Building process may take a few minutes up to a few hours depending on your computer's processing power.
{% endhint %}

Verify your **cardano-cli** and **cardano-node** were updated to the expected version.

```text
$(find ~/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") version
$(find ~/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") version
```

{% hint style="danger" %}
Stop your node by running **stopStakePool.sh** or 

```text
sudo systemctl stop cardano-stakepool
```
{% endhint %}

Copy **cardano-cli** and **cardano-node** files into bin directory.

```text
sudo cp $(find ~/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find ~/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

{% hint style="success" %}
Now restart your nodes with **startStakePool.sh** or

```text
sudo systemctl start cardano-stakepool
```
{% endhint %}

Finally, the following sequence will switch-over to your newly built cardano-node folder while keeping the old directory for backup.

```text
cd ~/git
mv cardano-node/ cardano-node-old/
mv cardano-node2/ cardano-node/
```

## 🤯 2. In case of problems

### 🛣 4.1 Forked off

Forget to update your node and now your node is stuck on an old chain?

Reset your database files and be sure to grab the [latest genesis, config, topology json files](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html).

```text
# Sample commands for clearing the db
cd $NODE_HOME
rm -rf db
rm -rf relaynode1/db
rm -rf relaynode2/db
```

### 📂 4.2 Roll back to previous version from backup

Following the above guide, you can simply restore the old cardano-node directory.

Then try the update procedure again.

```text
cd ~/git
mv cardano-node/ cardano-node-rolled-back/
mv cardano-node-old/ cardano-node/
```

### 🤖 4.3 Last resort: Rebuild from source code

Follow the steps in [How to build a Stakepool.](./)


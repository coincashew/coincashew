# How to update a Stakepool

## 📡 1. How to perform an update

From time to time, there will be new versions of Cardano-Node. Follow the [Official Cardano-Node Github Repo](https://github.com/input-output-hk/cardano-node) by enabling **notifications** with the watch functionality.

To update with `~/cardano-node` as the current binaries directory, copy the whole cardano-node directory to a new place so that you have a backup.

```text
cd
rsync -av cardano-node/ cardano-node2/
cd ~/cardano-node2
```

{% hint style="info" %}
Read the patch notes for any other special updates or dependencies that may be required for this latest release.
{% endhint %}

Install these two special updates for release 1.14.x

```text
sudo apt-get -y install curl libsodium-dev
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
```

Rebuild the latest binaries. Run the following command to pull and build the latest Cardano-Node binaries.

```text
git clean -fd
git fetch && git checkout release/1.14.x && git pull
cabal install cardano-node cardano-cli --overwrite-policy=always
```

Copy **cardano-cli** and **cardano-node** files into bin directory.

```text
sudo cp $HOME/.cabal/bin/cardano-cli /usr/local/bin/cardano-cli
sudo cp $HOME/.cabal/bin/cardano-node /usr/local/bin/cardano-node
```

Verify your **cardano-cli** and **cardano-node** were updated to the expected version.

```text
cardano-node version
cardano-cli version
```

{% hint style="danger" %}
Stop your node by pressing "q".
{% endhint %}

Finally, the following sequence will switch-over to your newly built cardano-node folder while keeping the old directory for backup.

```text
cd
mv cardano-node/ cardano-node-old/
mv cardano-node2/ cardano-node/
```

{% hint style="success" %}
Now restart your nodes.
{% endhint %}

## 🤯 2. In case of problems

### 🛣 4.1 Forked off

Forget to update your node and now your node is stuck on an old chain?

Reset your database files and be sure to grab the [latest genesis, config, topology json files](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html).

```text
# Sample commands for clearing the db
rm -rf ~/cardano-my-node/db
rm -rf ~/cardano-my-node/relaynode1/db
rm -rf ~/cardano-my-node/relaynode2/db
```

### 📂 4.2 Roll back to previous version from backup

Following the above guide, you can simply restore the old cardano-node directory.

Then try the update procedure again.

```text
mv cardano-node/ cardano-node-rolled-back/
mv cardano-node-old/ cardano-node/
```

### 🤖 4.3 Last resort: Rebuild from source code

Follow the steps in [How to build a Stakepool.](./)


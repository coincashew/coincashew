# How to update a Stakepool

## 📡 1. How to perform an update

From time to time, there will be new versions of `cardano-node`. Follow the [Official Cardano-Node Github Repo](https://github.com/input-output-hk/cardano-node) by enabling **notifications** with the watch functionality.

To update with `$HOME/git/cardano-node` as the current binaries directory, copy the whole cardano-node directory to a new place so that you have a backup.

```bash
cd $HOME/git
rm cardano-node-old/
rsync -av cardano-node/ cardano-node2/
cd cardano-node2/
```

{% hint style="danger" %}
Read the patch notes for any other special updates or dependencies that may be required for the latest release.
{% endhint %}

Remove the old binaries and rebuild the latest binaries. Run the following command to pull and build the latest binaries. Change the checkout **tag** or **branch** as needed.

```bash
rm -rf $HOME/git/cardano-node2/dist-newstyle/build/x86_64-linux/ghc-8.6.5
git clean -fd
git fetch --all && git checkout tags/1.18.1 && git pull
cabal build cardano-node cardano-cli
```

{% hint style="info" %}
Build process may take a few minutes up to a few hours depending on your computer's processing power.
{% endhint %}

Verify your **cardano-cli** and **cardano-node** were updated to the expected version.

```bash
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") version
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") version
```

{% hint style="danger" %}
Stop your node before updating the binaries.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
killall cardano-node
```
{% endtab %}

{% tab title="relaynode1" %}
```
killall cardano-node
```
{% endtab %}

{% tab title="systemd" %}
```
sudo systemctl stop cardano-node
```
{% endtab %}
{% endtabs %}

Copy **cardano-cli** and **cardano-node** files into bin directory.

```bash
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

{% hint style="success" %}
Now restart your node to use the updated binaries.
{% endhint %}

{% tabs %}
{% tab title="block producer node" %}
```bash
cd $NODE_HOME
./startBlockProducingNode.sh
```
{% endtab %}

{% tab title="relaynode1" %}
```
cd $NODE_HOME
./startRelayNode1.sh
```
{% endtab %}

{% tab title="systemd" %}
```
sudo systemctl start cardano-node
```
{% endtab %}
{% endtabs %}

Finally, the following sequence will switch-over to your newly built cardano-node folder while keeping the old directory for backup.

```bash
cd $HOME/git
mv cardano-node/ cardano-node-old/
mv cardano-node2/ cardano-node/
```

## 🤯 2. In case of problems

### 🛣 4.1 Forked off

Forget to update your node and now your node is stuck on an old chain?

Reset your database files and be sure to grab the [latest genesis, config, topology json files](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html).

```bash
cd $NODE_HOME
rm -rf db
```

### 📂 4.2 Roll back to previous version from backup

```bash
cd $HOME/git
mv cardano-node/ cardano-node-rolled-back/
mv cardano-node-old/ cardano-node/
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
$(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") version
$(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") version
```

### 🤖 4.3 Last resort: Rebuild from source code

Follow the steps in [How to build a Stakepool.](./)


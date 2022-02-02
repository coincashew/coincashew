### :top: Updating Your Node Height on PoolTool

{% hint style="info" %}
Credits to [QCPOL](https://cardano.stakepool.quebec) for this addition and credits to [papacarp](https://github.com/papacarp/pooltool.io/tree/master/sendmytip/shell/systemd) which this script is based on. Alternatively, use [cncli's](https://github.com/AndrewWestberg/cncli) PoolTool integration as described in the section [Configuring Slot Leader Calculation](../part-iii-operation/configuring-slot-leader-calculation.md).
{% endhint %}

When browsing pools on [pooltool.io](https://pooltool.io), you'll notice that there's a column named `height`. It shows the node's current block and let your (future) delegators know that your node is running and up to date.

{% tabs %}
{% tab title="block producer node" %}
If your block producer doesn't have Internet access, you can use a relay node.

**Installing the script**

```bash
cd $NODE_HOME
wget https://cardano.stakepool.quebec/scripts/qcpolsendmytip.sh
sed -i -e 's/\r$//' qcpolsendmytip.sh
md5sum qcpolsendmytip.sh
```

To make sure the file is genuine, the md5 hash should be `f7646132e922b24b140202e5f5cba3ac`. If it's not, stop here and delete the file with `rm qcpolsendmytip.sh`.

You will need your pooltool.io API key (shown in your profile after registering).

```bash
sed -i qcpolsendmytip.sh -e "s|CFG_MY_POOL_ID|$(cat stakepoolid.txt)|"
sed -i qcpolsendmytip.sh -e "s/CFG_MY_API_KEY/<YOUR POOLTOOL API KEY HERE>/"
sed -i qcpolsendmytip.sh -e "s|CFG_MY_NODE_SOCKET_PATH|$NODE_HOME/db/socket|"
chmod +x qcpolsendmytip.sh
```

**Installing the service (systemd)**

```bash
cd $NODE_HOME
wget https://cardano.stakepool.quebec/services/qcpolsendmytip.service
sed -i -e 's/\r$//' qcpolsendmytip.service
md5sum qcpolsendmytip.service
```

To make sure the file is genuine, the md5 hash should be `f848641fdc2692ee538e082bada44c2c`. If it's not, stop here and delete the file with `rm qcpolsendmytip.service`.

```bash
sed -i qcpolsendmytip.service -e "s|CFG_WORKING_DIRECTORY|$NODE_HOME|g"
sed -i qcpolsendmytip.service -e "s|CFG_USER|$(whoami)|"
sudo mv qcpolsendmytip.service /etc/systemd/system/qcpolsendmytip.service
sudo chmod 644 /etc/systemd/system/qcpolsendmytip.service
sudo systemctl daemon-reload
sudo systemctl enable qcpolsendmytip
sudo systemctl start qcpolsendmytip
```
{% endtab %}
{% endtabs %}

If everything was setup correctly, you should see your pool's height updated on pooltool.io

![Your pool's tip on pooltool.io](../../../../.gitbook/assets/tip.png)

{% hint style="warning" %}
**Tip: **If the script uses too much CPU on your machine, you can lower the frequency it checks for new blocks. Simply change **0.5** in the following script by a value that works for you. The value is in seconds. The original value of the script is **0.1**.
{% endhint %}

```bash
cd $NODE_HOME
sed -i qcpolsendmytip.sh -e "s/sleep.*/sleep 0.5/"
```

Then restart the service:

```bash
sudo systemctl restart qcpolsendmytip
```

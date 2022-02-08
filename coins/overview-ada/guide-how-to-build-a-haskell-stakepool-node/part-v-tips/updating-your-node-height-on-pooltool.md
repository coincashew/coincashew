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

You will need your pooltool.io API key.

To get your PoolTool API key:

1\. In your Web browser, navigate to [PoolTool.io](https://pooltool.io/)
2\. In the Search field, type your stake pool name or ticker.
3\. In the search results, click the **Pool Details** button in the Actions column next to your stake pool.
4\. On the Pool Details page, click the **Address Details** button next to the Reward Account or Owner Accounts addresses.
5\. On the Address Detail page, click the **Claim Address** button next to the Bech32 address for your stake pool.
6\. In the Claim Address dialog, click the **Claim Address** button, then type a secure password for your PoolTool account in the Password field, and then click **Claim Address**
7\. Send exactly the amount of ADA requested in the Cardano PoolTool dialog from a payment address for the same wallet as the stake address that you want to claim to the requested address.
8\. When the transaction you submitted in step 7 is confirmed, click **Sign In** on the Cardano PoolTool dialog.
9\. After signing in, click **Profile** in the left navigation.
10\. To get your API key, click the **Copy** button next to the API Key field, and then paste the API key as needed.

To configure the `qcpolsendmytip.sh` script, type:

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

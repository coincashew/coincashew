# Reducing Network Bandwidth Usage

{% hint style="info" %}
Hosting your own execution client can consume hundreds of gigabytes of data per day. Because data plans can be limited or costly, you might desire to slow down data usage but still maintain good connectivity to the network.
{% endhint %}

Edit your execution.service unit file.

```bash
sudo nano /etc/systemd/system/execution.service
```

Add the following flag to limit the number of peers on the `ExecStart` line.

{% tabs %}
{% tab title="Geth" %}
```bash
--maxpeers 10
# Example
# ExecStart       = /usr/bin/geth --maxpeers 10 --http --ws
```
{% endtab %}

{% tab title="Besu" %}
```bash
--max-peers 10
# Example
# ExecStart       = <home directory>/besu/bin/besu --max-peers 10 --rpc-http-enabled
```
{% endtab %}

{% tab title="Nethermind" %}
```bash
--Network.ActivePeersMaxCount 10
# Example
# ExecStart       = <home directory>/nethermind/Nethermind.Runner --Network.ActivePeersMaxCount 10 --JsonRpc.Enabled true
```
{% endtab %}

{% tab title="Erigon" %}
```
--maxpeers 10
```
{% endtab %}
{% endtabs %}

Finally, reload the new unit file and restart the execution client.

```bash
sudo systemctl daemon-reload
sudo systemctl restart execution
```

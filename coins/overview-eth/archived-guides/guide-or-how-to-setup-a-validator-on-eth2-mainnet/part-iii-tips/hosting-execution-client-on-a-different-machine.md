# Hosting Execution client on a Different Machine

{% hint style="info" %}
Hosting your own execution client on a different machine than where your beacon-chain and validator resides, can allow some extra modularity and flexibility.
{% endhint %}

On the execution client machine, edit your eth1.service unit file.

```bash
sudo nano /etc/systemd/system/eth1.service
```

Add the following flag to allow remote incoming http and or websocket api requests on the `ExecStart` line.

{% hint style="info" %}
If not using websockets, there's no need to include ws parameters. Only Nimbus requires websockets.
{% endhint %}

{% tabs %}
{% tab title="Geth" %}
```bash
--http.addr 0.0.0.0 --ws.addr 0.0.0.0
# Example
# ExecStart       = /usr/bin/geth --http.addr 0.0.0.0 --ws.addr 0.0.0.0 --http --ws
```
{% endtab %}

{% tab title="OpenEthereum (Parity)" %}
```bash
--jsonrpc-interface=all --ws-interface=all
# Example
# ExecStart       = <home directory>/openethereum/openethereum --jsonrpc-interface=all --ws-interface=all
```
{% endtab %}

{% tab title="Besu" %}
```bash
--rpc-http-host=0.0.0.0 --rpc-ws-enabled --rpc-ws-host=0.0.0.0
# Example
# ExecStart       = <home directory>/besu/bin/besu --rpc-http-host=0.0.0.0 --rpc-ws-enabled --rpc-ws-host=0.0.0.0 --rpc-http-enabled
```
{% endtab %}

{% tab title="Nethermind" %}
```bash
--JsonRpc.Host 0.0.0.0 --WebSocketsEnabled
# Example
# ExecStart       = <home directory>/nethermind/Nethermind.Runner --JsonRpc.Host 0.0.0.0 --WebSocketsEnabled --JsonRpc.Enabled true
```
{% endtab %}
{% endtabs %}

Reload the new unit file and restart the execution client.

```bash
sudo systemctl daemon-reload
sudo systemctl restart eth1
```

On the separate machine hosting the beacon-chain, update the beacon-chain unit file with the execution client's IP address.

{% tabs %}
{% tab title="Lighthouse" %}
```bash
# edit beacon-chain unit file
nano /etc/systemd/system/beacon-chain.service
# add the --eth1-endpoints parameter
# example
# --eth1-endpoints=http://192.168.10.22
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
# edit beacon chain unit file
nano /etc/systemd/system/beacon-chain.service
# modify the --web-url parameter
# example
# --web3-url=ws://192.168.10.22
```
{% endtab %}

{% tab title="Teku" %}
```bash
# edit teku.yaml
nano /etc/teku/teku.yaml
# change the eth1-endpoint
# example
# eth1-endpoint: "http://192.168.10.20:8545"
```
{% endtab %}

{% tab title="Prysm" %}
```bash
# edit beacon-chain unit file
nano /etc/systemd/system/beacon-chain.service
# add the --http-web3provider parameter
# example
# --http-web3provider=http://192.168.10.20:8545
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
# edit beacon-chain unit file
nano /etc/systemd/system/beacon-chain.service
# add the --eth1.providerUrl parameter
# example
# --eth1.providerUrl http://192.168.10.20:8545
```
{% endtab %}
{% endtabs %}

Reload the updated unit file and restart the beacon-chain.

```bash
sudo systemctl daemon-reload
sudo systemctl restart beacon-chain
```

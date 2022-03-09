# Configuring an Air-gapped, Offline Computer

{% hint style="info" %}
An air-gapped offline machine is called your cold environment.

* Protects against key-logging attacks, malware/virus based attacks and other firewall or security exploits.
* Physically isolated from the rest of your network.
* Must not have a network connection, wired or wireless.
* Is not a VM on a machine with a network connection.
* Learn more about [air-gapping at wikipedia](https://en.wikipedia.org/wiki/Air\_gap\_\(networking\)).
{% endhint %}

{% hint style="info" %}
A note about **hardware requirements** for an air-gapped offline machine.

* Can be as basic as a Raspberry Pi or an upcycled older laptop/desktop.
* Uses an usb port to transport files back and forth.
{% endhint %}

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
echo export NODE_HOME=$HOME/cardano-my-node >> $HOME/.bashrc
source $HOME/.bashrc
mkdir -p $NODE_HOME
```
{% endtab %}
{% endtabs %}

Copy from your **hot environment**, also known as your block producer node, a copy of the `cardano-cli` to your **cold environment**, this air-gapped offline machine.

Location of your cardano-cli.

```
/usr/local/bin/cardano-cli
```

{% hint style="danger" %}
In order to remain a true air-gapped environment, you must move files physically between your cold and hot environments with USB keys or other removable media.
{% endhint %}

After copying over to your cold environment, add execute permissions to the file.

```
sudo chmod +x /usr/local/bin/cardano-cli
```

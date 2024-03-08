# Step 3: Installing execution client

## Pick an execution client

Your choice of either [**Geth**](https://geth.ethereum.org)**,** [**Besu**](https://besu.hyperledger.org)**,** [**Nethermind**](https://www.nethermind.io)**, or** [**Erigon**](https://github.com/ledgerwatch/erigon)**.**

{% hint style="warning" %}
Only one execution client is required per node.
{% endhint %}

**Execution Client Diversity** - To strengthen Ethereum's resilience against potential attacks or consensus bugs, it's best practice to run a minority client in order to increase client diversity. Find the latest distribution of execution clients here: [https://clientdiversity.org](https://clientdiversity.org/)

<figure><img src="../../../../../.gitbook/assets/clidiv.png" alt=""><figcaption><p>May 2023 Client Diversity</p></figcaption></figure>

{% hint style="info" %}
:shield: **Recommendation** :shield:: Nethermind
{% endhint %}

{% hint style="warning" %}
**Reminder**: Ensure you are logged in and execute all steps in this guide as non-root user, `ethereum ,`created during Step 2: Configuring Node.
{% endhint %}

**Nethermind** is built on .NET core. Nethermind makes integration with existing infrastructures simple, without losing sight of stability, reliability, data integrity, and security.

{% content-ref url="nethermind.md" %}
[nethermind.md](nethermind.md)
{% endcontent-ref %}

**Hyperledger Besu** is written in Java and is anopen-source Ethereum client designed for demanding enterprise applications requiring secure, high-performance transaction processing.

{% content-ref url="besu.md" %}
[besu.md](besu.md)
{% endcontent-ref %}

**Geth** - Go-ethereum (aka Geth) is an Ethereum client built in Go. It is one of the original and most popular Ethereum clients.

{% content-ref url="geth.md" %}
[geth.md](geth.md)
{% endcontent-ref %}

**Erigon** is an implementation of Ethereum innovating on the efficiency frontier, written in Go.

{% content-ref url="erigon.md" %}
[erigon.md](erigon.md)
{% endcontent-ref %}


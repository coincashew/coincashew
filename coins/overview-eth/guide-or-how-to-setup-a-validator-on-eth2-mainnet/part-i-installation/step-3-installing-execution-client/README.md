# Step 3: Installing execution client

Your choice of either [**Besu**](https://besu.hyperledger.org)**,** [**Nethermind**](https://www.nethermind.io)**,** [**Reth**](reth.md) **or** [**Erigon**](https://github.com/ledgerwatch/erigon)**.**

{% hint style="warning" %}
Only one execution client is required per node.
{% endhint %}

**Execution Client Diversity** - To strengthen Ethereum's resilience against potential attacks or consensus bugs, it's best practice to run a minority client in order to increase client diversity. Find the latest distribution of execution clients here: [https://clientdiversity.org](https://clientdiversity.org/)

<figure><img src="../../../../../.gitbook/assets/cd-e.png" alt=""><figcaption><p>Sept 2023 Client Diversity</p></figcaption></figure>

{% hint style="info" %}
:shield: **Recommendation** :shield:: **Nethermind** or **Besu**
{% endhint %}

{% hint style="danger" %}
:octagonal\_sign:**Strongly discouraged** :octagonal\_sign:**: GETH can be** [**hazardous to your all YOUR STAKE.**](https://twitter.com/EthDreamer/status/1749355402473410714?ref\_src=twsrc%5Etfw%7Ctwcamp%5Etweetembed%7Ctwterm%5E1749355402473410714%7Ctwgr%5Ec8a1aa0ef51d2c9c4a70664acbe61505802be16a%7Ctwcon%5Es1\_\&ref\_url=https%3A%2F%2Fwww.redditmedia.com%2Fmediaembed%2F19de574%3Fresponsive%3Dtrueis\_nightmode%3Dtrue)
{% endhint %}

{% hint style="warning" %}
**Reminder**: Ensure you are logged in and execute all steps in this guide as non-root user, `ethereum ,`created during Step 2: Configuring Node.
{% endhint %}

## Select your desired execution client for further instructions.

| Execution Clients                                                                                                                                                                      |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Nethermind** is built on .NET core. Nethermind makes integration with existing infrastructures simple, without losing sight of stability, reliability, data integrity, and security. |
| **Hyperledger Besu** is written in Java and is anopen-source Ethereum client designed for demanding enterprise applications requiring secure, high-performance transaction processing. |
| **Reth** (short for Rust Ethereum) is a new Ethereum full node implementation that is focused on being user-friendly, highly modular, as well as being fast and efficient.             |
| **Geth** - Go-ethereum (aka Geth) is an Ethereum client built in Go. It is one of the original and most popular Ethereum clients.                                                      |
| **Erigon** is an implementation of Ethereum innovating on the efficiency frontier, written in Go.                                                                                      |

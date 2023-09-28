# Step 3: Installing execution client

{% hint style="info" %}
As of 9/26/2023, the following binaries are ready for Holesky relaunch.
{% endhint %}

| Client     | Ready | Version          |
| ---------- | ----- | ---------------- |
| besu       | ✅     | 23.7.3+          |
| nethermind | ✅     | v1.20.4+         |
| erigon     | ✅     | v2.49.3+         |
| geth       | ✅     | v1.13.2+         |
| reth       | ✅     | v0.1.0-alpha.10+ |

Your choice of either [**Geth**](https://geth.ethereum.org)**,** [**Besu**](https://besu.hyperledger.org)**,** [**Nethermind**](https://www.nethermind.io)**, or** [**Erigon**](https://github.com/ledgerwatch/erigon)**.**

{% hint style="warning" %}
Only one execution client is required per node.
{% endhint %}

**Execution Client Diversity** - To strengthen Ethereum's resilience against potential attacks or consensus bugs, it's best practice to run a minority client in order to increase client diversity. Find the latest distribution of execution clients here: [https://clientdiversity.org](https://clientdiversity.org/)

<figure><img src="../../../../.gitbook/assets/cd-e.png" alt=""><figcaption><p>Sept 2023 Client Diversity</p></figcaption></figure>

{% hint style="info" %}
:shield: **Recommendation** :shield:: Nethermind or Besu
{% endhint %}

{% hint style="warning" %}
**Reminder**: Ensure you are logged in and execute all steps in this guide as non-root user, `ethereum ,`created during Step 2: Configuring Node.
{% endhint %}

## Select your desired execution client for further instructions.

| Execution Clients                                                                                                                                                                      |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Nethermind** is built on .NET core. Nethermind makes integration with existing infrastructures simple, without losing sight of stability, reliability, data integrity, and security. |
| **Hyperledger Besu** is written in Java and is anopen-source Ethereum client designed for demanding enterprise applications requiring secure, high-performance transaction processing. |
| **Geth** - Go-ethereum (aka Geth) is an Ethereum client built in Go. It is one of the original and most popular Ethereum clients.                                                      |
| **Erigon** is an implementation of Ethereum innovating on the efficiency frontier, written in Go.                                                                                      |

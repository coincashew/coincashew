---
description: >-
  Execution clients (formerly known as eth1 nodes) grow quickly. Run this
  process to prune the blockchain and free up space.
---

# How to free up execution client (eth1) disk space with pruning

## Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](./). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

### :dagger: Why do I want to prune my execution client?

* Free up gigs of precious disk space. Typically 200gb or more is common.

### :robot: Pre-requisites

* Works with **geth + erigon (automatic)** currently
* Ensure at least 50+ GB of free disk space is available otherwise database corruption may occur.

### :construction: How to prune execution client

{% hint style="info" %}
Ensure adequate failover or backup execution clients are configured for use with your beacon-chain node before proceeding. geth is offline and unavailable during this process.
{% endhint %}

1\. Note how much disk space is currently used and stop the execution client

```
df
sudo service eth1 stop
```

2\. Start the pruning process and monitor it's process.

{% hint style="warning" %}
:fire: **Geth pruning Caveats**:&#x20;

* Pruning can take a few hours or longer (typically 2 to 10 hours is common) depending on your node's disk performance.
* There are three stages to pruning: **iterating state snapshot, pruning state data and compacting database.**
* "**Compacting database**" will stop updating status and appear hung. **Do not interrupt or restart this process.** Typically after an hour, pruning status messages will reappear.
{% endhint %}

{% tabs %}
{% tab title="Geth" %}
```bash
/usr/bin/geth --datadir $HOME/.ethereum snapshot prune-state
```
{% endtab %}

{% tab title="Erigon" %}
```bash
# Automatic if your systemd service is setup with --prune

# Example
# $HOME/erigon/build/bin/erigon --private.api.addr=localhost:9090 --pprof --metrics --prune htc

# Note: --prune deletes data older than 90K blocks from the tip of the chain (aka, for if tip block is no. 12'000'000, only the data between 11'910'000-12'000'000 will be kept).
```
{% endtab %}
{% endtabs %}

3\. Once the pruning is finished, restart the execution client service.

```bash
sudo service eth1 restart
```

4\. Compare the disk space of the node after pruning.

```bash
df
```

{% hint style="success" %}
Nice work. Enjoy the extra disk breathing room.
{% endhint %}

## &#x20;:robot: Start staking by building a validator <a href="#start-staking-by-building-a-validator" id="start-staking-by-building-a-validator"></a>

### Visit here for our [Mainnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet) and here for our [Testnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-testnet). <a href="#visit-here-for-our-mainnet-guide-and-here-for-our-testnet-guide" id="visit-here-for-our-mainnet-guide-and-here-for-our-testnet-guide"></a>

{% hint style="success" %}
Congrats on completing the guide. ✨

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it.

It really energizes us to keep creating the best crypto guides.

Use [cointr.ee to find our donation](https://cointr.ee/coincashew) addresses. 🙏

Any feedback and all pull requests much appreciated. 🌛

Hang out and chat with fellow stakers on Discord @

​[https://discord.gg/w8Bx8W2HPW](https://discord.gg/w8Bx8W2HPW) 😃
{% endhint %}

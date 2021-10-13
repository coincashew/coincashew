---
description: >-
  Running slasher is completely optional and yet can help protect the chain and
  earn you extra ETH.
---

# How to run a slasher

## :fast_forward: Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](./). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

### :dagger: What is a Slasher?

* Validators might commit slashable transactions such as
  * **Double Voting**: signs more than one block in same epoch
  * **Surround Votes**: signs two contradictory attestations
* A slasher will submit proof of the above offenses into a block proposal.
* Running a slashing helps protect and keeps the network healthy.
* If your slasher successfully detects an offense and is lucky enough to include proof of the offense into your scheduled block proposal, your validator earns extra ETH.

{% hint style="warning" %}
Slashers tend to be resource intensive and is currently recommended for advanced users only.
{% endhint %}

### :robot: Minimum Slasher System Requirements

* Quad-core or more CPU
* 16+ GB RAM
* 256GB+ SSD HD

### :construction: How to Configure the Slasher

Slasher functionality is currently available in Lighthouse or Prysm.

{% tabs %}
{% tab title="Lighthouse " %}
```bash
# Edit your beacon-chain unit file
sudo nano /etc/systemd/system/beacon-chain.service

# Append the following slasher flag to ExecStart
--slasher --debug-level debug

# Example of what your ExecStart could look like.
# lighthouse bn --staking --metrics --network mainnet --slasher --debug-level debug

# Reload the new unit file
sudo systemctl daemon-reload

# Restart your beacon-chain
sudo systemctl restart beacon-chain
```
{% endtab %}

{% tab title="Prysm" %}
```bash
# Revamped Prysm slasher implementation. 
# The slasher functionality is no longer a standalone binary. 
# Note: Running the slasher has considerably increased resource requirements. 
# Be sure to review the latest documentation before enabling this feature. 

# Edit your beacon-chain unit file
sudo nano /etc/systemd/system/beacon-chain.service

# Append the following slasher flag to ExecStart
--slasher

# Example of what your ExecStart could look like.
# prysm.sh beacon-chain --slasher

# Reload the new unit file
sudo systemctl daemon-reload

# Restart your beacon-chain
sudo systemctl restart beacon-chain
```
{% endtab %}
{% endtabs %}

{% hint style="success" %}
Nice work. You're running a slasher now. :dagger: :robot: :knife: 
{% endhint %}

{% hint style="info" %}
Be sure to familiarize yourself with the [reference material for detailed official slasher documentation.](how-to-run-a-slasher.md#reference-material)
{% endhint %}

##  :robot: Start staking by building a validator <a href="start-staking-by-building-a-validator" id="start-staking-by-building-a-validator"></a>

### Visit here for our [Mainnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet) and here for our [Testnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-testnet). <a href="visit-here-for-our-mainnet-guide-and-here-for-our-testnet-guide" id="visit-here-for-our-mainnet-guide-and-here-for-our-testnet-guide"></a>

{% hint style="success" %}
Congrats on completing the guide. ✨

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it.

It really energizes us to keep creating the best crypto guides.

Use [cointr.ee to find our donation](https://cointr.ee/coincashew) addresses. 🙏

Any feedback and all pull requests much appreciated. 🌛

Hang out and chat with fellow stakers on Discord @

​[https://discord.gg/w8Bx8W2HPW](https://discord.gg/w8Bx8W2HPW) 😃
{% endhint %}

:confetti_ball: **2020-12 Update**: Thanks to all [Gitcoin](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew) contributors, where you can contribute via [quadratic funding](https://vitalik.ca/general/2019/12/07/quadratic.html) and make a big impact. Funding complete! Thank you!🙏

{% embed url="https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew" %}

## :jigsaw: Reference Material

{% embed url="https://docs.prylabs.network/docs/prysm-usage/slasher/" %}

{% embed url="https://lighthouse-book.sigmaprime.io/slasher.html" %}

---
description: >-
  Scenario: Genesis block is long passed and now you would like to add more
  validators with your existing mnemonic seed.
---

# How to add a new validator to an existing setup with exisiting seed words

## ⏩ Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](./). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

1. Backup and move your existing `validator_key` directory and append the date to the end.

```bash
# Adjust your eth2deposit-cli directory accordingly
cd $HOME/eth2deposit-cli
# Renames and append the date to the existing validator_key directory
mv validator_key validator_key_$(date +"%Y%d%m-%H%M%S")
# Optional: you can also delete this folder since it can be regenerated.
```

{% hint style="info" %}
Using the eth2deposit-cli tool, you can add more validators by creating a new deposit data file and `validator_keys`
{% endhint %}

2. For example, in case we originally created **3 validators** but now wish to **add 5 more validators**, we could use the following command. Select the tab depending on how you acquired [**eth2deposit tool**](https://github.com/ethereum/eth2.0-deposit-cli).

{% hint style="warning" %}
**Security recommendation reminder**: For best security practices, key management and other activities where you type your 24 word mnemonic seed should be completed on an air-gapped offline cold machine booted from USB drive.
{% endhint %}

{% hint style="danger" %}
Reminder to use the same **keystore password.**
{% endhint %}

{% tabs %}
{% tab title="Build from source code" %}
```bash
# Generate from an existing mnemonic 5 more validators when 3 were previously already made
./deposit.sh existing-mnemonic --validator_start_index 3 --num_validators 5 --chain mainnet
```
{% endtab %}

{% tab title="Pre-built eth2deposit-cli binaries" %}
```bash
# Generate from an existing mnemonic 5 more validators when 3 were previously already made
./deposit existing-mnemonic --validator_start_index 3 --num_validators 5 --chain mainnet
```
{% endtab %}

{% tab title="Advanced - Most Secure" %}
{% hint style="warning" %}
🔥**Pro Security Tip**: Run the **eth2deposit-cli tool** and generate your **mnemonic seed** for your validator keys on an **air-gapped offline machine booted from usb**.
{% endhint %}

Follow this [ethstaker.cc](https://ethstaker.cc/) exclusive for the low down on making a bootable usb.

### Part 1 - Create a Ubuntu 20.04 USB Bootable Drive

{% embed url="https://www.youtube.com/watch?v=DTR3PzRRtYU" %}

### Part 2 - Install Ubuntu 20.04 from the USB Drive

{% embed url="https://www.youtube.com/watch?v=C97\_6MrufCE" %}

You can copy via USB key the pre-built eth2deposit-cli binaries from an online machine to an air-gapped offline machine booted from usb. Make sure to disconnect the ethernet cable and/or WIFI.

Run the existing-mnemonic command in the previous tabs.
{% endtab %}
{% endtabs %}

3. Complete the steps of uploading the `deposit_data-#########.json` to the [official Eth2 launch pad site](https://launchpad.ethereum.org/) and making your corresponding 32 ETH deposit transactions.

4. Finish by stopping your validator, importing the new validator key\(s\), restarting your validator and verifying the logs ensuring everything still works without error. [Review steps 2 and onward of the main guide if you need a refresher.](./#2-signup-to-be-a-validator-at-the-launchpad)

5. Finally, verify your **existing** validator's attestations are working with public block explorer such as

[https://beaconcha.in/](https://beaconcha.in/) or [https://beaconscan.com/](https://beaconscan.com/)

Enter your validator's pubkey to view its status.

{% hint style="info" %}
Your additional validators are now in the activation queue waiting their turn. Check your estimated activation time at [https://eth2-validator-queue.web.app/](https://eth2-validator-queue.web.app/)
{% endhint %}

##  🤖 Start staking by building a validator <a id="start-staking-by-building-a-validator"></a>

### Visit here for our [Mainnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet) and here for our [Testnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-testnet). <a id="visit-here-for-our-mainnet-guide-and-here-for-our-testnet-guide"></a>

{% hint style="success" %}
Congrats on completing the guide. ✨

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it.

It really energizes us to keep creating the best crypto guides.

Use [cointr.ee to find our donation](https://cointr.ee/coincashew) addresses. 🙏

Any feedback and all pull requests much appreciated. 🌛

Hang out and chat with fellow stakers on Discord @

​[https://discord.gg/w8Bx8W2HPW](https://discord.gg/w8Bx8W2HPW) 😃
{% endhint %}

🎊 **2020-12 Update**: Thanks to all [Gitcoin](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew) contributors, where you can contribute via [quadratic funding](https://vitalik.ca/general/2019/12/07/quadratic.html) and make a big impact. Funding complete! Thank you!🙏

{% embed url="https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew" %}


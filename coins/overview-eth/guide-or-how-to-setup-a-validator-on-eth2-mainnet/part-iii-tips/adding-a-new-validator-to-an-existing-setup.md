---
description: >-
  Scenario: Genesis block is long passed and now you would like to add more
  validators with your existing mnemonic seed.
---

# Adding a New Validator to an Existing Setup with Existing Seed Words

## :fast\_forward: Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](./). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

1\. Backup and move your existing `validator_key` directory and append the date to the end.

```bash
# Adjust your staking-deposit-cli directory accordingly
cd $HOME/staking-deposit-cli
# Renames and append the date to the existing validator_key directory
mv validator_key validator_key_$(date +"%Y%d%m-%H%M%S")
# Optional: you can also delete this folder since it can be regenerated.
```

{% hint style="info" %}
Using the staking-deposit-cli tool, you can add more validators by creating a new deposit data file and `validator_keys`
{% endhint %}

2\. For example, in case we originally created **3 validators** but now wish to **add 5 more validators**, we could use the following command.

{% hint style="warning" %}
**Security recommendation reminder**: For best security practices, key management and other activities where you type your 24 word mnemonic seed should be completed on an air-gapped offline cold machine booted from USB drive.
{% endhint %}

{% hint style="danger" %}
Reminder to use the same **keystore password** as existing validators.
{% endhint %}

```bash
# Generate from an existing mnemonic 5 more validators when 3 were previously already made
./deposit existing-mnemonic --validator_start_index 3 --num_validators 5 --chain mainnet
```

3\. Complete the steps of uploading the `deposit_data-#########.json` to the [official Eth2 launch pad site](https://launchpad.ethereum.org) and making your corresponding 32 ETH deposit transactions.

4\. Finish by stopping your validator, importing the new validator key(s), restarting your validator and verifying the logs ensuring everything still works without error. [Review steps 2 and onward of the main guide if you need a refresher.](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/signing-up-to-be-a-validator-at-the-launchpad)

5\. Finally, verify your **existing** validator's attestations are working with public block explorer such as

[https://beaconcha.in/](https://beaconcha.in) or [https://beaconscan.com/](https://beaconscan.com)

Enter your validator's pubkey to view its status.

{% hint style="info" %}
Your additional validators are now in the activation queue waiting their turn. Check your estimated activation time at [https://eth2-validator-queue.web.app/](https://eth2-validator-queue.web.app)
{% endhint %}

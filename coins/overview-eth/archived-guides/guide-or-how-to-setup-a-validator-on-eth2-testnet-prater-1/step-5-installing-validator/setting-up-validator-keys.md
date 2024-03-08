# Setting up Validator Keys

## :seedling: 1. Obtain testnet ETH

{% hint style="info" %}
Every 32 ETH you own allows you to make 1 validator. You can run thousands of validators with your beacon node. However on testnet, please only run 1 or 2 validators to keep the activation queue reasonably quick.
{% endhint %}

<details>

<summary>Option 1: Ethstaker's #cheap-goerli-validator Channel</summary>

* **Step 1**: Visit the [Ethstaker Discord](https://discord.io/ethstaker) and join the #cheap-goerli-validator channel

<!---->

* **Step 2**: Use the `/cheap-goerli-deposit` slash command and follow the instructions from the bot. You need to start typing the slash command and it will show above your input box where you can use it.

<!---->

* **Requirement**: In order to use the cheap goerli validator process, you must now set your withdrawal address to `0x4D496CcC28058B1D74B7a19541663E21154f9c84` when creating your validator keys and deposit file. This is to prevent abuses of this service.

</details>

<details>

<summary>Option 2: Watch this how-to Youtube video for Goerli ETH</summary>

Link: [https://youtu.be/uur7hGCscak](https://youtu.be/uur7hGCscak)

</details>

## :woman\_technologist: 2. Signup to be a validator at the Launchpad

1. Install dependencies, the ethereum foundation deposit tool and generate your two sets of key pairs.

{% hint style="info" %}
Each validator will have two sets of key pairs. A **signing key** and a **withdrawal key.** These keys are derived from a single mnemonic phrase. [Learn more about keys.](https://blog.ethereum.org/2020/05/21/keys/)

You will also set your [ETH Withdrawal Address](https://notes.ethereum.org/@launchpad/withdrawals-faq#Q-What-are-the-two-types-of-withdrawals), preferably from your Ledger or Trezor hardware wallet. However, for **testnet purposes** it's okay to use a browser/hot wallet address.

:octagonal\_sign::octagonal\_sign: **DO NOT USE AN EXCHANGE ADDRESS AS WITHDRAWAL ADDRESS.** :octagonal\_sign::octagonal\_sign:

:octagonal\_sign::octagonal\_sign: **Double check your work as this is permanent once set!** :octagonal\_sign::octagonal\_sign:

The Withdrawal Address is:

* where your ETH is returned upon "voluntary exiting a validator", or also known as full withdrawal.
* where you receive partial withdrawals, which is where any excess balance above 32 ETH is periodically scraped and made available for use.
{% endhint %}

You have the choice of using the [Wagyu GUI](https://github.com/stake-house/wagyu-installer), downloading the pre-built [Ethereum staking deposit tool](https://github.com/ethereum/staking-deposit-cli) or building it from source.

{% tabs %}
{% tab title="Pre-built staking-deposit-cli" %}
Download staking-deposit-cli.

```bash
cd $HOME
wget https://github.com/ethereum/staking-deposit-cli/releases/download/v2.5.0/staking_deposit-cli-d7b5304-linux-amd64.tar.gz
```

Verify the SHA256 Checksum matches the checksum on the [releases page](https://github.com/ethereum/staking-deposit-cli/releases).

```bash
echo "3f51859d78ad47a3e258470f5a5caf03d19ed1d4307d517325b7bb8f6fcde6ef *staking_deposit-cli-d7b5304-linux-amd64.tar.gz" | shasum -a 256 --check
```

Example valid output:

> staking\_deposit-cli-d7b5304-linux-amd64.tar.gz: OK

{% hint style="danger" %}
Only proceed if the sha256 check passes with **OK**!
{% endhint %}

Extract the archive.

```bash
tar -xvf staking_deposit-cli-d7b5304-linux-amd64.tar.gz
mv staking_deposit-cli-d7b5304-linux-amd64 staking-deposit-cli
rm staking_deposit-cli-d7b5304-linux-amd64.tar.gz
cd staking-deposit-cli
```

Make a new mnemonic and replace `<ETH_ADDRESS_FROM_IDEALLY_HARDWARE_WALLET>` with your [ethereum withdrawal address](https://notes.ethereum.org/@launchpad/withdrawals-faq#Q-If-I-used---eth1\_withdrawal\_address-when-making-my-initial-deposit-which-type-of-withdrawal-credentials-do-I-have), ideally from a Trezor, Ledger or comparable hardware wallet.

:octagonal\_sign::octagonal\_sign: **DO NOT USE AN EXCHANGE ADDRESS AS WITHDRAWAL ADDRESS.** :octagonal\_sign::octagonal\_sign:

:octagonal\_sign::octagonal\_sign: **Double check your work as this is permanent once set!** :octagonal\_sign::octagonal\_sign:

```
./deposit new-mnemonic --chain goerli --execution_address <ETH_ADDRESS_FROM_IDEALLY_HARDWARE_WALLET>
```
{% endtab %}

{% tab title="Build from source code" %}
Install dependencies.

```bash
sudo apt update
sudo apt install python3-pip git -y
```

Download source code and install.

```bash
cd ~
git clone https://github.com/ethereum/staking-deposit-cli
cd staking-deposit-cli
sudo ./deposit.sh install
```

Make a new mnemonic and replace `<ETH_ADDRESS_FROM_IDEALLY_HARDWARE_WALLET>` with your [ethereum withdrawal address](https://notes.ethereum.org/@launchpad/withdrawals-faq#Q-If-I-used---eth1\_withdrawal\_address-when-making-my-initial-deposit-which-type-of-withdrawal-credentials-do-I-have), ideally from a Trezor, Ledger or comparable hardware wallet.

:octagonal\_sign::octagonal\_sign: **DO NOT USE AN EXCHANGE ADDRESS AS WITHDRAWAL ADDRESS.** :octagonal\_sign::octagonal\_sign:

:octagonal\_sign::octagonal\_sign: **Double check your work as this is permanent once set!** :octagonal\_sign::octagonal\_sign:

```
./deposit.sh new-mnemonic --chain goerli --execution_address <ETH_ADDRESS_FROM_IDEALLY_HARDWARE_WALLET>
```
{% endtab %}

{% tab title="Wagyu" %}
Wagyu (formerly known as StakeHouse) is an application aimed at lowering the technical bar to staking on Ethereum 2.0.

Dubbed a 'one-click installer', it provides a clean UI automating the setup and management of all the infrastructure necessary to stake without the user needing to have any technical knowledge.

Download Wagyu: [https://wagyu.gg](https://wagyu.gg/)

Github: [https://github.com/stake-house/wagyu-installer](https://github.com/stake-house/wagyu-installer)

After creating the validator keys locally, you'll want to copy these validator keys via USB key or rsync file transfer to your staking node.

To align with this guide's steps, first make a default path to store your validator keys.

<pre><code><strong>mkdir -p $HOME/staking-deposit-cli/validator_keys
</strong></code></pre>

If using USB key, mount the key then copy.

```
cp <directory-with-keys>/*.json $HOME/staking-deposit-cli/validator_keys
```

If using rsync, copy your validator keys from your local computer to your staking node with the following command. Change ssh port if needed.

```
rsync -a "ssh -p 22" <directory-with-keys>/*.json <username>@<remote_host>:/home/<username>/staking-deposit-cli/validator_keys
```
{% endtab %}

{% tab title="Advanced - Most Secure" %}
{% hint style="warning" %}
:fire:**\[ Optional ] Pro Security Tip**: Run the staking-deposit-cli tool and generate your **mnemonic seed** for your validator keys on an **air-gapped offline machine booted from usb**.
{% endhint %}

You will learn how to boot up a windows PC into an airgapped [Tails operating system](https://tails.boum.org/index.en.html).

The Tails OS is an _amnesic_ operating system, meaning it will save nothing and _leave no tracks behind_ each time you boot it.

**Part 0 - Prerequisites**

You need:

* 2 storage mediums (can be USB stick, SD cards or external hard drives)
* One of them must be > 8GB
* Windows or Mac computer
* 30 minutes or longer depending on your download speed

**Part 1 - Download Tails OS**

Download the official image from the [Tails website](https://tails.boum.org/install/index.en.html). Might take a while, go grab a coffee.

Make sure you follow the guide on the Tails website to verify your download of Tails.

**Part 2 - Download and install the software to transfer your Tails image on your USB stick**

For Windows, use one of

* [Etcher](https://tails.boum.org/etcher/Etcher-Portable.exe)
* [Win32 Disk Imager](https://win32diskimager.org/#download)
* [Rufus](https://rufus.ie/en\_US/)

For Mac, download [Etcher](https://tails.boum.org/etcher/Etcher.dmg)

**Part 3 - Making your bootable USB stick**

Run the above software. This is an example how it looks like on Mac OS with etcher, but other software should be similar.

![](../../../../../.gitbook/assets/etcher\_in\_mac.png)

Select the Tails OS image that you downloaded as the image. Then select the USB stick (the larger one).

Then flash the image to the larger USB stick.

**Part 4 - Download and verify the staking-deposit-cli**

You can refer to the other tab on this guide on how to download and verify the staking-deposit-cli.

Copy the file to the other USB stick.

**Part 5 - Reboot your computer and into Tails OS**

After you have done all the above, you can reboot. If you are connected by a LAN cable to the internet, you can disconnect it manually.

Plug in the USB stick that has your Tails OS.

On Mac, press and hold the Option key immediately upon hearing the startup chime. Release the key after Startup Manager appears.

On Windows, it depends on your computer manufacturer. Usually it is by pressing F1 or F12. If it doesn't work, try googling "Enter boot options menu on \[Insert your PC brand]"

Choose the USB stick that you loaded up with Tails OS to boot into Tails.

**Part 6 - Welcome to Tails OS**

![](../../../../../.gitbook/assets/grub.png)

You can boot with all the default settings.

**Part 7 - Run the staking-deposit-cli**

Plug in your other USB stick with the `staking-deposit-cli` file.

Copy the `deposit` file to your home directory.

Add execute permissions

```
chmod +x deposit
```

Make a new mnemonic and replace `<ETH_ADDRESS_FROM_IDEALLY_HARDWARE_WALLET>` with your [ethereum withdrawal address](https://notes.ethereum.org/@launchpad/withdrawals-faq#Q-If-I-used---eth1\_withdrawal\_address-when-making-my-initial-deposit-which-type-of-withdrawal-credentials-do-I-have), ideally from a Trezor, Ledger or comparable hardware wallet.

:octagonal\_sign::octagonal\_sign: **DO NOT USE AN EXCHANGE ADDRESS AS WITHDRAWAL ADDRESS.** :octagonal\_sign::octagonal\_sign:

:octagonal\_sign::octagonal\_sign: **Double check your work as this is permanent once set!** :octagonal\_sign::octagonal\_sign:

```
./deposit new-mnemonic --chain goerli --execution_address <ETH_ADDRESS_FROM_IDEALLY_HARDWARE_WALLET>
```

If you ran this command directly from your non-Tails USB stick, the validator keys should stay on it. If it hasn't, copy the directory over to your non-Tails USB stick.

{% hint style="warning" %}
:fire: **Make sure you have saved your validator keys directory in your other USB stick (non Tails OS) before you shutdown Tails. Tails will delete everything saved on it after you shutdown.**.
{% endhint %}

{% hint style="success" %}
:tada: Congrats on learning how to use Tails OS to make an air gapped system. As a bonus, you can reboot into Tails OS again and connect to internet to surf the dark web or clear net safely!
{% endhint %}
{% endtab %}
{% endtabs %}

2\. If using **staking-deposit-cli**, follow the prompts and pick a **KEYSTORE password**. This password encrypts your keystore files. Write down your mnemonic and keep this safe and **offline**.

{% hint style="danger" %}
**Do not send real mainnet ETH during this process!** :octagonal\_sign: Use only goerli ETH.
{% endhint %}

{% hint style="warning" %}
**Caution**: Only deposit the 32 ETH per validator if you are confident your execution client (ETH1 node) and consensus client (ETH2 validator) will be fully synced and ready to perform validator duties. You can return later to launchpad with your deposit-data to finish the next steps.
{% endhint %}

3\. Follow the steps at [https://goerli.launchpad.ethereum.org](https://goerli.launchpad.ethereum.org/en/) while skipping over the steps you already just completed. Study the eth2 phase 0 overview material. Understanding eth2 is the key to success!

{% hint style="info" %}
:whale: **Batch Depositing Tip**: If you have many deposits to make for many validators, consider using [Abyss.finance's eth2depositor tool.](https://abyss.finance/eth2depositor) This greatly improves the deposit experience as multiple deposits can be batched into one transaction, thereby saving gas fees and saving your fingers by minimizing Metamask clicking.

Make sure to switch to **GÖRLI** network.

Source: [https://twitter.com/AbyssFinance/status/1379732382044069888](https://twitter.com/AbyssFinance/status/1379732382044069888)
{% endhint %}

4\. Back on the launchpad website, upload your`deposit_data-#########.json` found in the `validator_keys` directory.

5\. Connect to the launchpad with your Metamask wallet, review and accept terms. Ensure you're connected to **GÖRLI** network.

6\. Confirm the transaction(s). There's one deposit transaction of 32 ETH for each validator.

{% hint style="info" %}
For instance, if you want to run 3 validators you will need to have (32 x 3) = 96 goerli ETH plus some extra to cover the gas fees.
{% endhint %}

{% hint style="info" %}
Your transaction is sending and depositing your ETH to the goerli ETH2 deposit contract address.

**Check**, _double-check_, _**triple-check**_ that the goerli Eth2 deposit contract address is correct.

[`0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b`](https://goerli.etherscan.io/address/0xff50ed3d0ec03ac01d4c79aad74928bff48a7b2b)
{% endhint %}

{% hint style="danger" %}
:fire: **Critical Crypto Reminder:** **Keep your mnemonic, keep your ETH.**

* Write down your mnemonic seed **offline**. _Not email. Not cloud._
* Multiple copies are better. _Best stored in a_ [_metal seed._](https://jlopp.github.io/metal-bitcoin-storage-reviews/)
* Make **offline backups**, such as to a USB key, of your **`validator_keys`** directory.
{% endhint %}

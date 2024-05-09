---
description: >-
  How to recover an ethereum validator's 24 word secret recovery phrase with
  seedrecovery.py by btcrecover.
---

# 🔎 Guide | Recover Ethereum Validator Mnemonic Seed

## :question:Who is the guide for, what's involved, when do I need this?

* :people\_hugging: **WHO**: If you are an Ethereum validator experiencing errors due to a problematic secret recovery phrase or mnemonic, this guide can help you fix the majority of common errors.
* :chains: **WHAT**: Using [btcrecover's](https://github.com/3rdIteration/btcrecover) Seedrecover.py can fix the majorty of simple "invalid mnemonic" or "invalid seed" type errors. This commonly occurs when you have a valid seed backup that simply has a typo in it or missing word(s).
* :hourglass: **WHEN**: Typical scenarios include attempting to **set withdrawal credentials** or **re-generate keystore files**.

## :hammer\_pick: How to Recover?

## Step 1: Setup an offline PC with Ubuntu Live USB

* First, you'll need to create an Ubuntu Live USB. [Download Ubuntu ISO](https://ubuntu.com/download/desktop) and image to USB drive. See below video demos or [this guide](https://itsfoss.com/create-live-usb-of-ubuntu-in-windows/).

{% hint style="info" %}
:tv: **Video Demos**

**Windows**: Installing BTCRecover in Windows: [https://youtu.be/8q65eqpf4gE](https://youtu.be/8q65eqpf4gE)

**Linux**: Installing BTCRecover in Ubuntu Live USB: [https://youtu.be/Met3NbxcZTU](https://youtu.be/Met3NbxcZTU)
{% endhint %}

## Step 2: Install btcrecover

With a terminal open inside your Ubuntu Live session, run the following.

```bash
# Install dependencies
sudo apt install python3-tk
sudo add-apt-repository universe
sudo apt install python3-pip

# Download btcrecover and install requirements
cd ~
wget https://github.com/3rdIteration/btcrecover/archive/master.zip
unzip master.zip
cd btcrecover-master
pip3 install -r requirements.txt
pip3 install git+https://github.com/ethereum/staking-deposit-cli.git@v2.5.0
pip3 install py_ecc

# Verify the install by running tests
python3 run-all-tests.py -vv
```

## Step 3: Go offline

* Disconnect ethernet cable and/or disable WIFI.
* Verify no internet access by attemping to ping.&#x20;

```bash
ping 8.8.8.8
```

Ping result should say **Network is unreachable**.

## Step 4: Run the recovery process

{% hint style="info" %}
Recovery for Ethereum Validator seeds is the same as a standard seed recovery, but uses the validators public key (Also known as Signing Key) in the place of an address.



Seedrecover.py will automatically run through four search phases that should take a few hours at most. The four search phases include:

* Single typo
* Two typos, including one where you might have a completely different word
* Three typos, including one where you might have a completely different word
* Two typos that could be completely different words
{% endhint %}

Here's the command to recover your ETH validator's secret recovery phase. Update accordingly.

```bash
python3 seedrecover.py --mnemonic "<secret recovery phrase>" --addrs <pubkey of validator> --wallet-type ethereumvalidator --addr-limit <number of validators created> --mnemonic-length 24
```

### :question:About the flags

* **--mnemonic** : Enter your best guess for your seed/mnemnoic/secret recovery phrase
* **--addrs** :  this is your validators public key without the 0x prefix. For example, if you have the keystores files the pubkey can be found inside "keystore-m\_12381\_3600\_0\_0\_0-xxxxxxx.json" Without keystore files, you can look up your validator's pubkey online at beaconcha.in or etherscan.io by following the validator's 32ETH deposit transaction.
* **--addr-limit** : Adjust this to the number of validators you created on this mnemonic.

{% hint style="warning" %}
Not recommended: Running recovery on an online machine? Add the flag `--dsw`
{% endhint %}

### :thumbsup: Usage Examples

Best guess - Only have 23 words. Missing one word somewhere.

```bash
python3 seedrecover.py --mnemonic "cousin fury spatial aisle day write bulk empower fog fault stick broom demand valve fine able subway absent valve inform coconut oval season" --addrs 99722e2d3cdf850ef76516273273b5b2bfd062a6b706f6c395e116183fecd1ba6f9e9a479006a621168154e260f1a9d9 --wallet-type ethereumvalidator --addr-limit 1 --mnemonic-length 24
```

Place an x where the wrong word is, position is known.

```bash
python3 seedrecover.py --mnemonic "cousin fury spatial aisle day write bulk empower fog fault stick broom demand valve fine able x absent valve inform coconut oval season master" --addrs 99722e2d3cdf850ef76516273273b5b2bfd062a6b706f6c395e116183fecd1ba6f9e9a479006a621168154e260f1a9d9 --wallet-type ethereumvalidator --addr-limit 1 --mnemonic-length 24
```

Two wrong or missing words, position is known.

```bash
python3 seedrecover.py --mnemonic "cousin fury spatial aisle day write bulk empower fog fault stick broom demand valve fine able x x absent valve inform coconut oval season master" --addrs 99722e2d3cdf850ef76516273273b5b2bfd062a6b706f6c395e116183fecd1ba6f9e9a479006a621168154e260f1a9d9 --wallet-type ethereumvalidator --addr-limit 1 --mnemonic-length 24
```

Created 3 validators. Addr-limit is 3. One missing word somewhere.

```bash
python3 seedrecover.py --mnemonic "cousin fury spatial aisle day write bulk empower fog fault stick broom demand valve fine able absent valve inform coconut oval season master" --addrs b9bf3e3781f288547a10a65f3ec18d38668be0af5b498b446b95530e2adee6eb30fa4c0a47abe93b198d8fed7d68385a --wallet-type ethereumvalidator --addr-limit 3 --mnemonic-length 24
```

### :tada: Sample of logs when successfully recovering mnemonic.

```
Starting seedrecover 1.13.0-CryptoGuide, btcrecover 1.13.0-Cryptoguide on Python 3.10.12 64-bit, 21-bit unicodes, 64-bit ints

Assuming a 24 word mnemonic. (This can be overridden with --mnemonic-length)
2024-03-03 12:41:45 : Phase 1/4: up to 2 mistakes, excluding entirely different seed words.
Not enough entirely different seed words permitted; skipping this phase.
2024-03-03 12:41:45 : Search Complete
 Seed not found
2024-03-03 12:41:45 : Phase 2/4: 1 mistake which can be an entirely different seed word.
Wallet Type: btcrseed.WalletEthereumValidator
2024-03-03 12:41:48 : Using 10 worker threads
1660 of 2048 [#############################################################################################----------------------] 0:00:01, ETA:  0:00:00
2024-03-03 12:41:50 : Search Complete

If this tool helped you to recover funds, please consider donating 1% of what you recovered, in your crypto of choice to:
BTC: 37N7B7sdHahCXTcMJgEnHz7YmiR4bEqCrS 
BCH: qpvjee5vwwsv78xc28kwgd3m9mnn5adargxd94kmrt 
LTC: M966MQte7agAzdCZe5ssHo7g9VriwXgyqM 
ETH: 0x72343f2806428dbbc2C11a83A1844912184b4243 

Find me on Reddit @ https://www.reddit.com/user/Crypto-Guide

You may also consider donating to Gurnec, who created and maintained this tool until late 2017 @ 3Au8ZodNHPei7MQiSVAWb7NB2yqsb48GW4

Seed found: cousin fury spatial aisle day write bulk empower fog fault stick broom demand valve fine able subway absent valve inform coconut oval season master
```

## Step 5: Shutdown offline PC

By shutting down Ubuntu Live ISO session, all data used during this task is forgotten.

{% hint style="success" %}
Congrats on recovering your ETH Validator!!! Consider donating to the tool makers, btcrecover.
{% endhint %}

## :track\_next: Next Steps

* :brain: **Backup your secret recovery phrase!** [Review Backups Checklist](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/backups-checklist-critical-staking-node-data)
* :moneybag: **Update** [**Withdrawal Credentials**](https://www.coincashew.com/coins/overview-eth/update-withdrawal-keys-for-ethereum-validator-bls-to-execution-change-or-0x00-to-0x01-with-ethdo)
* :new: **Re-generate** [**Keystore Files**](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-iii-tips/adding-a-new-validator-to-an-existing-setup)
* :computer: **Manage your node with** [**EthPillar**](https://www.coincashew.com/coins/overview-eth/ethpillar)
* ​:confetti\_ball: **Support us on Gitcoin Grants:** We build this guide exclusively by community support!🙏

## :books: References

* btcrecover github: [https://github.com/3rdIteration/btcrecover](https://github.com/3rdIteration/btcrecover)
* official docs: [https://btcrecover.readthedocs.io/en/latest/Usage\_Examples/basic\_seed\_recoveries/#basic-ethereum-validator-recoveries](https://btcrecover.readthedocs.io/en/latest/Usage\_Examples/basic\_seed\_recoveries/#basic-ethereum-validator-recoveries)

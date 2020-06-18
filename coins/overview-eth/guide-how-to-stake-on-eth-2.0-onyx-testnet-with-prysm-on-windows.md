---
description: >-
  The Onyx Testnet is a public network created by Prysmatic Labs. It implements
  the Ethereum 2.0 Phase 0 protocol for a proof-of-stake blockchain, enabling
  anyone holding Goerli test ETH to join.
---

# Guide: How to stake on ETH 2.0 ONYX testnet with Prysm on Windows

## 🏁 0. Prerequisites

### \*\*\*\*🎗 **Minimum Setup Requirements**

* **Operating system:** Windows 10
* **Processor:** Dual core CPU
* **Memory:** 4GB RAM
* **Storage:** 20GB SSD
* **Internet:** 24/7 broadband internet connection with speeds at least 1 Mbps.
* **Power:** 24/7 electrical power
* **ETH balance:** at least 32 Goerli ETH
* **Wallet**: Metamask installed

If you need to install Metamask, refer to

{% page-ref page="../../wallets/browser-wallets/metamask-ethereum.md" %}

## 🤖 1. Install Prysm

1. Press **Windows Key** + **R** to open Run window
2. Type "**cmd**" then press OK
3. Change directories to where you would like to install. By default, location is `c:\Users\<yourUserName>`

{% hint style="info" %}
If your Windows 10 is version 1803 or later, your OS [ships with a copy of curl](https://devblogs.microsoft.com/commandline/tar-and-curl-come-to-windows/), already set up and ready to use. If not, install [curl manually](https://curl.haxx.se/windows/) or update your Windows.
{% endhint %}

```text
 mkdir prysm && cd prysm 
 curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.bat --output prysm.bat
```

Fix for ensuring logging works correctly.

```text
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1
```

{% hint style="info" %}
Prysm is a Ethereum 2.0 client and it comes in two components.

**Beacon chain client** - Responsible for managing the state of the beacon chain, validator shuffling, and more.

**Validator client** - Responsible for producing new blocks and attestations in the beacon chain and shard chains.
{% endhint %}

## ⚙ 2. Obtain Goerli test network ETH

Join the [Prysmatic Labs Discord](https://discord.com/invite/YMVYzv6) and send a request for ETH in the **`-request-goerli-eth channel`**

```text
!send <your metamask goerli network ETH address>
```

Otherwise, visit below and use metamask to request ETH on step 2, "Get GöETH — Test ether". 

{% embed url="https://prylabs.net/participate" %}

{% hint style="warning" %}
This method is sometimes unreliable.
{% endhint %}

## 👩💻 3. Generate a validator key pair

{% hint style="warning" %}
If you were participating on the previous Topaz testnet, you will first need to clear the database.

```text
.\prysm.bat beacon-chain --clear-db
```
{% endhint %}

```text
mkdir \.eth2validator
.\prysm.bat validator accounts create --keystore-path=\.eth2validator
```

Enter a password to encrypt your private keys.

Save the deposit data for the next steps. Sample deposit data looks as follows:

```text
========================Deposit Data=======================

0x2289511800000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000120d77ff7f6ee42ff448b239856012c2650752b664a3e17927135b0a363a78c1b550000000000000000000000000000000000000000000000000000000000000030b539868a621d45b51f66ce88bc80e35099e01f31a0aec8484e7fbd04936056483053c5f2b1d195273b651599555ef35e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200086c2c1fb70ed4e6435d2f32a3f6a5fdd4596ad5dc82bd6254ef73959d1ec2b0000000000000000000000000000000000000000000000000000000000000060a8480dd7d6341273789afa176e00e2c105cfe76adb670a211da5604c74cb7fd1ee6ceb4753a25400227fbf01cc344e98000d0705db8f3a964692f85901e4cb4fb6211aa5091967c22f550666adfa65bbde8b33c41cdc56fb62564a73a2135c20

===================================================================

```

## 🏂 4. Start the beacon chain

In a new terminal, start the beacon chain.

```text
.\prysm.bat beacon-chain
```

## 🚥 5. Start the validator

In a new terminal, start the validator.

```text
.\prysm.bat validator --keystore-path=\.eth2validator
```

## 📩 6. Send the validator deposit

1. Open **Metamask** wallet in your browser
2. Ensure you have selected the **Goerli Test Network** from the dropdown menu.
3. Click your account Identicon, the circular colorful icon.
4. Go to **Settings then Advanced**
5. Enable **"Show Hex Data"**
6. Click **Send**
7. Enter the Onyx Deposit Contract Address as Recipient:  [0x0F0F0fc0530007361933EaB5DB97d09aCDD6C1c8](https://goerli.etherscan.io/address/0x0F0F0fc0530007361933EaB5DB97d09aCDD6C1c8)
8. Enter **32 ETH** into the **Amount** field
9. Paste the **Deposit Data** from step 3 into the **Hex Data** field.
10. Click **Next** to send.

![Turning on Show Hex Data](../../.gitbook/assets/eth2-onyx-metamask.png)

![Preparing to send with 32ETH and Deposit Data](../../.gitbook/assets/eth2-onyx-send.png)

{% hint style="success" %}
Congratulations. Once your beacon-chain is sync'd, validator up and running, you just wait for activation. This process takes 4-5 hours. When you're assigned, your validator will begin creating and voting on blocks while earning ETH staking rewards.
{% endhint %}

## 🎞 7. Reference Material

Check out the official documentation at:

{% embed url="https://prylabs.net/participate" %}


# 🛡️ EthPillar: a simple TUI for Validator Node Management

{% hint style="info" %}
Why use EthPillar?

:smile: **Friendly Node Installer**: No node yet? Helps you installs a Ethereum node stack in a jiffy.

:floppy\_disk: **Ease of use**: No more remembering CLI commands required. Access common node operations via a simple text menu.

:owl: **Fast Updates**: Quickly find and download the latest consensus/execution release. Less downtime!

:tada:**Compatibility**: Behind the scenes, node commands and file structure are identical to V2 staking setups.&#x20;
{% endhint %}

{% hint style="warning" %}
Compatible with [a Coincashew V2 Staking Setup.](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet)&#x20;

If no staking setup is installed, EthPillar offers a quickstart to install a full Nethermind EL/ Nimbus CL node with Nimbus validator and mevboost enabled.
{% endhint %}

<figure><img src="../../.gitbook/assets/ethpillar.png" alt=""><figcaption><p>EthPillar Main Menu</p></figcaption></figure>

## Option 1: Automated One-Liner Install

Simply copy and paste the command into your terminal.

Open source source code available here: [https://github.com/coincashew/EthPillar](https://github.com/coincashew/EthPillar)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/coincashew/ethpillar/master/install.sh)"
```

## Option 2: Manual Install

**Install updates and packages:**

```bash
sudo apt-get update && sudo apt-get install git curl ccze
```

**Clone the ethpillar repo and install:**

```bash
mkdir -p ~/git/ethpillar
git clone https://github.com/coincashew/ethpillar.git ~/git/ethpillar
sudo ln -s ~/git/ethpillar/ethpillar.sh /usr/local/bin/ethpillar
```

#### Run ethpillar:

```bash
ethpillar
```

## :tada:Next Steps

{% hint style="success" %}
Congrats on installing a simple UI for making node maintenance easier!
{% endhint %}

<details>

<summary>Additional steps for new node operators</summary>

Firewall

Port forwarding

TBD

</details>

<details>

<summary>Additional steps for new Validators</summary>

Generate Keys

Upload

Load TBD

</details>

:thumbsup:Are you a EthPillar Enjooyer? [Support this public good by purchasing a limited edition POAP!](https://checkout.poap.xyz/169495)

<figure><img src="../../.gitbook/assets/3adf69e9-fb1b-4665-8645-60d71dd01a7b.png" alt=""><figcaption><p>Your EthPillar Enjoyoor's POAP</p></figcaption></figure>

**Purchase link:** [https://checkout.poap.xyz/169495](https://checkout.poap.xyz/169495)

ETH accepted on Mainnet, Arbitrum, Base, Optimism. :pray:

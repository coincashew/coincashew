# 🛡️ EthPillar: a simple UI for Validator Node Management

{% hint style="info" %}
Why use EthPillar?

:owl: **Fast Updates**: Quickly find and download the latest consensus/execution release

:floppy\_disk: **Ease of use**: No more remembering CLI commands required. Access common node operations via a simple text menu.

:tada:**Compatiblity**: Behind the scenes, node commands and file structure are identical to V2 staking setups.&#x20;
{% endhint %}

{% hint style="warning" %}
&#x20;[Requires a Coincashew V2 Staking Setup.](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet)
{% endhint %}

<figure><img src="../../.gitbook/assets/ethpillar.png" alt=""><figcaption><p>EthPillar Main Menu</p></figcaption></figure>

## Option 1: Automated One-Liner

Simply copy and paste the command into your terminal.

Open source source code available here: [https://github.com/coincashew/EthPillar](https://github.com/coincashew/EthPillar)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/coincashew/ethpillar/master/install.sh)"
```

## Option 2: Manual Method

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

{% hint style="success" %}
Congrats on installing a simple UI for making node maintenance easier!
{% endhint %}

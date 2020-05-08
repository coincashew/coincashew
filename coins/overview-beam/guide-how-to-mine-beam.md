# Guide: How to mine BEAM

## 🏁 1. Prerequisites

* AMD GPU with at least 3GB RAM
* Nvidia GPU with at least 3GB RAM

## 🌜 2. Install and use a compatible wallet

{% page-ref page="../../wallets/desktop-wallets/beam.mw-beam.md" %}

## ⛏ 3. Install mining software

### AMD GPU: lolMiner

1. Download latest miner binaries from 

   [https://bitcointalk.org/index.php?topic=4724735.0](https://bitcointalk.org/index.php?topic=4724735.0)

2. Pick a mining pool from

   [https://miningpoolstats.stream/beam](https://miningpoolstats.stream/beam)

3. Run the mining software with the following command line and modify the parameters within the &lt;&gt;

{% tabs %}
{% tab title="Windows" %}
```text
lolMiner.exe --coin BEAM --pool <poolAddr>:<portNumber> --user <Wallet or user name> --pass <userPassword>
```
{% endtab %}

{% tab title="Linux" %}
```
./lolMiner --coin BEAM --pool <poolAddr>:<portNumber> --user <Wallet or user name> --pass <userPassword>
```
{% endtab %}
{% endtabs %}

### Nvidia & AMD GPU: GMiner

1. Download latest miner binaries from 

   [https://bitcointalk.org/index.php?topic=5034735.0](https://bitcointalk.org/index.php?topic=5034735.0)

2. Pick a mining pool from

   [https://miningpoolstats.stream/beam](https://miningpoolstats.stream/beam)

3. Run the mining software with the following command line or edit the included `"mine_beam"` script file.

{% tabs %}
{% tab title="Windows" %}
```text
miner.exe --algo beamhash --pers Beam-PoW --server <poolAddr> --port <portNumber> --ssl 1 --user <Wallet or user name>.<rigName> --pass <userPassword>
```
{% endtab %}

{% tab title="Linux" %}
```
./miner --algo beamhash --pers Beam-PoW --server <poolAddr> --port <portNumber> --ssl 1 --user <Wallet or user name>.<rigName> --pass <userPassword>
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
If your Operating System quarantines the file, you will need to create a rule to exclude the files/directory.
{% endhint %}

## 💰 4. FAQ

### How much performance should I expect from my hardware?

1. Visit [whattomine.com](https://www.whattomine.com/)
2. Enter the \# of GPUs
3. Press **Beam**
4. Press **Calculate**

### How much can I expect to mine?

Enter in your hash rate at [whattomine.com](https://www.whattomine.com/coins/294-beam-beamhashii)

### When will I get paid?

When your earnings reaches the payout limit or threshold, you must request payment to your wallet. Often times, you need to open your wallet and be online to receive the Beam transaction. If using an exchange wallet, payment is automatically sent to your address upon request.


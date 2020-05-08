# Guide: How to mine GRIN

## 🏁 1. Prerequisites

* Nvidia GPU with at least 8GB RAM
* AMD GPU with at least 8GB RAM

## 🌜 2. Install and use a compatible wallet

{% page-ref page="../../wallets/desktop-wallets/grin++-grin.md" %}

## ⛏ 3. Install mining software

### AMD GPU: lolMiner

1. Download latest miner binaries from 

   [https://bitcointalk.org/index.php?topic=4724735.0](https://bitcointalk.org/index.php?topic=4724735.0)

2. Pick a mining pool from

   [https://miningpoolstats.stream/grin-c29](https://miningpoolstats.stream/grin-c29)

   [https://miningpoolstats.stream/grin-c31](https://miningpoolstats.stream/grin-c31)

   [https://miningpoolstats.stream/grin-c32](https://miningpoolstats.stream/grin-c32)

3. Run the mining software with the following command line and modify the parameters within the &lt;&gt;

{% hint style="info" %}
Grin currently has 3 mining algorithms. Experiment and choose the best for your GPU. grin-c29 has the lowest memory hardware requirements. Possible values for `--coin` are **`GRIN-C29M GRIN-C31 GRIN-C32`**
{% endhint %}

{% tabs %}
{% tab title="Windows" %}
```text
lolMiner.exe --coin GRIN-C29M --pool <poolAddr>:<portNumber> --user <Wallet or user name>.<rigID> --pass x
```
{% endtab %}

{% tab title="Linux" %}
```
./lolMiner --coin GRIN-C29M --pool <poolAddr>:<portNumber> --user <Wallet or user name>.<rigID> --pass x
```
{% endtab %}
{% endtabs %}

### Nvidia & AMD GPU: GMiner

1. Download latest miner binaries from 

   [https://bitcointalk.org/index.php?topic=5034735.0](https://bitcointalk.org/index.php?topic=5034735.0)

2. Pick a mining pool from

   [https://miningpoolstats.stream/grin-c29](https://miningpoolstats.stream/grin-c29)

   [https://miningpoolstats.stream/grin-c31](https://miningpoolstats.stream/grin-c31)

   [https://miningpoolstats.stream/grin-c32](https://miningpoolstats.stream/grin-c32)

3. Run the mining software with the following command line or edit the included `"mine_grin[29|31|32]"` script file.

{% hint style="info" %}
Grin currently has 3 mining algorithms. Experiment and choose the best for your GPU. grin-c29 has the lowest memory hardware requirements.
{% endhint %}

{% tabs %}
{% tab title="Windows" %}
```text
miner.exe --algo <grin29|grin31|grin32> --server <poolAddr> --port <portNumber> --user <Wallet or user name>.<rigName>
```
{% endtab %}

{% tab title="Linux" %}
```
./miner --algo <grin29|grin31|grin32> --server <poolAddr> --port <portNumber> --user <Wallet or user name>.<rigName>
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
3. Press **Cuckaroo29 or Cuckatoo31 or Cuckatoo32**
4. Press **Calculate**

### How much can I expect to mine?

Depending on your chosen Grin algorithm, enter your hash rate at the appropriate calculators:

{% embed url="https://www.whattomine.com/coins/293-grin-cuckaroom29" %}

{% embed url="https://www.whattomine.com/coins/324-grin-cuckatoo32" %}

{% embed url="https://www.whattomine.com/coins/299-grin-cuckatoo31" %}

### When will I get paid?

When your earnings reaches the payout limit or threshold, you must request payment to your wallet. Often times, you need to open your wallet and be online to receive the Grin transaction. If using an exchange wallet, payment is automatically sent to your address upon request.


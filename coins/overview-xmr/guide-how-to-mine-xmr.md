# Guide: How to mine Monero

## :checkered\_flag: 1. Prerequisites

* 64bit Intel or AMD CPU
* AMD/Nvidia GPU
* ARM CPU

## :last\_quarter\_moon\_with\_face: 2. Install and use a compatible wallet

{% content-ref url="../../wallets/mobile-wallets/cakewallet-monero.md" %}
[cakewallet-monero.md](../../wallets/mobile-wallets/cakewallet-monero.md)
{% endcontent-ref %}

{% content-ref url="../../wallets/mobile-wallets/monerujo-monero.md" %}
[monerujo-monero.md](../../wallets/mobile-wallets/monerujo-monero.md)
{% endcontent-ref %}

{% content-ref url="../../wallets/desktop-wallets/monero-official-gui.md" %}
[monero-official-gui.md](../../wallets/desktop-wallets/monero-official-gui.md)
{% endcontent-ref %}

{% content-ref url="../../wallets/mobile-wallets/coinomi-multi-chain-assets.md" %}
[coinomi-multi-chain-assets.md](../../wallets/mobile-wallets/coinomi-multi-chain-assets.md)
{% endcontent-ref %}

{% content-ref url="../../wallets/mobile-wallets/exodus-multi-chain-assets.md" %}
[exodus-multi-chain-assets.md](../../wallets/mobile-wallets/exodus-multi-chain-assets.md)
{% endcontent-ref %}

{% content-ref url="../../wallets/browser-wallets/mymonero-xmr.md" %}
[mymonero-xmr.md](../../wallets/browser-wallets/mymonero-xmr.md)
{% endcontent-ref %}

## :pick: 3. Install mining software

### CPU & GPU Mining software: xmrig

1.  Download latest miner binaries from

    [https://github.com/xmrig/xmrig/releases](https://github.com/xmrig/xmrig/releases)
2.  Pick a mining pool from

    [https://miningpoolstats.stream/monero](https://miningpoolstats.stream/monero)
3. Configure your xmrig with the [configuration wizard.](https://xmrig.com/wizard)

**Example: Command Line to mine with CPU and AMD GPU**

{% tabs %}
{% tab title="Windows" %}
```
xmrig.exe --opencl -o de.minexmr.com:443 -u 44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A -k --tls
```
{% endtab %}

{% tab title="Linux" %}
```
./xmrig --opencl -o de.minexmr.com:443 -u 44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A -k --tls
```
{% endtab %}

{% tab title="Mac" %}
```
./xmrig --opencl -o de.minexmr.com:443 -u 44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A -k --tls
```
{% endtab %}
{% endtabs %}

## :page\_facing\_up: 4. Enable Huge Pages

{% hint style="success" %}
Enabling huge pages can boost hash rate up to 50%
{% endhint %}

{% tabs %}
{% tab title="Windows" %}
**Two ways to enable huge pages.**

1. Run the `xmrig.exe` one time with administrator  and then reboot your PC.
   * Right-click `xmrig.exe` > select  "Run as administrator"

Or,

1. Manually change the **Lock Pages in Memory** setting.
   1. Press WindowsKey + R&#x20;
   2. Type `gpedit.msc`
   3. In **Local Group Policy Editor**, make the following update
      1. Open Computer Configuration
      2. Open Window Settings
      3. Open Security Settings
      4. Open Local Policies
      5. Select User Rights Assignment folder
      6. Double-click Lock pages in memory
      7. Click Add User or Group
      8. Hit search
      9. Select your Windows username
{% endtab %}

{% tab title="Linux" %}
```
sudo bash -c "echo vm.nr_hugepages=1280 >> /etc/sysctl.conf"
```

{% hint style="info" %}
:sparkles: **Tip:** Boost hash rate up to 3% more by enabling 1GB huge pages. Run the following command:

`sudo ./scripts/enable_1gb_pages.sh`
{% endhint %}
{% endtab %}
{% endtabs %}

## :moneybag: 5. FAQ

### 5.1 How much performance should I expect from my hardware?

{% tabs %}
{% tab title="CPU Mining" %}
Find your potential CPU mining performance at [https://monerobenchmarks.info/](https://monerobenchmarks.info)
{% endtab %}

{% tab title="GPU Mining" %}
1. Visit [whattomine.com](https://www.whattomine.com)
2. Enter the # of GPUs
3. Press **RandomX**
4. Press **Calculate**
{% endtab %}
{% endtabs %}

### 5.2 How much can I expect to mine?

Enter your hash rate at [whattomine.com](https://www.whattomine.com/coins/101-xmr-randomx)

### 5.3 When will I get paid?

When your earnings reaches the payout limit or threshold, payment is automatically sent to your address.

### 5.4 How can I optimize and tune my miner?

Follow the [Windows tuning guide by sech1 (XMRig Dev)](https://www.reddit.com/r/MoneroMining/comments/f18825/windows\_10\_tuning\_guide\_for\_randomx\_mining/)

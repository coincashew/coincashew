# :confetti\_ball: Adding or Changing Graffiti flag

Setup your `graffiti`, a custom message included in blocks your validator successfully proposes, and earn an early beacon chain validator POAP token. [Generate your POAP string by supplying an Ethereum 1.0 address here.](https://beaconcha.in/poap)

{% hint style="info" %}
Learn more about [POAP - The Proof of Attendance token.](https://www.poap.xyz)
{% endhint %}

{% tabs %}
{% tab title="Lighthouse" %}
Change the **--graffiti** value on ExecStart line. Save your file.

```bash
sudo nano /etc/systemd/system/validator.service
```
{% endtab %}

{% tab title="Nimbus" %}
Change the **--graffiti** value on ExecStart line. Save your file.

```bash
sudo nano /etc/systemd/system/beacon-chain.service
```
{% endtab %}

{% tab title="Teku" %}
Change the **validators-graffiti** value. Save your file.

```bash
sudo nano /etc/teku/teku.yaml
```
{% endtab %}

{% tab title="Prysm" %}
Change the **--graffiti** value on ExecStart line. Save your file.

```bash
sudo nano /etc/systemd/system/validator.service
```
{% endtab %}

{% tab title="Lodestar" %}
Change the **--graffiti** value on ExecStart line. Save your file.

```bash
sudo nano /etc/systemd/system/validator.service
```
{% endtab %}
{% endtabs %}

Reload the updated unit file and restart the validator process for your graffiti to take effect.

{% tabs %}
{% tab title="Lighthouse | Prysm | Lodestar" %}
```bash
sudo systemctl daemon-reload
sudo systemctl restart validator
```
{% endtab %}

{% tab title="Teku | Nimbus" %}
```
sudo systemctl daemon-reload
sudo systemctl restart beacon-chain
```
{% endtab %}
{% endtabs %}
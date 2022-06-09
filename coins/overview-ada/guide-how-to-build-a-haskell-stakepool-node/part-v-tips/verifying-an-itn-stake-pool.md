# :white\_check\_mark: Verifying an ITN Stake Pool

In order to defend against spoofing and hijacking of reputable stake pools, a owner can verify their ticker by proving ownership of an ITN stake pool.

{% hint style="info" %}
Incentivized Testnet phase of Cardano’s Shelley era ran from late November 2019 to late June 2020. If you participated, you can verify your ticker.
{% endhint %}

Make sure the ITN's `jcli` binaries are present in `$NODE_HOME`. Use `jcli` to sign your stake pool id with your `itn_owner.skey`

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
./jcli key sign --secret-key itn_owner.skey stakepoolid.txt --output stakepoolid.sig
```
{% endtab %}
{% endtabs %}

Visit [pooltool.io](https://pooltool.io) and enter your owner public key and pool id witness data in the metadata section.

Find your pool id witness with the following command.

{% tabs %}
{% tab title="air-gapped offline machine" %}
```
cat stakepoolid.sig
```
{% endtab %}
{% endtabs %}

Find your owner public key in the file you generated on ITN. This data might be stored in a file ending in `.pub`

Finally, [update your stake pool information](../part-iv-administration/updating-stake-pool-information.md) with the PoolTool-generated **`metadata-url`** and **`metadata-hash`**. Notice the metadata has an "extended" field that proves your ticker ownership since ITN.

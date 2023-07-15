# Verifying Your Mnemonic Phrase

Ensure you can regenerate the same eth2 key pairs by restoring your `validator_keys`

Using the pre-built staking-deposit-cli executable,

```bash
cd $HOME/staking-deposit-cli 
./deposit existing-mnemonic --chain mainnet
```

{% hint style="info" %}
When the **pubkey** in both **keystore** files are **identical**, this means your mnemonic phrase is veritably correct. Other fields will be different because of salting.
{% endhint %}

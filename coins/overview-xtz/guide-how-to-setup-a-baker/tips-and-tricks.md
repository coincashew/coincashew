# 9. Tips, Tricks and Other Commands

## :key2: Backup your keys

If you ever have to restore your account or baker, you will need these files. Make copies to another data device.

* `~/.tezos-node/identity.json`
* `~/.tezos-client/public_key_hashs`
* `~/.tezos-client/public_key`
* `~/.tezos-client/secret_keys`

## :beach: Important Locations

These files and folders are useful for backups and restores.

* `~/tezos (contains your binaries)`
* `~/.tezos-client`
  * `public_key_hashs`
  * `public_keys`
  * `secret_keys`
* `~/.tezos-node`
  * `identity.json (this is your node's identity)`
  * `context (this is the blockchain data)`

## :mag\_right: Push Alerts for your Baker

Rapidly get notified if something goes wrong.

* [TezosNotifierBot ](https://t.me/TezosNotifierBot)on Telegram

## :hotel: Make your Vote

Participate in the unique Tezos governance process and make the future Tezos better!

There are two kinds of voting, proposal selection and election voting.&#x20;

{% tabs %}
{% tab title="Proposal Selection" %}
{% hint style="info" %}
Determine the latest **proposal ID** by visiting your favorite block explorer such as [TzStats ](https://tzstats.com/election/head)or [Tezos.ID](https://tezos.id/proposals).
{% endhint %}

You can **upvote** a proposal with the following command.&#x20;

```
./tezos-client submit proposals for <baker account name> <proposal ID Hash>
```

> \#Example: `./tezos-client submit proposal for ledger_mybaker  PsDELPH1Kxsxt8f9eWbxQeRxkjfbxoqM52jvs5Y5fBxWWh4ifpo`

{% hint style="info" %}
Your baker's upvote is weighted by the number of rolls you control. At least 5% of all rolls must upvote in order for a proposal to be promoted or also known as reaching quorum. After reaching quorum, a proposal moves on to the next phase of governance, the exploration vote.
{% endhint %}
{% endtab %}

{% tab title="Election Voting" %}
Voting is available when an On-Chain election is two types of Vote Periods:

* **Exploration Vote Period**
* **Promotion Vote Period**

{% hint style="info" %}
Determine the latest **election** by visiting your favorite block explorer such as [TzStats](https://tzstats.com/election/head) or [Tezos.ID](https://tezos.id/voting-periods).
{% endhint %}

Suppose there is a current election and you want to vote.

You need two pieces of information:

* The current protocol hash identifier. Find it [here](https://tezos.id/protocols).
* Your vote decision which is either **yay**/**nay**/**pass**

The command to run is:

```
./tezos-client submit ballot for <baker account name> <protocol hash id> <yay/nay/pass>
```

> \#Example: `./tezos-client submit ballot for ledger_mybaker PsCARTHAGazKbHtnKfLzQg3kms52kSRpgnDY982a9oYsSXRLQEb yay`
{% endtab %}
{% endtabs %}

## :man\_detective: Test for ledger connectivity

If you are not sure your ledger is working properly, run the following and see if there is a valid response.

```
./tezos-client get ledger authorized path for ledger_mybaker
```

## :lollipop: Claim your fundraiser/donation account

First, activate your account using the KYC code:

```
./tezos-client add address myaccount <tz1 public key hash from PDF>
./tezos-client activate fundraiser account myaccount with <activation key from verification site>
```

Verify the balance of your newly activated account.

```
./tezos-client get balance for myaccount
```

If you wish to send funds from your account, then you will need to import your private key. **Keep this data confidential!** Better yet, after importing, send the funds to a new account on a hardware wallet such as a Ledger Nano.

```
./tezos-client import fundraiser secret key myaccount
```

{% hint style="info" %}
If you only want to activate your Tezos account and claim your tez from the fundraiser, a safe and easy way is to use: [https://stephenandrews.github.io/activatez/](https://stephenandrews.github.io/activatez/)
{% endhint %}

## :potable\_water: Drinking from a Tezos Faucet

Want to test something and play with tezos on testnet without risking real coins?

Two ways:

* Use the [Baking Bad Faucet Telegram Bot](https://t.me/tezos\_faucet\_bot)
* [Get some test tez from the faucet.](https://faucet.tzalpha.net/)

Proceed with the following commands:

```
./tezos-client activate account myaccount with ./faucet.json
./tezos-client get balance for myaccount
```

## :woman\_juggling: Exporting and importing a snapshot

Handy if you're building another node and want to speed up the blockchain sync process.

Also useful for reclaiming disk space.&#x20;

1. Run the export snapshot command
2. Stop the node
3. Rename `~/.tezos-node` to `~/.tezos-node2`
4. Run the import snapshot command
5. Copy `*.json` from `~/.tezos-node2` to `~/.tezos-node`
6. Start the node
7. Confirm everything is working
8. Remove `~/.tezos-node2` to free up disk space.

#### Export command

```
./tezos-node snapshot export --block <block hash> mySnapshot.file
```

#### Import command

```
./tezos-node snapshot import mySnapshot.file
```

## :sos: More help at the Official Documentation

Comprehensive and official Tezos documentation is always available here:

{% embed url="https://tezos.gitlab.io/" %}

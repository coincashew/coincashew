# 8. Distribute Rewards

## :interrobang: 0. Why?

Are you baking on behalf of others? Do you have accounts delegated to your baking address? No longer solo-baking? If yes, then you need a process to distribute rewards every cycle. The best way is with the following, TRD:

> ### Tezos Reward Distributor : Run & Forget
>
> TRD is a software for distributing staking rewards of delegators introduced in detail in this [Medium article](https://medium.com/@huseyinabanox/tezos-reward-distributor-e6588c4d27e7). This is not a script but a full scale application which can continuously run in the background as a Linux service. It can track cycles and make payments. However it does not have to be used as a service, but it can also be used interactively. The documentation can be found [here](https://habanoz.github.io/tezos-reward-distributor/)
>
> Source code: [https://github.com/habanoz/tezos-reward-distributor](https://github.com/habanoz/tezos-reward-distributor)

## :construction: 1. Installing TRD

1\. Install python 3.

```
sudo apt-get update
sudo apt-get -y install python3-pip
```

2\. Clone repo and install modules.

```
cd 
git clone https://github.com/habanoz/tezos-reward-distributor
cd tezos-reward-distributor
pip3 install -r requirements.txt
```

## :money_with_wings: 2. Setup your payout configuration

* By default, payment configuration is stored in `~/pymnt/cfg/`

```
# create directory
mkdir -p ~/pymnt/cfg/
cp tezos-reward-distributor/examples/tz1boot1pK9h2BVGXdyvfQSv8kd1LQM6H889.yaml ~/pymnt/cfg/
nano ~/pymnt/cfg/<tz1_yourBakerAddress>.yaml
```

Example contents of `<tz1_yourBakerAddress>.yaml`

```
version : 1.0
baking_address : tz1_yourBakerAddress
payment_address : myPaymentAddress
service_fee : 15
founders_map : {tz1_yourBakerAddress: 1}
owners_map : {tz1_yourBakerAddress: 1}
specials_map : {}
supporters_set : {}
min_delegation_amt : 100
reactivate_zeroed : True
delegator_pays_xfer_fee : True
delegator_pays_ra_fee : True
rules_map:
  mindelegation: TOB
  tz1_yourBakerAddress: TOB
```

{% hint style="info" %}
TOB means to balance. Review the [detailed configuration help documentation here](https://habanoz.github.io/tezos-reward-distributor/configuration.html).
{% endhint %}

## :firecracker: 3. Setup and configure a new Rewards Payment Address

1\. Generate a new tz1 account named`myPaymentAddress`. Add a passphrase to protect it.

```
cd ~/tezos
./tezos-client gen keys myPaymentAddress

# Enter passphrase to encrypt your key:
# Confirm passphrase:
```

2\. Verify that the account was created successfully.

```
./tezos-client list known addresses
```

3\. You should see your `myPaymentAddress` along with it's public address starting with `tz1.` See below for example.

> `myPaymentAddress: t1420a9zkodJpP5xtbwez651YxRKJtxVmqe (encrypted sk known)`

4\. :sparkles: **VERY IMPORTANT STEP**: Backup the secret key and your passphrase. Save this somewhere safe.

```
./tezos-client show address myPaymentAddress -S
```

Example output`:`

> `Secret Key: encrypted:edesk1<randomCharacters>`

{% hint style="danger" %}
Reminder: Backup your secret key and passphrase, _**carefully and correctly.**_
{% endhint %}

## :sparkler: 4. Setup Tezos Client and Signer

1. Update and run the following command with your secret key that you backed up earlier.

```
cd ~/tezos
./tezos-signer import secret key myPaymentAddress encrypted:edesk1<randomCharacters>
```

2\. Start the signer process which will sign payment transactions generated fromTRD.

```
./tezos-signer launch socket signer -a 127.0.0.1 -p 22000 -W
```

3\. Add the payment address to tezos-client. Make sure to update `<tz1_myPaymentAddress>` with your payment address public key.

```
./tezos-client import secret key myPaymentAddress tcp://127.0.0.1:22000/<tz1_myPaymentAddress> -f
```

## :woman_running: 5. Running Tezos Reward Distributor

To run TRD, execute the following command.

```
cd ~/tezos-reward-distributor
python3 src/main.py -O 60 -E ~/tezos --do_not_publish_stats -P tzstats
```

{% hint style="info" %}
Want to double check everything and do a dry run before sending rewards? Add `-D` to the command line.
{% endhint %}

{% hint style="info" %}
`-O` means delay the payment for 60 blocks from the start of a cycle. `-P` is the rpc provider of the data used to calculate the rewards.
{% endhint %}

{% hint style="success" %}
That's it! Every cycle or \~3 days, reward payments can automatically be distributed from `myPaymentAddress.` Just make sure to transfer enough tez from your baker address to this payment address.
{% endhint %}

## :open_file_folder: 6. Reviewing payment reports

* `~/pymnt/reports/` contains CSV files detailing calculations, failed/done payments.

## :robot: 7. Updating Tezos Reward Distributor

```
git fetch origin #fetches new branches
git status #see the changes
git pull
```

{% hint style="info" %}
Check the change logs and review the new fixes/updates for potentially breaking changes requiring attention. Use `git log` command.
{% endhint %}

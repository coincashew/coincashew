# Auditing your nodes configuration

{% hint style="info" %}
This guide was graciously contributed by [\[FRADA\] ADA Madin France](https://cardano-france-stakepool.org/). If you find this guide useful, please consider staking to it (**FRADA** ticker).🙏
{% endhint %}

To make sure your Cardano nodes (relays and block-producer) are correctly configured, you can use an automated audit script that will do the following checks :

**Cardano Node checks**

* Environment Variables
* Systemd cardano-node file verification and parsing
* Cardano startup script verification and parsing
* Node operation mode (Block Producer ? Relay ?)
* Topology mode
* Topology configuration
* KES keys expiry and rotation alert

**Security and system checks**

* SSHD hardening
* Null passwords check
* Important services running
* Firewalling rules extract
* sysctl.conf hardening check

{% hint style="info" %}
Please note that this script is only intended to help you identify configuration and basic security issues. It does not guarantee that your server is fully protected.
{% endhint %}

## How to use the Cardano Audit Script

### Download the Audit Script

The script can be found on this [GitHub repository](https://github.com/Kirael12/Cardano-Audit-Coincashew) by [\[FRADA\] ADA Made In France](https://cardano-france-stakepool.org)

You can directly download the repository from your Cardano Nodes :

```bash
cd $HOME/git
git clone https://github.com/Kirael12/Cardano-Audit-Coincashew
```

### Make script executable

```bash
cd $HOME/git/Cardano-Audit-Coincashew
chmod +x audit-coincashew.sh
```

### Run the script

The script must be ran with sudo and the -E option, to include your environment variables defined during the Coincashew guide (like $NODE\_HOME or $NODE\_CONFIG)

```bash
sudo -E ./audit-coincashew.sh
```

## Results

It takes 20 seconds for the script to complete. You'll get information about your node and will immediately be able to check whether your configuration is good or not, and make appropriate changes.

<div data-full-width="false">

<img src="https://github.com/Kirael12/coincashew/assets/113426048/8491c683-4445-4492-8daa-1dddc3ea2807" alt="Sample Output">

</div>

![More sample output](https://github.com/Kirael12/coincashew/assets/113426048/47174d08-7b36-4351-b31c-6ea17a148512)

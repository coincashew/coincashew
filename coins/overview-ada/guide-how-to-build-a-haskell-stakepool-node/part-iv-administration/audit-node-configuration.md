# Auditing Your nodes configuration

{% hint style="info" %}
This guide was graciously contributed by [\[FRADA\] ADA Made in France](https://cardano-france-stakepool.org/). If you find this guide useful, please consider staking to it (**FRADA** ticker).🙏
{% endhint %}

To make sure your Cardano nodes (relays and block-producer) are correctly configured, you can use an automated audit script that will do the following checks :

**Cardano compliance**

- New 9.1.0 Cardano-Node version requirement for Chang hardfork
- Cardano-node latest version verification
- Cardano bootstrap check
- Environment Variables
- Systemd cardano-node file verification and parsing
- Cardano startup script verification and parsing
- Node operation mode (Block Producer ? Relay ?)
- Topology mode (p2p enabled)
- Topology configuration file parsing and compliance checks
- Cardano security checks (hot keys permissions, cold keys detection)
- KES keys rotation alert

**Security and system checks**

- SSHD hardening
- Null passwords check
- Important services running (ufw, fail2ban, ntp server...)
- Firewalling rules extract
- sysctl.conf hardening check

{% hint style="info" %}
Please note that this script is only intended to help you identify configuration and basic security issues. It does not guarantee that your server is fully protected.
{% endhint %}

## How to use the Cardano Audit Script

### Download the Audit Script

The script can be found on this [GitHub repository](https://github.com/Kirael12/cardano-node-audit) by [\[FRADA\] ADA Made In France](https://cardano-france-stakepool.org)

You can directly download the repository from your Cardano Nodes :

```bash
cd $HOME/git
mkdir audit-cardano-node
cd audit-cardano-node
wget --show-progress -q https://github.com/Kirael12/cardano-node-audit/releases/latest/download/audit-cardano-node.sh
```

### Make script executable

```bash
cd $HOME/git/audit-cardano-node
chmod +x audit-cardano-node.sh
```

### Run the script

The script must be ran with sudo and the -E option, to include your environment variables defined during the Coincashew guide (like $NODE\_HOME or $NODE\_CONFIG)

```bash
sudo -E ./audit-cardano-node.sh
```
You will be asked to select the type of your Cardano setup with a menu. Select COINCASHEW. You can also choose to perform only security checks.

![Screenshot 1](https://github.com/user-attachments/assets/88d6f008-264e-4d19-9736-cbe8588ef243)

You will then be asked if you want to export the results to a file.

![Screenshot 2](https://github.com/user-attachments/assets/1664112d-d627-4db9-bc4e-88d2d1533037)

## Results

It takes 20 seconds for the script to complete. You'll get information about your node and will immediately be able to check whether your configuration is good or not, and make appropriate changes.
Sample outputs :

![Screenshot 3](https://github.com/user-attachments/assets/553a041d-d25d-4ca5-8ce4-86c39f4f183c)
![Screenshot 4](https://github.com/user-attachments/assets/ce31e683-70ed-4f1a-bd2f-b6a31e35186b)
![Screenshot 5](https://github.com/user-attachments/assets/5b8ef782-187a-4924-b589-8e9f9067c242)

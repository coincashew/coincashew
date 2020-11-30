---
description: Quick steps to secure your node.
---

# Guide \| Security Best Practices for a ETH2 validator beaconchain node

## 🧙♂Create a non-root user with sudo privileges

{% hint style="info" %}
Make a habit of logging to your server using a non-root account. This will prevent the accidental deletion of files if you make a mistake. For instance, the command `rm` can wipe your entire server if run incorrectly using by a root user.
{% endhint %}

{% hint style="danger" %}
🔥**Tip**: Do NOT routinely use the root account. Use `su` or `sudo`,  always.
{% endhint %}

SSH to your server

```bash
ssh username@server.public.ip.address
# example
# ssh myUsername@77.22.161.10
```

Create a new user called ethereum

```text
sudo useradd -m -s /bin/bash ethereum
```

Set the password for ethereum user

```text
sudo passwd ethereum
```

Add ethereum to the sudo group

```text
sudo usermod -aG sudo ethereum
```

## 🔐 **Disable SSH password Authentication and Use SSH Keys only**

{% hint style="info" %}
The basic rules of hardening SSH are:

* No password for SSH access \(use private key\)
* Don't allow root to SSH \(the appropriate users should SSH in, then `su` or `sudo`\)
* Use `sudo` for users so commands are logged
* Log unauthorized login attempts \(and consider software to block/ban users who try to access your server too many times, like fail2ban\)
* Lock down SSH to only the ip range your require \(if you feel like it\)
{% endhint %}

Create a new SSH key pair on your local machine. Run this on your local machine. You will be asked to type a file name in which to save the key. This will be your **keyname**.

```text
ssh-keygen -t rsa
```

Transfer the public key to your remote node. Update **keyname.pub** appropriately.

```bash
ssh-copy-id -i $HOME/.ssh/keyname.pub ethereum@server.public.ip.address
```

Login with your new ethereum user

```text
ssh ethereum@server.public.ip.address
```

Disable root login and password based login. Edit the `/etc/ssh/sshd_config file`

```text
sudo nano /etc/ssh/sshd_config
```

Locate **ChallengeResponseAuthentication** and update to no

```text
ChallengeResponseAuthentication no
```

Locate **PasswordAuthentication** update to no

```text
PasswordAuthentication no
```

Locate **PermitRootLogin** and update to no

```text
PermitRootLogin no
```

Locate **PermitEmptyPasswords** and update to no

```text
PermitEmptyPasswords no
```

**Optional**: Locate **Port** and customize it your **random** port.

```bash
Port <port number>
```

Validate the syntax of your new SSH configuration.

```text
sudo sshd -t
```

If no errors with the syntax validation, reload the SSH process

```text
sudo service sshd reload
```

Verify the login still works

{% tabs %}
{% tab title="Standard SSH Port 22" %}
```text
ssh ethereum@server.public.ip.address
```
{% endtab %}

{% tab title="Custom SSH Port" %}
```bash
ssh ethereum@server.public.ip.address -p <custom port number>
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Alternatively, you might need to use

```bash
ssh -i <path to your SSH_key_name.pub> ethereum@server.public.ip.address
```
{% endhint %}

## 🤖 **Update your system**

{% hint style="warning" %}
It's critically important to keep your system up-to-date with the latest patches to prevent intruders from accessing your system.
{% endhint %}

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get autoremove
sudo apt-get autoclean
```

Enable automatic updates so you don't have to manually install them.

```text
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## 🐻 Disable root account

System admins should not frequently log in as root in order to maintain server security. Instead, you can use sudo execute that require low-level privileges.

```bash
# To disable the root account, simply use the -l option.
sudo passwd -l root
```

```bash
# If for some valid reason you need to re-enable the account, simply use the -u option.
sudo passwd -u root
```

## 🛠 Setup Two Factor Authentication for SSH \[Optional\]

{% hint style="info" %}
SSH, the secure shell, is often used to access remote Linux systems. Because we often use it to connect with computers containing important data, it’s recommended to add another security layer. Here comes the two factor authentication \(_2FA_\).
{% endhint %}

```text
sudo apt install libpam-google-authenticator -y
```

To make SSH use the Google Authenticator PAM module, edit the `/etc/pam.d/sshd` file:

```text
sudo nano /etc/pam.d/sshd
```

Add the follow line:

```text
auth required pam_google_authenticator.so
```

Now you need to restart the `sshd` daemon using:

```text
sudo systemctl restart sshd.service
```

Modify `/etc/ssh/sshd_config`

```text
sudo nano /etc/ssh/sshd_config
```

Locate **ChallengeResponseAuthentication** and update to yes

```text
ChallengeResponseAuthentication yes
```

Locate **UsePAM** and update to yes

```text
UsePAM yes
```

Save the file and exit.

Run the **google-authenticator** command.

```text
google-authenticator
```

It will ask you a series of questions, here is a recommended configuration:

* Make tokens “time-base”": yes
* Update the `.google_authenticator` file: yes
* Disallow multiple uses: yes
* Increase the original generation time limit: no
* Enable rate-limiting: yes

You may have noticed the giant QR code that appeared during the process, underneath are your emergency scratch codes to be used if you don’t have access to your phone: write them down on paper and keep them in a safe place.

Now, open Google Authenticator on your phone and add your secret key to make two factor authentication work.

## 🧩 Secure Shared Memory

{% hint style="info" %}
One of the first things you should do is secure the shared [memory](https://www.lifewire.com/what-is-random-access-memory-ram-2618159) used on the system. If you're unaware, shared memory can be used in an attack against a running service. Because of this, secure that portion of system memory. 

To learn more about secure shared memory, read this [techrepublic.com article](https://www.techrepublic.com/article/how-to-enable-secure-shared-memory-on-ubuntu-server/).
{% endhint %}

Edit `/etc/fstab`

```text
sudo nano /etc/fstab
```

Insert the following line to the bottom of the file and save/close.

```text
tmpfs    /run/shm    tmpfs    ro,noexec,nosuid    0 0
```

Reboot the node in order for changes to take effect.

```text
sudo reboot
```

## ⛓**Install Fail2ban**

{% hint style="info" %}
Fail2ban is an intrusion-prevention system that monitors log files and searches for particular patterns that correspond to a failed login attempt. If a certain number of failed logins are detected from a specific IP address \(within a specified amount of time\), fail2ban blocks access from that IP address.
{% endhint %}

```text
sudo apt-get install fail2ban -y
```

Edit a config file that monitors SSH logins.

```text
sudo nano /etc/fail2ban/jail.local
```

Add the following lines to the bottom of the file.

{% hint style="info" %}
🔥 **Whitelisting IP address tip**: The `ignoreip` parameter accepts IP addresses, IP ranges or DNS hosts that you can specify to be allowed to connect. This is where you want to specify your local machine, local IP range or local domain, separated by spaces.

```bash
# Example
ignoreip = 192.168.1.0/24 127.0.0.1/8 
```
{% endhint %}

```bash
[sshd]
enabled = true
port = <22 or your random port number>
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
# whitelisted IP addresses
ignoreip = <list of whitelisted IP address, your local daily laptop/pc>
```

Save/close file.

Restart fail2ban for settings to take effect.

```text
sudo systemctl restart fail2ban
```

## 🧱**Configure your Firewall**

The standard UFW firewall can be used to control network access to your node.

With any new installation, ufw is disabled by default. Enable it with the following settings.

* Port 22 \(or your random port \#\) TCP for SSH connection
* Ports for p2p traffic
  * Lighthouse uses port 9000 tcp/udp
  * Teku uses port 9000 tcp/udp
  * Prysm uses port 13000 tcp and port 12000 udp
  * Nimbus uses port 9000 tcp/udp
  * Lodestar uses port 30607 tcp and port 9000 udp
* Port 30303 tcp/udp eth1 node
* Port 3000 tcp for Grafana
* Port 9090 tcp for prometheus export data \(optional\)

{% hint style="warning" %}
**Reminder**: please never expose the prometheus endpoint to the public internet!
{% endhint %}

{% tabs %}
{% tab title="Lighthouse" %}
```bash
sudo ufw allow <22 or your random port number>/tcp
sudo ufw allow 9000/tcp
sudo ufw allow 9000/udp
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow 3000/tcp
sudo ufw enable
sudo ufw status numbered
```
{% endtab %}

{% tab title="Prysm" %}
```bash
sudo ufw allow <22 or your random port number>/tcp
sudo ufw allow 13000/tcp
sudo ufw allow 12000/udp
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow 3000/tcp
sudo ufw enable
sudo ufw status numbered
```
{% endtab %}

{% tab title="Teku" %}
```bash
sudo ufw allow <22 or your random port number>/tcp
sudo ufw allow 9000/tcp
sudo ufw allow 9000/udp
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow 3000/tcp
sudo ufw enable
sudo ufw status numbered
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
sudo ufw allow <22 or your random port number>/tcp
sudo ufw allow 9000/tcp
sudo ufw allow 9000/udp
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow 3000/tcp
sudo ufw enable
sudo ufw status numbered
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
sudo ufw allow <22 or your random port number>/tcp
sudo ufw allow 30607/tcp
sudo ufw allow 9000/udp
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow 3000/tcp
sudo ufw enable
sudo ufw status numbered
```
{% endtab %}
{% endtabs %}

**\[ Optional \]** Whitelisting or permitting connections from a specific IP, can be setup via the following command.

```bash
sudo ufw allow from <your local daily laptop/pc>
# Example
# sudo ufw allow from 192.168.50.22
```

Confirm the settings are in effect.

> ```csharp
>      To                         Action      From
>      --                         ------      ----
> [ 1] 22/tcp                     ALLOW IN    Anywhere
> [ 2] 3000/tcp                   ALLOW IN    Anywhere
> [ 3] 9000/tcp                   ALLOW IN    Anywhere
> [ 4] 9090/tcp                   ALLOW IN    Anywhere
> [ 5] 30303/tcp                  ALLOW IN    Anywhere
> [ 6] 22/tcp (v6)                ALLOW IN    Anywhere (v6)
> [ 7] 3000/tcp (v6)              ALLOW IN    Anywhere (v6)
> [ 8] 9000/tcp (v6)              ALLOW IN    Anywhere (v6)
> [ 9] 9090/tcp (v6)              ALLOW IN    Anywhere (v6)
> [10] 30303/tcp (v6)             ALLOW IN    Anywhere (v6)
> ```

## 📞 Verify Listening Ports

If you want to maintain a secure server, you should validate the listening network ports every once in a while. This will provide you essential information about your network.

```bash
sudo ss -tulpn
# Example output. Ensure the port numbers look right.
# Netid  State    Recv-Q  Send-Q    Local Address:Port   Peer Address:Port   Process
# tcp    LISTEN   0       128       127.0.0.1:5052       0.0.0.0:*           users:(("lighthouse",pid=12160,fd=22))
# tcp    LISTEN   0       128       127.0.0.1:5054       0.0.0.0:*           users:(("lighthouse",pid=12160,fd=23))
# tcp    LISTEN   0       1024      0.0.0.0:9000         0.0.0.0:*           users:(("lighthouse",pid=12160,fd=21))
# udp    UNCONN   0       0         *:30303              *:*                 users:(("geth",pid=22117,fd=158))
# tcp    LISTEN   0       4096      *:30303              *:*                 users:(("geth",pid=22117,fd=156))
```

Alternatively you can use `netstat`

```bash
sudo netstat -tulpn
# Example output. Ensure the port numbers look right.
# Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
# tcp        0      0 127.0.0.1:5052          0.0.0.0:*               LISTEN      12160/lighthouse
# tcp        0      0 127.0.0.1:5054          0.0.0.0:*               LISTEN      12160/lighthouse
# tcp        0      0 0.0.0.0:9000            0.0.0.0:*               LISTEN      12160/lighthouse
# tcp6       0      0 :::30303                :::*                    LISTEN      22117/geth
# udp6       0      0 :::30303                :::*                    LISTEN      22117/geth
```

## ✨ Additional validator node best practices

<table>
  <thead>
    <tr>
      <th style="text-align:left"></th>
      <th style="text-align:left"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">Networking</td>
      <td style="text-align:left">
        <p></p>
        <p>Assign static internal IPs to both your validator node and daily laptop/PC.
          This is useful in conjunction with ufw and Fail2ban&apos;s whitelisting
          feature. Typically, this can be configured in your router&apos;s settings.
          Consult your router&apos;s manual for instructions.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Power Outage</td>
      <td style="text-align:left">In case of power outage, you want your validator machine to restart as
        soon as power is available. In the BIOS settings, change the <b>Restore on AC / Power Loss</b> or <b>After Power Loss</b> setting
        to always on.</td>
    </tr>
  </tbody>
</table>

## 🤖 Start staking by building a validator

* Visit here for our [Mainnet guide](guide-or-how-to-setup-a-validator-on-eth2-mainnet.md)
* Visit here for our [Testnet guide](guide-or-how-to-setup-a-validator-on-eth2-testnet.md)

{% hint style="success" %}
Congrats on completing the guide. 

Did you find our guide useful? Let us know with a tip and we'll keep updating it. 

It really energizes us to keep creating the best crypto guides. 

Use [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. 🙏 
{% endhint %}

## 🚀 References

{% embed url="https://medium.com/@BaneBiddix/how-to-harden-your-ubuntu-18-04-server-ffc4b6658fe7" caption="" %}

{% embed url="https://linux-audit.com/ubuntu-server-hardening-guide-quick-and-secure/" caption="" %}

{% embed url="https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04" caption="" %}

{% embed url="https://ubuntu.com/tutorials/configure-ssh-2fa\#1-overview" caption="" %}

{% embed url="https://linuxize.com/post/install-configure-fail2ban-on-ubuntu-20-04/" %}

[https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3\#file-ubuntu-hardening-md](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3#file-ubuntu-hardening-md)

{% embed url="https://www.lifewire.com/harden-ubuntu-server-security-4178243" caption="" %}

{% embed url="https://www.ubuntupit.com/best-linux-hardening-security-tips-a-comprehensive-checklist/" caption="" %}


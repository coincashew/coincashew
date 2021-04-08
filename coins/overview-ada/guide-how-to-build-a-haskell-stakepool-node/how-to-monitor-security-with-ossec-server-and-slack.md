---
description: Guide to monitor your node security with OSSEC and Slack.
---

# How to Monitor Security with OSSEC server and Slack

{% hint style="info" %}
This guide was contributed by [Billionaire Pool](www.billionairepool.com). If you find this guide useful, please consider staking to it \(**BIL** ticker\). Thank you 🙏
{% endhint %}

{% hint style="info" %}
The guide is kindly hosted by our Coincashew friends. Use [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. 🙏
{% endhint %}

## 🤖 Pre-requisites

* Ubuntu Server or Ubuntu Desktop installed
* SSH server installed
* a SSH client or terminal window access

## 🔓 Recommended Stake Pool Security

If you need ideas on how to harden your stake pool's nodes, refer to

{% page-ref page="how-to-harden-ubuntu-server.md" %}

These are very recommended steps to perform before configuring a monitoring service.

## 📐 Install packages

Some packages will be required for the installation. You will need

* libz
* libssl
* libpcre2
* libevent
* make, gcc

On Ubuntu run this command to install them

```text
sudo apt install libz-dev libssl-dev libpcre2-dev build-essential libevent-dev
```

## 🛸 Download OSSEC

First of all, we will need to get a fresh copy of OSSEC. We will download it from github and then checkout the latest stable version.

Go to this page and find out the latest version number.

{% embed url="https://github.com/ossec/ossec-hids/releases" caption="" %}

Then, login to your server and

```bash
mkdir -p $HOME/git
cd $HOME/git
git clone https://github.com/ossec/ossec-hids.git
cd ossec-hids
git checkout 3.6.0
```

## 🛠 Install OSSEC

OSSEC can be installed in **server**, **agent**, **local** or **hybrid** mode. This installation is for monitoring the server that OSSEC is installed on. That means a **local** installation.

You will be guided in the installation by a bash script. As you will see, at this stage we will keep the default settings for most of the installation. To initiate it, type

```bash
sudo ./install.sh
```

The installation script will prompt you with some questions. We start with installation language

```text
  (en/br/cn/de/el/es/fr/hu/it/jp/nl/pl/ru/sr/tr) [en]:
```

Here we will use this language so press ENTER.

```text
You are about to start the installation process of the OSSEC HIDS.
 You must have a C compiler pre-installed in your system.

  - System: Linux ubuntu 4.19.0-16-arm64
  - User: root
  - Host: ubuntu


  -- Press ENTER to continue or Ctrl-C to abort. --
```

Press ENTER to start the installation process

```text
1- What kind of installation do you want (server, agent, local, hybrid or help)? local

  - Local installation chosen.
```

Type **local** for local installation

```text
2- Setting up the installation environment.

 - Choose where to install the OSSEC HIDS [/var/ossec]: 

    - Installation will be made at  /var/ossec .
```

ENTER for default location. For safety reasons, this location will be accessible only to root user. You don't want anyone to read and potentially find ways to exploit information about your OSSEC configuration.

```text
3- Configuring the OSSEC HIDS.

  3.1- Do you want e-mail notification? (y/n) [y]: n
```

Type **n** and ENTER. We will have slack notifications so there's no need to turn on mail notifications. If you want it anyway, you will need to provide an email address with a valid SMTP server.

```text
  3.2- Do you want to run the integrity check daemon? (y/n) [y]:

   - Running syscheck (integrity check daemon).
```

Press ENTER to confirm. You will want to have an integrity check daemon to checksum important files and monitor any change.

```text
  3.3- Do you want to run the rootkit detection engine? (y/n) [y]: 

   - Running rootcheck (rootkit detection).
```

Press ENTER to confirm. Rootkits are malicious software designed to allow illicit access to protected parts of the system. This detection is typically achieved looking for virus "signatures", by integrity checking and by monitoring system usage.

```text
  3.4- Active response allows you to execute a specific 
       command based on the events received. For example,
       you can block an IP address or disable access for
       a specific user.  
       More information at:
       http://www.ossec.net/en/manual.html#active-response

   - Do you want to enable active response? (y/n) [y]: 

     - Active response enabled.
```

This will be a key step for our Slack setup. We want active response to get immediately notified of all threats. Press ENTER.

```text
   - By default, we can enable the host-deny and the 
     firewall-drop responses. The first one will add
     a host to the /etc/hosts.deny and the second one
     will block the host on iptables (if linux) or on
     ipfilter (if Solaris, FreeBSD or NetBSD).
   - They can be used to stop SSHD brute force scans, 
     portscans and some other forms of attacks. You can 
     also add them to block on snort events, for example.

   - Do you want to enable the firewall-drop response? (y/n) [y]: 

     - firewall-drop enabled (local) for levels >= 6

   - 
      - *==your ip==*

   - Do you want to add more IPs to the white list? (y/n)? [n]:
```

OSSEC can provide a firewall drop rule for local firewall in response to high level threats. Optionally, you can whitelist the addresses that you use to connect to the server.

```text
  3.6- Setting the configuration to analyze the following logs:
    -- /var/log/messages
    -- /var/log/auth.log
    -- /var/log/syslog
    -- /var/log/dpkg.log

 - If you want to monitor any other file, just change 
   the ossec.conf and add a new localfile entry.
   Any questions about the configuration can be answered
   by visiting us online at http://www.ossec.net .

   --- Press ENTER to continue ---
```

Configuration is done. The script reminds you that some log files will be monitored by default. We will add specific folders and files later. Press ENTER to start to compile and install OSSEC.

```text
5- Installing the system

 - System is Debian (Ubuntu or derivative).
 - Init script modified to start OSSEC HIDS during boot.

 - Configuration finished properly.

 - To start OSSEC HIDS:
      /var/ossec/bin/ossec-control start

 - To stop OSSEC HIDS:
      /var/ossec/bin/ossec-control stop

 - The configuration can be viewed or modified at /var/ossec/etc/ossec.conf


    Thanks for using the OSSEC HIDS.
    If you have any question, suggestion or if you find any bug,
    contact us at https://github.com/ossec/ossec-hids or using
    our public maillist at  
    https://groups.google.com/forum/#!forum/ossec-list

    More information can be found at http://www.ossec.net

    ---  Press ENTER to finish (maybe more information below). ---
```

{% hint style="success" %}
Congratulations! You just completed the installation.
{% endhint %}

## ✨ Create a new service for OSSEC autostart

Now we want OSSEC to run automatically at startup. To achieve this, we will create a systemd service.

```bash
cd $HOME
cat ossec.service <<EOF
[Unit]
Description=OSSEC service

[Service]
Type=forking
ExecStart=/var/ossec/bin/ossec-control start
ExecStop=/var/ossec/bin/ossec-control stop

[Install]
WantedBy=multi-user.target
EOF

sudo mv ossec.service /etc/systemd/system
sudo systemctl daemon-reload
```

For now we won't start the service, as we want to configure the integration with Slack notifications.

## 🔮 Configure your Slack workspace

Go to your Slack workspace and create a **private** channel for each of the server that you want to monitor. You really don't want your monitoring information to be public. Let's say we call our channel `ossec-ubuntu` as the name of the server.

We will first create a Slack App for the OSSEC service. Go to this page

[https://api.slack.com/apps?new\_app=1](https://api.slack.com/apps?new_app=1)

and click **Create New App**. Enter `OSSEC` as a name and select your workspace. Next click on the OSSEC app to view the API information.

Next click on **Add features and functionality** and **Incoming Webhooks**. Here we will add an new webhook for the server. Click on **Add New Webhook to Workspace** and select the channel you want to post to.

Then copy the **WebHook URL** from webhooks page.

The information we need will be as follows

```bash
SLACKUSER="ossec" # A name you choose for your slack user
CHANNEL="#ossec-ubuntu" # The channel the hook will post to
SITE="https://hooks.slack.com/services/<some token string>" # The WebHook URL you just copied
```

We are ready to configure OSSEC with our Slack information.

## 👾 Let OSSEC talk to your Slack API

OSSEC uses a bash script to forward its notifications to Slack. We will first configure this

```bash
sudo nano /var/ossec/active-response/ossec-slack.sh
```

and modify the empty fields **SLACKUSER**, **CHANNEL** and **SITE** with the information you prepared in the previous session. Eventually, the first part of the script will look like this

```bash
#!/bin/sh

# Change these values!
# SLACKUSER user who posts notifications
# CHANNEL which channel it should be posted
# SITE is the URL provided by the Slack's WebHook, something like:
# https://hooks.slack.com/services/TOKEN"
SLACKUSER="ossec"
CHANNEL="#ossec-ubuntu"
SITE="https://hooks.slack.com/services/<some token string>"
SOURCE="ossec2slack"
```

Next, we will edit the main ossec config file to actually forward the notifications to this script

```bash
sudo nano /var/ossec/etc/ossec.conf
```

and add these lines at the end of the commands section

```markup
  <!-- SLACK -->                
  <command>                             
    <name>ossec-slack</name>
    <executable>ossec-slack.sh</executable>
    <expect></expect> <!-- no expect args required -->
    <timeout_allowed>no<timeout_allowed>
  </command>  

  <active-response>
    <command>ossec-slack</command>
    <location>local</location>
    <level>3</level>
  </active-response>
```

Current level of notifications for this command is 3. This means that you will be notified for example of all succeeded events, such as ssh logins or sudo commands. This ensures a very good level of protection, but if you think that these notifications are not useful, you can adjust the level. I would suggest raising this to the bearable minimum. I actually keep this at 3 to get notifications for all logins to my servers. As you will see, you will also fine-tune the notifications to your system in the last section.

OK, now let's start OSSEC and see if everything works. Type

```bash
sudo systemctl start ossec
```

If everything is ok, you should get a notification of level 3 with comment `OSSEC started` in your slack channel.

We will stop it again for now, as we have to make a few more changes.

```bash
sudo systemctl stop ossec
```

## 🍰 Stake pool specific configuration for OSSEC

OSSEC has the capacity to monitor realtime changes to folder. To use this feature, we will edit the `ossec.conf` file. Type

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Look for the `<directories>` entries and modify as below

```markup
    <!-- Directories to check  (perform all possible verifications) -->
    <directories report_changes="yes" realtime="yes" check_all="yes">/etc,/usr/bin,/usr/sbin</directories>
    <directories report_changes="yes" realtime="yes" check_all="yes">/bin,/sbin,/boot</directories>

    <directories report_changes="yes" realtime="yes" check_all="yes">/usr/local/bin</directories>
```

Here we added the keywords `report_changes="yes" realtime="yes` to all directories to monitor their realtime changes. We also want to monitor specific files in the cardano node folder. We will then add a line like this one

```markup
    <directories report_changes="yes" realtime="yes" restrict=".skey|.cert|.json|.txt|.sh|.addr|env" check_all="yes">/home/cardano/pool</directories>
```

where `/home/cardano/pool` is our cardano node folder. Change this directory to point to your node directory. It's also a good idea to exclude the database and logs folder, so we will add also the following lines to the `<ignore>` fields.

```markup
    <ignore>/home/cardano/pool/db</ignore>
    <ignore>/home/cardano/pool/logs</ignore>
```

Another important point is that we want to spot any potential DoS attack to our relay nodes. To achieve this we will monitor the number of connections on the node port from each server and track when a server has more than 2 connections. To monitor the number of connections on a specific port we will use this command

```bash
netstat -tn 2>/dev/null | grep :<YOUR-PORT> | awk '{print $5}' | cut -d: -f1 | uniq -c | sort -nr
```

where you will change `<YOUR-PORT>` with the node port \(say 3001 or 6000 for example\).

The output will be something like this

```text
      2 xxx.yyy.zzz.www
      1 xxx.yyy.zzz.www
      1 xxx.yyy.zzz.www
      1 xxx.yyy.zzz.www
      1 xxx.yyy.zzz.www
      1 xxx.yyy.zzz.www
      1 xxx.yyy.zzz.www
```

In this case, we want to track all IPs that have more than 2 connections at the same time. To achieve this we will add an `awk '$1 > 2 { print $2}'` at the end. So our final tracker will be this one, to be inserted at the end of the `<localfile>` commands section. Remember to change `<YOUR-PORT>` with the actual node port.

```markup
    <localfile>
      <log_format>full_command</log_format>
      <command>netstat -tn 2>/dev/null | grep :<YOUR-PORT> | awk '{print $5}' | cut -d: -f1 | uniq -c | sort -nr | awk '$1 > 2 { print $2}'</command>
    </localfile>
```

Finally, we want a tracer for errors in topologyUpdater log. Suppose that you put your topologyUpdater log in `/home/cardano/logs/topologyUpdate_lastresults.json`, we will add a section like this one

```markup
    <localfile>
      <log_format>syslog</log_format>
      <location>/home/cardano/logs/topologyUpdate_lastresults.json</location>
    </localfile>
```

to enable monitoring of this log. Save and close this file. At this point OSSEC will know that it needs to look at this file.

We will also add a decoder to let OSSEC know the correct interpretation of this file. Open the `decoder.xml` file

```bash
sudo nano /var/ossec/etc/decoder.xml
```

and add these lines at the end

```markup
<!-- Decoder topologyUpdater -->
<!-- { "resultcode": "502", "datetime":"2021-04-07 08:15:50", "clientIp": "8.8.8.8", "msg": "invalid blockNo []" } -->
<!-- { "resultcode": "504", "datetime":"2021-04-07 08:19:59", "clientIp": "8.8.8.8", "iptype": 4, "msg": "one request per hour please" } -->
<decoder name="topologyupdater">
  <prematch>\{ "resultcode"</prematch>
</decoder>

<decoder name="topologyupdater-ip">
  <parent>topologyupdater</parent>
  <prematch>iptype</prematch>
  <pcre2>\{ "resultcode": "(.*?)", "datetime":"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}", "clientIp": "(.*?)", "iptype": [0-9], "msg": "(.*?)" \}</pcre2>
  <order>resultcode, clientip, msg</order>
</decoder>

<decoder name="topologyupdater-noip">
  <parent>topologyupdater</parent>
  <prematch_pcre2>", "msg"</prematch_pcre2>
  <pcre2>\{ "resultcode": "(.*?)", "datetime":"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}", "clientIp": "(.*?)", "msg": "(.*?)" \}</pcre2>
  <order>resultcode, clientip, msg</order>
</decoder>
```

Now let's check that everything works. Run this command

```bash
sudo /var/ossec/bin/ossec-logtest
```

and paste this test line then press ENTER. The line should be recognized and decoded, such as in this example

```javascript
{ "resultcode": "502", "datetime":"2021-04-07 08:15:50", "clientIp": "8.8.8.8", "msg": "invalid blockNo []" }
```

The result show be like this one

```text
**Phase 1: Completed pre-decoding.
       full event: '{ "resultcode": "502", "datetime":"2021-04-07 08:15:50", "clientIp": "8.8.8.8", "msg": "invalid blockNo []" }'
       hostname: 'relaynode1'
       program_name: '(null)'
       log: '{ "resultcode": "502", "datetime":"2021-04-07 08:15:50", "clientIp": "8.8.8.8", "msg": "invalid blockNo []" }'

**Phase 2: Completed decoding.
       decoder: 'topologyupdater'
       resultcode: '502'
       clientip: '8.8.8.8'
       msg: 'invalid blockNo []'
```

Here you see that OSSEC correctly identified the decoder to use and separated the fields in the right way.

Good! We defined all trackers and files to monitor. Save and close this file. Next step will be the definition of local rules.

## 🔎 Setting rules and fine-tuning

OSSEC comes with a number of predefined rules that implement the best practices in server security. However, sometimes they are a bit too invasive or need to be adapted to the specific server you are running. Each set of rules comes in a `.xml` file. In this section, we will configure the `local_rules.xml` file to adapt them to our cardano node.

To edit your rules type

```bash
sudo nano /var/ossec/rules/local_rules.xml
```

First of all, we will create a new rule to silence all warnings coming from loop devices having no space. Rules have a unique ID \(in this case we will use consecutive numbers starting from 100,001\) and a level of security. Level 0 means no notification. This rule will be based on rule 531, which is activated in case a device has no empty space, and will be give level 0, i.e. silence, all string matching the regular expression defined in the `pcre2` fields \(perl regular expression format\). We also ad a human format description.

```markup
  <rule id="100001" level="0">
     <if_sid>531</if_sid>
     <pcre2>loop</pcre2>
     <description>Ignore full space on /dev/loopX.</description>
  </rule>
```

Next, we will configure a rule with high severity to keep track of the incoming connections with more than 2 connections. Don't forget to change `<YOUR-PORT>` with the actual node port.

```markup
  <rule id="100002" level="7">
    <if_sid>530</if_sid>
    <match>ossec: output: 'netstat -tn 2>/dev/null | grep :<YOUR-PORT></match>
    <check_diff />
    <description>More than 2 connections to relay from same peer.</description>
  </rule>
```

Finally, we also want to track errors on topologyUpdater so we will add these lines at the end after the `</group>` line. Here we are creating a new group for our topologyUpdate decoder, which by default has an alert level of 0 and an alert level of 4 for invalid block errors \(usually when the node is not working\) and level of 3 \(low level notification\) when topologyUpdater performs more than one request per hour.

```markup
 <group name="syslog,topologyupdater,">
  <rule id="110000" level="0" noalert="1">
    <decoded_as>topologyupdater</decoded_as>
    <description>topologyUpdater messages grouped.</description>
  </rule>

  <rule id="110001" level="0">
    <if_sid>110000</if_sid>
    <match>204</match>
    <description>topologyUpdater OK.</description>
  </rule>

  <rule id="110002" level="4">
    <if_sid>110000</if_sid>
    <match>502</match>
    <description>topologyUpdater: invalid block.</description>
  </rule>

  <rule id="110003" level="3">
    <if_sid>110000</if_sid>
    <match>504</match>
    <description>topologyUpdater: too many requests.</description>
  </rule>
</group>
```

Save and close this file and restart OSSEC. If you let it run for an hour or so, you'll see that you will get a lot of notifications to your OSSEC channel. For example, for some reasons cardano node logs to syslog with very long lines and these generate a high severity warning because they might be a signal for a potential attack. To avoid this we will make a change in the `mainnet-config.json` file.

```bash
sed -i ${NODE_CONFIG}-config.json \
    -e "s/minSeverity\": \"Info\"/minSeverity\": \"Notice\"/g"
```

Now restart your cardano node

```bash
sudo systemctl restart cardano-node
```

and you should enjoy a calmer environment.

{% hint style="success" %}
Congrats on completing the guide. ✨

This guide was contributed by [Billionaire Pool](www.billionairepool.com). If you find this guide useful, please consider staking to it \(**BIL** ticker\). Thank you 🙏

Join [@BillionairePool](https://twitter.com/BillionairePool) on Twitter or hang out and chat at on Discord @

[https://discord.gg/tDW6dqh7](https://discord.gg/tDW6dqh7)

The guide is kindly hosted by our Coincashew friends. Use [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. 🙏

Hang out and chat with fellow stake pool operators on Discord @

[https://discord.gg/w8Bx8W2HPW](https://discord.gg/w8Bx8W2HPW) 😃

Hang out and chat with our stake pool community on Telegram @ [https://t.me/coincashew](https://t.me/coincashew)
{% endhint %}

## 🚀 References

{% embed url="https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ossec-security-notifications-on-ubuntu-14-04" caption="" %}

{% embed url="https://www.built.io/blog/how-to-implement-a-host-based-intrusion-detection-system--hids-in-the-cloud" caption="" %}

{% embed url="https://defragged.org/ossec/2016/01/ossec-integrates-slack-and-pagerduty/" caption="" %}


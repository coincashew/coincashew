# 6. Auto-start and monitoring

## :trophy: Objectives

1. Auto-start your baker when the computer reboots due to maintenance, power outage, etc with systemd.
2. Automatically restart crashed tezos-\[node|baker|endorser|accuser] processes
3. Maximize your baker up-time and performance at making rolls and endorsements.

## :control_knobs: Setup instructions

Before starting, ensure all tezos processes are stopped. Check with:

```
ps -ef | grep tezos
```

If there are tezos processes, type 

```
kill <pid>
```

where \<pid> is the process ID number, the first # in the `ps `output.

> `#example ps output, the pid is 23311`\
> `username 23311 121 6 11:22 ? 11:22:33 /home/username/tezos/tezos-node run`

Prepare by saving your Ubuntu username and changing to SU/root.

```
cd
whoami > myusername
sudo su
```

{% hint style="info" %}
Enter your SU/root password.
{% endhint %}

Run the following to create the `tezos-node.service` configuration.

```
cat > /etc/systemd/system/tezos-node.service << EOF 
# The Tezos Node service (part of systemd)
# file: /etc/systemd/system/tezos-node.service 

[Unit]
Description     = Tezos Node Service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = replaceUsername
Group		= replaceUsername
WorkingDirectory= /home/replaceUsername/
ExecStart	= /home/replaceUsername/tezos/tezos-node run --rpc-addr 127.0.0.1:8732
Restart         = always

[Install]
WantedBy	= multi-user.target
RequiredBy	= tezos-baker.service tezos-endorser.service tezos-accuser.service
EOF
```

Run the following to create the `tezos-baker.service` configuration.

```
cat > /etc/systemd/system/tezos-baker.service << EOF 
# The Tezos Baker service (part of systemd)
# file: /etc/systemd/system/tezos-baker.service 

[Unit]
Description     = Tezos Baker Service
BindsTo		= tezos-node.service
After           = tezos-node.service

[Service]
User            = replaceUsername
Group		= replaceUsername
WorkingDirectory= /home/replaceUsername/
ExecStartPre	= /bin/sleep 1
ExecStart       = /home/replaceUsername/tezos/tezos-baker-006-PsCARTHA run with local node /home/replaceUsername/.tezos-node ledger_mybaker
Restart         = always

[Install]
WantedBy	= multi-user.target
EOF
```

{% hint style="info" %}
Make sure your ledger account name is correct on the **ExecStart **line. i.e. `ledger_mybaker`
{% endhint %}

Run the following to create the `tezos-endorser.service` configuration.

```
cat > /etc/systemd/system/tezos-endorser.service << EOF 
# The Tezos Endorser service (part of systemd)
# file: /etc/systemd/system/tezos-endorser.service 

[Unit]
Description     = Tezos Endorser Service
BindsTo		= tezos-node.service
After           = tezos-node.service

[Service]
User            = replaceUsername
Group		= replaceUsername
WorkingDirectory= /home/replaceUsername/
ExecStartPre	= /bin/sleep 1
ExecStart       = /home/replaceUsername/tezos-endorser-006-PsCARTHA run ledger_mybaker
Restart         = always

[Install]
WantedBy	= multi-user.target
EOF
```

{% hint style="info" %}
Again, make sure your ledger account name is correct on the **ExecStart **line. i.e. `ledger_mybaker`
{% endhint %}

Run the following to create the `tezos-accuser.service` configuration.

```
cat > /etc/systemd/system/tezos-accuser.service << EOF 
# The Tezos Accuser service (part of systemd)
# file: /etc/systemd/system/tezos-accuser.service 

[Unit]
Description     = Tezos Accuser Service
BindsTo		= tezos-node.service
After           = tezos-node.service

[Service]
User            = replaceUsername
Group		= replaceUsername
WorkingDirectory= /home/replaceUsername/
ExecStartPre	= /bin/sleep 1
ExecStart       = /home/replaceUsername/tezos/tezos-accuser-006-PsCARTHA run
Restart         = always

[Install]
WantedBy	= multi-user.target
EOF 
```

The following command updates the files with your Ubuntu username.

```
for f in /etc/systemd/system/tezos-*.service ; do
    myUsernamevar=$(cat myusername)
    sed -i.bak "s/replaceUsername/$myUsernamevar/g" "$f"
done
rm myusername
```

Run the following to enable the services.

```
sudo systemctl enable tezos-node.service
sudo systemctl enable tezos-baker.service
sudo systemctl enable tezos-endorser.service
sudo systemctl enable tezos-accuser.service
```

{% hint style="info" %}
Type your su/root password, if needed.
{% endhint %}

Finally, start the services. The following single command will start all child processes, which are the baker, endorser, and accuser, because of binding settings.

```
sudo systemctl reload-or-restart tezos-node.service
```

{% hint style="success" %}
Nice work. Your baker is now managed by the reliability and robustness of systemd.
{% endhint %}

## :eyeglasses: Viewing logs

Create a new terminal for each journalctl and you can view each log simultaneously.

```
journalctl --follow --unit=tezos-node.service
```

```
journalctl --follow --unit=tezos-baker.service
```

```
journalctl --follow --unit=tezos-endorser.service
```

```
journalctl --follow --unit=tezos-accuser.service
```

## :mag: Viewing the status of all tezos services

```
sudo systemctl status 'tezos-*.service'
```

## :arrows_counterclockwise: Restarting all services

```
sudo systemctl reload-or-restart tezos-node.service
```

## :twisted_rightwards_arrows: Restarting individual services

```
sudo systemctl reload-or-restart tezos-node.service
sudo systemctl reload-or-restart tezos-endorser.service
sudo systemctl reload-or-restart tezos-accuser.service
sudo systemctl reload-or-restart tezos-baker.service
```

## :octagonal_sign: Stopping services

```
sudo systemctl stop tezos-node.service
sudo systemctl stop tezos-baker.service
sudo systemctl stop tezos-endorser.service
sudo systemctl stop tezos-accuser.service
```

## :file_cabinet: Filtering logs

```
journalctl --unit=tezos-endorser.service --since=yesterday
journalctl --unit=tezos-endorser.service --since=today
journalctl --unit=tezos-endorser.service --since='2019-01-01 00:00:00' --until='2019-01-02 12:00:00'
```

## :man_mechanic: Making Configuration Changes

If you edit any of the above .service files, you to notify systemd of your new changes by reloading the new configuration by running the following:

```
systemctl daemon-reload
```

If you modify the`  [Install]  `section, you must reenable the service.

```
sudo systemctl reenable SERVICEFILENAME
```

## :pray: Credits

Concept and scripts modified from here:

[https://github.com/etomknudsen/tezos-baking](https://github.com/etomknudsen/tezos-baking)

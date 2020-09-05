---
description: >-
  chrony is an implementation of the Network Time Protocol and helps to keep
  your computer's time synchronized with NTP.
---

# How to setup chrony

## 🐣 1. Installation

Install chrony.

```text
sudo apt-get install chrony
```

 Update the config file located in `/etc/chrony/chrony.conf` with the following 

```text
pool time.google.com       iburst minpoll 1 maxpoll 2 maxsources 3
pool ntp.ubuntu.com        iburst minpoll 1 maxpoll 2 maxsources 3
#pool time.nist.giv         iburst minpoll 1 maxpoll 2 maxsources 3
pool us.pool.ntp.org     iburst minpoll 1 maxpoll 2 maxsources 3

# This directive specify the location of the file containing ID/key pairs for
# NTP authentication.
keyfile /etc/chrony/chrony.keys

# This directive specify the file into which chronyd will store the rate
# information.
driftfile /var/lib/chrony/chrony.drift

# Uncomment the following line to turn logging on.
#log tracking measurements statistics

# Log files location.
logdir /var/log/chrony

# Stop bad estimates upsetting machine clock.
maxupdateskew 5.0

# This directive enables kernel synchronisation (every 11 minutes) of the
# real-time clock. Note that it can’t be used along with the 'rtcfile' directive.
rtcsync

# Step the system clock instead of slewing it if the adjustment is larger than
# one second, but only in the first three clock updates.
makestep 0.1 -1
```

Restart chrony in order for config change to take effect.

```text
systemctl restart chronyd.service
```

## 🤖 2. Helpful Commands

To see the source of synchronization data.

```text
chronyc sources
```

To view the current status of chrony.

```text
chronyc tracking
```


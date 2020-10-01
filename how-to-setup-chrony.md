---
description: >-
  chronyはネットワークタイムプロトコルを実装します。コンピュータの時刻をNTPと同期させるのに役立ちます。
---

# chronyセットアップガイド

## 🐣 1. インストール

chronyをインストールします。

```text
sudo apt-get install chrony
```

`/etc/chrony/chrony.conf` にある構成ファイルをっ秋の内容のように編集します。

```text
nano /etc/chrony/chrony.conf
```

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

設定を有効にするには、Chronyを再起動します。

```text
systemctl restart chronyd.service
```

## 🤖 2. ヘルプコマンド

同期データのソースを確認します。

```text
chronyc sources
```

現在のステータスを表示します。

```text
chronyc tracking
```


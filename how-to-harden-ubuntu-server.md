---
description: ノード保護のためのセキュリティ強化方法です。
---

# Ubuntuサーバーを強化する手順

<!--{% hint style="success" %}
Thank you for your support and kind messages! It really energizes us to keep creating the best crypto guides. Use [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses and share your message. 🙏 
{% endhint %}-->

## 🧙♂ ルート権限を付与したユーザーアカウントの作成

{% hint style="info" %}
サーバを操作する場合はrootアカウントを使用せず、root権限を付与したユーザーアカウントで操作するようにしましょう。
rootアカウントで誤ってrmコマンドを使用すると、サーバ全体が完全消去されます。
{% endhint %}

<!--SSH to your server

```text
ssh username@server.ip.address
```-->

新しいユーザーの追加　(例：cardano)

```text
useradd -m -s /bin/bash cardano
```

cardanoにパスワードを設定します。

```text
passwd cardano
```

cardanoをsudoグループに追加する

```text
usermod -aG sudo cardano
```

## \*\*\*\*🔏 **SSHパスワード認証を無効化し、SSH鍵認証方式のみを使用する**

{% hint style="info" %}
SSHを強化する基本的なルールは次の通りです。

* SSHログイン時パスワード無効化 \(秘密鍵を使用\)
* rootアカウントでのSSHログイン無効化 \(root権限な必要なコマンドは`su` or `sudo`コマンドを使う\)
* 許可されていないアカウントからのログイン試行をログに記録する \(fail2banなどの、不正アクセスをブロックまたは禁止するソフトウェアの導入を検討する\)
* SSHログイン元のIPアドレス範囲のみに限定する \(希望する場合のみ\)※利用プロバイダーによっては、定期的にグローバルIPが変更されるので注意が必要
{% endhint %}

### 鍵ペアーの作成

ローカルマシンに新しいSSH公開鍵と秘密鍵のペアキーを作成する。ファイル名(キーネーム)を入力するように求められます。

```text
ssh-keygen -t rsa
```

公開鍵(***.pub)をリモートノードへ転送する。
{% hint style="info" %}
ssh-copy-id コマンドを使用することで、リモートサーバへ「.ssh/authorized_keys」として転送してくれます。
{% endhint %}
```bash
ssh-copy-id -i $HOME/.ssh/<キーネーム>.pub cardano@server.ip.address
```

先程作成したユーザーアカウント(cardano)でログインする

```text
ssh cardano@server.ip.address
```

### SSHの設定変更

`/etc/ssh/sshd_config`ファイルを開く

```text
sudo nano /etc/ssh/sshd_config
```

**ChallengeResponseAuthentication**の項目を「no」にする

```text
ChallengeResponseAuthentication no
```

**PasswordAuthentication**の項目を「no」にする

```text
PasswordAuthentication no 
```

**PermitRootLogin**の項目を「no」にする

```text
PermitRootLogin no
```

**PermitEmptyPasswords**の項目を「no」にする

```text
PermitEmptyPasswords no
```

ポート番号をランダムな数値へ変更する
{% hint style="info" %}
ローカルマシンからSSHログインする際、ポート番号を以下で設定した番号に合わせてください。
{% endhint %}

```bash
Port <port number>
```

SSH構文にエラーがないかチェックします。

```text
sudo sshd -t
```

SSH構文エラーがない場合、SSHプロセスを再起動します。

```text
sudo service sshd reload
```

一旦、ログオフし、ログイン出来るか確認します。

```text
exit
```

```text
ssh cardano@server.ip.address
```

{% hint style="info" %}
上記でログイン出来ない場合は、SSHキーを指定してログインします。

```bash
ssh -i <path to your SHH_key_name.pub> cardano@server.ip.address
```
{% endhint %}

## \*\*\*\*🤖 **システムを更新する**

{% hint style="warning" %}
不正アクセスを予防するには、システムに最新のパッチを適用することが重要です。
{% endhint %}

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get autoremove
sudo apt-get autoclean
```

自動更新を有効にすると、手動でインストールする手間を省けます。

```text
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## 🧸 rootアカウントを無効にする

サーバーのセキュリティを維持するために、頻繁にrootアカウントでログインしないでください。

```bash
# rootアカウントを無効にするには、-lオプションを使用します。
sudo passwd -l root
```

```bash
# 何らかの理由でrootアカウントを有効にする必要がある場合は、-uオプションを使用します。
sudo passwd -u root
```

## 🛠 SSHの2段階認証を設定する

{% hint style="info" %}
SSHはリモートアクセスに使用されますが、重要なデータを含むコンピュータとの接続としても使われるため、別のセキュリティーレイヤーの導入をお勧めします。2段階認証(2FA)
{% endhint %}

```text
sudo apt install libpam-google-authenticator -y
```

SSHがGoogle Authenticator PAM モジュールを使用するために、`/etc/pam.d/sshd`ファイルを編集します。

```text
sudo nano /etc/pam.d/sshd 
```

以下の行を追加します。

```text
auth required pam_google_authenticator.so
```

以下を使用して`sshd`デーモンを再起動します。

```text
sudo systemctl restart sshd.service
```

`/etc/ssh/sshd_config` ファイルを開きます。

```text
sudo nano /etc/ssh/sshd_config
```

**ChallengeResponseAuthentication**の項目を「yes」にします。

```text
ChallengeResponseAuthentication yes
```

**UsePAM**の項目を「yes」にします。

```text
UsePAM yes
```

ファイルを保存して閉じます。

**google-authenticator** コマンドを実行します。

```text
google-authenticator
```

いくつか質問事項が表示されます。推奨項目は以下のとおりです。

* Make tokens “time-base”": yes
* Update the `.google_authenticator` file: yes
* Disallow multiple uses: yes
* Increase the original generation time limit: no
* Enable rate-limiting: yes

プロセス中に大きなQRコードが表示されますが、その下には緊急時のスクラッチコードがひょうじされますので、忘れずに書き留めておいて下さい。

スマートフォンでGoogle認証システムアプリを開き、秘密鍵を追加して2段階認証を機能させます。

## 🧩 安全な共有メモリー

{% hint style="info" %}
システムで共有されるメモリを保護します。
{% endhint %}

`/etc/fstab`を開きます

```text
sudo nano /etc/fstab
```

次の行をファイルの最後に追記して保存します。

```text
tmpfs	/run/shm	tmpfs	ro,noexec,nosuid	0 0
```

変更を有効にするには、システムを再起動します。

```text
sudo reboot
```

## \*\*\*\*⛓ **Fail2banのインストール**

{% hint style="info" %}
Fail2banは、ログファイルを監視し、ログイン試行に失敗した特定のパターンを監視する侵入防止システムです。特定のIPアドレスから（指定された時間内に）一定数のログイン失敗が検知された場合、Fail2banはそのIPアドレスからのアクセスをブロックします。
{% endhint %}

```text
sudo apt-get install fail2ban -y
```

SSHログインを監視する設定ファイルを開きます。

```text
sudo nano /etc/fail2ban/jail.local
```

ファイルの最後に次の行を追加し保存します。

```bash
[sshd]
enabled = true
port = <22 or your random port number>
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
```

fail2banを再起動して設定を有効にします。

```text
sudo systemctl restart fail2ban
```

## \*\*\*\*🧱 **ファイアウォールを構成する**

標準のUFWファイアウォールを使用して、ノードへのネットワークアクセスを制限できます。

新規インストール時点では、デフォルトでufwが無効になっているため、以下のコマンドで有効にしてください。

* SSH接続用のポート22番\(または設定したランダムなポート番号 \#\)
* ノード用のポート6000番または6001番
* ノード監視Grafana用3000番ポート \(このノードで起動している場合\)
* ブロックプロデューサーノードおよびリレーノード用に設定を変更して下さい。
* ブロックプロデューサーノードでは、リレーノードのIPのみ受け付ける用に設定してください。

```bash
ufw allow <22またはランダムなポート番号>/tcp
#リレーノードのIPを指定する場合
#ufw allow from <リレーノードIP> to any port <ノード用のポート番号>
ufw allow 6000/tcp
ufw allow 3000/tcp
ufw enable
ufw status numbered
```

設定が有効であることを確認します。

> ```csharp
>      To                         Action      From
>      --                         ------      ----
> [ 1] 22/tcp                     ALLOW IN    Anywhere
> [ 2] 3000/tcp                   ALLOW IN    Anywhere
> [ 3] 6000/tcp                   ALLOW IN    Anywhere
> [ 4] 22/tcp (v6)                ALLOW IN    Anywhere (v6)
> [ 5] 3000/tcp (v6)              ALLOW IN    Anywhere (v6)
> [ 6] 6000/tcp (v6)              ALLOW IN    Anywhere (v6)
> ```

## 🔭 リスニングポートの確認

安全なサーバーを維持するには、時々リスニングネットワークポートを検証する必要があります。これにより、ネットワークに関する重要な情報を得られます。

```text
netstat -tulpn
ss -tulpn
```

## 🚀 参考文献

{% embed url="https://medium.com/@BaneBiddix/how-to-harden-your-ubuntu-18-04-server-ffc4b6658fe7" %}

{% embed url="https://linux-audit.com/ubuntu-server-hardening-guide-quick-and-secure/" %}

{% embed url="https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04" %}

{% embed url="https://ubuntu.com/tutorials/configure-ssh-2fa\#1-overview" %}

[https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3\#file-ubuntu-hardening-md](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3#file-ubuntu-hardening-md)

{% embed url="https://www.lifewire.com/harden-ubuntu-server-security-4178243" %}

{% embed url="https://www.ubuntupit.com/best-linux-hardening-security-tips-a-comprehensive-checklist/" %}


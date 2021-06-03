---
description: >-
  このマニュアルでは、１つのブロックプロデューサーノードと１つのリレーノードで構成し、ソースコードからカルダノステークプールをセットアップする手順となっております。
---

# カルダノステークプール構築手順

## 🎉 ∞ お知らせ

{% hint style="info" %}
このマニュアルは、[X Stake Pool](https://xstakepool.com)オペレータの[BTBF](https://twitter.com/btbfpark)が[CoinCashew](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#9-register-your-stakepool)より許可を得て、日本語翻訳しております。
{% endhint %}

{% hint style="success" %}
このマニュアルは、カルダノノードv1.27.0に対応しています。
最終更新日：2021年5月14日の時点guide version 4.2.0  
{% endhint %}

{% hint style="info" %}
こちらのマニュアルは更新頻度が低く、最新情報ではない可能性があります。  
BTBFが管理するドメイン[https://dev.xstakepool.com/](https://dev.xstakepool.com/)の日本語マニュアルをご参照ください。
{% endhint %}

## 🏁 0. 前提条件

### 🧙♂ ステークプールオペレータの必須スキル

カルダノステークプールを運営するには、以下のスキルを必要とします。

* カルダノノードを継続的にセットアップ、実行、維持する運用スキル
* ノードを24時間年中無休で維持するというコミット
* システム運用スキル
* サーバ管理スキル \(運用および保守\).
* 開発と運用経験 \(DevOps\)
* サーバ強化とセキュリティに関する知識
* カルダノ財団公式ステークプールセットアップコース受講

{% hint style="danger" %}
🛑 **このマニュアルを進めるには、上記のスキル要件を必要とします** 🚧
{% endhint %}

### 🎗 ステークプールハードウェア(VPSスペック)要件\(最小構成\)

* **２つのサーバー:** ブロックプロデューサーノード用1台、 リレーノード用1台
* **エアギャップオフラインマシン1台 \(コールド環境\)** (2Core-CPU/メモリ8GB以上)
* **オペレーティング・システム:** 64-bit Linux \(Ubuntu 20.04 LTS\)
* **プロセッサー:** 1.6GHz以上(ステークプールまたはリレーの場合は2Ghz以上)の2つ以上のコアを備えたIntelまたはAMD x86プロセッサー
* **メモリー:** 8GB RAM（サードパーティー製ツールを導入する場合2GBのスワップ領域を設定するか、10GB以上のメモリを搭載）
* **ストレージ:** SSD 24GB以上の空き容量

* **インターネット:** 10 Mbps以上のブロードバンド回線.
* **データプラン**: 1時間あたり1GBの帯域. 1ヶ月あたり720GB.
* **電力:** 安定供給された電力
* **ADA残高:** 505 ADA以上

### 🏋♂ ステークプールハードウェア(VPSスペック)要件\(推奨構成\)

* **３つのサーバー:** ブロックプロデューサーノード用1台、 リレーノード用2台
* **エアギャップオフラインマシン1台 \(コールド環境\)**(2Core-CPU/メモリ16GB以上)
* **オペレーティング・システム:** 64-bit Linux \(i.e. Ubuntu 20.04 LTS\)
* **プロセッサー:** 4 core以上の CPU
* **メモリー:** 16GB RAM
* **ストレージ:** 256GB+ SSD
* **インターネット:** 100 Mbps以上のブロードバンド回線
* **データプラン**: 無制限
* **電力:** 無停電電源装置\(UPS\)による電源管理
* **ADA残高:** ステークプールに対する保証金をご自身で定める分

### 🔓 Ubuntuセットアップガイド

ステークプールのサーバ初期設定とセキュリティ強化するには、以下の内容を実施して下さい。

{% hint style="info" %}
<<<<<<< HEAD
[Ubuntuサーバー初期設定(+セキュリティ設定)](./how-to-harden-ubuntu-server.md)
=======
[Ubuntuサーバー初期設定\(+セキュリティ設定\)](how-to-harden-ubuntu-server.md)
>>>>>>> 8f25989ac2a51373ecd00c54f8158f7f5a29df1d
{% endhint %}

### 🧱 ノードを再構築したい場合

もしノードインストールを初めからやり直したい場合は[項目18.2](./guide-how-to-build-a-haskell-stakepool-node.md#182-resetting-the-installation)で、リセットの方法を確認して下さい。

### 🧱 試しにノードを起動してみたい方へ

Linuxサーバのコマンドや、ノード起動などお試しテストでやってみたい方は、項目の1，2，3，4, 5をやってみましょう！  
この項目はブロックチェーンには直接的に影響がないので、たとえ間違ったコマンドを送信してもネットワークには問題ございません。

## 🏭 1. CabalとGHCをインストールします

ターミナルを起動し、以下のコマンドを入力しましょう！

まずはじめに、パッケージを更新しUbuntuを最新の状態に保ちます。

```bash
sudo apt-get update -y
```
```bash
sudo apt-get upgrade -y
```
```bash
sudo apt-get install git jq bc automake tmux rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf -y
```

次に、Libsodiumをインストールします。

```bash
mkdir $HOME/git
cd $HOME/git
git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
sudo make install
```

GHCUPをインストールします。

```bash
cd $HOME
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```
> Press ENTER to proceed or ctrl-c to abort.
Note that this script can be re-run at any given time.

⇒Enter

>Press ENTER to proceed or ctrl-c to abort.
Installation may take a while

⇒Enter

>Answer with YES or NO and press ENTER

⇒noと入力しEnter

>Detected bash shell on your system...
If you want ghcup to automatically add the required PATH variable to "/home/xxxx/.bashrc"
answer with YES, otherwise with NO and press ENTER.

⇒yesと入力しEnter

```bash
source ~/.bashrc
ghcup upgrade
ghcup install cabal 3.4.0.0
ghcup set cabal 3.4.0.0
```

GHCをインストールします。

```bash
ghcup install ghc 8.10.4
ghcup set ghc 8.10.4
```

環境変数を設定しパスを通します。 ノードの場所は **$NODE\_HOME** に設定されます。 最新のノード構成ファイルは**$NODE\_CONFIG** と **$NODE\_BUILD\_NUM**によって取得されます。

```bash
echo PATH="$HOME/.local/bin:$PATH" >> $HOME/.bashrc
echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> $HOME/.bashrc
echo export NODE_HOME=$HOME/cardano-my-node >> $HOME/.bashrc
echo export NODE_CONFIG=mainnet>> $HOME/.bashrc
echo export NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g') >> $HOME/.bashrc
source $HOME/.bashrc
```

Cabalを更新し、正しいバージョンが正常にインストールされていることを確認して下さい。

```bash
cabal update
cabal --version
ghc --version
```

{% hint style="info" %}
Cabalのライブラリーバージョンは「3.4.0.0」で GHCのバージョンは「8.10.4」であることを確認してください。
{% endhint %}

## 🏗 2. ソースコードからノードを構築する

{% hint style="info" %}
バイナリーファイルは必ずソースコードからビルドするようにし、整合性をチェックしてください。  
また、IOGは現在ARMアーキテクチャ用のバイナリファイルを提供していません。Raspberry Piを使用してプールを構築する場合は、ARM用コンパイラでコンパイルする必要があります。
{% endhint %}

Gitからソースコードをダウンロードし、最新のタグに切り替えます。

```bash
cd $HOME/git
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node
git fetch --all --recurse-submodules --tags
git checkout tags/1.27.0
```

Cabalのビルドオプションを構成します。

```bash
cabal configure -O0 -w ghc-8.10.4
```

Cabal構成、プロジェクト設定を更新し、ビルドフォルダーをリセットします。

```bash
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
sed -i $HOME/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
rm -rf $HOME/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.10.4
```

カルダノノードをビルドします。

```text
cabal build cardano-cli cardano-node
```

{% hint style="info" %}
サーバスペックによって、ビルド完了までに数分から数時間かかる場合があります。
{% endhint %}

**cardano-cli**ファイルと **cardano-node**ファイルをbinディレクトリにコピーします。

```bash
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
```
```bash
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

**cardano-cli** と **cardano-node**のバージョンが上記で指定したGitタグバージョンであることを確認してください。

```text
cardano-node version
cardano-cli version
```

## 📐 3. ノードを構成する

ノード構成に必要な config.json、genesis.json、及び topology.json ファイルを取得します。

```bash
mkdir $NODE_HOME
cd $NODE_HOME
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-byron-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-topology.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-shelley-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json
```

以下のコードを実行し **config.json**ファイルを更新します。  

* TraceBlockFetchDecisionsを「true」に変更します。

```bash
sed -i ${NODE_CONFIG}-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
```

環境変数を追加し、.bashrcファイルを更新します。

```bash
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> $HOME/.bashrc
source $HOME/.bashrc
```

## 🤖 4. ノード起動スクリプトを作成する。

起動スクリプトには、ディレクトリ、ポート番号、DBパス、構成ファイルパス、トポロジーファイルパスなど、カルダノノードを実行するために必要な変数が含まれています。

全行をコピーしコマンドラインに送信します。

{% tabs %}
{% tab title="リレーノード1" %}
```bash
cat > $NODE_HOME/startRelayNode1.sh << EOF 
#!/bin/bash
DIRECTORY=\$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```
{% endtab %}

{% tab title="ブロックプロデューサーノード" %}
```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
#!/bin/bash
DIRECTORY=\$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```
{% endtab %}
{% endtabs %}

## ✅ 5. ノードを起動します。

起動スクリプトに実行権限を付与し、ブロックチェーンの同期を開始します。

**リレーノードから実施します。**

{% tabs %}
{% tab title="リレーノード" %}
```bash
cd $NODE_HOME
chmod +x startRelayNode1.sh
./startRelayNode1.sh
```
{% endtab %}

{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
chmod +x startBlockProducingNode.sh
./startBlockProducingNode.sh
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
slot番号などが表示され、勢いよくログが流れていたら起動成功です  
ただ、このままでは画面を閉じるとノードが終了するので次の工程に移ってください。
{% endhint %}

{% hint style="info" %}
🛑 ノードを停止するには「Ctrl」+「c」を押します。
{% endhint %}

{% hint style="info" %}
✨ **ヒント**: 複数のノードをセットアップする場合、同期が完了したDBディレクトリを他のサーバにコピーすることにより、同期時間を節約することができます。
{% endhint %}

一旦ノードを停止します。
```
Ctrl+C
```

### 🛠 5-1.自動起動とバックグラウンド起動を設定する\(systemd＋tmux\)

先程のスクリプトだけでは、ターミナル画面を閉じるとノードが終了してしまうので、スクリプトをサービスとして登録し、自動起動設定と別セッションで起動するように設定しましょう

#### 🍰 ステークプールにsystemdを使用するメリット

1. メンテナンスや停電など、自動的にコンピュータが再起動したときステークプールを自動起動します。
2. クラッシュしたステークプールプロセスを自動的に再起動します。
3. ステークプールの稼働時間とパフォーマンスをレベルアップさせます。

#### 🛠 セットアップ手順

始める前にステークプールが停止しているか確認してください。

```bash
killall -s 2 cardano-node
```

以下のコードを実行して、ユニットファイルを作成します。

{% tabs %}
{% tab title="リレーノード1" %}
```bash
cat > $NODE_HOME/cardano-node.service << EOF
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target

[Service]
User            = $(whoami)
Type            = forking
WorkingDirectory= $NODE_HOME
ExecStart       = /usr/bin/tmux new -d -s cnode
ExecStartPost   = /usr/bin/tmux send-keys -t cnode $NODE_HOME/startRelayNode1.sh Enter
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
LimitNOFILE=32768
Restart=always
RestartSec=5

[Install]
WantedBy	= multi-user.target
EOF
```
{% endtab %}

{% tab title="ブロックプロデューサーノード" %}
```bash
cat > $NODE_HOME/cardano-node.service << EOF
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target

[Service]
User            = $(whoami)
Type            = forking
WorkingDirectory= $NODE_HOME
ExecStart       = /usr/bin/tmux new -d -s cnode
ExecStartPost   = /usr/bin/tmux send-keys -t cnode $NODE_HOME/startBlockProducingNode.sh Enter
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
LimitNOFILE=32768
Restart=always
RestartSec=5

[Install]
WantedBy	= multi-user.target
EOF
```
{% endtab %}
{% endtabs %}

`/etc/systemd/system`にユニットファイルをコピーして、権限を付与します。

```bash
sudo cp $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
```

```bash
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

次のコマンドを実行して、OS起動時にサービスの自動起動を有効にします。

```text
sudo systemctl daemon-reload
sudo systemctl enable cardano-node
sudo systemctl start cardano-node
```

[5-2.gLiveView ノードステータスモニターをインストールします](guide-how-to-build-a-haskell-stakepool-node.md#5-2-gliveview-ndosuttasumonitwoinsutrushimasu)に進んでください。

{% hint style="danger" %}
以下は、systemdを有効活用するためのコマンドです。  
必要に応じで実行するようにし、一連の流れで実行しないでください
{% endhint %}

\*\*\*\*⛓ **システム起動後に、ログモニターを表示します**

```text
tmux a -t cnode
```

**バックグラウンド起動中のセッション(別画面)を確認する**

```text
tmux ls
```

#### 🚧 セッションをバックグラウンド実行に切り替え、コマンドラインを表示します。

```text
press Ctrl + b を押した後、すぐに d (デタッチ)
```

#### 🔄 ノードサービスを再起動します。

```text
sudo systemctl reload-or-restart cardano-node
```

#### 🛑 ノードサービスを停止します。

```text
sudo systemctl stop cardano-node
```

#### 🗄 ログのフィルタリング

```bash
journalctl --unit=cardano-node --since=yesterday
journalctl --unit=cardano-node --since=today
journalctl --unit=cardano-node --since='2020-07-29 00:00:00' --until='2020-07-29 12:00:00'
```

### 🛠 5-2.gLiveView ノードステータスモニターをインストールします

現在のcardano-nodeはログが流れる画面で、何が表示されているのかよくわかりません。  
それを視覚的に確認できるツールが**gLiveView**です。


{% hint style="info" %}
gLiveViewは重要なノードステータス情報を表示し、systemdサービスとうまく連携します。1.23.0から正式にLiveViewが削除されgLiveViewは代替ツールとして利用できます。このツールを作成した [Guild Operators](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview) の功績によるものです。
{% endhint %}

Guild LiveViewをインストールします。

```bash
mkdir $NODE_HOME/scripts
cd $NODE_HOME/scripts
sudo apt install bc tcptraceroute -y
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh
```

**env** ファイルによってファイル構成を指定できます。  
ノードのポート番号を6000以外に設定している場合は、envファイルを開いて修正してください。   

```bash
sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```

Guild Liveviewを起動します。

```text
./gLiveView.sh
```
{% hint style="info" %}
**このツールを立ち上げてもノードは起動しません。ノードは別途起動しておく必要があります**  
リレー／BPは自動判別されます。  
リレーノードでは基本情報に加え、トポロジー接続状況を確認できます。  
BPノードでは基本情報に加え、KES有効期限、ブロック生成状況を確認できます。  

[p]リレーノード用リモートピア分析について
ピアにpingを送信する際ICMPpingを使用します。リモートピアのファイアウォールがICMPトラフィックを受け付ける場合のみ機能します。
{% endhint %}

詳しくは開発元のドキュメントを参照してください [official Guild Live View docs.](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview)

この画面が表示され、ノードが同期したら準備完了です。

## 🔮 6. ブロックプロデューサーノードを構築する

{% hint style="info" %}
手順１～5までをブロックプロデューサー用サーバーで実施してから、以下を実施します。
{% endhint %}

{% hint style="info" %}
ブロックプロデューサーノードは、ブロック生成に必要なペアキー \(cold keys, KES hot keys and VRF hot keys\)を用いて起動します。リレーノードのみに接続します。
{% endhint %}

{% hint style="info" %}
一方で、リレーノードはキーを所有していないため、ブロック生成はできません。その代わり、他のリレーノードとの繋がりを持ち最新スロットを取得します。
{% endhint %}

{% hint style="success" %}
このマニュアルでは、2つのサーバー上に1ノードづつ構築します。1つのノードはブロックプロデューサーノード、もう1つのノードはリレーノード1という名前のリレーノードになります。
{% endhint %}

{% hint style="danger" %}
**topology.json** ファイルの構成について

* リレーノードでは、パプリックノード \(IOHKや他のリレーノード\) 及び、自身の

  ブロックプロデューサーノード情報を記述します。

* ブロックプロデューサーノードでは、自身のリレーノード情報のみ記述します。
{% endhint %}

**「＊」はBPノードのパプリックIPアドレス**に置き換えて下さい

{% tabs %}
{% tab title="リレーノード" %}
```bash
cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "relays-new.cardano-mainnet.iohk.io",
        "port": 3001,
        "valency": 2
      },
      {
        "addr": "***.**.**.**",
        "port": 6000,
        "valency": 1
      }
    ]
  }
EOF
```
{% endtab %}
{% endtabs %}

リレーノードを再起動する

```text
sudo systemctl reload-or-restart cardano-node
```

自身のブロックプロデューサーノード上で以下のコマンドを実行します。 **「＊」はリレーノードのパプリックIPアドレス**に置き換えてください。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "***.**.**.**",
        "port": 6000,
        "valency": 1
      }
    ]
  }
EOF
```
{% endtab %}
{% endtabs %}

BPノードを再起動する

```text
sudo systemctl reload-or-restart cardano-node
```

## 🔏 7. エアギャップオフラインマシンを構成する

{% hint style="info" %}
エアギャップオフラインマシンは「コールド環境」と呼ばれコンピュータネットワークにおいてセキュリティを高める方法の一つ。 安全にしたいコンピュータやネットワークを、インターネットや安全でないLANといったネットワークから物理的に隔離することを指す。

* キーロギング攻撃、マルウエア／ウイルスベースの攻撃、その他ファイアウォールやセキュリティーの悪用から保護します。
* 有線・無線のインターネットには接続しないでください。
* ネットワーク上にあるVMマシンではありません。
* エアギャップについて更に詳しく知りたい場合は、[こちら](https://ja.wikipedia.org/wiki/%E3%82%A8%E3%82%A2%E3%82%AE%E3%83%A3%E3%83%83%E3%83%97)を参照下さい。
{% endhint %}

エアギャップオフラインマシン上で手順1～2をセットアップした後、以下のパスを環境変数にセットします。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
echo export NODE_HOME=$HOME/cardano-my-node >> $HOME/.bashrc
source $HOME/.bashrc
mkdir -p $NODE_HOME
```
{% endtab %}
{% endtabs %}

{% hint style="danger" %}
最も安全な構成を維持するには、USBなどを利用してホット環境とコールド環境間でファイルを物理的に移動することが望ましいです。
{% endhint %}

## ⚙ 8. ブロックプロデューサーキーを生成する。

{% hint style="info" %}
以下の項目を実施する前にBPノードが起動しているか確認してください。
```
tmux a -t cnode
```
ログが流れていればノードが起動しています。
Ctrl+B を押したあとにdを押すと前の画面に戻ります。
{% endhint %}

ブロックプロデューサーノードでは [Shelley台帳仕様書](https://hydra.iohk.io/build/2473732/download/1/ledger-spec.pdf)で定義されている、３つのキーを生成する必要があります。

* ステークプールのコールドキー \(node.cert\)
* ステークプールのホットキー \(kes.skey\)
* ステークプールのVRFキー \(vrf.skey\)

まずは、KESペアキーを作成します。 \(KES=Key Evolving Signature\)

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
KESキーは、キーを悪用するハッカーからステークプールを保護するために作成され、90日ごとに再生成する必要があります。
{% endhint %}

{% hint style="danger" %}
🔥 **コールドキーは常にエアギャップオフラインマシンで生成および保管する必要があります** コールドキーは次のパスに格納されるようにします。 `$HOME/cold-keys.`
{% endhint %}

コールドキーを格納するディレクトリを作成します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```text
mkdir $HOME/cold-keys
pushd $HOME/cold-keys
```
{% endtab %}
{% endtabs %}

コールドキーのペアキーとカウンターファイルを作成します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cardano-cli node key-gen \
    --cold-verification-key-file node.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter

chmod 400 node.vkey
chmod 400 node.skey
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
すべてのキーを別の安全なストレージデバイスにバックアップしましょう！複数のバックアップを作成することをおすすめします。
{% endhint %}

ジェネシスファイルからslotsPerKESPeriodを出力します。

{% hint style="warning" %}
続行する前に、ノードをブロックチェーンと完全に同期する必要があります。 同期が途中の場合、正しいslotsPerKESPeriodを取得できません。 あなたのノードが完全に同期されたことを確認するには、こちらのサイト[https://pooltool.io/](https://pooltool.io/)で自身の同期済みエポックとスロットが一致しているかをご確認ください。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
echo slotsPerKESPeriod: ${slotsPerKESPeriod}
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo slotNo: ${slotNo}
```
{% endtab %}
{% endtabs %}

スロット番号をslotsPerKESPeriodで割り、kesPeriodを算出します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
echo kesPeriod: ${kesPeriod}
startKesPeriod=${kesPeriod}
echo startKesPeriod: ${startKesPeriod}
```
{% endtab %}
{% endtabs %}

これにより、プール運用証明書を生成することができます。

**kes.vkey** をエアギャップオフラインマシンのcardano-my-nodeディレクトリにコピーします。

{% hint style="info" %}
ステークプールオペレータは、プールを実行する権限があることを確認するための運用証明書を発行する必要があります。証明書には、オペレータの署名が含まれプールに関する情報（アドレス、キーなど）が含まれます。
{% endhint %}

**XXX**の部分を上記で算出した数値（startKesPeriodの値）に置き換えます。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
cardano-cli node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period XXX \
    --out-file node.cert
```
{% endtab %}
{% endtabs %}

**node.cert** をブロックプロデューサノードのcardano-my-nodeディレクトリにコピーします。

VRFペアキーを作成します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
cardano-cli node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
```
{% endtab %}
{% endtabs %}

vrfキーのアクセス権を読み取り専用に更新します。

```text
chmod 400 vrf.skey
```

次のコマンドを実行して一旦ノードを停止します。  
（以下のコマンドは、8-1を実施している前提のコマンドです）

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
sudo systemctl stop cardano-node
```
{% endtab %}
{% endtabs %}

起動スクリプトにKES、VRF、運用証明書のパスを追記し更新します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
DIRECTORY=\$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
KES=\${DIRECTORY}/kes.skey
VRF=\${DIRECTORY}/vrf.skey
CERT=\${DIRECTORY}/node.cert
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG} --shelley-kes-key \${KES} --shelley-vrf-key \${VRF} --shelley-operational-certificate \${CERT}
EOF
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
ステークプールを運用するには、KES、VRFキー、および運用証明書が必要です。
{% endhint %}

ブロックプロデューサーノードを起動します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
sudo systemctl start cardano-node
```
{% endtab %}
{% endtabs %}

## 🔐 9. 各種アドレス用のキーを作成します。\(payment／stake用アドレス\)

{% hint style="danger" %}
ステークプール登録後、やり直しは出来ません。
{% endhint %}

まずは、プロトコルパラメータを取得します。

{% hint style="info" %}
このエラーが出た場合は、ノードが同期を開始するまで待つか、手順３に戻り「db/socket」へのパスが追加されているか確認してください。

`cardano-cli: Network.Socket.connect: : does not exist (No such file or directory)`
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
cardano-cli query protocol-parameters \
    --mainnet \
    --out-file params.json
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
paymentキーは支払い用アドレスに使用され、stakeキーはプール委任アドレス用の管理に使用されます。
{% endhint %}

{% hint style="danger" %}
🔥 **運用上のセキュリティに関する重要なアドバス:** キーの生成はエアギャップオフラインマシンで生成する必要があり、インターネット接続が無くても生成可能です。

ホット環境\(オンライン\)で必要とする手順は以下の内容のみです。

* 現在のスロット番号を取得する
* アドレスの残高を照会する
* トランザクションの送信
{% endhint %}



{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
以下は、エアギャップオフラインマシンで行ってください。 支払い用アドレスのペアキーを作成します。: `payment.skey` & `payment.vkey`

```bash
cd $NODE_HOME
cardano-cli address key-gen \
    --verification-key-file payment.vkey \
    --signing-key-file payment.skey
```

ステークアドレス用のペアキーを作成します。 `stake.skey` & `stake.vkey`

```bash
cardano-cli stake-address key-gen \
    --verification-key-file stake.vkey \
    --signing-key-file stake.skey
```

ステークアドレス検証キーから、ステークアドレスファイルを作成します。 `stake.addr`

```bash
cardano-cli stake-address build \
    --stake-verification-key-file stake.vkey \
    --out-file stake.addr \
    --mainnet
```

ステークアドレスに委任する支払い用アドレスを作成します。

```bash
cardano-cli address build \
    --payment-verification-key-file payment.vkey \
    --stake-verification-key-file stake.vkey \
    --out-file payment.addr \
    --mainnet
```

上書きされないようパーミッションを変更する。

```bash
chmod 400 payment.vkey
chmod 400 payment.skey
chmod 400 stake.vkey
chmod 400 stake.skey
chmod 400 stake.addr
chmod 400 payment.addr
```

**※プール運営開始後に、上記の処理を実行するとアドレスが上書きされるので注意してください。**
{% endtab %}

<!--{% tab title="Mnemonic Method" %}
{% hint style="info" %}
このプロセスを提案してくれた [ilap](https://gist.github.com/ilap/3fd57e39520c90f084d25b0ef2b96894)のクレジット表記です。
{% endhint %}

{% hint style="success" %}
**この方法によるメリット**: 委任をサポートするウォレット（ダイダロス、ヨロイなど）からプール報酬を確認することが可能になります。
{% endhint %}

15ワードまたは24ワード長のシェリー互換ニーモニックを、オフラインマシンのダイダロスまたはヨロイを使用して作成します。

ブロックプロデューサーノードに `cardano-wallet`をダウンロードします。

```bash
###
### On ブロックプロデューサーノード,
###
cd $NODE_HOME
wget https://hydra.iohk.io/build/3662127/download/1/cardano-wallet-shelley-2020.7.28-linux64.tar.gz
```

正規ウォレットであることを確認するために、SHA256チェックを実行します。

```bash
echo "f75e5b2b4cc5f373d6b1c1235818bcab696d86232cb2c5905b2d91b4805bae84 *cardano-wallet-shelley-2020.7.28-linux64.tar.gz" | shasum -a 256 --check
```

チェックが成功した例：

> cardano-wallet-shelley-2020.7.28-linux64.tar.gz: OK

{% hint style="danger" %}
SHA256チェックで **OK**が出た場合のみ続行してください。
{% endhint %}

USBキーまたはその他のリムーバブルメディアを介して、カルダノウォレットをエアギャップオフラインマシンに転送します。

ウォレットファイルを抽出してクリーンアップします。

```bash
###
### On エアギャップオフラインマシン,
###
tar -xvf cardano-wallet-shelley-2020.7.28-linux64.tar.gz
rm cardano-wallet-shelley-2020.7.28-linux64.tar.gz
```

スクリプトファイルを作成します。`extractPoolStakingKeys.sh`

```bash
###
### On エアギャップオフラインマシン,
###
cat > extractPoolStakingKeys.sh << HERE
#!/bin/bash 

CADDR=\${CADDR:=\$( which cardano-address )}
[[ -z "\$CADDR" ]] && ( echo "cardano-address cannot be found, exiting..." >&2 ; exit 127 )

CCLI=\${CCLI:=\$( which cardano-cli )}
[[ -z "\$CCLI" ]] && ( echo "cardano-cli cannot be found, exiting..." >&2 ; exit 127 )

OUT_DIR="\$1"
[[ -e "\$OUT_DIR"  ]] && {
           echo "The \"\$OUT_DIR\" is already exist delete and run again." >&2 
           exit 127
} || mkdir -p "\$OUT_DIR" && pushd "\$OUT_DIR" >/dev/null

shift
MNEMONIC="\$*"

# Generate the master key from mnemonics and derive the stake account keys 
# as extended private and public keys (xpub, xprv)
echo "\$MNEMONIC" |\
"\$CADDR" key from-recovery-phrase Shelley > root.prv

cat root.prv |\
"\$CADDR" key child 1852H/1815H/0H/2/0 > stake.xprv

cat root.prv |\
"\$CADDR" key child 1852H/1815H/0H/0/0 > payment.xprv

TESTNET=0
MAINNET=1
NETWORK=\$MAINNET

cat payment.xprv |\
"\$CADDR" key public | tee payment.xpub |\
"\$CADDR" address payment --network-tag \$NETWORK |\
"\$CADDR" address delegation \$(cat stake.xprv | "\$CADDR" key public | tee stake.xpub) |\
tee base.addr_candidate |\
"\$CADDR" address inspect
echo "Generated from 1852H/1815H/0H/{0,2}/0"
cat base.addr_candidate
echo

# XPrv/XPub conversion to normal private and public key, keep in mind the 
# keypars are not a valind Ed25519 signing keypairs.
TESTNET_MAGIC="--testnet-magic 42"
MAINNET_MAGIC="--mainnet"
MAGIC="\$MAINNET_MAGIC"

SESKEY=\$( cat stake.xprv | bech32 | cut -b -128 )\$( cat stake.xpub | bech32)
PESKEY=\$( cat payment.xprv | bech32 | cut -b -128 )\$( cat payment.xpub | bech32)

cat << EOF > stake.skey
{
    "type": "StakeExtendedSigningKeyShelley_ed25519_bip32",
    "description": "",
    "cborHex": "5880\$SESKEY"
}
EOF

cat << EOF > payment.skey
{
    "type": "PaymentExtendedSigningKeyShelley_ed25519_bip32",
    "description": "Payment Signing Key",
    "cborHex": "5880\$PESKEY"
}
EOF

"\$CCLI" shelley key verification-key --signing-key-file stake.skey --verification-key-file stake.evkey
"\$CCLI" shelley key verification-key --signing-key-file payment.skey --verification-key-file payment.evkey

"\$CCLI" shelley key non-extended-key --extended-verification-key-file payment.evkey --verification-key-file payment.vkey
"\$CCLI" shelley key non-extended-key --extended-verification-key-file stake.evkey --verification-key-file stake.vkey


"\$CCLI" shelley stake-address build --stake-verification-key-file stake.vkey \$MAGIC > stake.addr
"\$CCLI" shelley address build --payment-verification-key-file payment.vkey \$MAGIC > payment.addr
"\$CCLI" shelley address build \
    --payment-verification-key-file payment.vkey \
    --stake-verification-key-file stake.vkey \
    \$MAGIC > base.addr

echo "Important the base.addr and the base.addr_candidate must be the same"
diff base.addr base.addr_candidate
popd >/dev/null
HERE
```

バイナリーファイルを使用するには、アクセス権を追加してパスをエクスポートします。

```bash
###
### On エアギャップオフラインマシン,
###
chmod +x extractPoolStakingKeys.sh
export PATH="$(pwd)/cardano-wallet-shelley-2020.7.28:$PATH"
```

キーを抽出し、ニーモニックフレーズで更新します。

```bash
###
### On エアギャップオフラインマシン,
###
./extractPoolStakingKeys.sh extractedPoolKeys/ <15|24-word length mnemonic>
```

{% hint style="danger" %}
**重要**: **base.addr** と **base.addr\_candidate** は同じでなければなりません。
{% endhint %}

新しいステークキーは次のフォルダーにあります。 `extractedPoolKeys/`

`paymentとstake`で使用するペアキーを `$NODE_HOME`に移動します。

```bash
###
### On エアギャップオフラインマシン,
###
cd extractedPoolKeys/
cp stake.vkey stake.skey stake.addr payment.vkey payment.skey base.addr $NODE_HOME
cd $NODE_HOME
#Rename to base.addr file to payment.addr
mv base.addr payment.addr
```

{% hint style="info" %}
**payment.addr**はあなたのプール誓約金を保持しているアドレスになります。
{% endhint %}

ニーモニックフレーズを保護するには、履歴とファイルを削除します。

```bash
###
### On エアギャップオフラインマシン,
###
history -c && history -w
rm -rf $NODE_HOME/cardano-wallet-shelley-2020.7.28
```

すべてのターミナルウィンドウを閉じ、履歴のない新しいウィンドウを開きます。

{% hint style="success" %}
いかがでしょうか？ウォレットでプール報酬を確認することが可能になりました。
{% endhint %}
{% endtab %} -->
{% endtabs %}

次のステップは、あなたの支払いアドレスに送金する手順です。

**payment.addr** をブロックプロデューサノードのcardano-my-nodeディレクトリにコピーします。

{% tabs %}
{% tab title="メインネット" %}
以下のウォレットアドレスから送金が可能です。

* ダイダロス / ヨロイウォレット
* もしITNに参加している場合は、キーを変換できます。

次のコードを実行し。支払いアドレスを表示させ、このアドレスに送金します。

```bash
echo "$(cat payment.addr)"
```
{% endtab %}

{% tab title="メインネット候補版" %}
以下のウォレットアドレスから送金が可能です。

* [テストネット用口座](https://testnets.cardano.org/en/shelley/tools/faucet/)
* バイロンメインネット資金 
* INTに参加している場合は、キーを変換できます。 

次のコードを実行し。支払いアドレスを表示させます。

```text
echo "$(cat payment.addr)"
```
{% endtab %}

{% tab title="Shelley テストネット" %}
[テストネット用口座](https://testnets.cardano.org/en/shelley/tools/faucet/)にあなたの支払い用アドレスをリクエストします。

次のコードを実行し。支払いアドレスを表示させます。

```text
echo "$(cat payment.addr)"
```

このアドレスを上記ページのリクエスト欄に貼り付けます。

{% hint style="info" %}
シェリーテストネット用口座は24時間ごとに100,000fADAを提供します。
{% endhint %}
{% endtab %}
{% endtabs %}

支払い用アドレスに送金後、残高を確認してください。

{% hint style="danger" %}
続行する前に、ノードをブロックチェーンと完全に同期させる必要があります。完全に同期されていない場合は、残高が表示されません。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet
```
{% endtab %}
{% endtabs %}

次のように表示されます。

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        1000000000
```

## 👩 10. ステークアドレスを登録します。

{% hint style="danger" %}
ステークプール登録後、やり直しは出来ません。
{% endhint %}

`stake.vkey`を使用して、`stake.cert`証明証を作成します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
cardano-cli stake-address registration-certificate \
    --stake-verification-key-file stake.vkey \
    --out-file stake.cert
```
{% endtab %}
{% endtabs %}

**stake.cert** をブロックプロデューサーノードのcardano-my-nodeディレクトリにコピーします。
ttlパラメータを設定するには、最新のスロット番号を取得する必要があります。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

残高とUTXOを出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
{% endtab %}
{% endtabs %}

keyDepositの値を出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
keyDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakeAddressDeposit')
echo keyDeposit: $keyDeposit
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
ステークアドレス証明書の登録には2,000,000 lovelace \(2ADA\)が必要です。
{% endhint %}

build-rawトランザクションコマンドを実行します。

{% hint style="info" %}
**invalid-hereafter**の値は、現在のスロット番号よりも大きくなければなりません。この例では現在のスロット番号＋10000を使用します。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp \
    --certificate stake.cert
```
{% endtab %}
{% endtabs %}

現在の最低手数料を計算します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
残高が、手数料+keyDepositの値よりも大きいことを確認してください。そうしないと機能しません。
{% endhint %}

計算結果を出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
txOut=$((${total_balance}-${keyDeposit}-${fee}))
echo Change Output: ${txOut}
```
{% endtab %}
{% endtabs %}

ステークアドレスを登録するトランザクションファイルを作成します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file stake.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

**tx.raw**をエアギャップオフラインマシンのcardano-my-nodeディレクトリにコピーします。

paymentとstakeの秘密鍵でトランザクションファイルに署名します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

**tx.signed**をブロックプロデューサーノードcardano-my-nodeディレクトリにコピーします。

署名されたトランザクションを送信します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

## 📄 11. ステークプールを登録します。

{% hint style="warning" %}
こちらの手順は初回プール登録時のみ有効です。  
プール登録後にメタ情報、誓約、固定費、変動費、リレー情報を変更する場合は、[18.4](guide-how-to-build-a-haskell-stakepool-node.md#184-prumetayamarginno)の変更手順を実施してください。
{% endhint %}

{% hint style="warning" %}
ステークプール登録には**500ADA**の登録料が必要です。  
payment.addrに入金されている必要があります。
{% endhint %}

## 11-1.プール情報のJSONファイルを作成してプールのメタデータを作成します。

{% hint style="info" %}
まだホームページがない場合は「jsonファイルをGithubでホストする方法」を実施してください
{% endhint %}

{% tabs %}
{% tab title="jsonファイルをGithubでホストする方法" %}

1.Githubアカウントを作成しログインします [https://github.com/](https://github.com/)  

2.右上の＋マークをクリックし**new repository** をクリックします。  

3.**Repository name**に任意のリポジトリ名を入力し、**Create repository**をクリックします。  

4.小さい文字で書かれた"**creating a new file**"をクリックします。  

![](.gitbook/assets/git1.png)

5.ファイル名を **poolMetaData.json** として入力し **json** コンテンツを貼り付けます。
{% hint style="warning" %}
下記は参考フォーマットとなります。ご自身のプール名、Ticker名に書き換えてください  
まだhomepageアドレスが無い場合は、ご自身のTwitterアドレスでも大丈夫です。
{% endhint %}
![](.gitbook/assets/git2.png)

```bash
{
"name": "MyPoolName",
"description": "My pool description",
"ticker": "MPN",
"homepage": "https://myadapoolnamerocks.com"
}
```
{% hint style="warning" %}
**ticker**名の長さは3～5文字にする必要があります。文字はA-Zと0-9のみで構成する必要があります。  
**description**の長さは255文字以内(255byte)となります。（ひらがな、漢字、カタカナは1文字2byte）
{% endhint %}

6.**Commit new file**をクリックします。

![](.gitbook/assets/git3.png)

7.作成したファイルの名前をクリックします。

8.**Rawボタン**をクリックします。

1. 「**https://raw**」から始まるURLをコピーします。

> 例: [https://raw.githubusercontent.com/coincashew/test/master/poolMetaData.json](https://raw.githubusercontent.com/coincashew/test/master/poolMetaData.json)

10.URLは64文字より短くする必要があります。 [https://git.io/](https://git.io/) を使用してURLを短縮します。

11.9でコピーしたURLを貼り付けます。

12.短縮されたURLをpool.cert作成時の`--metadata-url` に記述します。

> 例:  
> --metadata-url https://git.io/JUcnl

13．**ブロックプロデューサーノード**でjsonファイルをダウンロードし、ハッシュ値を計算する。  
{% hint style="warning" %}
下記のURLを12で作成した**短縮URL**に置き換えてから実行してください
{% endhint %}

```bash
cd $NODE_HOME
wget -O poolMetaData.json https://git.io/JUcnl
```

メタデータファイルのハッシュ値を計算します。

```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```


{% endtab %}


{% tab title="ご自身のホームページサーバでホストする方法" %}

{% hint style="warning" %}
下記は参考フォーマットとなります。ご自身のプール名、Ticker名に書き換えてから、ターミナルで実行してください。  
まだhomepageアドレスが無い場合は、ご自身のTwitterアドレスでも大丈夫です。
{% endhint %}

**ブロックプロデューサーノード**でjsonファイルを作成し、ハッシュ値を計算する。
{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
cat > poolMetaData.json << EOF
{
"name": "MyPoolName",
"description": "My pool description",
"ticker": "MPN",
"homepage": "https://myadapoolnamerocks.com"
}
EOF
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
**ticker**名の長さは3～5文字にする必要があります。文字はA-Zと0-9のみで構成する必要があります。  
**description**の長さは255文字以内\(255byte\)となります。（ひらがな、漢字、カタカナは1文字2byte）
{% endhint %}

メタデータファイルのハッシュ値を計算します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}
**poolMetaData.json**をあなたの公開用WEBサーバへアップロードしてください。 
{% endtab %}
{% endtabs %}
  
**poolMetaDataHash.txt**をエアギャップオフラインマシンへコピーしてください  
 


最小プールコストを出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
minPoolCost=$(cat $NODE_HOME/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
minPoolCostは 340000000 lovelace \(340 ADA\)です。
{% endhint %}

ステークプールの登録証明書を作成します。 **メタデータのURL**と**リレーノード情報**を追記し構成します。リレーノード構成にはDNSベースまたはIPベースのどちらかを選択できます。

{% hint style="warning" %}
**metadata-url**は64文字以内とし、あなたの環境に合わせて修正してください。
{% endhint %}

ブロックプロデューサーノードにある**vrf.vkey**をエアギャップオフラインマシンcardano-my-nodeディレクトリにコピーします。

pool.certを作成する

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000 \
    --pool-cost 345000000 \
    --pool-margin 0.15 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --pool-relay-ipv4 <リレーノードのパプリックIPへ書き換え> \
    --pool-relay-port 6000 \
    --metadata-url <poolMetaData.jsonをアップロードしたURLを記述> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
ここでは345ADAの固定費と15%のプールマージン、100ADAの誓約を設定しています。 ご自身の設定値に変更してください。
{% endhint %}

{% hint style="info" %}
上記のpool.cert作成時、自身のリレー情報を以下の3パターンの記述方法があります。 ノード管理を簡単にするために、DNSベースのリレー設定をお勧めします。 もしリレーサーバを変更する場合、IPアドレスが変わるため、その都度登録証明書を再送する必要がありますがDNSベースで登録しておけば、IPアドレスが変更になってもお使いのドメイン管理画面にてIPアドレスを変更するだけで完了します。
{% endhint %}

{% hint style="info" %}
#### \*\*\*\*✨ **複数のリレーノードを構成する記述方法**

**DNSレコードに1つのエントリーの場合**

```bash
    --single-host-pool-relay <your first relay node address> \
    --pool-relay-port 6000 \
    --single-host-pool-relay <your Second relay node address> \
    --pool-relay-port 6000 \
```

**ラウンドロビンDNSベース** [**SRV DNS record**](https://support.dnsimple.com/articles/srv-record/)の場合

```bash
    --multi-host-pool-relay <your first relay node address> \
    --pool-relay-port 6000 \
```

**IPアドレス, 1ノード1IPアドレスの場合**

```bash
    --pool-relay-port 6000 \
    --pool-relay-ipv4 <リレーノードのパプリックIPへ書き換え> \
    --pool-relay-port 6000 \
    --pool-relay-ipv4 <リレーノードのパプリックIPへ書き換え> \
```
{% endhint %}

ステークプールにステークを誓約するファイルを作成します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
```
{% endtab %}
{% endtabs %}

**pool.cert**と**deleg.cert**をブロックプロデューサーノードcardano-my-nodeディレクトリにコピーします。

{% hint style="info" %}
自分のプールに資金を預けることを**Pledge\(誓約\)**と呼ばれます

* あなたの支払い用アドレスの残高はPledge額よりも大きい必要があります。
* 誓約金を宣言しても、実際にはどこにも移動されていません。payment.addrに残ったままです。
* 誓約を行わないと、ブロック生成の機会を逃し委任者は報酬を得ることができません。
* あなたの誓約金はブロックされません。いつでも自由に取り出せます。
{% endhint %}

**ttl**パラメータを設定するには、最新のスロット番号を取得する必要があります。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

残高と**UTXOs**を出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
{% endtab %}
{% endtabs %}

poolDepositを出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
poolDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakePoolDeposit')
echo poolDeposit: $poolDeposit
```
{% endtab %}
{% endtabs %}

build-rawトランザクションコマンドを実行します。

{% hint style="info" %}
**invalid-hereafter**の値は、現在のスロット番号よりも大きくなければなりません。この例では、現在のスロット+10000を使用します。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${poolDeposit}))  \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

最低手数料を計算します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
payment.addrの残高が、手数料コスト+poolDeposit\(500ADA\)よりも大きいことを確認してください。小さい場合は機能しません。
{% endhint %}

計算結果を出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
txOut=$((${total_balance}-${poolDeposit}-${fee}))
echo txOut: ${txOut}
```
{% endtab %}
{% endtabs %}

トランザクションファイルを作成します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

**tx.raw**をエアギャップオフラインマシンのcardano-my-nodeディレクトリにコピーします。

トランザクションに署名します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

**tx.signed**ブロックプロデューサーノードcardano-my-nodeディレクトリにコピーします。

トランザクションを送信します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

## 🐣 12. ステークプールが機能しているか確認します。

ステークプールIDは以下のように出力できます。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cardano-cli stake-pool id --cold-verification-key-file $HOME/cold-keys/node.vkey --output-format hex > stakepoolid.txt
```
{% endtab %}
{% endtabs %}

**stakepoolid.txt**をブロックプロデューサーノードcardano-my-nodeディレクトリにコピーします。

このファイルを用いて、自分のステークプールがブロックチェーンに登録されているか確認します。

```text
cat stakepoolid.txt
```

表示されたPoolIDであなたのステークプールがブロックチェーンに登録されているか、次のサイトで確認することが出来ます。  
[https://pooltool.io/](https://pooltool.io/)

## ⚙ 13. トポロジーファイルを構成する。

{% hint style="info" %}
この項目はリレーノードで実施します。  
**リレーノードが起動しているか確認してください** 例）tmux a -t cnode
{% endhint %}

{% hint style="info" %}
バージョン1.25.1ではP2P\(ピア・ツー・ピア\)ノードを自動検出しないため、手動でトポロジーを構成する必要があります。この手順をスキップすると生成したブロックがブロックチェーン外で孤立するため、必須の設定項目となります。
{% endhint %}

{% tabs %}
{% tab title="topologyUpdater.shで更新する場合" %}
### 🚀 topologyUpdater.shを使用してリレーノードを公開する

{% hint style="info" %}
この方法を提案して頂いた [GROWPOOL](https://twitter.com/PoolGrow) および [CNTOOLS Guild OPS](https://cardano-community.github.io/guild-operators/#/Scripts/topologyupdater) へのクレジット表記。
{% endhint %}

ノード情報をトポロジーフェッチリストに公開するスクリプト「`topologyUpdater.sh`」を作成します。 7行目の"CHANGE ME"をリレーノードのIPアドレスに変えます。  
※26行目の"CHANGE ME"はそのままでお願いします。

以下コードをリレー用サーバで実施してください。

```bash
cat > $NODE_HOME/topologyUpdater.sh << EOF
#!/bin/bash
# shellcheck disable=SC2086,SC2034

USERNAME=$(whoami)
CNODE_PORT=6000
CNODE_HOSTNAME="xxx.xxx.xxx.xx"  #リレーのIPアドレスに変更する
CNODE_BIN="/usr/local/bin"
CNODE_HOME=$NODE_HOME
CNODE_LOG_DIR="\${CNODE_HOME}/logs"
GENESIS_JSON="\${CNODE_HOME}/${NODE_CONFIG}-shelley-genesis.json"
NETWORKID=\$(jq -r .networkId \$GENESIS_JSON)
CNODE_VALENCY=1   # optional for multi-IP hostnames
NWMAGIC=\$(jq -r .networkMagic < \$GENESIS_JSON)
[[ "\${NETWORKID}" = "Mainnet" ]] && HASH_IDENTIFIER="--mainnet" || HASH_IDENTIFIER="--testnet-magic \${NWMAGIC}"
[[ "\${NWMAGIC}" = "1097911063" ]] && NETWORK_IDENTIFIER="--mainnet" || NETWORK_IDENTIFIER="--testnet-magic \${NWMAGIC}"
 
export PATH="\${CNODE_BIN}:\${PATH}"
export CARDANO_NODE_SOCKET_PATH="\${CNODE_HOME}/db/socket"
 
blockNo=\$(/usr/local/bin/cardano-cli query tip \${NETWORK_IDENTIFIER} | jq -r .block )
 
# Note:
# if you run your node in IPv4/IPv6 dual stack network configuration and want announced the
# IPv4 address only please add the -4 parameter to the curl command below  (curl -4 -s ...)
if [ "\${CNODE_HOSTNAME}" != "CHANGE ME" ]; then
  T_HOSTNAME="&hostname=\${CNODE_HOSTNAME}"
else
  T_HOSTNAME=''
fi

if [ ! -d \${CNODE_LOG_DIR} ]; then
  mkdir -p \${CNODE_LOG_DIR};
fi

curl -4 -s "https://api.clio.one/htopology/v1/?port=\${CNODE_PORT}&blockNo=\${blockNo}&valency=\${CNODE_VALENCY}&magic=\${NWMAGIC}\${T_HOSTNAME}" | tee -a \$CNODE_LOG_DIR/topologyUpdater_lastresult.json
EOF
```

権限を追加し、「topologyUpdater.sh」を実行します。

```bash
###
### On relaynode1
###
cd $NODE_HOME
chmod +x topologyUpdater.sh
./topologyUpdater.sh
```

`topologyUpdater.sh`が正常に実行された場合、以下の形式が表示されます。

> `{ "resultcode": "201", "datetime":"2020-07-28 01:23:45", "clientIp": "1.2.3.4", "iptype": 4, "msg": "nice to meet you" }`

{% hint style="info" %}
スクリプトが実行されるたびに、**`$NODE_HOME/logs`**にログが作成されます。 ※`topologyUpdater.sh`は1時間以内に2回以上実行しないで下さい。最悪の場合ブラックリストに追加されることがあります。
{% endhint %}

crontabジョブを追加し、「topologyUpdater.sh」が自動的に実行されるように設定します。

以下のコードは毎時22分に実行されるように指定しています。\(上記スクリプトを実行した時間\(分\)より以前の分を指定して下さい。\)

{% hint style="danger" %}
以下のコードは複数回実行しないで下さい。  
複数回実行した場合、同じ時間に複数自動実行されるスケジュールが登録されてしまうので、ブラックリストに入ります。
{% endhint %}

```bash
###
### On relaynode1
###
cat > $NODE_HOME/crontab-fragment.txt << EOF
22 * * * * ${NODE_HOME}/topologyUpdater.sh
EOF
crontab -l | cat - crontab-fragment.txt >crontab.txt && crontab crontab.txt
rm crontab-fragment.txt
```

> no crontab for ~~ というメッセージが表示されることがありますが、Cron初回設定時に表示されるメッセージとなりますので、問題ありません。

```text
crontab -l
```

以下が返り値として表示されればOK。

> "22  __  __ /home/_\*_/cardano-my-node/topologyUpdater.sh"

{% hint style="success" %}
4時間の間で4回スクリプトが実行された後に、ノードがオンライン状態で有ることが認められた場合にノードIPがトポロジーフェッチリストに登録されます。
{% endhint %}

### トポロジーフェッチリストに登録されたか確認する

```bash
cd $NODE_HOME/logs
cat topologyUpdater_lastresult.json
```

以下の内容が表示されていれば登録成功  
resultcodeが400番台・500番台の場合は、サーバ設定に問題があります。

```text
{ "resultcode": "201", "datetime":"2021-01-10 18:30:06", "clientIp": "000.000.000.000", "iptype": 4, "msg": "nice to meet you" }
{ "resultcode": "203", "datetime":"2021-01-10 19:30:03", "clientIp": "000.000.000.000", "iptype": 4, "msg": "welcome to the topology" }
{ "resultcode": "204", "datetime":"2021-01-10 20:30:04", "clientIp": "000.000.000.000", "iptype": 4, "msg": "glad you're staying with us" }
```

### 🤹♀ リレーノードトポロジーファイルを更新する

{% hint style="danger" %}
リレーノードIPがトポロジーフェッチリストに登録されたことを確認後、以下のセクションを実行して下さい。
{% endhint %}

トポロジーファイルを更新する`relay-topology_pull.sh`スクリプトを作成します。 コマンドラインに送信する際に、**自身のブロックプロデューサーのIPアドレスとポート番号に書き換えて下さい**

※お知り合いのノードや自ノードが複数ある場合は、IOHKノード情報の後に "\|" で区切ってIPアドレス:ポート番号:Valency の形式で追加できます。

> 例）\|relays-new.cardano-mainnet.iohk.io:3001:2\|relay1-eu.xstakepool.com:3001:1\|00.000.000.00:3001:1

```bash
###
### On relaynode1
###
cat > $NODE_HOME/relay-topology_pull.sh << EOF
#!/bin/bash
BLOCKPRODUCING_IP=<BLOCK PRODUCERS PUBLIC IP ADDRESS>
BLOCKPRODUCING_PORT=6000
PEERS=18
curl -4 -s -o $NODE_HOME/${NODE_CONFIG}-topology.json "https://api.clio.one/htopology/v1/fetch/?max=\${PEERS}&customPeers=\${BLOCKPRODUCING_IP}:\${BLOCKPRODUCING_PORT}:1|relays-new.cardano-mainnet.iohk.io:3001:2"
EOF
```

shファイルに権限を追加し、relay-topology\_pull.shを実行して新しいトポロジーファイル\(mainnet-topology.json\)を生成します。

```bash
###
### On relaynode1
###
cd $NODE_HOME
chmod +x relay-topology_pull.sh
./relay-topology_pull.sh
```

新しいトポロジーファイル\(mainnet-topology.json\)は、ステークプールを再起動した後に有効となります。

```bash
###
### On relaynode1
###
sudo systemctl reload-or-restart cardano-node
```

{% hint style="warning" %}
トポロジーファイルを更新した場合は、リレーノードを再起動することを忘れないで下さい。
{% endhint %}
{% endtab %}

<!-- 
{% tab title="Pooltool.ioで更新する場合" %}
※非推奨※ 1. [https://pooltool.io/](https://pooltool.io/)へアクセスします。 2. アカウントを作成してログインします。 3. あなたのステークプールを探します。 4. **Pool Details** &gt; **Manage** &gt; **CLAIM THIS POOL**をクリックします。 5. プール名とプールURLがある場合は入力します。 6. あなたのリレーノード情報を入力します。

![](.gitbook/assets/ada-relay-setup-mainnet.png)

プライベートノードには、自身のブロックプロデューサーノードと、IOHKのノード情報を入力して下さい。

IOHKのノードアドレスは:

```text
relays-new.cardano-mainnet.iohk.io
```

IOHKのポート番号は:

```text
3001
```

リレーノードのトポロジーファイルには以下の情報が含まれていることが前提です。

* あなたのブロックプロデューサーノード情報
* IOHKのノード情報
* 他のリレーノード情報

{% hint style="info" %}
要求と承認があるまで、リレーノード接続は確立されません。
{% endhint %}

リレーノードのtopology.jsonファイルを更新するスクリプトを作成します。

```bash
###
### On relaynode1
###
cat > $NODE_HOME/get_buddies.sh << EOF 
#!/usr/bin/env bash

# YOU CAN PASS THESE STRINGS AS ENVIRONMENTAL VARIABLES, OR EDIT THEM IN THE SCRIPT HERE
if [ -z "\$PT_MY_POOL_ID" ]; then
## CHANGE THESE TO SUIT YOUR POOL TO YOUR POOL ID AS ON THE EXPLORER
PT_MY_POOL_ID="XXXXXXXX"
fi

if [ -z "\$PT_MY_API_KEY" ]; then
## GET THIS FROM YOUR ACCOUNT PROFILE PAGE ON POOLTOOL WEBSITE
PT_MY_API_KEY="XXXXXXXX"
fi

if [ -z "\$PT_MY_NODE_ID" ]; then
## GET THIS FROM YOUR POOL MANAGE TAB ON POOLTOOL WEBSITE
PT_MY_NODE_ID="XXXXXXXX"
fi

if [ -z "\$PT_TOPOLOGY_FILE" ]; then
## SET THIS TO THE LOCATION OF YOUR TOPOLOGY FILE THAT YOUR NODE USES
PT_TOPOLOGY_FILE="$NODE_HOME/${NODE_CONFIG}-topology.json"
fi

JSON="\$(jq -n --compact-output --arg MY_API_KEY "\$PT_MY_API_KEY" --arg MY_POOL_ID "\$PT_MY_POOL_ID" --arg MY_NODE_ID "\$PT_MY_NODE_ID" '{apiKey: \$MY_API_KEY, nodeId: \$MY_NODE_ID, poolId: \$MY_POOL_ID}')"
echo "Packet Sent: \$JSON"
RESPONSE="\$(curl -s -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "\$JSON" "https://api.pooltool.io/v0/getbuddies")"
SUCCESS="\$(echo \$RESPONSE | jq '.success')"
if [ \$SUCCESS ]; then
  echo "Success"
  echo \$RESPONSE | jq '. | {Producers: .message}' > \$PT_TOPOLOGY_FILE
  echo "Topology saved to \$PT_TOPOLOGY_FILE.  Note topology will only take effect next time you restart your node"
else
  echo "Failure "
  echo \$RESPONSE | jq '.message'
fi
EOF
```

リレーノードごとに、Pooltool.ioで指定された変数の値を記入して下さい。

* PT\_MY\_POOL\_ID 
* PT\_MY\_API\_KEY 
* PT\_MY\_NODE\_ID

この情報でスクリプトを更新します。\(このスクリプトにはバグがあります。\)

{% hint style="info" %}
**nano**エディターで更新できます。

`nano $NODE_HOME/relaynode1/get_buddies.sh`
{% endhint %}

このスクリプトに権限を追加し実行します。

```bash
###
### On relaynode1
###
cd $NODE_HOME
chmod +x get_buddies.sh
./get_buddies.sh
```

新しいトポロジーファイルを有効にするために、ステークプールを再起動します。

```bash
###
### On relaynode1
###
sudo systemctl reload-or-restart cardano-node
```

{% hint style="info" %}
Pooltool.ioでリクエストが承認されたら、その都度get\_buddies.shスクリプトを実行して、最新のトポロジーファイルに更新して下さい。その後ステークプールを再起動します。
{% endhint %}
{% endtab %}
-->

{% endtabs %}

{% hint style="danger" %}
\*\*\*\*🔥 **重要な確認事項:** ブロックを生成するには、「TXs processed」が増加していることを確認する必要があります。万一、増加していない場合にはトポロジーファイルの内容を再確認して下さい。「peers」数はリレーノードが他ノードと接続している数を表しています。
{% endhint %}

**🛠 gLiveView で確認**

```bash
cd $NODE_HOME/scripts
./gLiveView.sh
```

{% hint style="info" %}
「Txs processed」が増加しているか確認する
{% endhint %}


![](https://gblobscdn.gitbook.com/assets%2F-M5KYnWuA6dS_nKYsmfV%2F-MGldUPmEkJqK1vDLzOT%2F-MGlehnIvBsYqfb4KGvG%2Fgliveview-core.png?alt=media&token=9954ab81-26ae-4e7a-bfdf-d3b73c82d1ec)

{% hint style="danger" %}
\*\*\*\*🛑 **注意事項**r: ブロックプロデューサーノードを実行するためには、以下の３つのファイルが必要です。このファイルが揃っていない場合や起動時に指定されていない場合はブロックが生成できません。

```bash
###
### On ブロックプロデューサーノード
###
KES=\${DIRECTORY}/kes.skey
VRF=\${DIRECTORY}/vrf.skey
CERT=\${DIRECTORY}/node.cert
```

**上記以外のキーファイルは、エアギャップオフライン環境で保管する必要があります**
{% endhint %}

{% hint style="success" %}
おめでとうございます！ステークプールが登録され、ブロックを作成する準備が出来ました。
{% endhint %}

## 🎇 14. ステークプール報酬を確認する

ブロックが正常に生成できた後、エポック終了後に報酬を確認しましょう！  
エアギャップにある **stake.addr**をBPのcardano-my-nodeフォルダへコピーしてください

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
cardano-cli query stake-address-info \
 --address $(cat stake.addr) \
 --mainnet
```
{% endtab %}
{% endtabs %}

## 🔮 15. 監視ツール「Prometheus」および「Grafana Dashboard」のセットアップ

プロメテウスはターゲットに指定したメトリックHTTPエンドポイントをスクレイピングし、情報を収集する監視ツールです。[オフィシャルドキュメントはこちら](https://prometheus.io/docs/introduction/overview/) グラファナは収集されたデータを視覚的に表示させるダッシュボードツールです。

### 🐣 15.1 インストール

「prometheus」および「prometheus node exporter」をインストールします。 この手順では、リレーノード1でprometheusとGrafana本体を稼働させ、リレーノード1およびブロックプロデューサーノードの情報を取得する手順です。

{% tabs %}
{% tab title="リレーノード1" %}
```text
sudo apt-get install -y prometheus prometheus-node-exporter
```
{% endtab %}

{% tab title="ブロックプロデューサーノード" %}
```bash
sudo apt-get install -y prometheus-node-exporter
```
{% endtab %}
{% endtabs %}

grafanaをインストールします。

{% tabs %}
{% tab title="リレーノード1" %}
```bash
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="リレーノード1" %}
```bash
echo "deb https://packages.grafana.com/oss/deb stable main" > grafana.list
sudo mv grafana.list /etc/apt/sources.list.d/grafana.list
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="リレーノード1" %}
```bash
sudo apt-get update && sudo apt-get install -y grafana
```
{% endtab %}
{% endtabs %}

サービスを有効にして、自動的に開始されるように設定します。

{% tabs %}
{% tab title="リレーノード1" %}
```bash
sudo systemctl enable grafana-server.service
sudo systemctl enable prometheus.service
sudo systemctl enable prometheus-node-exporter.service
```
{% endtab %}

{% tab title="ブロックプロデューサーノード" %}
```text
sudo systemctl enable prometheus-node-exporter.service
```
{% endtab %}
{% endtabs %}

`/etc/prometheus/prometheus.yml` に格納されている、「prometheus.yml」を更新します。

ご自身の&lt;ブロックプロデューサーIPアドレス&gt;に書き換えて、コマンドを送信してください。

{% tabs %}
{% tab title="リレーノード1" %}
```bash
cat > prometheus.yml << EOF
global:
  scrape_interval:     15s # 15秒ごとに取得します

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label job=<job_name> to any timeseries scraped from this config.
  - job_name: 'prometheus'

    static_configs:
      - targets: ['localhost:9100']
        labels:
          alias: 'relaynode1'
          type:  'system'
      - targets: ['ブロックプロデューサーIPアドレス:9100']
        labels:
          alias: 'block-producing-node'
          type:  'system'
      - targets: ['ブロックプロデューサーIPアドレス:12798']
        labels:
          alias: 'block-producing-node'
          type:  'cardano-node'
      - targets: ['localhost:12798']
        labels:
          alias: 'relaynode1'
          type:  'cardano-node'
EOF
```
{% endtab %}
{% endtabs %}

prometheus.ymlを移動します

{% tabs %}
{% tab title="リレーノード1" %}
```bash
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
```
{% endtab %}
{% endtabs %}

サービスを起動します。

{% tabs %}
{% tab title="リレーノード1" %}
```text
sudo systemctl restart grafana-server.service
sudo systemctl restart prometheus.service
sudo systemctl restart prometheus-node-exporter.service
```
{% endtab %}
{% endtabs %}

サービスが正しく実行されていることを確認します。

{% tabs %}
{% tab title="リレーノード1" %}
```text
sudo systemctl --no-pager status grafana-server.service prometheus.service prometheus-node-exporter.service
```
{% endtab %}
{% endtabs %}

${NODE\_CONFIG}-config.jsonに新しい `hasEKG`情報と `hasPrometheus`ポート情報を更新します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
sed -i ${NODE_CONFIG}-config.json -e "s/127.0.0.1/0.0.0.0/g"
```
{% endtab %}

{% tab title="リレーノード1" %}
```bash
cd $NODE_HOME
sed -i ${NODE_CONFIG}-config.json -e "s/127.0.0.1/0.0.0.0/g"
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
ファイアウォールを設定している場合は、ブロックプロデューサーノードにて9100番と12798番ポートをリレーノードIP指定で開放して下さい。  
リレーノード1では、Grafana用に3000番ポートを開放してください。
{% endhint %}

ステークプールを停止してスクリプトを再起動します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
sudo systemctl reload-or-restart cardano-node
```
{% endtab %}

{% tab title="リレーノード1" %}
```bash
sudo systemctl reload-or-restart cardano-node
```
{% endtab %}
{% endtabs %}

## 📶 16 Grafanaダッシュボードの設定

1. リレーノード1で、ローカルブラウザから [http://localhost:3000](http://localhost:3000) または http://&lt;リレーノードIPアドレス&gt;:3000 を開きます。 事前に 3000番ポートを開いておく必要があります。
2. ログイン名・PWは次のとおりです。 **admin** / **admin**
3. パスワードを変更します。
4. 左メニューの歯車アイコンから データソースを追加します。
5. 「Add data source」をクリックし、「Prometheus」を選択します。
6. 名前は **Prometheus**としてください。
7. **URL** を [http://localhost:9090](http://localhost:9090)に設定します。
8. **Save & Test**をクリックします。
9. 次の[JSONファイル](https://raw.githubusercontent.com/btbf/coincashew/master/guild-tools/grafana-monitor-cardano-nodes-by-kaze.json)を開き、内容を全選択してコピーします。
10. 左メニューから**Create +** iconを選択 &gt; **Import**をクリックします。
11. 9でコピーした内容を「Import via panel json」に貼り付けます
12. **Load**ボタンをクリックし、次の画面で**\*Import**ボタンをクリックします。

![Grafana system health dashboard](https://gblobscdn.gitbook.com/assets%2F-M5KYnWuA6dS_nKYsmfV%2F-MJFWbLTL5oVQ3taFexL%2F-MJFX9deFAhN4ks6OQCL%2Fdashboard-kaze.jpg?alt=media&token=f28e434a-fcbf-40d7-8844-4ff8a36a0005)

{% hint style="success" %}
おめでとうございます！これで基本的な設定は完了です。 次の項目は、運用中の便利なコマンドや保守のヒントが書かれています。
{% endhint %}

## 👏 17. 寄付とクレジット表記

{% hint style="info" %}
このマニュアル制作に携わった全ての方に、感謝申し上げます。 快く翻訳を承諾して頂いた、[CoinCashew](https://www.coincashew.com/)には敬意を表します。
この活動をサポートして頂ける方は、是非寄付をよろしくお願い致します。
{% endhint %}

### CoinCashew ADAアドレス
```bash
addr1qxhazv2dp8yvqwyxxlt7n7ufwhw582uqtcn9llqak736ptfyf8d2zwjceymcq6l5gxht0nx9zwazvtvnn22sl84tgkyq7guw7q
```

### X StakePoolへの寄付  
 
カルダノ分散化、日本コミュニティ発展の為に日本語化させて頂きました。私達をサポート頂ける方は当プールへ委任頂けますと幸いです。  
* Ticker：XSP  
Pool ID↓  
```bash
788898a81174665316af96880459dcca053f7825abb1b0db9a433630
```

* ADAアドレス
```bash
addr1q85kms3xw788pzxcr8g8d4umxjcr57w55k2gawnpwzklu97sc26z2lhct48alhew43ry674692u2eynccsyt9qexxsesjzz8qp
```
  
  
### 全ての協力者
* 👏 Antonie of CNT for being awesomely helpful with Youtube content and in telegram.
* 👏 Special thanks to Kaze-Stake for the pull requests and automatic script contributions.
* 👏 The Legend of ₳da [TLOA] for translating this guide to Spanish.
* 👏 X-StakePool [BTBF] for translating this guide to Japanese.
* 👏 Chris of OMEGA \| CODEX for security improvements.
* 👏 Raymond of GROW for topologyUpdater improvements and being awesome.

## 🛠 18. プール運用とメンテナンス

### 🤖 18.1 新しいkesPeriodで運用証明書を更新する

{% hint style="info" %}
ホットキーの有効期限が切れると、ホットキーを再作成し新しい運用証明書を発行する必要があります。
{% endhint %}

**kesPeriodの更新**: 新しい運用証明書を発行するときは、次を実行して「startKesPeriod」を見つけます

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slot')
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
startKesPeriod=${kesPeriod}
echo startKesPeriod: ${startKesPeriod}
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```
{% endtab %}
{% endtabs %}

kes.vkeyをエアギャップオフラインマシンのcardano-my-nodeディレクトリにコピーします。 
  
次のコマンドで、新しい `node.cert`ファイルを作成します。このときstartKesPeriodの値を下記のXXXの箇所に置き換えてからコマンドを送信してください。

**XXX**の部分を上記で算出した数値（startKesPeriodの値）に置き換えます。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
chmod u+rwx $HOME/cold-keys
cardano-cli node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period XXX \
    --out-file node.cert
chmod a-rwx $HOME/cold-keys
```
{% endtab %}
{% endtabs %}

{% hint style="danger" %}
**node.cert** をブロックプロデューサーノードのcardano-my-nodeディレクトリにコピーします。
{% endhint %}

この手順を完了するには、ブロックプロデューサーノードを停止して再起動します。

{% tabs %}
{% tab title="ブロックプロデューサーノードsystemctl" %}
```text
sudo systemctl reload-or-restart cardano-node
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}

\*\*\*\*✨ **ヒント:** ホットキーを作成したら、コールドキーへのアクセス件を変更しセキュリティを向上させることができます。これによって誤削除、誤った編集などから保護できます。

ロックするには

```bash
chmod a-rwx $HOME/cold-keys
```

ロックを解除するには

```bash
chmod u+rwx $HOME/cold-keys
```
{% endhint %}

### 🔥 18.2 インストールのリセット

もう一度はじめからやり直したいですか？次の方法でやり直すことができます。

git repoを削除してから `$NODE_HOME` と `cold-keys` ディレクトリの名前を変更します \(またはオプションで削除します\)

```bash
rm -rf $HOME/git/cardano-node/ $HOME/git/libsodium/
mv $NODE_HOME $(basename $NODE_HOME)_backup_$(date -I)
mv $HOME/cold-keys $HOME/cold-keys_backup_$(date -I)
```

### 🌊 18.3 データベースのリセット

ブロックチェーンファイルの破損やノードがスタックして動かない場合、dbファイルを削除することで初めから同期をやり直すことができます。

```bash
cd $NODE_HOME
rm -rf db
```

### 📝 18.4 プールメタ情報、誓約や固定費、Marginの変更手順

{% hint style="info" %}
誓約、固定費、Margin、リレー情報、メタ情報を変更する場合は、登録証明書の再送を行います。
{% endhint %}

minPoolCostを出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
minPoolCost=$(cat $NODE_HOME/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
minPoolCost は340000000 lovelace \(340 ADA\)です。 `--pool-cost`は最低でもこの値以上に指定します。
{% endhint %}

poolMetaData.jsonをGithubでホストしている場合はダウンロードする  
短縮URLをご自身のものに修正してからコマンドを実行してください

{% tabs %}
{% tab title="poolMetaData.jsonをGithubでホストしている場合" %}
```bash
cd $NODE_HOME
wget -O poolMetaData.json https://git.io/JUcnl
```
{% endtab %}
{% endtabs %}

poolMetaData.jsonを変更する場合は、メタデータファイルのハッシュを再計算し、更新されたpoolMetaData.jsonをWEBサーバへアップロードしてください。 詳細については [項目11-1](./guide-how-to-build-a-haskell-stakepool-node.md#11-1-prunojsonfairuwoshiteprunometadtawoshimasu)を参照して下さい。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```text
cd $NODE_HOME
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

登録証明書トランザクションを作成します。

複数のリレーノードを設定する場合は [**こちら**](./guide-how-to-build-a-haskell-stakepool-node.md#norirndowosuru) を参考にパラメーターを指定して下さい。  
  

**poolMetaDataHash.txt** をエアギャップオフラインマシンのcardano-my-nodeディレクトリにコピーします。

{% hint style="warning" %}
**metadata-url**は64文字以下にする必要があります。
{% endhint %}

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
```

```bash
cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 1000000000 \
    --pool-cost 345000000 \
    --pool-margin 0.20 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --pool-relay-ipv4 <リレーノードのパプリックIPへ書き換え> \
    --pool-relay-port 6000 \
    --metadata-url https://xxx.xxx.xxx/poolMetaData.json \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
この例では345ADAの固定費と20%のMrgin、1000ADAを誓約しています。
{% endhint %}

ステークプールに誓約します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```text
cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
```
{% endtab %}
{% endtabs %}

**pool.cert**と**deleg.cert** をブロックプロデューサーのcardano-my-nodeディレクトリにコピーします。

ttlパラメータを設定するには、最新のスロット番号を取得する必要があります。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

残高と **UTXOs**を出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
{% endtab %}
{% endtabs %}

build-rawトランザクションコマンドを実行します。

{% hint style="info" %}
**ttl**の値は、現在のスロット番号よりも大きくなければいけません。この例では現在のスロット番号＋10000で設定しています。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

最低手数料を計算します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

計算結果を出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
txOut=$((${total_balance}-${fee}))
echo txOut: ${txOut}
```
{% endtab %}
{% endtabs %}

トランザクションファイルを構築します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

**tx.raw** をエアギャップオフラインマシンのcardano-my-nodeディレクトリにコピーします。

トランザクションに署名します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

**tx.signed**ををブロックプロデューサーノードのcardano-my-nodeディレクトリにコピーします。

トランザクションを送信します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

プール名、ティッカー名、WebsiteURLは数分後～数時間で反映します。  
誓約や手数料の変更は次のエポックで有効になります。  



<!--
{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
cardano-cli query ledger-state --mainnet > ledger-state.json
jq -r '.esLState._delegationState._pstate._pParams."'"$(cat stakepoolid.txt)"'"  // empty' ledger-state.json
```
{% endtab %}
{% endtabs %}
-->

<!--
### 🧩 18.5 SSHを介したファイルの転送

一般的な使用例

* stake/paymentキーのバックアップをダウンロードする
* オフラインノードからブロックプロデューサーへ新しいファイルをアップロードする。

#### ノードからローカルPCにファイルをダウンロードする方法

```bash
ssh <USERNAME>@<IP ADDRESS> -p <SSH-PORT>
rsync -avzhe “ssh -p <SSH-PORT>” <USERNAME>@<IP ADDRESS>:<PATH TO NODE DESTINATION> <PATH TO LOCAL PC DESTINATION>
```

> 例:
>
> `ssh myusername@6.1.2.3 -p 12345`
>
> `rsync -avzhe "ssh -p 12345" myusername@6.1.2.3:/home/myusername/cardano-my-node/stake.vkey ./stake.vkey`

#### ローカルPCからノードにファイルをアップロードする方法

```bash
ssh <USERNAME>@<IP ADDRESS> -p <SSH-PORT>
rsync -avzhe “ssh -p <SSH-PORT>” <PATH TO LOCAL PC DESTINATION> <USERNAME>@<IP ADDRESS>:<PATH TO NODE DESTINATION>
```

> 例:
>
> `ssh myusername@6.1.2.3 -p 12345`
>
> `rsync -avzhe "ssh -p 12345" ./node.cert myusername@6.1.2.3:/home/myusername/cardano-my-node/node.cert`

-->
### ✅ 18.5 ITNキーでステークプールティッカーを確認する。

信頼できるステークプールのなりすましや、プール運営を悪用する人から身を守るために、所有者はITNステークプールの所有権を証明することでティッカーを証明できます。

ITNのバイナリファイルが`$NODE_HOME`にあることを確認して下さい。 `itn_owner.skey`はステークプールIDに署名するために使用されています。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
./jcli key sign --secret-key itn_owner.skey stakepoolid.txt --output stakepoolid.sig
```
{% endtab %}
{% endtabs %}

次のコマンドでプールIDを確認します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```text
cat stakepoolid.sig
```
{% endtab %}
{% endtabs %}

ITNで作成したファイルで、所有者の公開鍵を見つけます。このデータは末尾が「.pub」で保存されている可能性があります。

### 📚 18.6 ノードの構成ファイル更新

最新の.jsonファイルをダウンロードして、構成ファイルを最新の状態に保ちます。

```bash
NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')
cd $NODE_HOME
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-byron-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-shelley-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json
sed -i ${NODE_CONFIG}-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g" \
    -e "s/127.0.0.1/0.0.0.0/g"
```

### 💸 18.7 簡単なトランザクション送信の例をご紹介します

**10 ADA** を payment.addrから自分のアドレスへ送信する例です 🙃

まずは、最新のスロット番号を取得し **invalid-hereafter** パラメータを正しく設定します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

lovelaces形式で送信する金額を設定します。. ✨ **1 ADA** = **1,000,000 lovelaces** で覚えます。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
amountToSend=10000000
echo amountToSend: $amountToSend
```
{% endtab %}
{% endtabs %}

送金先のアドレスを設定します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
destinationAddress=送金先アドレス
echo destinationAddress: $destinationAddress
```
{% endtab %}
{% endtabs %}

残高と **UTXOs**を出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
{% endtab %}
{% endtabs %}

build-rawトランザクションコマンドを実行します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --tx-out ${destinationAddress}+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

最低手数料を出力します

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 2 \
    --mainnet \
    --witness-count 1 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

計算結果を出力します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
txOut=$((${total_balance}-${fee}-${amountToSend}))
echo Change Output: ${txOut}
```
{% endtab %}
{% endtabs %}

トランザクションファイルを構築します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --tx-out ${destinationAddress}+${amountToSend} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

**tx.raw** をエアギャップオフラインマシンのcardano-my-nodeディレクトリにコピーします。

トランザクションに署名します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

**tx.signed** をブロックプロデューサーノードのcardano-my-nodeディレクトリにコピーします。

署名されたトランザクションを送信します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

入金されているか確認します。

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cardano-cli query utxo \
    --address ${destinationAddress} \
    --mainnet \
```
{% endtab %}
{% endtabs %}

先程指定した金額と一致していれば問題ないです。

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        10000000
```

### 🔓 18.8 ノードのセキュリティを強化する

{% hint style="info" %}
絶賛翻訳中！！
{% endhint %}


### 🍰 18.9 報酬を請求する

2つの送金方法があります。
{% hint style="info" %}
**1.payment.addrへ送金する方法**は[こちら](./guide-how-to-build-a-haskell-stakepool-node.md#18-10-1-paymentaddrhesuru)

**2.任意のアドレスへ送金する方法は**[こちら](./guide-how-to-build-a-haskell-stakepool-node.md#18-10-2-noadoresuhesuru)
{% endhint %}

    
{% hint style="danger" %}
入力ミスなどで送金が失敗しても責任は負えません。自己責任のもと実施下さい。  
**payment.skey**と**stake.skey**は必ずオフライン環境で保管してください。  
{% endhint %}


#### 18.10.1 payment.addrへ送金する方法

ステークプールの報酬を請求する例を見ていきます。

{% hint style="info" %}
報酬は `stake.addr` アドレスに蓄積されていきます。  
**1回のトランザクションで引き出せる金額は残高全額のみです。**  
(分割して引き出すことはできません)
{% endhint %}


まずはじめにブロックチェーンの先頭 **tip** を見つけて **invalid-hereafter** パラメーターを適切に設定します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
rewardBalance=$(cardano-cli query stake-address-info \
    --mainnet \
    --address $(cat stake.addr) | jq -r ".[0].rewardAccountBalance")
echo rewardBalance: $rewardBalance
```
{% endtab %}
{% endtabs %}
✨ **1 ADA** = **1,000,000 lovelaces.**と覚えましょう  

報酬の移動先となるアドレスを設定します。このアドレスには取引手数料を支払うための残高が必要です。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
destinationAddress=$(cat payment.addr)
echo destinationAddress: $destinationAddress
```
{% endtab %}
{% endtabs %}

あなたの payment.addr の残高, utxos をみつけて、引き出し文字を作成します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}

withdrawalString="$(cat stake.addr)+${rewardBalance}"
```
{% endtab %}
{% endtabs %}

build-raw transactionコマンドを実行します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --withdrawal ${withdrawalString} \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

現在の最低料金を計算します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

変更出力を計算します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
txOut=$((${total_balance}-${fee}+${rewardBalance}))
echo Change Output: ${txOut}
```
{% endtab %}
{% endtabs %}

トランザクションをビルドします。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --withdrawal ${withdrawalString} \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

**tx.raw** を **エアギャップオフラインマシン**のcardano-my-nodeディレクトリにコピーします。

支払いとステークの秘密鍵の両方を使用していトランザクションに署名します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

**tx.signed** を **ブロックプロデューサノード**のcardano-my-nodeディレクトリにコピーします。

署名されたトランザクションを送信します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

資金が到着したか確認します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli query utxo \
    --address ${destinationAddress} \
    --mainnet
```
{% endtab %}
{% endtabs %}

更新されたラブレースの残高と報酬を表示します。

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....  
```


#### 18.10.2 任意のアドレスへ送金する方法

{% hint style="info" %}
報酬は `stake.addr` アドレスに蓄積されていきます。  
**１回のトランザクションで引き出せる金額は残高全額のみです。**
(分割して引き出すことはできません)  
**トランザクション手数料はpayment.addrから引き落とされます。**
{% endhint %}

現在のスロットNoを算出します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

入金先アドレスを指定します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
destinationAddress=入金先アドレスを指定する
echo destinationAddress: $destinationAddress
```
{% endtab %}
{% endtabs %}

報酬アドレス残高参照

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cd $NODE_HOME
rewardBalance=$(cardano-cli query stake-address-info \
    --mainnet \
    --address $(cat stake.addr) | jq -r ".[0].rewardAccountBalance")
echo rewardBalance: $rewardBalance
```
{% endtab %}
{% endtabs %}


あなたの payment.addr の残高を参照します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}

withdrawalString="$(cat stake.addr)+${rewardBalance}"
echo ${withdrawalString}
```
{% endtab %}
{% endtabs %}

build-raw transactionコマンドを実行します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --tx-out ${destinationAddress}+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --withdrawal ${withdrawalString} \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

現在の最低料金を計算します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 2 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

変更出力を計算します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
txOut=$((${total_balance}-${fee}))
echo Change Output: ${txOut}
```
{% endtab %}
{% endtabs %}

トランザクションをビルドします。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --tx-out ${destinationAddress}+${rewardBalance} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --withdrawal ${withdrawalString} \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

**tx.raw** を **エアギャップオフラインマシン**のcardano-my-nodeディレクトリにコピーします。

支払いとステークの秘密鍵の両方を使用していトランザクションに署名します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cd $NODE_HOME
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

**tx.signed** を **ブロックプロデューサノード**のcardano-my-nodeディレクトリにコピーします。

署名されたトランザクションを送信します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

資金が到着したか確認します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli query utxo \
    --address ${destinationAddress} \
    --mainnet
```
{% endtab %}
{% endtabs %}

更新されたラブレースの残高と報酬を表示します。

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....  
```


### 🕒 18.12 スロットリーダースケジュール - ブロック生成時期を確認する

{% hint style="info" %}
[ブロックログツール](guild-tools/README.md) を導入する
{% endhint %}


## 🌜 19. ステークプールを廃止する


現在のエポックを計算します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
startTimeGenesis=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r .systemStart)
startTimeSec=$(date --date=${startTimeGenesis} +%s)
currentTimeSec=$(date -u +%s)
epochLength=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r .epochLength)
epoch=$(( (${currentTimeSec}-${startTimeSec}) / ${epochLength} ))
echo current epoch: ${epoch}
```
{% endtab %}
{% endtabs %}

プールが引退できる最も早くて最も遅い引退エポックを見つけます。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
poolRetireMaxEpoch=$(cat $NODE_HOME/params.json | jq -r '.poolRetireMaxEpoch')
echo poolRetireMaxEpoch: ${poolRetireMaxEpoch}

minRetirementEpoch=$(( ${epoch} + 1 ))
maxRetirementEpoch=$(( ${epoch} + ${poolRetireMaxEpoch} ))

echo earliest epoch for retirement is: ${minRetirementEpoch}
echo latest epoch for retirement is: ${maxRetirementEpoch}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
\*\*\*\*🚧 **例**: エポック39でeMax18の場合,

* 最も早いポックは 40 \( 現在のエポック  + 1\).
* 最も遅いエポックは 57 \( eMax + 現在のエポック\). 

エポック40で一刻も早く引退したいと思っていることにしておきましょう。
{% endhint %}

登録解除証明書 `pool.dereg.`を作成し、「エポックを希望のリタイアメントエポック(通常は最も早いエポック)に更新する」として保存します。

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cardano-cli stake-pool deregistration-certificate \
--cold-verification-key-file $HOME/cold-keys/node.vkey \
--epoch <retirementEpoch> \
--out-file pool.dereg
```
{% endtab %}
{% endtabs %}

**pool.dereg** を **ブロックプロデューサノード**のcardano-my-nodeディレクトリにコピーします。

残高と **UTXOs**を見つけます。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
```
{% endtab %}
{% endtabs %}

```
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```

build-raw transactionコマンドを実行します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.dereg \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

最低料金を計算します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

変更出力を計算します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
txOut=$((${total_balance}-${fee}))
echo txOut: ${txOut}
```
{% endtab %}
{% endtabs %}

トランザクションをビルドします。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.dereg \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

**tx.raw** を **エアギャップオフラインマシン**のcardano-my-nodeディレクトリにコピーします。

Sign the transaction. 

{% tabs %}
{% tab title="エアギャップオフラインマシン" %}
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

**tx.signed** を **ブロックプロデューサノード**のcardano-my-nodeディレクトリにコピーします。

トランザクションに署名します。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

{% hint style="success" %}
プールは指定されたエポックの終了時にリタイアします。この例はエポック40の終わりにリタイアが発生します。  
  
もし心変わりがある場合は、エポック40が終了する前に新しい登録証明書を作成して送信できます。これにより登録解除証明書が無効になります。
{% endhint %}

リタイアエポックのあと、空の結果を返す次のクエリを使用して、プールが正常にリタイアされたことを確認できます。

{% tabs %}
{% tab title="ブロックプロデューサノード" %}
```bash
cd $NODE_HOME
cardano-cli query ledger-state --mainnet > ledger-state.json
jq -r '.esLState._delegationState._pstate._pParams."'"$(cat stakepoolid.txt)"'"  // empty' ledger-state.json
```
{% endtab %}
{% endtabs %}

## 🚀 20. このマニュアルに関する問い合わせ先

{% hint style="success" %}
このマニュアルは役に立ちましたか？ 不明な点がある場合は、下記までご連絡下さい。

・コミュニティ：[Cardano SPO Japanese Guild](https://discord.com/invite/3HnVHs3)

・Twitter：[@btbfpark](https://twitter.com/btbfpark)

・Twitter：[@X\_StakePool\_XSP](https://twitter.com/X_StakePool_XSP)

このマニュアルは、常に[最新版](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#19-retiring-your-stake-pool)に沿って更新されます。
{% endhint %}


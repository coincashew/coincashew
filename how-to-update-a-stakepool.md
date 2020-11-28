---
description: >-
  最新ノードをソースコードからビルドするには、数分～数時間かかる場合があります。その間プールを停止させるとブロック生成のチャンスが失われ、委任者に迷惑がかかります。プール停止時間を最小限に抑えた方法でアップデートするよう心がけましょう。
---


# ステークプールを更新する方法

{% hint style="info" %}
このマニュアルは、[X Stake Pool](https://xstakepool.com)オペレータの[BTBF](https://twitter.com/btbfpark)が[CoinCashew](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#9-register-your-stakepool)より許可を得て、日本語翻訳しております。
{% endhint %}

## 📡 1. ノードバージョンアップデート手順

 `cardano-node`は常に更新されており、バージョンがアップデートされるたびにプールサーバでも作業が必要です。 [Official Cardano-Node Github Repo](https://github.com/input-output-hk/cardano-node) をフォローし最新情報を取得しましょう。

現在の `$HOME/git/cardano-node` ディレクトリに更新する場合は、ディレクトリ全体を新しい場所へコピーしてバックアップを作成します。(ロールバックする際に必要となります)

```bash
cd $HOME/git
rm -rf cardano-node-old/
rsync -av cardano-node/ cardano-node2/
cd cardano-node2/
```

{% hint style="danger" %}
最新のリリースに必要となる他の更新や依存関係については、パッチノートを参照して下さい。
{% endhint %}

### v1.23.0リリースに伴う新しい依存関係

GHC バージョン8.10.2をインストールします。

```bash
cd
wget https://downloads.haskell.org/ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz
tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz
rm ghc-8.10.2-x86_64-deb9-linux.tar.xz
cd ghc-8.10.2
./configure
sudo make install
```

GHCバージョン 8.10.2がインストールされたことを確認します。

```bash
source $HOME/.bashrc
cabal update
ghc -V
```

> \#バージョン出力の例
>
> The Glorious Glasgow Haskell Compilation System, version 8.10.2

ビルドオプションを構成します。

```text
cd $HOME/git/cardano-node2/
cabal configure -O0 -w ghc-8.10.2
```

#### Liveviewを無効にする

このリリースからLiveViewは削除されました。

以下を実行して **mainnet-config.json**の内容を変更します。

* LiveView を SimpleViewへ変更します。

```bash
cd $NODE_HOME
sed -i mainnet-config.json \
    -e "s/LiveView/SimpleView/g"
```

#### ログ出力をコンソールとJSONファイルの両方に対応する場合の記述方法

```bash
  "defaultScribes": [
    [
      "FileSK",
      "logs/node.json"
    ],
    [
      "StdoutSK",
      "stdout"
    ]
  ],


 ~~~
 ~~~
 ~~~
  

   "setupScribes": [
    {
      "scFormat": "ScJson",
      "scKind": "FileSK",
      "scName": "logs/node.json"
    },
    {
      "scFormat": "ScText",
      "scKind": "StdoutSK",
      "scName": "stdout",
      "scRotation": null
    }
  ]
 ```



#### gLiveViewをインストールします（任意）

LiveViewの代わりにノードを監視するコミュニティ製の監視ツールです。  
(メモリー使用率が高くなることに注意して下さい)

[インストールはこちらを参照してください](./#18-13-gliveview-node-status-monitoring)

### 新しいバイナリーファイルをコンパイルする

古いバイナリーを削除し、最新のバイナリーを再構築します。次のコマンドを実行して、最新のバイナリをプルしてビルドします。必要に応じて、チェックアウト **tag** または **branch** を変更して下さい。

```bash
cd $HOME/git/cardano-node2/
rm -rf $HOME/git/cardano-node2/dist-newstyle/build/x86_64-linux/ghc-8.6.5
git clean -fd
git fetch --all --recurse-submodules --tags
git checkout tags/1.23.0 && git pull
cabal build cardano-node cardano-cli
```

{% hint style="info" %}
コンピュータの処理能力によっては、ビルドプロセスに数分から数時間かかる場合があります。
{% endhint %}

**cardano-cli** と **cardano-node** が希望のバージョンに更新されたことを確認して下さい。

```bash
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") version
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") version
```

{% hint style="danger" %}
バイナリーファイルを更新する前に、ノードを停止して下さい。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
killall -s 2 cardano-node
```
{% endtab %}

{% tab title="リレーノード1" %}
```
killall -s 2 cardano-node
```
{% endtab %}

{% tab title="systemd" %}
```
sudo systemctl stop cardano-node
```
{% endtab %}
{% endtabs %}

**cardano-cli** と **cardano-node** ファイルをbinディレクトリにコピーします。

```bash
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

{% hint style="success" %}
ノードを再起動して、更新されたバイナリーを使用します。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
./startBlockProducingNode.sh
```
{% endtab %}

{% tab title="リレーノード" %}
```
cd $NODE_HOME
./startRelayNode1.sh
```
{% endtab %}

{% tab title="systemd" %}
```
sudo systemctl start cardano-node
```
{% endtab %}
{% endtabs %}

最後に、前バージョンで使用していたバイナリフォルダをリネームし、バックアップとして保持します。最新バージョンを構築したフォルダをcardano-nodeとして使用します。

```bash
cd $HOME/git
mv cardano-node/ cardano-node-old/
mv cardano-node2/ cardano-node/
```

## 🤯 2. 問題が発生した場合

### 🛣 4.1 更新を忘れていた場合

ノードの更新を忘れ、ノードが古いチェーンで止まっている場合

データベースをリセットし [最新の genesis, config, topology json files](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html)を取得して下さい。

```bash
cd $NODE_HOME
rm -rf db
```

### 📂 4.2 バックアップから前バージョンへロールバックする
最新バージョンに問題がある場合は、以前のバージョンへ戻しましょう。

{% hint style="danger" %}
バイナリを更新する前にノードを停止します。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
killall -s 2 cardano-node
```
{% endtab %}

{% tab title="リレーノード1" %}
```
killall -s 2 cardano-node
```
{% endtab %}

{% tab title="systemd" %}
```
sudo systemctl stop cardano-node
```
{% endtab %}
{% endtabs %}

古いリポジトリを復元します。

```bash
cd $HOME/git
mv cardano-node/ cardano-node-rolled-back/
mv cardano-node-old/ cardano-node/
```

バイナリーファイルを `/usr/local/bin`にコピーします。

```bash
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

バイナリーが希望するバージョンであることを確認します。

```bash
/usr/local/bin/cardano-cli version
/usr/local/bin/cardano-node version
```

{% hint style="success" %}
次にノードを再起動して同期が開始しているか確認して下さい。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
./startBlockProducingNode.sh
```
{% endtab %}

{% tab title="リレードード1" %}
```bash
cd $NODE_HOME
./startRelayNode1.sh
```
{% endtab %}

{% tab title="systemd" %}
```
sudo systemctl start cardano-node
```
{% endtab %}
{% endtabs %}

### 🤖 4.3 上手く行かない場合は、ソースコードから再構築

次のマニュアル [カルダノステークプール構築手順](./)1～3を実行する。


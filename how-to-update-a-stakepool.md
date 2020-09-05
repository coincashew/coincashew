# ステークプールを更新する方法

このマニュアルは、[X Stake Pool](https://xstakepool.com)オペレータの[BTBF](https://twitter.com/btbfpark)が[CoinCashew](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#9-register-your-stakepool)より許可を得て、日本語翻訳しております。
{% endhint %}

## 📡 1. ノードバージョンアップデート手順

 `cardano-node`は常に更新されており、バージョンがアップデートされるたびにプールサーバでも作業が必要です。 [Official Cardano-Node Github Repo](https://github.com/input-output-hk/cardano-node) をフォローし最新情報を取得しましょう。

現在の `$HOME/git/cardano-node` ディレクトリに更新する場合は、ディレクトリ全体を新しい場所へコピーしてバックアップを作成します。(ロールバックする際に必要となります)

```bash
cd $HOME/git
rm cardano-node-old/
rsync -av cardano-node/ cardano-node2/
cd cardano-node2/
```

{% hint style="danger" %}
最新のリリースに必要となる他の更新や依存関係については、パッチノートを参照して下さい。
{% endhint %}

古いバイナリーを削除し、最新のバイナリーを再構築します。次のコマンドを実行して最新のバイナリーを取得し構築します。更新したいバージョンに合わせてタグを更新します。

```bash
rm -rf $HOME/git/cardano-node2/dist-newstyle/build/x86_64-linux/ghc-8.6.5
git clean -fd
git fetch --all && git checkout tags/1.19.0 && git pull
cabal build cardano-node cardano-cli
```

{% hint style="info" %}
コンピュータの処理能力によっては、構築プロセスに数分から数時間かかる場合があります。
{% endhint %}

**cardano-cli** と **cardano-node** が、指定したバージョンに更新されたことを確認して下さい。

```bash
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") version
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") version
```

{% hint style="danger" %}
バイナリーを更新する前にノードを停止します。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
killall cardano-node
```
{% endtab %}

{% tab title="リレーノード" %}
```
killall cardano-node
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
次に、ノードを再起動して正常に同期が開始されているか確認して下さい。
{% endhint %}

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cd $NODE_HOME
./startBlockProducingNode.sh
```
{% endtab %}

{% tab title="リレーノード1" %}
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

以前使用していたフォルダをバックアップとして保存し、新しく構築された**cardano-node**フォルダーに切り替えます。

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
killall cardano-node
```
{% endtab %}

{% tab title="リレーノード1" %}
```
killall cardano-node
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


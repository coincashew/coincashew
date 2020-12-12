---
description: >-
  最新ノードをソースコードからビルドするには、数分～数時間かかる場合があります。その間プールを停止させるとブロック生成のチャンスが失われ、委任者に迷惑がかかります。プール停止時間を最小限に抑えた方法でアップデートするよう心がけましょう。
---

## 🚀 このマニュアルに関する問い合わせ先

{% hint style="success" %}
このマニュアルは役に立ちましたか？ 不明な点がある場合は、下記までご連絡下さい。

・コミュニティ：[Cardano SPO Japanese Guild](https://discord.com/invite/3HnVHs3)

・Twitter：[@btbfpark](https://twitter.com/btbfpark)

・Twitter：[@X\_StakePool\_XSP](https://twitter.com/X_StakePool_XSP)

{% endhint %}

{% hint style="success" %} 2020年12月11日時点でこのガイドは v.1.24.2に対応しています。 😁 {% endhint %}

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
git clone https://github.com/input-output-hk/cardano-node.git cardano-node2
cd cardano-node2/
```

{% hint style="danger" %}
最新のリリースに必要となる他の更新や依存関係については、パッチノートを参照して下さい。
{% endhint %}

{% tabs %} {% tab title="v1.23.0からバージョンアップする場合" %} このリリースは、今後のアレグラとメアリーのハードフォークとそれらがもたらす新機能のサポートを提供します。

・Allegraハードフォークは、Catalyst財務スキームをサポートするために必要ないくつかの機能を追加します。スロット番号を介して、既存のマルチシグスクリプト言語を時間の述語で拡張します。これにより、例えば特定の時点までの使用できないスクリプトアドレスを作成できます。  
  
・Maryハードフォークはマルチアセットサポートを追加します。これはERC20及びERC721トークン相当しますが、UTｘO元帳でネイティブにサポートされます。これはGoguen機能セットの一部です。これは非常に重要な機能であり、交換を含む全てのカルダノウォレットの実装に影響します。  
  
ステークプールオペレーター(SPO)と取引所は、ノード構成の「オプション」セクションを下記のエントリーで更新する必要がありますので、後ほどmainnet-config.jsonを更新します。
```bash
  "options": {
    "mapBackends": {
      "cardano.node.resources": [
        "EKGViewBK"
      ],
```
{% endtab %}



{% tab title="1.21.1からバージョンアップする場合" %} このリリースには、今後のアレグラとメアリーのハードフォークとそれらがもたらす新機能をサポートするためのかなりの量の内部変更が含まれています。これはAllegraハードフォーク前の最終リリースではありませんが、AllegraとMaryの両方のハードフォークの機能の大部分が含まれています。  
  
・Allegraハードフォークは、Catalyst財務スキームをサポートするために必要ないくつかの機能を追加します。スロット番号を介して、既存のマルチシグスクリプト言語を時間の述語で拡張します。これにより、例えば特定の時点までの使用できないスクリプトアドレスを作成できます。  
  
・Maryハードフォークはマルチアセットサポートを追加します。これはERC20及びERC721トークン相当しますが、UTｘO元帳でネイティブにサポートされます。これはGoguen機能セットの一部です。これは非常に重要な機能であり、交換を含む全てのカルダノウォレットの実装に影響します。  
  
このリリースでもう１つ注目せうべき変更は、まだ多くのブロックを作成していない小さなプールに役立つプールランキングの調整です。新しいプールが完全でない平均レベルで実行されると想定する代わりに、多かれ少なかれ完全に実行されると想定するように初期ベイジアン事前確率を調整しました。この事前情報は、実際のパフォーマンス履歴に基づいて引き続き更新されるため、パフォーマンスの低いプールはランキングで低下します。この変更はパフォーマンス履歴がほとんどなく、スコアが最初の事前設定の影響を大きく受けるため、これまでにブロックがほとんど生成されていない小さなプールに特に役に立ちます。  
  
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
nano mainnet-config.json
 ```
 以下を該当する部分に貼り付けます。

 ```
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
```
```
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

#### vrf.skeyのパーミッションを変更する（ブロックプロデューサーの場合のみ）

バージョン1.23.0より、vrf.skeyパーミッションチェックが実装され、所有者読み取り専用権限に設定することでノードを起動できます。
```
cd $NODE_HOME
chmod 400 vrf.skey
```



#### gLiveViewをインストールします（任意）

LiveViewの代わりにノードを監視するコミュニティ製の監視ツールです。  
(メモリー使用率が高くなることに注意して下さい)

[インストールはこちらを参照してください](./#18-13-gliveview-node-status-monitoring)


{% endtab %} {% endtabs %}

### 新しいバイナリーファイルをコンパイルする

古いバイナリーを削除し、最新のバイナリーを再構築します。次のコマンドを実行して、最新のバイナリをプルしてビルドします。必要に応じて、チェックアウト **tag** または **branch** を変更して下さい。

```bash
cd $HOME/git/cardano-node2
cabal clean
cabal update
rm -rf $HOME/git/cardano-node2/dist-newstyle/build/x86_64-linux/ghc-8.6.5
rm -rf $HOME/git/cardano-node2/dist-newstyle/build/x86_64-linux/ghc-8.10.2
git clean -fd
git fetch --all --recurse-submodules --tags
git checkout tags/1.24.2 && git pull
cabal configure -O0 -w ghc-8.10.2
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
cabal build cardano-node cardano-cli
```

{% hint style="info" %}
コンピュータの処理能力によっては、ビルドプロセスに数分から数時間かかる場合があります。
{% endhint %}

**cardano-cli** と **cardano-node** が希望のバージョンに更新されたことを確認して下さい。

```bash
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") version
```
```bash
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") version
```

### mainnet-config.jsonのアップデート  
  
* 既存のファイルをバックアップします。
```bash
cd $NODE_HOME
cp mainnet-config.json mainnet-config-bk.json
 ```

* 最新のmainnet-config.jsonをダウンロードします。
```bash
NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json
```
値を変更します。  
* TraceBlockFetchDecisionsを「true」に変更します。
```bash
sed -i ${NODE_CONFIG}-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
```
```bash
sed -i ${NODE_CONFIG}-config.json -e "s/127.0.0.1/0.0.0.0/g" 
```

### ログファイルを作成するように設定する
 ```bash
nano mainnet-config.json
 ```
* defaultScribesを下記のように書き換える
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
```
* setupScribesを下記のように書き換える
 ```bash
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
  
 Ctrl+Oでファイルを保存し、Ctrl+Xで閉じる

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
```
```bash
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

バージョンを確認します。
```bash
cardano-node version
cardano-cli version
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

## 👏 5. 寄付とクレジット表記

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
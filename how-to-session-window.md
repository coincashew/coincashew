---
description: ローカルPCからSSHで接続している場合、ノードスクリプトを別セッションで起動させることでノードセッションを終了させずにバックグラウンド実行できる
---

# ノード起動スクリプトを別セッションで起動する方法

## 1.別セッション起動用のスクリプトを作成する。  
  
  
  
{% tabs %}
{% tab title="ブロックプロデューサーノード" %}  
  
  
```bash
cd $NODE_HOME
nano startStakePool.sh
```
新規ファイルを開いて、下記のコマンドを貼り付けます。
  
```bash
#!/bin/bash
SESSION=node
tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
   # tmux attach-session -t $SESSION
    tmux new-session -s $SESSION -n window -d
    tmux send-keys -t $SESSION:window. $NODE_HOME/startBlockProducingNode.sh Enter
    echo Stakepool started. \"tmux a\" to view.
fi
```
Ctrl+O で保存し、Ctrl+Xで閉じます  
{% endtab %}

{% tab title="リレーノード1" %}
```bash
cd $NODE_HOME
nano startStakePool.sh
```
新規ファイルを開いて、下記のコマンドを貼り付けます。
```bash
#!/bin/bash
SESSION=node
tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
   # tmux attach-session -t $SESSION
    tmux new-session -s $SESSION -n window -d
    tmux send-keys -t $SESSION:window. $NODE_HOME/startRelayNode1.sh Enter
    echo Stakepool started. \"tmux a\" to view.
fi
```
Ctrl+O で保存し、Ctrl+Xで閉じます  
{% endtab %}
{% endtabs %}

## 2.startStakePool.shの使い方

### 起動する(初回のみ)

```text
cd $NODE_HOME
chmod +x startStakePool.sh
./startStakePool.sh
tmux a
```

### バックグラウンド実行に切り替える

```text
Ctrl+B D
```
※再びノード監視を表示させたい場合は「tmux a」  



### ノードを終了させる
```text
Ctrl+C
```
※別セッション内(tmux)でノードを終了させないと、ノード再起動時の同期が遅い  

### 別セッション内(tmux)でのノード再起動
```text
cd $NODE_HOME
./startRelayNode1.sh
```

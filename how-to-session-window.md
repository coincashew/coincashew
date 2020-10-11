---
description: ローカルPCからSSHで接続している場合、ノードスクリプトを別セッションで起動させることでノードセッションを終了させずにバックグラウンド実行できる
---

# ノード起動スクリプトを別セッションで起動する方法

## 1.別セッション起動用のスクリプトを作成する。  
  

{% tabs %}
{% tab title="ブロックプロデューサーノード" %}
```bash
cat > $NODE_HOME/startStakePool.sh << EOF 
#!/bin/bash
SESSION=node
tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
   # tmux attach-session -t $SESSION
    tmux new-session -s $SESSION -n window -d
    tmux send-keys -t $SESSION:window.0 ./startBlockProducingNode.sh Enter
    set -g mouse-resize-pane on
    echo Stakepool started. \"tmux a\" to view.
fi
EOF
```
{% endtab %}

{% tab title="リレーノード1" %}
```bash
cat > $NODE_HOME/startStakePool.sh << EOF 
#!/bin/bash
SESSION=node
tmux has-session -t $SESSION 2>/dev/null
if [ $? != 0 ]; then
   # tmux attach-session -t $SESSION
    tmux new-session -s $SESSION -n window -d
    tmux send-keys -t $SESSION:window. ./startRelayNode1.sh Enter
    echo Stakepool started. \"tmux a\" to view.
fi
EOF
```
{% endtab %}
{% endtabs %}

## 2.startStakePool.shの使い方

### 起動する(初回のみ)

```text
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
Shift+q
```
※別セッション内(tmux)でノードを終了させないと、ノード再起動時の同期が遅い  

### 別セッション内(tmux)でのノード再起動
```text
cd $NODE_HOME
./startRelayNode1.sh
```

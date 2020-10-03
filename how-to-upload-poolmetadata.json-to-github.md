# poolMetaData.jsonをGithubにアップロードする方法

## poolmetadata.jsonをホストするクイックステップ

1. Githubアカウントを作成しログインします [https://github.com/](https://github.com/)
2. 短い名前で**new repository** を名を作成します。
3. **Create repository**をクリックします。
3. 小さい文字で書かれた"**creating a new file**"をクリックします。

![](.gitbook/assets/git1.png)

1. ファイル名を **poolMetaData.json** として入力し **json** コンテンツを貼り付けます。

![](.gitbook/assets/git2.png)

1. **Commit new file**をクリックします。

![](.gitbook/assets/git3.png)

1. 新しいファイルの名前をクリックします。

2. **Rawボタン**をクリックします。

3. URLをコピーします。

> 例: [https://raw.githubusercontent.com/coincashew/test/master/poolMetaData.json](https://raw.githubusercontent.com/coincashew/test/master/poolMetaData.json)

9. URLは64文字より短くする必要があります。 [https://git.io/](https://git.io/) を使用してURLを短縮します。

10. 8でコピーしたURLを貼り付けます。

> 例:  
> [https://git.io/JUcnl](https://git.io/JUcnl)

11.  短縮されたURLを`--metadata-url` に記述します。


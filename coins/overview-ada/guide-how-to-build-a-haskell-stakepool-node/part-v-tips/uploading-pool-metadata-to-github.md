# Uploading Pool Metadata to GitHub

To host the file containing metadata for your pool on GitHub:

1. Sign up for a Github account by visiting [https://github.com/](https://github.com)
2. Create a **new repository** with a short name
3. Click Get started by "**creating a new file**"

![](../../../../.gitbook/assets/git1.png)

4\. Enter your file name as **poolMetaData.json** and paste in your **json **content.

![](../../../../.gitbook/assets/git2.png)

5\. Click **Commit new file**

![](../../../../.gitbook/assets/git3.png)

6\. Click your new file's name

7\. Click on **Raw button**

8\. Copy the URL into your clipboard

> Example: [https://raw.githubusercontent.com/coincashew/test/master/poolMetaData.json](https://raw.githubusercontent.com/coincashew/test/master/poolMetaData.json)

9\. The URL must be shorter than 64 characters. Use [https://git.io/](https://git.io) to shorten it.

> Example:\
> [https://git.io/JUcnl](https://git.io/JUcnl)

10\. Use this tinyurl URL`--metadata-url` in your stakepool registration transaction.

11\. Download your json with `wget` from your git.io url

```bash
cd $NODE_HOME
wget -O poolMetaData.json <your git.io link>
```

{% hint style="info" %}
This step may be required because git.io may change the json file by removing spaces and new lines.
{% endhint %}

12\. Generate the updated pool metadata hash

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

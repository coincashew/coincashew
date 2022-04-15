# Uploading Pool Metadata to GitHub

**To host the file containing metadata for your pool on GitHub:**

1. Sign up for a [GitHub](https://github.com) account.
2. Create a **new repository** with a short name
3. Click Get started by "**creating a new file**"  
![](../../../../.gitbook/assets/git1.png)  
4. Enter your file name as **poolMetaData.json** and paste in your JSON content.  
![](../../../../.gitbook/assets/git2.png)  
5. Click **Commit New File**  
![](../../../../.gitbook/assets/git3.png)  
6. Click your new file's name
7. Click the **Raw** button.
8. Copy the URL into your clipboard  
{% hint style="info" %}
Example: [https://raw.githubusercontent.com/coincashew/test/master/poolMetaData.json](https://raw.githubusercontent.com/coincashew/test/master/poolMetaData.json)
{% endhint %}  
9. If the URL that you copied in step 8 is longer than 64 characters, then use [TinyURL](https://tinyurl.com/app) to shorten the URL.  
10. In your stakepool registration transaction, set the value of the `--metadata-url` parameter to a URL having a length of less than 64 characters.  
11. On your block producer node, download your JSON file from your git.io URL using the `wget` command:
```bash
cd $NODE_HOME
wget -O poolMetaData.json <your git.io link>
```  
{% hint style="info" %}
git.io may change your JSON file by removing spaces and new lines. Download your JSON file to ensure that the metadata hash you calculate in step 12 is correct.
{% endhint %}
12. On your block producer node, generate the updated pool metadata hash.  
```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```
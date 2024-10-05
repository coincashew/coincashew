# Downloading Configuration Files

Running Cardano Node requires multiple configuration files. You must download the configuration files on each computer hosting an instance of Cardano Node for your stake pool.

**To download Cardano Node configuration files:**

1. On the computer hosting your block-producing node, using a Web browser navigate to the Cardano Node [GitHub repository](https://github.com/IntersectMBO/cardano-node), then browse to the latest release, then click to expand the **Downloads** dropdown list in the _Technical Specification_ section of the release notes, and then click the **Configuration Files** link.
2. On the Environments page, click **Production (Mainnet)**, and then click the following links: **Node Config (Non-block-producers)**, **Node Config (Block-producers)**, **Node Topology**, **Byron Genesis**, **Shelley Genesis**, **Alonzo Genesis** and **Conway Genesis**. Save all configuration files using the default file names in the folder that you set for the `$NODE_HOME` environment variable.

{% hint style="info" %}
You set the `NODE_HOME` environment variable and created the corresponding folder when [Installing GHC and Cabal](../part-i-installation/installing-ghc-and-cabal.md).
{% endhint %}

3. On each computer hosting a relay or block-producing node for your stake pool, repeat steps 1 to 2

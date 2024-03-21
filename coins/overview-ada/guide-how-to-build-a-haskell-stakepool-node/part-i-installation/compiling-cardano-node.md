# Compiling Cardano Node

After you finish installing GHC and Cabal successfully, you can compile Cardano Node from source code.

**To compile Cardano Node:**

1. In a terminal window on the computer hosting your block-producing node, type the following command to navigate to the working directory that you created in the procedure [Installing Glasgow Haskell Compiler and Cabal](installing-ghc-and-cabal.md):

```bash
cd $HOME/git
```

1. To download Cardano Node source code, type:

```bash
git clone https://github.com/IntersectMBO/cardano-node.git
cd cardano-node
git fetch --all --recurse-submodules --tags
```

1. To switch the repository that you downloaded to your local computer in step 2 to the latest tagged commit, type:

```bash
git checkout $(curl -s https://api.github.com/repos/IntersectMBO/cardano-node/releases/latest | jq -r .tag_name)
```

{% hint style="info" %}
Typing a dollar sign ("$") before a command in parentheses refers to the output of the command in parentheses. For example, using a Web browser you can navigate to the above URL https://api.github.com/repos/IntersectMBO/cardano-node/releases/latest to display the data that the `curl` command retrieves, and then confirm the value of the `tag_name` attribute that the `jq` command selects.
{% endhint %}

1. To adjust the project configuration to disable optimization and set the recommended compiler version, type the following command where `<GHCVersionNumber>` is the GHC version that you set in the procedure [Installing Glasgow Haskell Compiler and Cabal](installing-ghc-and-cabal.md):

```bash
cabal update
cabal configure -O0 -w ghc-<GHCVersionNumber>
```

1. Using a text editor, open the file named `cabal.project.local` located in the current folder, and then add the following lines at the end of the file to avoid installing a custom libsodium library:

```bash
package cardano-crypto-praos
 flags: -external-libsodium-vrf
```

1. Save and close the `cabal.project.local` file.
2. To produce executable `cardano-node` and `cardano-cli` binaries, type:

```bash
cabal build cardano-node cardano-cli
```

{% hint style="info" %}
Depending on your the processing power of your computer, the build process requires about 20 minutes to complete.
{% endhint %}

1. To copy the `cardano-node` and `cardano-cli` binaries that you produced in step 7 into the `/usr/local/bin` directory, type:

```bash
sudo cp -p "$(./scripts/bin-path.sh cardano-node)" /usr/local/bin/cardano-node
sudo cp -p "$(./scripts/bin-path.sh cardano-cli)" /usr/local/bin/cardano-cli
```

1. To confirm that the version installed on your computer matches the latest release available in the Cardano Node [GitHub repository](https://github.com/input-output-hk/cardano-node), type:

```bash
cardano-node --version
cardano-cli --version
```

1. On each computer hosting a relay node for your stake pool, repeats steps 1 to 9

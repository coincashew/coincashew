# Installing the Glasgow Haskell Compiler and Cabal

To compile Cardano Node using source code, you must install the Glasgow Haskell Compiler (GHC) and Cabal for building applications and libraries.

<!-- Reference:
https://www.haskell.org/cabal/ -->

For each Cardano Node release, Input-Output recommends compiling binaries using specific versions of GHC and Cabal. For example, refer to [Installing cardano-node and cardano-cli from source](https://developers.cardano.org/docs/get-started/installing-cardano-node/) in the [Cardano Developer Portal](https://developers.cardano.org/docs/get-started/) to determine the GHC and Cabal versions required for the current Cardano Node release. _Table 1_ lists GHC and Cabal version requirements for the current Cardano Node release.

_Table 1 Current Cardano Node Version Requirements_

|  Release Date  |  Cardano Node Version  |  GHC Version   | Cabal Version  |
|:--------------:|:----------------------:|:--------------:|:--------------:|
|  March 7, 2022 |         1.34.1         |     8.10.7     |    3.6.2.0     |

**To install GHC and Cabal:**

1. In a terminal window on the computer hosting your block-producing node, to install the latest versions of all previously installed packages assuming the answer `yes` to all prompts, type:
```bash
sudo apt-get update -y
sudo apt-get upgrade -y
```

2. To install packages and tools required for downloading and compiling Cardano Node source code, type:
```bash
sudo apt-get install autoconf automake build-essential curl g++ git jq libffi-dev libgmp-dev libncursesw5 libssl-dev libsystemd-dev libtinfo-dev libtool make pkg-config tmux wget zlib1g-dev -y
```
{% hint style="info" %}
To list all packages installed on your computer, type `apt list --installed`
{% endhint %}

<!-- In addition, the previous procedure recommended typing the command sudo apt-get install bc rsync htop libncurses-dev libtinfo5 Currently in the guide, instructions for installing bc and rsync are included when needed, and htop is not used. libncurses-dev and libtinfo5 are installed automatically. -->

<!-- GHCup requires build-essential curl libffi-dev libffi7 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 -->

3. To use the GHCup installer to install GHC and Cabal, type:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

4. During installation, when prompted:  
  i. Press ENTER to proceed.  
  ii. To prepend the required PATH variable to `$HOME/.bashrc`, type `P`  
  {% hint style="info" %}
  The `$HOME` environment variable or `~` tilde prefix refers to the home directory associated with your login name.
  {% endhint %}  
  iii. When prompted to install haskell-language-server (HLS), type `N`  
  iv. When prompted to install slack, type `N`  
  v. Press ENTER to proceed.

<!-- References:
http://www.gnu.org/software/bash/manual/html_node/Tilde-Expansion.html
https://stackoverflow.com/questions/39331531/difference-between-login-name-and-user-name -->

5. When GHCup finishes installing GHC and Cabal, type the following commands to reload your shell profile, and then confirm that GHCup installed correctly:
```bash
source $HOME/.bashrc
ghcup --version
```
{% hint style="info" %}
If GHCup is installed correctly, then the `ghcup --version` command returns `The GHCup Haskell installer, version <GHCupVersionNumber>` where `<GHCupVersionNumber>` is the version number of GHCup installed on your computer.
{% endhint %}

6. To set the Glasgow Haskell Compiler to the version required for compiling the current Cardano Node release, type the following commands where `<GHCVersionNumber>` is the GHC version that you need to install and use:
```bash
ghcup install ghc <GHCVersionNumber>
ghcup set ghc <GHCVersionNumber>
ghc --version
```

7. To set Cabal to the version required for compiling the current Cardano Node release, type the following commands where `<CabalVersionNumber>` is the Cabal version that you need to install and use:
```bash
ghcup install cabal <CabalVersionNumber>
ghcup set cabal <CabalVersionNumber>
cabal --version
```

8. To create a working directory to store source code and builds related to Cardano Node, type:
```bash
mkdir $HOME/git
cd $HOME/git
```

9. To download, compile and install `libsodium`, type:
```bash
git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
sudo make install
```  
{% hint style="info" %}
If you are using the **Debian** GNU/Linux distribution, then additional linking may be required:
```bash
sudo ln -s /usr/local/lib/libsodium.so.23.3.0 /usr/lib/libsodium.so.23
```
If you are using the **CentOS** Linux distribution on Amazon Web Services, then clearing the lib cache may be required:
```bash
sudo ldconfig
```
If you are using Ubuntu on a **Raspberry Pi 4**, then type the following command to resolve a `cannot find -lnuma` error message when compiling `libsodium`:
```bash
sudo apt-get install libnuma-dev
```
{% endhint %}

10. Using a text editor, open the `$HOME/.bashrc` file, and then add the following lines at the end of the file:
```bash
# Set environment variables so that the compiler finds libsodium on your computer
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
# Set an environment variable indicating the file path to configuration files and scripts
# related to operating your Cardano node
export NODE_HOME="$HOME/cardano-my-node"
# Set an environment variable indicating the Cardano network cluster where your node runs
export NODE_CONFIG="mainnet"
```
{% hint style="info" %}
If you plan to use your Cardano node on the testnet network instead of mainnet, then replace the line `export NODE_CONFIG="mainnet"` in your `$HOME/.bashrc` file with `export NODE_CONFIG="testnet"` Also, when working through the _How to Set Up a Cardano Stake Pool_ guide, replace every instance of the command option `--mainnet` with `--testnet-magic 1097911063`
{% endhint %}

11. Save and close the `$HOME/.bashrc` file.

12. To create the folder set for the `$NODE_HOME` environment variable in your `$HOME/.bashrc` file, type:
```bash
mkdir $HOME/cardano-my-node
```

13. To reload your shell profile, type:
```bash
source $HOME/.bashrc
```

14. On each computer hosting a relay node for your stake pool, repeat steps 1 to 13
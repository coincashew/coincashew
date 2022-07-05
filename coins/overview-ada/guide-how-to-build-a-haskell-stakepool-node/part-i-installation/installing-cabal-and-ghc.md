# Installing Cabal and GHC

If using Ubuntu Desktop, **press** Ctrl+Alt+T. This will launch a terminal window.

First, update packages and install Ubuntu dependencies.

```bash
sudo apt-get update -y
```

```
sudo apt-get upgrade -y
```

```
sudo apt-get install git jq bc make automake rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf -y
```

Install Libsodium.

```bash
mkdir $HOME/git
cd $HOME/git
git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
sudo make install
```

{% hint style="info" %}
**Debian OS pool operators**: extra lib linking may be required.

```bash
sudo ln -s /usr/local/lib/libsodium.so.23.3.0 /usr/lib/libsodium.so.23
```

**AWS Linux CentOS pool operators**: clearing the lib cache may be required.

```bash
sudo ldconfig
```

**Raspberry Pi 4 with Ubuntu pool operators**: extra lib linking may be required.

```bash
sudo apt-get install libnuma-dev
```

This will help to solve "cannot find -lnuma" error when compiling.
{% endhint %}

Install Cabal and dependencies.

```bash
sudo apt-get -y install pkg-config libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev build-essential curl libgmp-dev libffi-dev libncurses-dev libtinfo5
```

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

Answer **NO** to installing haskell-language-server (HLS).

Answer **YES** to automatically add the required PATH variable to ".bashrc".

```bash
cd $HOME
source .bashrc
ghcup upgrade
ghcup install cabal 3.4.0.0
ghcup set cabal 3.4.0.0
```

Install GHC.

```bash
ghcup install ghc 8.10.4
ghcup set ghc 8.10.4
```

Update PATH to include Cabal and GHC and add exports. Your node's location will be in **$NODE\_HOME**. The [cluster configuration](https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html) is set by **$NODE\_CONFIG**.

```bash
echo PATH="$HOME/.local/bin:$PATH" >> $HOME/.bashrc
echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> $HOME/.bashrc
echo export NODE_HOME=$HOME/cardano-my-node >> $HOME/.bashrc
echo export NODE_CONFIG=mainnet>> $HOME/.bashrc
source $HOME/.bashrc
```

{% hint style="info" %}
:bulb: **How to use this Guide on TestNet**

Run the following commands to set your **NODE\_CONFIG** to testnet rather than mainnet.

```bash
echo export NODE_CONFIG=testnet>> $HOME/.bashrc
source $HOME/.bashrc
```

As you work through this guide, replace every instance of\*\* \*\*CLI parameter

```bash
 --mainnet 
```

with

```bash
--testnet-magic 1097911063
```
{% endhint %}

Update cabal and verify the correct versions were installed successfully.

```bash
cabal update
cabal --version
ghc --version
```

{% hint style="info" %}
Cabal library should be version 3.4.0.0 and GHC should be version 8.10.4
{% endhint %}

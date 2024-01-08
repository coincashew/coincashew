# Configuring an Air-gapped, Offline Computer

Store and safeguard the sensitive secret (private) keys for your stake pool using an air-gapped, offline computer. The most effective technique to prevent private key exposure is to guarantee that a necessary private key is never held for any length of time on any Internet-connected computer, also known as a hot node. Your air-gapped, offline computer may also be referred to as a cold environment.

Your air-gapped, offline computer:

* Protects against key-logging attacks; malware- or virus-based attacks; and, other firewall or security exploits
* Must not have a wired or wireless network connection
* Is not a virtual machine (VM) on a computer having a network connection
* Is physically isolated from the rest of your network

Read more about requirements to [Air Gap](https://en.wikipedia.org/wiki/Air\_gap\_\(networking\)).

## System Requirements

The system requirements for the air-gapped, offline computer that you use to support your stake pool operation are minimal. The computer must support the same operating system that you install on your hot nodes. For example, you may use a Raspberry Pi or an upcycled older computer or laptop.

Your cold environment requires a USB port to facilitate transporting files to and from your block-producing node using a USB stick or other removable media.

## Copying the cardano-cli Binary

Copy the `cardano-cli` binary that you produced when [Compiling Cardano Node](../part-i-installation/compiling-cardano-node.md) to your air-gapped, offline computer.

**To copy the cardano-cli binary to your cold environment:**

1. Insert the removable media that you want to use to transfer files into a hot node where you compiled the `cardano-cli` binary.
2. If you followed the Coin Cashew guide, then copy the `cardano-cli` binary located in the folder `/usr/local/bin/` to the removable media that you inserted in step 1

{% hint style="info" %}
If you do not know the location of the `cardano-cli` binary, then type `which cardano-cli`
{% endhint %}

3. Eject the removable media from your hot node, and then insert the removable media into your air-gapped, offline computer.
4. On your air-gapped, offline computer, copy the `cardano-cli` binary from the removable media to the `/usr/local/bin/` folder.
5. To give execute permissions to the `cardano-cli` binary, type:

```bash
sudo chmod +x /usr/local/bin/cardano-cli
```

## Setting the NODE\_HOME Environment Variable

For convenience when following the Coin Cashew guide, create a `NODE_HOME` environment variable on your air-gapped, offline computer set to the same file path that you set on your block-producing and relay nodes when [Installing GHC and Cabal](../part-i-installation/installing-ghc-and-cabal.md).

**To create a NODE\_HOME environment variable:**

1. On your air-gapped, offline computer, open the file `$HOME/.bashrc` using a text editor, and then add the following line at the end of the file:

```bash
export NODE_HOME="$HOME/cardano-my-node"
```

2. To create the folder set for the `NODE_HOME` environment variable in the `$HOME/.bashrc` file, type:

```bash
mkdir $HOME/cardano-my-node
```

3. To reload your shell profile, type:

```bash
source $HOME/.bashrc
```

## Installing libsecp256k1 <a href="#libsecp" id="libsecp"></a>

To use the `cardano-cli` binary on your air-gapped, offline computer you must also install the `libsecp256k1` library that you installed on your hot nodes. Use the following procedure to install `libsecp256k1` without connecting your air-gapped, offline computer to the Internet.

{% hint style="info" %}
Alternately, thanks to [TerminadaPool](https://terminada.io/), if you prefer you can [create your own Debian (DEB) package](https://github.com/TerminadaPool/libsecp256k1-iog-debian) to install `libsecp256k1` offline.
{% endhint %}

**To install the `libsecp256k1` library on your air-gapped, offline computer:**

1. On the air-gapped, offline computer, open the `$HOME/.bashrc` file using a text editor, and then add the following lines at the end of the file:

```bash
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
```

2. Save and close the `$HOME/.bashrc` file.
3. To reload the `$HOME/.bashrc` file, type:

```bash
source $HOME/.bashrc
```

4. On the air-gapped, offline computer, if the `/usr/local/lib/pkgconfig` folder does not exist, then type the following command to create the folder:

```bash
sudo mkdir /usr/local/lib/pkgconfig
```

5. Using removable media, copy the following four files from a block-producing or relay node where you installed `libsecp256k1` to the same location on your air-gapped, offline computer:

```bash
/usr/local/lib/libsecp256k1.a
/usr/local/lib/libsecp256k1.la
/usr/local/lib/libsecp256k1.so.0.0.0
/usr/local/lib/pkgconfig/libsecp256k1.pc
```

6. To set file permissions and ownership for the `libsecp256k1` library files on the air-gapped, offline computer, type the following commands using a terminal window:

```bash
cd /usr/local/lib
sudo chown root:root libsecp256k1.*
sudo chmod 644 libsecp256k1.a
sudo chmod 755 libsecp256k1.la
sudo chmod 755 libsecp256k1.so.0.0.0
sudo chown root:root ./pkgconfig/libsecp256k1.pc
sudo chmod 644 ./pkgconfig/libsecp256k1.pc
```

7. To create symbolic links, type:

```bash
sudo ln -s libsecp256k1.so.0.0.0 libsecp256k1.so
sudo ln -s libsecp256k1.so.0.0.0 libsecp256k1.so.0
```

8. Type `ls -la` and then confirm that in step 7 you created the following symbolic links:

```bash
lrwxrwxrwx root root libsecp256k1.so -> libsecp256k1.so.0.0.0
lrwxrwxrwx root root libsecp256k1.so.0 -> libsecp256k1.so.0.0.0
```

9. To update available symbolic links for currently shared libraries, type:

```bash
sudo ldconfig
```
## Installing the blst Library <a href="#blst" id="blst"></a>

Use the following procedure to install the `blst` library on your air-gapped, offline computer without connecting to the Internet.

1. After cloning the `blst` GitHub repository at https://github.com/supranational/blst on a block-producing node or relay node, using removable media copy the `blst` folder to your air-gapped, offline computer.

2. Type the following commands:

```
cd blst
git checkout v0.3.10
./build.sh
cat > libblst.pc << EOF
prefix=/usr/local
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libblst
Description: Multilingual BLS12-381 signature library
URL: https://github.com/supranational/blst
Version: 0.3.10
Cflags: -I\${includedir}
Libs: -L\${libdir} -lblst
EOF
sudo cp libblst.pc /usr/local/lib/pkgconfig/
sudo cp bindings/blst_aux.h bindings/blst.h bindings/blst.hpp /usr/local/include/
sudo cp libblst.a /usr/local/lib
sudo chmod u=rw,go=r /usr/local/{lib/{libblst.a,pkgconfig/libblst.pc},include/{blst.{h,hpp},blst_aux.h}}
```
<!-- Source: https://github.com/input-output-hk/cardano-node-wiki/blob/main/docs/getting-started/install.md-->


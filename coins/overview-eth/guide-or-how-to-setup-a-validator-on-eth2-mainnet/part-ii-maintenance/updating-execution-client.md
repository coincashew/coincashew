# Updating Execution Client

## :rocket: Automated Updates

:pill:**Install** [**EthPillar**](../../ethpillar.md): a simple companion UI for node management!&#x20;

Update your software with a keystroke.

To update, navigate to

`EthPillar > Execution Client > Update to latest release`

<figure><img src="../../../../.gitbook/assets/el-update.png" alt=""><figcaption><p>EthPillar Update</p></figcaption></figure>

## :fast\_forward: Manual Updates

When a new release is cut, you will want to update to the latest stable release. The following shows you how to update your execution client.

{% hint style="warning" %}
Always review the **release notes** before updating. There may be changes requiring your attention.

* [Nethermind](https://github.com/NethermindEth/nethermind/releases)
* [Besu](https://github.com/hyperledger/besu/releases)
* [Geth](https://github.com/ethereum/go-ethereum/releases)
* [Erigon](https://github.com/ledgerwatch/erigon/releases)
{% endhint %}

{% hint style="success" %}
:fire: **Pro tip**: Plan your update to overlap with the longest attestation gap. [Learn how here.](finding-the-longest-attestation-slot-gap.md)
{% endhint %}

## Step 1: Select your execution client.

{% hint style="warning" %}
Staking setups prior to July 2023:\
Using **eth1** as the execution client service name? [V1 update instructions available here.](https://www.coincashew.com/coins/overview-eth/archived-guides/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/updating-your-execution-client)
{% endhint %}

### Nethermind

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-zip and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/NethermindEth/nethermind/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux-x64)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O nethermind.zip $BINARIES_URL
unzip -o nethermind.zip -d $HOME/nethermind
rm nethermind.zip
```

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries and restart the services.

```bash
sudo rm -rf /usr/local/bin/nethermind
sudo mv $HOME/nethermind /usr/local/bin/nethermind
sudo systemctl start execution
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Build the binaries.

```bash
cd ~/git/nethermind
# Get new tags
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
# Build
dotnet publish src/Nethermind/Nethermind.Runner -c release -o nethermind
```

Verify Nethermind was properly built by checking the version.

```shell
./nethermind/nethermind --version
```

Sample output of a compatible version.

```
Version: 1.25.2+78c7bf5f
Commit: 78c7bf5f2c0819f23e248ee6d108c17cd053ffd3
Build Date: 2024-01-23 06:34:53Z
OS: Linux x64
Runtime: .NET 8.0.1
```

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries and restart the services.

```bash
sudo rm -rf /usr/local/bin/nethermind
sudo mv $HOME/git/nethermind/nethermind /usr/local/bin
sudo systemctl start execution
```

</details>

### Besu

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/hyperledger/besu/releases/latest"
TAG=$(curl -s $RELEASE_URL | jq -r .tag_name)
BINARIES_URL="https://github.com/hyperledger/besu/releases/download/$TAG/besu-$TAG.tar.gz"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O besu.tar.gz $BINARIES_URL
tar -xzvf besu.tar.gz -C $HOME
rm besu.tar.gz
sudo mv $HOME/besu-* besu
```

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries and restart the services.

```bash
sudo rm -rf /usr/local/bin/besu
sudo mv $HOME/besu /usr/local/bin/besu
sudo systemctl start execution
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Build the binaries.

```bash
cd ~/git/besu
# Get new tags
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
# Build
./gradlew installDist
```

Verify Besu was properly built by checking the version.

```shell
./build/install/besu/bin/besu --version
```

Sample output of a compatible version.

```
besu/v23.4.0/linux-x86_64/openjdk-java-17
```

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries and restart the services.

```bash
sudo rm -rf /usr/local/bin/besu
sudo cp -a $HOME/git/besu/build/install/besu /usr/local/bin/besu
sudo systemctl start execution
```

</details>

### Geth

<details>

<summary>Option 1 - Download binaries</summary>

<pre class="language-bash"><code class="lang-bash">RELEASE_URL="https://geth.ethereum.org/downloads"
<strong>FILE="https://gethstore.blob.core.windows.net/builds/geth-linux-amd64[a-zA-Z0-9./?=_%:-]*.tar.gz"
</strong>BINARIES_URL="$(curl -s $RELEASE_URL | grep -Eo $FILE | head -1)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O geth.tar.gz $BINARIES_URL
tar -xzvf geth.tar.gz -C $HOME --strip-components=1
</code></pre>

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Install new binaries, restart the services and cleanup files.

```bash
sudo mv $HOME/geth /usr/local/bin
sudo systemctl start execution
rm geth.tar.gz COPYING
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Build the binary.

```bash
cd $HOME/git/go-ethereum
# Get new tags
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
# Build
make geth
```

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries and restart the services.

```bash
sudo rm -rf /usr/local/bin/geth
sudo cp $HOME/git/go-ethereum/build/bin/geth /usr/local/bin
sudo systemctl start execution
```

</details>

### Erigon

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

<pre class="language-bash"><code class="lang-bash">RELEASE_URL="https://api.github.com/repos/ledgerwatch/erigon/releases/latest"
<strong>BINARIES_URL="$(curl -s $RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep linux_amd64)"
</strong>
echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O erigon.tar.gz $BINARIES_URL
tar -xzvf erigon.tar.gz -C $HOME
rm erigon.tar.gz README.md
</code></pre>

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries and restart the services.

```bash
sudo rm -rf /usr/local/bin/erigon
sudo mv $HOME/erigon /usr/local/bin/erigon
sudo systemctl start execution
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Build the binary.

```bash
cd $HOME/git/erigon
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
make erigon
```

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries and restart the services.

```bash
sudo rm -rf /usr/local/bin/erigon
sudo cp $HOME/git/erigon/build/bin/erigon /usr/local/bin
sudo systemctl start execution
```

</details>

### Reth

<details>

<summary>Option 1 - Download binaries</summary>

Run the following to automatically download the latest linux release, un-tar and cleanup.

```bash
RELEASE_URL="https://api.github.com/repos/paradigmxyz/reth/releases/latest"
BINARIES_URL="$(curl -s $RELEASE_URL | jq -r '.assets[] | select(.name | startswith ("reth")) | .browser_download_url' | grep x86_64-unknown-linux-gnu.tar.gz$)"

echo Downloading URL: $BINARIES_URL

cd $HOME
wget -O reth.tar.gz $BINARIES_URL
tar -xzvf reth.tar.gz -C $HOME
rm reth.tar.gz
```

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries, display the version, and restart the services.

```bash
sudo rm -rf /usr/local/bin/reth
sudo mv $HOME/reth /usr/local/bin
reth --version
sudo systemctl restart execution
```

</details>

<details>

<summary>Option 2 - Build from source code</summary>

Build the binaries.

```bash
cd ~/git/reth
git fetch --tags
# Get latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
# Checkout latest tag
git checkout $latestTag
# Build the release
cargo build --release
```

Verify Reth was built properly by checking the version number.

```bash
~/git/reth/target/release/reth --version
```

In case of compilation errors, run the following sequence.

```bash
rustup update
cargo clean
cargo build --release --features jemalloc
```

Stop the services.

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl stop execution
</strong></code></pre>

Remove old binaries, install new binaries and restart the services.

```bash
sudo rm -rf /usr/local/bin/reth
sudo cp ~/git/reth/target/release/reth /usr/local/bin
sudo systemctl restart execution
```

</details>

## Step 2: Verify services and logs are working properly

```bash
# Verify services status
sudo systemctl status execution
```

```bash
# Check logs
sudo journalctl -fu execution
```

## Step 3: Optional - Verify your validator's attestations on public block explorer

1\) Visit [https://beaconcha.in/](https://beaconcha.in) or [https://beaconscan.com/](https://beaconscan.com)

2\) Enter your validator's pubkey into the search bar and look for successful attestations.

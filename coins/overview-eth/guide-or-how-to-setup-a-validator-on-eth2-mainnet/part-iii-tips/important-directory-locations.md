# :open\_file\_folder: Important Directory Locations

{% hint style="info" %}
In case you need to locate your validator keys, database directories or other important files.
{% endhint %}

#### Consensus engine files and locations

{% tabs %}
{% tab title="Lighthouse" %}
```bash
# Validator Keys
~/.lighthouse/mainnet/validators

# Beacon Chain Data
~/.lighthouse/mainnet/beacon

# List of all validators and passwords
~/.lighthouse/mainnet/validators/validator_definitions.yml

#Slash protection db
~/.lighthouse/mainnet/validators/slashing_protection.sqlite
```
{% endtab %}

{% tab title="Nimbus" %}
```bash
# Validator Keys
/var/lib/nimbus/validators

# Beacon Chain Data
/var/lib/nimbus/db

#Slash protection db
/var/lib/nimbus/validators/slashing_protection.sqlite3

#Logs
/var/lib/nimbus/beacon.log
```
{% endtab %}

{% tab title="Teku" %}
```bash
# Validator Keys
/var/lib/teku

# Beacon Chain Data
/var/lib/teku/beacon

#Slash protection db
/var/lib/teku/validator/slashprotection
```
{% endtab %}

{% tab title="Prysm" %}
```bash
# Validator Keys
~/.eth2validators/prysm-wallet-v2/direct

# Beacon Chain Data
~/.eth2/beaconchaindata
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
# Validator Keystores
$rootDir/keystores

# Validator Secrets
$rootDir/secrets

# Validator DB Data
$rootDir/validator-db
```
{% endtab %}
{% endtabs %}

#### Execution engine files and locations

{% tabs %}
{% tab title="Geth" %}
```bash
# database location
$HOME/.ethereum
```
{% endtab %}

{% tab title="OpenEthereum (Parity)" %}
```bash
# database location
$HOME/.local/share/openethereum
```
{% endtab %}

{% tab title="Besu" %}
```bash
# database location
$HOME/.besu/database
```
{% endtab %}

{% tab title="Nethermind" %}
```bash
#database location
$HOME/.nethermind/nethermind_db/mainnet
```
{% endtab %}

{% tab title="Erigon" %}
```bash
#database location
/var/lib/erigon
```
{% endtab %}
{% endtabs %}
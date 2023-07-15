# Important Directory Locations

{% hint style="info" %}
In case you need to locate your validator keys, database directories or other important files.
{% endhint %}

#### Consensus engine files and locations

{% tabs %}
{% tab title="Lighthouse" %}
```bash
# Validator Keys
/var/lib/lighthouse/validators

# Beacon Chain Data
/var/lib/lighthouse/beacon

# List of all validators and passwords
/var/lib/lighthouse/validators/validator_definitions.yml

#Slash protection db
/var/lib/lighthouse/validators/slashing_protection.sqlite
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
/var/lib/prysm/validators

# Beacon Chain Data
/var/lib/prysm/beacon/beaconchaindata
```
{% endtab %}

{% tab title="Lodestar" %}
```bash
# Validator Keystores
/var/lib/lodestar/validators

# Validator DB Data
/var/lib/lodestar/validators

# Beacon Chain Data
/var/lib/lodestar/chain-db
```
{% endtab %}
{% endtabs %}

#### Execution engine files and locations

{% tabs %}
{% tab title="Geth" %}
```bash
# database location
/var/lib/geth
```
{% endtab %}

{% tab title="Besu" %}
```bash
# database location
/var/lib/besu
```
{% endtab %}

{% tab title="Nethermind" %}
```bash
#database location
/var/lib/nethermind
```
{% endtab %}

{% tab title="Erigon" %}
```bash
#database location
/var/lib/erigon
```
{% endtab %}
{% endtabs %}

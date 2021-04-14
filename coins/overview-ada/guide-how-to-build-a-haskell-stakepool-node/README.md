---
description: >-
Esta guía mostrará la forma de instalar y configurar una Stake Pool de Cardano desde su código fuente, usando una configuración de dos nodos, con 1 nodo productor de bloques y 1 nodo relevador.
---

# Guía: ¿Cómo implementar una Stake Pool en Cardano?

{% hint style="info" %}
¡Muchas gracias por todo el apoyo y los mensajes! Realmente nos motiva a seguir creando las mejores guías de criptomonedas. Sigue el enlace para ver [nuestras direcciones de donación](https://cointr.ee/coincashew) 🙏 
{% endhint %}

{% hint style="success" %}
Esta guía fue actualizada el 7 de Abril de 2021, con **versión 3.2.0**, escrita para la  **mainnet de cardano** en su versión **1.26.1** 😁 
{% endhint %}

### 🏁 0. Prerrequisitos

#### 🧙♂ Habilidades necesarias para los Operadores de una Stake Pool

Como operador de un nodo de Cardano, tendrás que tener las siguientes habilidades:

* Conocimientos de como implementar, arrancar y mantener un nodo de Cardano de manera continua.
* Compromiso de mantener tu nodo funcionando 24/7/365.
* Habilidad para operar sistemas.
* Habilidad para la administración de servidores \(operación y mantenimiento\).

### 🧙 Experiencia necesaria para los Operadores de una Stake Pool

* Experiencia en DevOps.
* Experiencia [reforzando ](https://www.lifewire.com/harden-ubuntu-server-security-4178243) y [aumentando la seguridad de un servidor](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3).
* [Haber tomado el curso oficial de Stake Pool.](https://cardano-foundation.gitbook.io/stake-pool-course/) 

{% hint style="danger" %}
🛑 **Antes de continuar con la guía, es NECESARIO cumplir con los requisitos anteriores.** 🚧 
{% endhint %}

#### 🎗 Hardware mínimo

* **Dos servidores independientes:** 1 para el nodo productor, 1 para el nodo relevador.
* **Un equipo fuera de línea \(Ambiente frío\)**
* **Sistema Operativo:** Linux 64-bit \(por ejemplo Ubuntu Server 20.04 LTS\)
* **Procesador:** Un procesador AMD o Intel de x86 con dos o más núcleos, de 2GHz o mayor.
* **Memoria:** 8GB de RAM
* **Almacenamiento:** Al menos 20GB de almacenamiento disponible.
* **Internet:** Concexión con una velocidad de al menos 10Mbps.
* **Plan de Datos**: De al menos 1GB por hora. 720GB al mes.
* **Alimentación:** Alimentación eléctrica confiable.
* **ADA:** Al menos 505 ADA para depósitos al Stake Pool y tarifas de transacción.

#### 🏋♂ Hardware recomendado a futuro

* **Tres servidores independientes:** 1 para el nodo productor de bloques, 2 para los nodos relevadores.
* **Un equipo fuera de línea \(Ambiente frío\)**
* **Sistema Operativo:** Linux 64-bit \(por ejemplo Ubuntu Server 20.04 LTS\)
* **Procesador:** Un procesador de 4 núcleos o mayor.}
* **Memoria:** Más de 8GB de RAM
* **Almacenamiento:** Un SSD 256GB o más.
* **Internet:** Concexión con una velocidad de al menos 100Mbps.
* **Plan de Datos**: Ilimitado
* **Alimentación:** Alimentación eléctrica confiable con UPS.
* **ADA:** Dependerá del parámetro **a0**, entre más ADA en el Stake Pool será mejor a futuro. Actualmente el valor no es relevante.

#### 🔓 Factores de seguridad recomendados para el Stake Pool

Si necesitas ideas de cómo reforzar la seguridad de tus nodos, puedes ir a:

{% page-ref page="how-to-harden-ubuntu-server.md" %}

### 🛠 Instalación de Ubuntu

Si requieres instalar **Ubuntu Server**, puedes ir a:

{% embed url="https://ubuntu.com/tutorials/install-ubuntu-server\#1-overview" %}

Si requieres instalar **Ubuntu Desktop**, puedes ir a:

{% page-ref page="../../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}


### 🧱 Reconstruyendo Nodos

Si estás reconstruyendo o reusando una instalación existente de `cardano-node`, ve a la [sección 18.2 ¿Cómo reiniciar la instalación?.](./#18-2-resetting-the-installation)

### 🏭 1. Instalar Cabal y GHC

Si estás usando Ubuntu Desktop, **presiona** Ctrl+Alt+T. Esto abrirá la terminal.

Primero, actualizamos los paquetedes e instalamos las dependencias de Ubuntu.

```bash
sudo apt-get update -y
```

```text
sudo apt-get upgrade -y
```

```text
sudo apt-get install git jq bc make automake rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf -y
```

Instalamos Libsodium.

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
Para los Operadores que utilicen Debian OS, puede que sea necesario vincular una librería adicional.

```bash
sudo ln -s /usr/local/lib/libsodium.so.23.3.0 /usr/lib/libsodium.so.23
```
{% endhint %}

Instalamos Cabal y sus dependencias

```bash
sudo apt-get -y install pkg-config libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev build-essential curl libgmp-dev libffi-dev libncurses-dev libtinfo5
```

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

Respondemos **NO** cuand se pregunte por instalar haskell-language-server \(HLS\).

Respondemos **YES** para agregar de manera automática la variable PATH al archivo ".bashrc".

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
ghcup upgrade
ghcup install cabal 3.4.0.0
ghcup set cabal 3.4.0.0
```

Instalamos GHC

```bash
ghcup install ghc 8.10.4
ghcup set ghc 8.10.4
```

Actualizamos la variable PATH para que incluya a Cabal y GHC, y agregamos exports. La localización del nodo estará en **$NODE\_HOME**. La [configuración del cluster](https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html) está dada por **$NODE\_CONFIG** y **$NODE\_BUILD\_NUM**. 

```bash
echo PATH="$HOME/.local/bin:$PATH" >> $HOME/.bashrc
echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> $HOME/.bashrc
echo export NODE_HOME=$HOME/cardano-my-node >> $HOME/.bashrc
echo export NODE_CONFIG=mainnet>> $HOME/.bashrc
echo export NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g') >> $HOME/.bashrc
source $HOME/.bashrc
```

{% hint style="info" %}
💡 **¿Cómo usar esta guía para la TestNet?**

Simplemente reemplaza cada instancia de ****CLI parameter 

 `--mainnet` 

con

`--testnet-magic 1097911063`
{% endhint %}

Actualizamos Cabal y verificamos que las versiones correctas hayan sido instaladas de manera exitosa.

```bash
cabal update
cabal --version
ghc --version
```

{% hint style="info" %}
La librería de Cabal debe de ser versión 3.4.0.0 y la de GHC debe ser versión 8.10.4
{% endhint %}


### 🏗 2. Construyendo el nodo desde el código fuente

Descarga el código fuente y cambia al _tag_ más reciente.

```bash
cd ~/git
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node
git fetch --all
git checkout tags/1.19.1
```

Actualiza cabal config, configuración del proyecto y resetea la carpeta de construcción.

```bash
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
sed -i $HOME/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
rm -rf $HOME/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.6.5
```

Construye cardano-node desde el código fuente.

```text
cabal build cardano-cli cardano-node
```

El proceso de construcción puede tomar unos minutos e incluso algunas horas dependiendo del poder del procesador de tu compoutadora.

Copia los archivos **cardano-cli** y **cardano-node** a tu carpeta _bin_.

```bash
sudo cp $(find ~/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find ~/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

Verifica las versiones de **cardano-cli** and **cardano-node**.

```text
cardano-node version
cardano-cli version
```

### 📐 3. Configura tu nodo

Aquí conseguirás los archivos config.json, genesis.json y topology.json necesarios para configurar tu nodo.

```bash
mkdir $NODE_HOME
cd $NODE_HOME
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-byron-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-topology.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-shelley-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json
```

Ejecuta lo siguiente para modificar **config.json** y

* actualiza ViewMode a "LiveView"
* actualiza TraceBlockFetchDecisions a "true"

```bash
sed -i ${NODE_CONFIG}-config.json \
    -e "s/SimpleView/LiveView/g" \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
```

Actualiza las variables **.bashrc** de tu shell.

```bash
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> ~/.bashrc
source ~/.bashrc
```

#### 🔮 4 Configura el nodo productor de bloques

Un nodo productor de bloques será configurado con varios pares de llaves necesarios para la creación de bloques \(cold keys \(llaves frías\), KES hot keys \(llaves calientes KES\) y VRF hot keys \(llaves calientes VRF\)\). Debe de conectarse solamente con sus nodos de relevo.

Un nodo de relevo no tendrá ninguna de las llaves y por lo tanto será incapaz de producir bloques. Estará conectada a su nodo productor de bloques respectivo, y a otros relevos y nodos externos.

En esta guía. construiremos **dos nodos** en dos **servidores distintos**. Un nodo será designado como **nodo productor de bloques**, y el otro será el nodo de relevo, llamado **relaynode1**.

Configura el archivo **topology.json** de tal forma que

* tus nodos de relevo se conecten a los nodos públicos de relevo \(IOHK y relevos de tus 'buddies'\) y a tu nodo porductor de bloques
* el nodo productor de bloques se conecte **solamente** a tus nodos de relevo

En tu **nodo productor de bloques**, ejecuta lo siguiente. Actualiza la **addr** con la dirección IP pública de tu nodo de relevo.

```bash
cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "<RELAYNODE1'S PUBLIC IP ADDRESS>",
        "port": 6000,
        "valency": 1
      }
    ]
  }
EOF
```

### 🛸 5. Configura tu\(s\) nodo\(s\) de relevo

🚧 En tu otro servidor que será designado como tu nodo de relevo o lo que llmaremos **relaynode1** por el resto de esta guía, cuidadosamente **respite los pasos 1 al 3** para construir los binarios de cardano.

Puedes tener varios nodos de relevo en lo que aumentas la arquitectura de tu stake pool. Simplemente crea **relaynodeN** y adapta las instrucciones de la guía de manera apropiada.

En tu **relaynode1**, ejecútalo con lo siguiente posteriormente de haber actualizado la dirección IP pública de tu nodo productor de bloques.

```bash
cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "<BLOCK PRODUCER NODE'S PUBLIC IP ADDRESS>",
        "port": 6000,
        "valency": 1
      },
      {
        "addr": "relays-new.cardano-mainnet.iohk.io",
        "port": 3001,
        "valency": 2
      }
    ]
  }
EOF
```

La _valency_ \(valencia\) le indica al nodo cuántas conexiones debe de mantener abiertas. Solamente direcciones DNS son afectadas. Si el valor es 0, la dirección es ignorada.

✨ **Consejo para la asignación de puertos:** Vas a necesitar asignar los puertos 3001 y 3002 a tu computadora. Chequea con [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) o [https://canyouseeme.org/](https://canyouseeme.org/).

### 🔏 6. Configura la máquina fuera de línea, totalmente aislada del internet

Una máquina fuera de línea, totalmente aislada del internet es conocida como tu ambiente frío.

* Protege contra ataques key-logging, ataques basados en malware/virus y otras explotaciones de seguridad o firewall \(cortafuegos\). 
* Físicamente aisladas del resto de tu red. 
* No debe de tener conexión a la red, inalámbrica o con cable ethernet. 
* No es una VM en una máquina con conexión a una red.
* Lee más sobre ['air-gapping' en wikipedia](https://en.wikipedia.org/wiki/Air_gap_%28networking%29).

```bash
echo export NODE_HOME=$HOME/cardano-my-node >> $HOME/.bashrc
source $HOME/.bashrc
mkdir -p $NODE_HOME
```

Copia desde tu **ambiente caliente**, también conocido como tu nodo productor de bloques, una copia de los binarios de **`cardano-cli`** en tu **ambiente frío**, esta máquina fuera de línea, totalmente aislada del internet.

Para permanecer un ambiente verdaderamente fuera de línea, asilado del internet, deberás mover tus archivos entre tus ambientes frío y caliente de manera física con llaves USB u otro dispositivo similar.

### 🤖 7. Crea scripts de arranque

El script de arranque contiene todas las variables necesarias para ejecutar un nodo-cardano como la carpeta, puerto, db, path, archivos de config y archivo de topología.

Para tu nodo **nodo productor de bloques**:

```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
#!/bin/bash
DIRECTORY=\$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```

Para tu **relaynode1**:

```bash
cat > $NODE_HOME/startRelayNode1.sh << EOF 
#!/bin/bash
DIRECTORY=\$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```

### ✅ 8. Inicia los nodos

**Oprime** Ctrl+Alt+T. Esto lanzará la terminal en una ventana.

Agrega permisos de ejecución al script, inicia tu stake pool, y comienza a sincronizarte con la blockchain.

Inicia tu nodo productor de bloques

```bash
cd $NODE_HOME
chmod +x startBlockProducingNode.sh
./startBlockProducingNode.sh
```

Inicia tu nodo de relevo

```bash
cd $NODE_HOME
chmod +x startRelayNode1.sh
./startRelayNode1.sh
```

🛑 **Para detener tu nodo**, puede oprimir '**`q`**' o ejecutar el comando `killall cardano-node`

✨ **Consejo**: Si sincronizas la base de datos de un nodo, puedes copiar la carpeta de la base de datos directamente a tu otro nodo y ahorrarte algo de tiempo.

¡Felicidades! Ahora tu nodo está operando exitosamente. Deja que se sincronice por completo.

### ⚙ 9. Crea las llaves para el nodo productor de bloques

El nodo productor de bloques requiere que crees 3 llaves definidas en las [especificaciones del libro de Shelley](https://hydra.iohk.io/build/2473732/download/1/ledger-spec.pdf):

* llave fría del stake pool
* llave caliente del stake pool \(llave KES\)
* llave VRF del stake pool

Primero, crea una par de llaves KES.

```bash
cd $NODE_HOME
cardano-cli shelley node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```

Las llaves KES \(key evolving signature \(llave evolutiva de firmas\) son creadas para asegurar tu stake pool contra hackers que quieran comprometer tus llaves. Estas deberán de ser regeneradas cada 90 días.

Las **llaves frías** deberán de ser creadas y almacenadas en tu máquina fuera de línea, aislada del internet. Las llaves frías son los archivos almacenados en `$HOME/cold-keys.`

Crea una carpeta para alamcenar tus llaves frías.

**Ambiente Frío**

```text
mkdir $HOME/cold-keys
pushd $HOME/cold-keys
```

Crea un set de llaves frías y crea el archivo contador frío.

**Ambiente Frío**

```bash
cardano-cli shelley node key-gen \
    --cold-verification-key-file node.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter
```

Asegúrate de **respaldar todas tus llaves** a otro dispositivo de almacenamiento seguro. Crea varias copias.

Determina el número de slots por periodo KES usando el archivo génesis.

**Nodo Productor de Bloques**

```bash
pushd +1
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
echo slotsPerKESPeriod: ${slotsPerKESPeriod}
```

**Antes de continuar, tu nodo debe de estar completamente sincronizado a la blockchain. De lo contrario, no podrás calcular el periodo KES actual. Tu nodo está sincronizado cuando la** _**epoch**_ **y** _**slot\#**_ **son iguales a los que se encuentran en un explorador de bloques como** [**https://pooltool.io/**](https://pooltool.io/)

**Nodo Productor de Bloques**

```bash
slotNo=$(cardano-cli shelley query tip --mainnet | jq -r '.slotNo')
echo slotNo: ${slotNo}
```

Encuentra el kesPeriod dividiendo el número del slot tip por el slotsPerKESPeriod.

**Nodo Productor de Bloques**

```bash
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
echo kesPeriod: ${kesPeriod}kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
echo kesPeriod: ${kesPeriod}
startKesPeriod=$(( ${kesPeriod} - 1 ))
echo startKesPeriod: ${startKesPeriod}
```

Con este cálculo, puedes crear un certificado funcional para tu pool.

Copia **kes.vkey** a tu **ambiente frío**.

Cambia el valor de **startKesPeriod** con el apropiado.

Los operadores de stake pool debe de mostrar un certificado funcional para verificar que el pool tiene la autoridad para operar. El certificado incluye la firma del operador e incluye información clave sobre el pool \(direcciones, llaves, etc.\). Los certificados fucnionales representan el enlace entre las llaves frías del operador y su llave funcional.

**Ambiente Frío**

```bash
cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period <startKesPeriod> \
    --out-file node.cert
```

Copia **node.cert** a tu **ambiente caliente**.

Crea un par de llaves VRF.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
```

Abre una terminal en una nueva ventana con Ctrl+Alt+T y detén tu stake pool ejecutando lo siguiente:

**Nodo Productor de Bloques**

```bash
killall cardano-node
```

Actualiza tu script de arranque con los nuevos datos **KES, VRF y Certificado Funcional**

**Nodo Productor de Bloques**

```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
DIRECTORY=\$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
KES=\${DIRECTORY}/kes.skey
VRF=\${DIRECTORY}/vrf.skey
CERT=\${DIRECTORY}/node.cert
cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG} --shelley-kes-key \${KES} --shelley-vrf-key \${VRF} --shelley-operational-certificate \${CERT}
EOF
```

Para operar un stake pool, dos sets de llaves son necesarios: la llave KES \(caliente\) y la llave fría. Las llaves frías generan nuevas llaves calientes de manera periódica.

Ahora inicia tu stake pool.

**Nodo Productor de Bloques**

```bash
cd $NODE_HOME
./startBlockProducingNode.sh
```

### 🔐 10. Prepara las llaves de pago y de staking

Primero, obtén los parámetros del protocolo.

Espera a que el nodo productor de bloques comience a sincronizarse antes de continuar si recibes este mensaje de error.

`cardano-cli: Network.Socket.connect: : does not exist (No such file or directory)`

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query protocol-parameters \
    --mainnet \
    --out-file params.json
```

Las llaves de pago son usadas para enviar y recibir pagos y las llaves de staking son usadas para manejar las delegaciones del stake.

Hay dos formas de crear tus pares de llaves `payment` y `stake`. Escoge la que mejor te parezca.

🔥 **Consejo Crucial para la Seguridad Operacional:** las llaves `payment` y `stake` deben de ser generadas y usadas para construir transacciones en un ambiente frío. En otras palabras, tu **máquina fuera de línea, asilada del internet**. Copia los binario de `cardano-cli` a tu máquina fuera de línea y ejecuta el método CLI method o el método mnemotécnico. Los únicos pasos hechos en línea en un ambiente caliente son los pasos que requieren data en vivo. Principalmente los siguientes tipos de pasos:

* consultar el tip del slot actual
* consultar el saldo de una dirección \(cuenta\) de ADA
* enviar una transacción

**MÉTODO CLI**

Crea un nuevo para de llaves de pago: `payment.skey` & `payment.vkey`

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
cd $NODE_HOME
cardano-cli shelley address key-gen \
    --verification-key-file payment.vkey \
    --signing-key-file payment.skey
```

Crea un nuevo par de llaves de dirección de stake: `stake.skey` & `stake.vkey`

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
cardano-cli shelley stake-address key-gen \
    --verification-key-file stake.vkey \
    --signing-key-file stake.skey
```

Crea tu dirección de stake desde la llave de verificación de dirección de stake y almacénala en `stake.addr`

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
cardano-cli shelley stake-address build \
    --staking-verification-key-file stake.vkey \
    --out-file stake.addr \
    --mainnet
```

Crea una dirección de pago para tu llave de pago `payment.vkey` la cual delegará a tu dirección de stake, `stake.vkey`

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
cardano-cli shelley address build \
    --payment-verification-key-file payment.vkey \
    --staking-verification-key-file stake.vkey \
    --out-file payment.addr \
    --mainnet
```

**MÉTODO MNEMOTÉCNICO** Créditos a [ilap](https://gist.github.com/ilap/3fd57e39520c90f084d25b0ef2b96894) por crear este proceso.

**Beneficios**: Monitorea y controla las recompensas del pool desde cualquier billetera \(Daedalus, Yoroi o cualquier otra billetera\) que soporte staking.

Crea un mnemotécnico de 15 o 24 palabras compatible con Shelley con [Daedalus](https://daedaluswallet.io/) or [Yoroi](../../../wallets/browser-wallets/yoroi-wallet-cardano.md) en una máquina desconectada del internet.

Usando tu **nodo productor de bloques en línea**, descarga `cardano-wallet`.

```bash
###
### En tu nodo productor de bloques,
###
cd $NODE_HOME
wget https://hydra.iohk.io/build/3662127/download/1/cardano-wallet-shelley-2020.7.28-linux64.tar.gz
```

Verifica la legitimidad de `cardano-wallet` revisando el [sha256 hash encontrado en el botón **Details**.](https://hydra.iohk.io/build/3662127/)

```bash
echo "f75e5b2b4cc5f373d6b1c1235818bcab696d86232cb2c5905b2d91b4805bae84 *cardano-wallet-shelley-2020.7.28-linux64.tar.gz" | shasum -a 256 --check
```

Ejemplo de output válido:

> cardano-wallet-shelley-2020.7.28-linux64.tar.gz: OK

Continua solamente si el sha256 pasa el chequeo con **OK**!

Transfiere la **cardano-wallet** a tu **máquina fuera de línea, aislada del internet** via llave USB o con un dispositivo similar.

Extrae los archivos de la billetera y limpia.

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
tar -xvf cardano-wallet-shelley-2020.7.28-linux64.tar.gz
rm cardano-wallet-shelley-2020.7.28-linux64.tar.gz
```

Crea el script `extractPoolStakingKeys.sh`.

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
cat > extractPoolStakingKeys.sh << HERE
#!/bin/bash 

CADDR=\${CADDR:=\$( which cardano-address )}
[[ -z "\$CADDR" ]] && ( echo "cardano-address cannot be found, exiting..." >&2 ; exit 127 )

CCLI=\${CCLI:=\$( which cardano-cli )}
[[ -z "\$CCLI" ]] && ( echo "cardano-cli cannot be found, exiting..." >&2 ; exit 127 )

OUT_DIR="\$1"
[[ -e "\$OUT_DIR"  ]] && {
        echo "The \"\$OUT_DIR\" is already exist delete and run again." >&2 
        exit 127
} || mkdir -p "\$OUT_DIR" && pushd "\$OUT_DIR" >/dev/null

shift
MNEMONIC="\$*"

# Genera la llave maestra de los mnemotécnicos y deriva las llaves stake de la cuenta (dirección)
# como llaves públicas y privadas (xpub, xprv)
echo "\$MNEMOTECNICO" |\
"\$CADDR" key from-recovery-phrase Shelley > root.prv

cat root.prv |\
"\$CADDR" key child 1852H/1815H/0H/2/0 > stake.xprv

cat root.prv |\
"\$CADDR" key child 1852H/1815H/0H/0/0 > payment.xprv

TESTNET=0
MAINNET=1
NETWORK=\$MAINNET

cat payment.xprv |\
"\$CADDR" key public | tee payment.xpub |\
"\$CADDR" address payment --network-tag \$NETWORK |\
"\$CADDR" address delegation \$(cat stake.xprv | "\$CADDR" key public | tee stake.xpub) |\
tee base.addr_candidate |\
"\$CADDR" address inspect
echo "Generado de 1852H/1815H/0H/{0,2}/0"
cat base.addr_candidate
echo

# Conversión a llaves publicas y privadas normales de XPrv/XPub, recuerda que 
# "keypars" no son llaves pares de firmar Ed25519 válidas.
TESTNET_MAGIC="--testnet-magic 42"
MAINNET_MAGIC="--mainnet"
MAGIC="\$MAINNET_MAGIC"

SESKEY=\$( cat stake.xprv | bech32 | cut -b -128 )\$( cat stake.xpub | bech32)
PESKEY=\$( cat payment.xprv | bech32 | cut -b -128 )\$( cat payment.xpub | bech32)

cat << EOF > stake.skey
{
    "tipo": "StakeExtendedSigningKeyShelley_ed25519_bip32",
    "descripcion": "",
    "cborHex": "5880\$SESKEY"
}
EOF

cat << EOF > payment.skey
{
    "tipo": "PaymentExtendedSigningKeyShelley_ed25519_bip32",
    "descripcion": "Payment Signing Key",
    "cborHex": "5880\$PESKEY"
}
EOF

"\$CCLI" shelley key verification-key --signing-key-file stake.skey --verification-key-file stake.evkey
"\$CCLI" shelley key verification-key --signing-key-file payment.skey --verification-key-file payment.evkey

"\$CCLI" shelley key non-extended-key --extended-verification-key-file payment.evkey --verification-key-file payment.vkey
"\$CCLI" shelley key non-extended-key --extended-verification-key-file stake.evkey --verification-key-file stake.vkey


"\$CCLI" shelley stake-address build --stake-verification-key-file stake.vkey \$MAGIC > stake.addr
"\$CCLI" shelley address build --payment-verification-key-file payment.vkey \$MAGIC > payment.addr
"\$CCLI" shelley address build \
    --payment-verification-key-file payment.vkey \
    --stake-verification-key-file stake.vkey \
    \$MAGIC > base.addr

echo "Importante la base.addr y la base.addr_candidate deben de ser iguales"
diff base.addr base.addr_candidate
popd >/dev/null
HERE
```

Agrega los permisos y actualiza el PATH.

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
chmod +x extractPoolStakingKeys.sh
export PATH="$(pwd)/cardano-wallet-shelley-2020.7.28:$PATH"
```

Extrae tus llaves. Actualiza el comando con tu frase mnemotécnica.

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
./extractPoolStakingKeys.sh extractedPoolKeys/ <15|24-word length mnemonic>
```

**Importante, la base.addr y la base.addr\_candidate deben de ser iguales. Revisa el output de la pantalla.**

Tus nuevas llaves de staking están en la carpeta `extractedPoolKeys/`

Ahora mueve los pares de llaves `payment/stake` hacia tu `$NODE_HOME` para usarlas con tu stake pool.

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
cd extractedPoolKeys/
cp stake.vkey stake.skey stake.addr payment.vkey payment.skey base.addr $NODE_HOME
cd $NODE_HOME
#Renombra el archivo base.addr como payment.addr
mv base.addr payment.addr
```

**payment.addr**, o también conocida como base.addr en este script de extracción, será la dirección de ADA que contenga el pledge de tu pool.

Limpia el historial bash para proteger tu frase mnemotécnica y remueve los archivos `cardano-wallet`.

```bash
###
### En una máquina fuera de línea, aislada del internet,
###
history -c && history -w
rm -rf $NODE_HOME/cardano-wallet-shelley-2020.7.28
```

Finalmente cierra todas tus ventanas con terminales y abre nuevas con cero historial.

Genial, ahora puedes monitorear tus recompensas del pool en tu billetera.

El siguiente paso es acreditar tu dirección de pago.

Copia **payment.addr** a tu **ambiente caliente**.

La dirección de pago puede ser acreditada desde

* tu billetera de Daedalus / Yoroi 
* si formaste parte de la ITN, puedes convertir tus llaves.

Ejecuta lo siguiente para encontrar tu dirección de pago.

```bash
cat payment.addr
```

Después de haber acreditado a tu cuenta, chequea el saldo de tu dirección de pago.

Antes de continuar, tus nodos deben de estar completamente sincronizados con la blockchain. de lo contrario, no podrás ver tus fondos.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --mainnet
```

Deberías de ver un output similar a este. Esta es la transacción de tu saldo no utilizado \(UXTO\).

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        1000000000
```

### 👩💻 11. Registra tu dirección de stake

Crea tu certificado, `stake.cert`, usando la llave `stake.vkey`

**Nodo Productor de Bloques**

```text
cardano-cli shelley stake-address registration-certificate \
    --staking-verification-key-file stake.vkey \
    --out-file stake.cert
```

Vas a necesitar encontrar el **tip** de la blockchain para establecer el parámetro **ttl**.

**Nodo Productor de Bloques**

```bash
currentSlot=$(cardano-cli shelley query tip --mainnet | jq -r '.slotNo')
echo Current Slot: $currentSlot
```

Encuentra tu saldo y **UTXOs**.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Saldo Total de ADA: ${total_balance}
echo Numero de UTXOs: ${txcnt}
```

Encuentra el valor del keyDeposit.

**Nodo Productor de Bloques**

```bash
keyDeposit=$(cat $NODE_HOME/params.json | jq -r '.keyDeposit')
echo keyDeposit: $keyDeposit
```

El registro del certificado de la dirección de stake \(keyDeposit\) cuesta 2000000 lovelace.

Ejectura el comando build-raw

El valor del **ttl** debe de ser mayor que el tip actual. En este ejemplo, usamos el slot actual + 10000.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp \
    --certificate stake.cert
```

Calcula el costo mínimo actual:

**Nodo Productor de Bloques**

```bash
fee=$(cardano-cli shelley transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo costoMinimo: $fee
```

Asegúrate que tu saldo sea mayor al costo a pagar + keyDeposit o esto no funcionará.

Calcula el output de tu cambio.

**Nodo Productor de Bloques**

```bash
txOut=$((${total_balance}-${keyDeposit}-${fee}))
echo Change Output: ${txOut}
```

Construye tu transacción con la cual vas a registrar tu dirección de stake.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file stake.cert \
    --out-file tx.raw
```

Copia **tx.raw** a tu **ambiente frío**.

Firma la transacción con ambas llaves de pago y de stake.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```

Copia **tx.signed** a tu **ambiente caliente**.

Envía la transacción firmada.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --mainnet
```

### 📄 12. Registra tu stake pool

Creá los metadatos de tu pool con un archivo JSON. Actualízalos con la información de tu pool.

**ticker** de 3-5 caracteres.

**descripción** no puede exceder los 255 caracteres.

**Nodo Productor de Bloques**

```bash
cat > poolMetaData.json << EOF
{
"name": "NombreDeMiPool",
"description": "Descripción de mi Pool",
"ticker": "NDMP",
"homepage": "https://mipoolesgenial.com"
}
EOF
```

Calcula el hash del archivo de tus metadatos.

```bash
cardano-cli shelley stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```

Ahora sube el archivo **poolMetaData.json** a tu sitio web o a un sitio público como [https://pages.github.com/](https://pages.github.com/)

Encuentra el costo operacional mínimo del pool.

**Nodo Productor de Bloques**

```bash
minPoolCost=$(cat $NODE_HOME/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}
```

minPoolCost es de 340000000 lovelace o 340 ADA. Por lo tanto, tu `--pool-cost` debe de ser esta cantidad como mínimo.

Crea el certificado de registro para tu stake pool. Actualízalo con tu **URL de metadatos** y**dirección IP del nodo de relevo**. Elige una de las tres opciones disponibles para configurar los nodos de relevo -- basados en DNS, basados en DNS con Sistema de Liga, o basados en IP.

Relevos basados en DNS son recomendados por simplicidad de mantenimiento del nodo. En otras palabras, no tendrás que reenviar esta transacción para el **certificado de registro** transaction cada vez que tu IP cambie. También fácilmente puedes actualizar el DNS a que apunte hacia la nueva IP si debes de mudarte o reconstruir tu nodo de relevo, por ejemplo.

**✨ ¿Cómo configurar múltiples nodos de relevo?**

Actualiza la siguiente operación

`cardano-cli shelley stake-pool registration-certificate`

para ser ejecutada de manera apropiada en tu máquina fuera de línea, aislada del internet.

**Relevos basados en DNS, 1 entrada por cada DNS**

```bash
    --single-host-pool-relay relevo1.mipoolesgenial.com\
    --pool-relay-port 6000 \
    --single-host-pool-relay relevo2.mipoolesgenial.com\
    --pool-relay-port 6000 \
```

**Relevos basados en DNS con Sistema de Liga, 1 entrada por** [**cada SRV DNS**](https://support.dnsimple.com/articles/srv-record/)\*\*\*\*

```bash
    --multi-host-pool-relay nodosDeRelevo.mipoolesgenial\
    --pool-relay-port 6000 \
```

**Relevos basados en IP, 1 entrada por dirección IP**

```bash
    --pool-relay-port 6000 \
    --pool-relay-ipv4 <primera dirección IP pública de tu nodo de relevo> \
    --pool-relay-port 6000 \
    --pool-relay-ipv4 <segunda dirección IP pública de tu nodo de relevo> \
```

**metadata-url** no debe de exceder los 64 caracteres.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000 \
    --pool-cost 345000000 \
    --pool-margin 0.15 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --single-host-pool-relay <relevo basado en DNS, ejemplo ~ relevo1.mipoolesgenial.com> \
    --pool-relay-port 6000 \
    --metadata-url <url donde subiste tu archivo poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```

Aquí vamos a pledge 100 ADA con un costo fijo de ADA y un margen del pool de 15%.

Vamos a stake nuestro pledge al pool.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley stake-address delegation-certificate \
    --staking-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
```

Copia **deleg.cert** a tu **ambiente caliente**.

Esto crea un certificado de delegación el cual delega fondos de todas las direcciones de stake asociadas con la llave `stake.vkey` al pool perteneciente a la llave fría `node.vkey`

El compromiso de stake que hace el operador del stake pool para delegar a su propio pool se llama **Pledge**.

* Tu saldo debe de ser mayor a la cantidad de pledge.
* Tus fondos del pledge no son movidos a ningún lado. En el ejemplo de esta guía, el pledge permanece en las llaves del dueño del stake pool, específicamente `payment.addr`
* No complir con tu pledge resultará en que pierdas oportunidades para producir bloques y tus delegadores perderán recompensas. 
* Tu pledge no está fijada. Eres libre de transferir tus fondos.

Necesitas encontrar el **tip** de la blockchain para establecer el parámetro **ttl** de forma correcta.

**Nodo Productor de Bloques**

```bash
currentSlot=$(cardano-cli shelley query tip --mainnet | jq -r '.slotNo')
echo Slot Actual: $currentSlot
```

Encuentra tu saldo y **UTXOs**.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Saldo Total de ADA: ${total_balance}
echo Numero de UTXOs: ${txcnt}
```

Encuentra el costo del depósito del pool.

**Nodo Productor de Bloques**

```bash
poolDeposit=$(cat $NODE_HOME/params.json | jq -r '.poolDeposit')
echo poolDeposit: $poolDeposit
```

Ejecuta el comando de transacciones build-raw.

El valor del **ttl** debe de ser mayor al tip actual. En este ejemplo, usamos el slot + 10000.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${poolDeposit}))  \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```

Calcula el costo mínimo:

**Nodo Productor de Bloques**

```bash
fee=$(cardano-cli shelley transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo costoMinimo: $fee
```

Asegúrate que tu saldo sea mayor al costo a pagar + minPoolCost o esto no funcionará.

Calcula el output de tu cambio.

**Nodo Productor de Bloques**

```bash
txOut=$((${total_balance}-${poolDeposit}-${fee}))
echo txOut: ${txOut}
```

Construye la transacción.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw
```

Copia **tx.raw** a tu **ambiente frío**.

Firma la transacción.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```

Copia **tx.signed** a tu **ambiente caliente**.

Envía la transacción.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --mainnet
```

### 🐣 13. Localiza tu Stake pool ID y verifica que todo funcione

Puedes obtener tu stake pool ID de la siguiente forma:

**Máquina fuera de línea, asilada del internet**

```bash
cardano-cli shelley stake-pool id --verification-key-file $HOME/cold-keys/node.vkey > stakepoolid.txt
cat stakepoolid.txt
```

Copia **stakepoolid.txt** a tu **ambiente caliente**.

Ahora que tienes tu stake pool ID, verifica que esté incluida en la blockchain.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query ledger-state --mainnet | grep publicKey | grep $(cat stakepoolid.txt)
```

¡El output de una cadena no-vacía significa que estás registrado! 👏

Con tu stake pool ID, ahora puedes econtrar tus data en los exploradores de bloques como [https://pooltool.io/](https://pooltool.io/)

### ⚙ 14. Configura tus archivos de topología

Shelley testnet ha sido lanzada sin descubrimiento de nodos peer-to-peer \(p2p\), así que esto significa que necesitarás agregar nodos de relevo confiables de maner manual para poder configurar nuestra topología. Este es un **paso crucial** ya que saltarse este paso resultará que tus bloques producidos sea aislados del resto de la red.

Hay dos formas de configurar tus archivos de topología.

* **método topologyUpdater.sh** es automatizado y funciona después de 4 houras. 
* **método Pooltool.io** te otorga el control sobre quiénes se conectan a tus nodos.

**Método topologyUpdater.sh**

#### 🚀 Publicando tu Nodo de Relevo con topologyUpdater.sh

Créditos a [GROWPOOL](https://twitter.com/PoolGrow) por la adición y créditos a [CNTOOLS Guild OPS](https://cardano-community.github.io/guild-operators/Scripts/topologyupdater.html) por la creación del proceso.

Crea el script `topologyUpdater.sh` el cual publica la información de tu nodo a una lista de búsqueda de topología.

```bash
###
### En relaynode1
###
cat > $NODE_HOME/topologyUpdater.sh << EOF
#!/bin/bash
# shellcheck disable=SC2086,SC2034

USERNAME=$(whoami)
CNODE_PORT=6000  # debe ser igual al puerto de tu nodo de relevo establecido en el comando de arranque
CNODE_HOSTNAME="CHANGE ME"  # opcional. debe resolverse al IP del cual estás solicitando
CNODE_BIN="/usr/local/bin"
CNODE_HOME=$NODE_HOME
CNODE_LOG_DIR="\${CNODE_HOME}/logs"
GENESIS_JSON="\${CNODE_HOME}/${NODE_CONFIG}-shelley-genesis.json"
NETWORKID=\$(jq -r .networkId \$GENESIS_JSON)
CNODE_VALENCY=1   # optional para DNS con múltiples IP
NWMAGIC=\$(jq -r .networkMagic < \$GENESIS_JSON)
[[ "\${NETWORKID}" = "Mainnet" ]] && HASH_IDENTIFIER="--mainnet" || HASH_IDENTIFIER="--testnet-magic \${NWMAGIC}"
[[ "\${NWMAGIC}" = "764824073" ]] && NETWORK_IDENTIFIER="--mainnet" || NETWORK_IDENTIFIER="--testnet-magic \${NWMAGIC}"

export PATH="\${CNODE_BIN}:\${PATH}"
export CARDANO_NODE_SOCKET_PATH="\${CNODE_HOME}/db/socket"

blockNo=\$(cardano-cli shelley query tip \${NETWORK_IDENTIFIER} | jq -r .blockNo )

# Nota:
# si ejecutas tu nodo en IPv4/IPv6 con configuración de red dual stack y solamente quieres anunciar la
# dirección IPv4 por favor agregael parámetro -4 parameter al comando curl que se muestra acontinuación (curl -4 -s ...)
if [ "\${CNODE_HOSTNAME}" != "CHANGE ME" ]; then
  T_HOSTNAME="&hostname=\${CNODE_HOSTNAME}"
else
  T_HOSTNAME=''
fi

if [ ! -d \${CNODE_LOG_DIR} ]; then
  mkdir -p \${CNODE_LOG_DIR};
fi

curl -s "https://api.clio.one/htopology/v1/?port=\${CNODE_PORT}&blockNo=\${blockNo}&valency=\${CNODE_VALENCY}&magic=\${NWMAGIC}\${T_HOSTNAME}" | tee -a \$CNODE_LOG_DIR/topologyUpdater_lastresult.json
EOF
```

Agrega los permisos y ejecuta el script actulizador.

```bash
###
### En relaynode1
###
cd $NODE_HOME
chmod +x topologyUpdater.sh
./topologyUpdater.sh
```

Cuando el script `topologyUpdater.sh` se ejecute correctament, verás

> `{ "resultcode": "201", "datetime":"2020-07-28 01:23:45", "clientIp": "1.2.3.4", "iptype": 4, "msg": "nice to meet you" }`

Cada vez que el script se ejecute y actualice tu IP, un registro es creado en **`$NODE_HOME/logs`**

Agrega una tarea crontab para automáticamente ejecutar `topologyUpdater.sh` cada hora en el minuto 22. Puedes cambiar el valor 22 con el de tu preferencia.

```bash
###
### En relaynode1
###
cat > $NODE_HOME/crontab-fragment.txt << EOF
22 * * * * ${NODE_HOME}/topologyUpdater.sh
EOF
crontab -l | cat - crontab-fragment.txt >crontab.txt && crontab crontab.txt
rm crontab-fragment.txt
```

Luego de cuatro horas y cuatro actulizaciones, la IP de tu nodo será registrada en la lista de búsqueda de topología.

#### 🤹♀ Actualiza los archivos de topología de tu nodo de relevo

Completa esta sección luego de **cuatro horas** cuando la IP de tu nodo de relevo sea registrada apropiadamente.

Crea el script `relay-topology_pull.sh` el cual busca tus colegas en tu nodo de relevo y los actualiza en tu archivo de topología. **Actualízalo con tu dirección IP pública de tu nodo productor de bloques**.

```bash
###
### En relaynode1
###
cat > $NODE_HOME/relay-topology_pull.sh << EOF
#!/bin/bash
BLOCKPRODUCING_IP=<BLOCK PRODUCERS PUBLIC IP ADDRESS>
BLOCKPRODUCING_PORT=6000
curl -s -o $NODE_HOME/${NODE_CONFIG}-topology.json "https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=\${BLOCKPRODUCING_IP}:\${BLOCKPRODUCING_PORT}:2|relays-new.${NODE_URL}.iohk.io:3001:2"
EOF
```

Agrega los permisos y extrae los nuevos archivos de topología.

```bash
###
### En relaynode1
###
chmod +x relay-topology_pull.sh
./relay-topology_pull.sh
```

La nueva topología entra en efecto luego de reiniciar tu stake pool.

```bash
###
### En relaynode1
###
killall cardano-node
./startRelayNode1.sh
```

**¡No olvides reiniciar tus nodos cada vez que actualices la topología!**

**Método Pooltool.io**

1. Visita [https://htn.pooltool.io/](https://htn.pooltool.io/)
2. Crea una cuenta e inicia sesión
3. Busca tu stake pool ID
4. Click ➡ **Pool Details** &gt; **Manage** &gt; **CLAIM THIS POOL**
5. Completa el nombre de tu pool y el URL del pool si cuentas con uno.
6. Completa tus **Private Nodes \(Nodos Privados\)** y **Your Relays \(Tus Nodos de Relevo\)** de la siguiente manera.

Puede encontrar tu IP pública con [https://www.whatismyip.com/](https://www.whatismyip.com/) o

```text
curl http://ifconfig.me/ip
```

Agrega solicitudes de nodos o "buddies" \(amigos\) a cada uno de tus nodos de relevo. Asegúrate de incluir el nodo de IOHK y tus nodos privados.

La dirección del nodo de IOHK es:

```text
relays-new.cardano-mainnet.iohk.io
```

El puerto del nodo de IOHK es:

```text
3001
```

Por ejemplo, en los buddies de relaynode1 deberías de agregar **solicitudes** para

* tu BlockProducingNode privado
* tu RelayNode2 privado
* nodo de IOHK
* y cualquier otro nodo de algún buddy o amigo que encuentres o conozcas

Por ejemplor, en los buddies de relaynode2 deberías de agregar **solicitudes** para

* tu BlockProducingNode privado
* tu RelayNode1 privado
* nodo de IOHK
* y cualquier otro nodo de algún buddy o amigo que encuentres o conozcas

la conexión de un nodo de relevo no es establecida hasta que haya una solicitud y ésta sea aprovada.

Para relaynode1, crea un script get\_buddies.sh para actualizar tu archivo topology.json

```bash
###
### En relaynode1
###
cat > $NODE_HOME/relaynode1/get_buddies.sh << EOF 
#!/usr/bin/env bash

# PUEDES PASAR ESTAS CADENAS COMO VARIABLES DE AMBIENTE, O EDITARLAS EN ESTE SCRIPT
if [ -z "\$PT_MY_POOL_ID" ]; then
## CAMBIA ESTAS A LA CONVENIENCIA DE TU POOL CON TU POOL ID COMO APARECE EN EL EXPLORADOR
PT_MY_POOL_ID="XXXXXXXX"
fi

if [ -z "\$PT_MY_API_KEY" ]; then
## OBTÉN ESTO DEL PERFIL DE TU CUENTA EN LA PÁGINA DE POOLTOOL
PT_MY_API_KEY="XXXXXXXX"
fi

if [ -z "\$PT_MY_NODE_ID" ]; then
## OBTÉN ESTO DE LA PESTAÑA MANAGE DE LA PÁGINA DE POOLTOOL
PT_MY_NODE_ID="XXXXXXXX"
fi

if [ -z "\$PT_TOPOLOGY_FILE" ]; then
## ESTABLECE EL PATH QUE UTILIZA TU ARCHIVO TOPOLOGY.JSON
PT_TOPOLOGY_FILE="$NODE_HOME/relaynode1/${NODE_CONFIG}-topology.json"
fi

JSON="\$(jq -n --compact-output --arg MY_API_KEY "\$PT_MY_API_KEY" --arg MY_POOL_ID "\$PT_MY_POOL_ID" --arg MY_NODE_ID "\$PT_MY_NODE_ID" '{apiKey: \$MY_API_KEY, nodeId: \$MY_NODE_ID, poolId: \$MY_POOL_ID}')"
echo "Packet Sent: \$JSON"
RESPONSE="\$(curl -s -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "\$JSON" "https://api.pooltool.io/v0/getbuddies")"
SUCCESS="\$(echo \$RESPONSE | jq '.success')"
if [ \$SUCCESS ]; then
  echo "Éxito"
  echo \$RESPONSE | jq '. | {Producers: .message}' > \$PT_TOPOLOGY_FILE
  echo "Topology almacenada en \$PT_TOPOLOGY_FILE.  Nota topology solamente tomará efecto la próxima vez que reinicies tu nodo"
else
  echo "Fracaso "
  echo \$RESPONSE | jq '.message'
fi
EOF
```

Para cada uno de tus nodos de relevo, actualiza las siguientes variables de pooltool.io en tu scripts get\_buddies.sh

* PT\_MY\_POOL\_ID 
* PT\_MY\_API\_KEY 
* PT\_MY\_NODE\_ID

Actualiza tus scripts get\_buddies.sh con esta información.

Usa **nano** para editar tus scripts.

`nano $NODE_HOME/relaynode1/get_buddies.sh`

Agrega los permisos de ejecución a estos scripts. Ejecuta los scripts para actualizar tus archivos de topología.

```bash
###
### En relaynode1
###
cd $NODE_HOME
chmod +x get_buddies.sh
./get_buddies.sh
```

Detén y reinicia ru stake pool para que los cambios a la topología hagan efecto.

```bash
###
### En relaynode1
###
killall cardano-node
./startRelayNode1.sh
```

En lo que tus SOLICITUDES sean aprovadas, deberás de ejecutar nuevamente el script get\_buddies.sh para extraer la data más reciente de la topología. Reinicia tus nodos de relevo posteriormente.

\*\*\*\*🔥 **Paso crucial:** Para tener listo un stake pool funcional para producir bloques, debes de ver el número de **TXs processed** incrementar. De lo contrario, revisa tu topología y asegúrate que tus buddies de relevo estén debidamente conectados e, idealmente, produciendo algunos bloques.

\*\*\*\*🛑 **Recordatorio Crucial**: Las únicas **keys \(llaves\)** y **certs** necesarios para ejecutar un stake pool son los requeridos por tu nodo productor de bloques. Estos tres arechivos son los siguientes:

```bash
###
### En nodo productor de bloques
###
KES=\${DIRECTORY}/kes.skey
VRF=\${DIRECTORY}/vrf.skey
CERT=\${DIRECTORY}/node.cert
```

**Todas las demás llaves deben de permanecer en un ambiente frío, tu máquina fuera de línea, aislada del internet**

¡Felicidades! Tu stake pool ha sido registrada y está lista para producir bloques.

### 🎇 15. Revisando las Recompensas del Stake Pool

Al concluir la epoch y asumiendo que hayas producido bloques de manera exitosa, revisa de la siguiente manera:

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query stake-address-info \
 --address $(cat stake.addr) \
 --mainnet
```

### 🔮 16. Configura tu Consola de Control con Prometheus y Grafana

Prometheus es una plataforma de monitoreo que recolecta métricas de objetivos monitoreados mediante la extracción de métricas de extremos HTTPS en estos objetivos. [Documentación oficial disponible aquí.](https://prometheus.io/docs/introduction/overview/) Grafana es una consola de control usada para visualizar la data recolectada.

#### 🐣 16.1 Instalación

Instala prometheus y prometheus node exporter.

**Relaynode1**

```text
sudo apt-get install -y prometheus prometheus-node-exporter
```

**Nodo Productor de Bloques**

```bash
sudo apt-get install -y prometheus-node-exporter
```

Instala grafana.

**Relaynode1**

```bash
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
```

**Relaynode1**

```bash
echo "deb https://packages.grafana.com/oss/deb stable main" > grafana.list
sudo mv grafana.list /etc/apt/sources.list.d/grafana.list
```

**Relaynode1**

```bash
sudo apt-get update && sudo apt-get install -y grafana
```

Habilita los servicios para que inicien de manera automática.

**Relaynode1**

```bash
sudo systemctl enable grafana-server.service
sudo systemctl enable prometheus.service
sudo systemctl enable prometheus-node-exporter.service
```

**Nodo Productor de Bloques**

```text
sudo systemctl enable prometheus-node-exporter.service
```

Actualiza prometheus.yml ubicado en `/etc/prometheus/prometheus.yml`

Cambia **&lt;block producer public ip address&gt;** en el siguiente comando.

```bash
cat > prometheus.yml << EOF
global:
  scrape_interval:     15s # Predeterminadamente, extrae objetivos cada 15 segundos.

  # Adjunta estas etiquetas a cualquier serie de tiempo o alertas al comunicarte con
  # sistemas externos (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# Una configuración de extracción conteniendo exactamente un extremo a ser extraído:
# En este caso, es el mismo Prometheus.
scrape_configs:
  # El nombre del trabajo es agregado a la etiqueta job=<job_name> a cualquier series de tiempo extraídas de esta config.
  - job_name: 'prometheus'

    static_configs:
      - targets: ['localhost:9100']
      - targets: ['<block producer public ip address>:12700']
        labels:
          alias: 'block-producing-node'
          type:  'cardano-node'
      - targets: ['localhost:12701']
        labels:
          alias: 'relaynode1'
          type:  'cardano-node'
EOF
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
```

Finalmente, reinicia los servicios.

**Relaynode1**

```text
sudo systemctl restart grafana-server.service
sudo systemctl restart prometheus.service
sudo systemctl restart prometheus-node-exporter.service
```

Verifica que los servicios estén ejecutándose de manera correcta:

```text
sudo systemctl status grafana-server.service prometheus.service prometheus-node-exporter.service
```

Actualiza los archivos de configuración `${NODE_CONFIG}-config.json` con los nuevos puertos de `hasEKG` `hasPrometheus`.

**Nodo Productor de Bloques**

```bash
cd $NODE_HOME
sed -i ${NODE_CONFIG}-config.json -e "s/    12798/    12700/g" -e "s/hasEKG\": 12788/hasEKG\": 12600/g"
```

**Relaynode1**

```bash
cd $NODE_HOME
sed -i ${NODE_CONFIG}-config.json -e "s/    12798/    12701/g" -e "s/hasEKG\": 12788/hasEKG\": 12601/g"
```

Detén y reinicia tu stake pool.

**Nodo Productor de Bloques**

```bash
cd $NODE_HOME
killall cardano-node
./startBlockProducingNode.sh
```

**Relaynode1**

```bash
cd $NODE_HOME
killall cardano-node
./startRelayNode1.sh
```

#### 📶 16.2 Configurando la Consola de Control de Grafana

1. En relaynode1, abre [http://localhost:3000](http://localhost:3000) en tu explorador o [http://&lt;dirección](http://<dirección) IP de tu nodo de tu relaynode1&gt;:3000 en tu explorador. Pueda que necesites habilitar el puerto 3000 router y/o firewall \(cortafuegos\).
2. Inicia sesión con **admin** / **admin**
3. Cambia la contraseña
4. Click en el ícono de **engrane para configuración**, luego en **Add data Source**
5. Selecciona **Prometheus**
6. Establece el **Name** a **"prometheus**" . ✨ Las minúsculas son importantes.
7. Establece el **URL** a [http://localhost:9090](http://localhost:9090)
8. Click **Save & Test**
9. Click en el ícono **Create +** &gt; **Import**
10. Agrega la consola de control importando el id: **11074**
11. Click en el botón **Load**.
12. Establece **Prometheus** data source como "**prometheus**"
13. Click en el botón **Import**.

Grafana [dashboard ID 11074](https://grafana.com/grafana/dashboards/11074) es un excelente visualizador de la salud general del sistema.

Importa un **Nodo de Cardano** a la consola de control

1. Click en el ícono **Create +** &gt; **Import**
2. Agrega la consola de control usando **importing via panel json. Copy the json from below.**
3. Click el botón **Import**.

```bash
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": 1,
  "links": [],
  "panels": [
    {
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "decimals": 2,
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "purple",
                "value": null
              }
            ]
          },
          "unit": "d"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 5,
        "w": 6,
        "x": 0,
        "y": 0
      },
      "id": 18,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        }
      },
      "pluginVersion": "7.0.3",
      "targets": [
        {
          "expr": "(cardano_node_Forge_metrics_remainingKESPeriods_int * 6 / 24 / 6)",
          "instant": true,
          "interval": "",
          "legendFormat": "Days till renew",
          "refId": "A"
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "Key evolution renew left",
      "type": "stat"
    },
    {
      "datasource": "prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "#EAB839",
                "value": 12
              },
              {
                "color": "green",
                "value": 24
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 5,
        "w": 5,
        "x": 6,
        "y": 0
      },
      "id": 12,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        }
      },
      "pluginVersion": "7.0.3",
      "targets": [
        {
          "expr": "cardano_node_Forge_metrics_remainingKESPeriods_int",
          "instant": true,
          "interval": "",
          "legendFormat": "KES Remaining",
          "refId": "A"
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "KES remaining",
      "type": "stat"
    },
    {
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "align": null
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "yellow",
                "value": 460
              },
              {
                "color": "red",
                "value": 500
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 5,
        "w": 6,
        "x": 11,
        "y": 0
      },
      "id": 2,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        }
      },
      "pluginVersion": "7.0.3",
      "targets": [
        {
          "expr": "cardano_node_Forge_metrics_operationalCertificateExpiryKESPeriod_int",
          "format": "time_series",
          "instant": true,
          "interval": "",
          "legendFormat": "KES Expiry",
          "refId": "A"
        },
        {
          "expr": "cardano_node_Forge_metrics_currentKESPeriod_int",
          "instant": true,
          "interval": "",
          "legendFormat": "KES current",
          "refId": "B"
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "KES Perioden",
      "type": "stat"
    },
    {
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "align": null
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 5,
        "w": 6,
        "x": 0,
        "y": 5
      },
      "id": 10,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        }
      },
      "pluginVersion": "7.0.3",
      "targets": [
        {
          "expr": "cardano_node_ChainDB_metrics_slotNum_int",
          "instant": true,
          "interval": "",
          "legendFormat": "SlotNo",
          "refId": "A"
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "Slot",
      "type": "stat"
    },
    {
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "align": null
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 5,
        "w": 5,
        "x": 6,
        "y": 5
      },
      "id": 8,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        }
      },
      "pluginVersion": "7.0.3",
      "targets": [
        {
          "expr": "cardano_node_ChainDB_metrics_epoch_int",
          "format": "time_series",
          "instant": true,
          "interval": "",
          "legendFormat": "Epoch",
          "refId": "A"
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "Epoch",
      "type": "stat"
    },
    {
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 5,
        "w": 6,
        "x": 11,
        "y": 5
      },
      "id": 16,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "mean"
          ],
          "fields": "",
          "values": false
        }
      },
      "pluginVersion": "7.0.3",
      "targets": [
        {
          "expr": "cardano_node_ChainDB_metrics_blockNum_int",
          "instant": true,
          "interval": "",
          "legendFormat": "Block Height",
          "refId": "A"
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "Block Height",
      "type": "stat"
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "align": null
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 9,
        "x": 0,
        "y": 10
      },
      "hiddenSeries": false,
      "id": 6,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pluginVersion": "7.0.3",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "cardano_node_ChainDB_metrics_slotInEpoch_int",
          "interval": "",
          "legendFormat": "Slot in Epoch",
          "refId": "B"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Slot in Epoch",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": true,
      "dashLength": 10,
      "dashes": false,
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "align": null
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 4,
      "gridPos": {
        "h": 9,
        "w": 8,
        "x": 9,
        "y": 10
      },
      "hiddenSeries": false,
      "id": 20,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": false,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pluginVersion": "7.0.3",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "cardano_node_Forge_metrics_nodeIsLeader_int",
          "interval": "",
          "legendFormat": "Node is leader",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Node is Block Leader",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "decimals": null,
          "format": "none",
          "label": "Slot",
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 6,
        "w": 9,
        "x": 0,
        "y": 19
      },
      "hiddenSeries": false,
      "id": 14,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": false,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "cardano_node_metrics_mempoolBytes_int / 1024",
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "Memory KB",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Memory Pool",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "KBs",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "datasource": "prometheus",
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "decimals": 2,
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              }
            ]
          },
          "unit": "dthms"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 6,
        "w": 8,
        "x": 9,
        "y": 19
      },
      "id": 4,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "last"
          ],
          "fields": "",
          "values": false
        }
      },
      "pluginVersion": "7.0.3",
      "targets": [
        {
          "expr": "cardano_node_metrics_upTime_ns / (1000000000)",
          "format": "time_series",
          "instant": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "Server Uptime",
          "refId": "A"
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "Block-Producer Uptime",
      "type": "stat"
    }
  ],
  "refresh": "5s",
  "schemaVersion": 25,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-24h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ]
  },
  "timezone": "",
  "title": "Cardano Node",
  "uid": "bTDYKJZMk",
  "version": 1
}
```

¡Felicidades! Prometheus y Grafana están funcionando.

### 👏 17. Agradeciemientos, Telegram de Coincashew y Material de Referencia

#### 😁 17.1 Agradecimientos

"Gracias a todos los 11000 y cada uno de ustedes, los hodlers de Cardano, constructores, stakers y operadores de pools por hacer del mejor futuro una realid."

👏 "Agradecimiento especial a [Kaze-Stake](https://github.com/Kaze-Stake) por las _pull requests_ y contribuciones de scripts automáticos."

#### \*\*\*\*💬 **17.2 Canal de Chat en Telegram**

Este es el Telegram de **COINCASHEW**. Es un canal en **INGLÉS** [https://t.me/coincashew](https://t.me/coincashew)

#### 😊 17.3 Donaciones y Propinas

**PRIMERAMENTE, DONACIONES A COINCASHEW, LOS CREADORES DE ESTA GUÍA** "Apreciamos sinceramente todas las [donaciones](../../../contact-us/donations.md). 😁 ¡Gracias por apoyar a Cardano y a nosotros!"

**Dirección de ADA de COINCASHEW**

```text
addr1qxhazv2dp8yvqwyxxlt7n7ufwhw582uqtcn9llqak736ptfyf8d2zwjceymcq6l5gxht0nx9zwazvtvnn22sl84tgkyq7guw7q
```

**DONACIONES A THE LEGEND OF ₳DA POR LA TRADUCCIÓN DE ESTA GUÍA** Si llegaron hasta aquí, ¡muchas felicidades por sus esfuerzos y paciencia! No fue fácil, pero justo lo logramos. Si desean apoyarnos, pueden hacerlo delegando a nuestro stake pool **The Legend of ₳da \[TLOA\]** O si desean hacer alguna donación, favor hacerla a la dirección que se encuentra debajo de este comentario. Y si ya están delegando con cualquier stake pool, ¡gracias por apoyar la decentralización! 😁

**Dirección de ADA de The Legend of ₳da \[TLOA\]**

```text
addr1q87d37clyu4ctaz5ah8lrjwzyrsrqvpt0u83wghvdl66ea6gvzmayvajt7rstn79xtcxmuxk84k3s0qypq7af74lfemsvlzktu
```

#### 🙃 17.4 Contribuyentes, Donadores y Stake Pool Amistosas de CoinCashew

**✨ Contribuyentes a la Guía**

* 👏 Agradecimiento especial a Kaze-Stake por las pull requests y por las contribuciones de scripts de automatización.
* 👏 The Legend of ₳da \[TLOA\] por traducir esta guía a Español.
* 👏 Chris de OMEGA \| CODEX por las mejoras de seguridad.
* 👏 Raymond de GROW por las mejoras del topologyUpdater y por ser genial.
* 👏 Antonie de CNT por ser de mucha ayuda con el contenido de Youtube y en Telegram.

**💸 Donadores de Propinas**

* 😊 BEBOP 
* 😊 DEW
* 😊 GROW
* 😊 Leonardo

**🚀Stake Pools Preferidas de CoinCashew**

* 🌟 OMEGA \| CODEX
* 🌟 TLOA
* 🌟 KAZE
* 🌟 BEBOP
* 🌟 DEW
* 🌟 GROW
* 🌟 CNT

#### 📚 17.5 Material de Referencia

Para más información y documentación oficial, favor fererise a los siguientes enlaces \(**en inglés**\):

[https://docs.cardano.org/en/latest/getting-started/stake-pool-operators/index.html](https://docs.cardano.org/en/latest/getting-started/stake-pool-operators/index.html)

[https://testnets.cardano.org/en/shelley/get-started/creating-a-stake-pool/](https://testnets.cardano.org/en/shelley/get-started/creating-a-stake-pool/)

[https://github.com/input-output-hk/cardano-tutorials](https://github.com/input-output-hk/cardano-tutorials)

[https://github.com/cardano-community/guild-operators](https://github.com/cardano-community/guild-operators)

[https://github.com/gitmachtl/scripts](https://github.com/gitmachtl/scripts)

**CNTools por Guild Operators**

Varios operadores de pools han preguntado cómo crear una stake pool con CNTools. La [guía oficial la puedes encontrar aquí.](https://cardano-community.github.io/guild-operators/#/Scripts/cntools)

### 🛠 18. Consejos Operacionales y de Mantenimiento

#### 🤖 18.1 Actualizando el certificado funcional con un nuevo Periodo KES

Es obligatorio que recrees las llaves calientes y emitas un nuevo vertificado funcional, un proceso llamado rotando las llaves KES, cuando las laves calientes hayn caducado.

**Mainnet**: Las laves KES serán válidas por 120 rotaciones o por 90 días

**Actualizando el Periodo KES**: Cuando sea tiempo de emitir un nuevo certificado funcional, ejecuta lo siguiente:

**Nodo Productor de Bloques**

```bash
cd $NODE_HOME
slotNo=$(cardano-cli shelley query tip --mainnet | jq -r '.slotNo')
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
startKesPeriod=$(( ${kesPeriod} - 1 ))
echo startKesPeriod: ${startKesPeriod}
```

Crear un nuevo par de llaves KES.

**Nodo Productor de Bloques**

```bash
cd $NODE_HOME
cardano-cli shelley node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```

Copia **kes.vkey** a tu **ambiente frío**

Crea el nuevo archivo `node.cert` con el siguiente comando. Actualiza `<startKesPeriod>` con el valor anterior.

**Máquina fuera de línea, aislada del internet**

```bash
cd $NODE_HOME
chmod u+rwx $HOME/cold-keys
cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period <startKesPeriod> \
    --out-file node.cert
chmod a-rwx $HOME/cold-keys
```

Copia **node.cert** a tu nodo productor de bloques.

\*\*\*\*✨ **Consejo:** Con tus llaves calientes creadas, puede remover el acceso a las llaves frías para mejorar la seguridad. Esto te protege contra la eliminación o alteración accidental, y el acceso no deseado.

Para bloquear,

```bash
chmod a-rwx $HOME/cold-keys
```

Para desbloquear,

```bash
chmod u+rwx $HOME/cold-keys
```

#### 🔥 18.2 Reseteando la instalación

¿Quieres un inicio limpio? ¿Estás reusando un servidor existente? ¿La blockchain ha sido forked?

Elimina la carpeta git, y luego renombra tu carpetas anteriores `$NODE_HOME` y `cold-keys` \(u opcionalmente, remúevelas\). Ahora puedes comenzar con esta guía desde el inicio nuevamente.

```bash
rm -rf $HOME/git/cardano-node/ $HOME/git/libsodium/
mv $NODE_HOME $(basename $NODE_HOME)_backup_$(date -I)
mv $HOME/cold-keys $HOME/cold-keys_backup_$(date -I)
```

#### 🌊 18.3 Reseteando las bases de datos

¿Archivos corruptos o blockchain estancada? Elimina todas las carpetas db.

```bash
cd $NODE_HOME
rm -rf db
```

#### 📝 18.4 Modificando el pledge, los costos operacionales, el margen del pool, etc.

¿Necesitas cambiar tu pledge, los costos operacionales, el margen del pool, pool IP/puerto, o los metadatos? Simplemente reenvía tu certificado de registro de tu stake pool.

Encuentra el costo mínimo del pool.

**Nodo Productor de Bloques**

```bash
minPoolCost=$(cat $NODE_HOME/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}
```

minPoolCost es de 340000000 lovelace o 340 ADA. Por lo tanto, tu `--pool-cost` debe de ser sta cantidad como mínimo.

Si vas a modificar tu poolMetaData.json, recuerda calcular el hash de tu archivo de metadato y reenvía el archivo poolMetaData.json actualizado. Refiérete a la [sección 9 para información.](/#9-register-your-stakepool) Si estás verificando tu stake pool ID, el hash te es proporcionado por pooltool.

**Nodo Productor de Bloques**

```text
cardano-cli shelley stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```

Actualiza con tus configuración deseada la siguiente transacción para registrar el certificado.

Si tienes **múltiples nodos de relevo**, **refiérete a la sección 12 de esta guía** y cambia tus parámetros de manera apropiada.

**metadata-url** no debe de exceder los 64 caracteres.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 1000000000 \
    --pool-cost 345000000 \
    --pool-margin 0.20 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --single-host-pool-relay <dns based relay, example ~ relaynode1.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
    --metadata-url <url where you uploaded poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```

Aquí nuestra pledge es de 1000 ADA con un costo fijo de 345 ADA y un margen del pool de 20%.

Vamos a stake nuestro pledge al pool.

**Máquina fuera de línea, aislada del internet**

```text
cardano-cli shelley stake-address delegation-certificate \
    --staking-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
```

Copia **deleg.cert** a tu **ambiente caliente**.

Necesitas encontrar el **tip** de la blockchain para establecer el parámetro **ttl** adecuadamente.

**Nodo Productor de Bloques**

```bash
currentSlot=$(cardano-cli shelley query tip --mainnet | jq -r '.slotNo')
echo Current Slot: $currentSlot
```

Encuentra tu saldo y **UTXOs**.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Saldo Total de ADA: ${total_balance}
echo Numero de UTXOs: ${txcnt}
```

Ejecuta el comando de transacción build-raw.

El valor del **ttl** debe de ser mayor al tip actual. En este ejemplo, usamos el slot actual + 10000.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```

Calcula el costo mínimo a pagar:

**Nodo Productor de Bloques**

```bash
fee=$(cardano-cli shelley transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo costoMinimo: $fee
```

Calcula el output de tu cambio.

**Nodo Productor de Bloques**

```bash
txOut=$((${total_balance}-${fee}))
echo txOut: ${txOut}
```

Construye la transacción.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw
```

Copia **tx.raw** a tu **ambiente frío**.

Firma la transacción.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```

Envía la transacción.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --mainnet
```

Los cambios tomarán efecto a partir de la siguiente epoch. Luego de la transición de la siguiente epoch, verifica que las opciones de tu pool sean las correctas.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query ledger-state --mainnet --out-file ledger-state.json
jq -r '.esLState._delegationState._pstate._pParams."'"$(cat stakepoolid.txt)"'"  // empty' ledger-state.json
```

#### 🧩 18.5 Transfiriendo archivos via SSH

Algunos casos en los que lo necesitarás incluyen

* Descargando respaldo de tus llaves de stake/pago
* Enviando un nuevo certificado funcional al productor de bloques desde un nodo sin conexión a internet

**Para descargar arachivos de un nodo a tu PC local**

```bash
ssh <USUARIO>@<DIRECCIÓN IP> -p <PUERTO-SSH>
rsync -avzhe “ssh -p <PUERTO-SSH>” <USUARIO>@<DIRECCIÓN IP>:<PATH REMITENTE DEL NODO> <PATH DESTINATARIO EN EL PC LOCAL>
```

> Ejemplo:
>
> `ssh miusuario@6.1.2.3 -p 12345`
>
> `rsync -avzhe "ssh -p 12345" miusuario@6.1.2.3:/home/miusuario/cardano-my-node/stake.vkey ./stake.vkey`

**Para enviar archivos desde tu PC local a tu nodo**

```bash
ssh <USUARIO>@<DIRECCIÓN IP> -p <PUERTO-SSH>
rsync -avzhe “ssh -p <PUERTO-SSH>” <PATH REMITENTE A TU PC LOCAL> <USUARIO>@<DIRECCIÓN IP>:<PATH DESTINATARIO DEL NODO>
```

> Ejemplo:
>
> `ssh miusuario@6.1.2.3 -p 12345`
>
> `rsync -avzhe "ssh -p 12345" ./node.cert miusuario@6.1.2.3:/home/miusuario/cardano-my-node/node.cert`

#### 🏃♂ 18.6 Auto-inicio con servicios systemd

**🍰 Beneficios de usar systemd para tu stake pool**

1. Auto-inicia tu stake pool caundo la computadora se reinicia debido a mantenimiento, apagón, etc.
2. Automáticamente reinicia procesos fallido de tu stake pool.
3. Maximiza el tiempo útil y el rendimiento de tu stake pool.

**🛠 Intrucciones para Configurar**

Antes de comenzar, asegúrate que tu pool esté detenido.

```bash
killall cardano-node
```

Ejecuta lo siguiente para crear una **unidad de archivo** para definir tu configuración de `cardano-stakepool.service`

**Nodo Productor de Bloques**

```bash
cat > $NODE_HOME/cardano-node.service << EOF 
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service 

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
Type            = forking
WorkingDirectory= $NODE_HOME
ExecStart       = /usr/bin/tmux new -d -s cnode
ExecStartPost   = /usr/bin/tmux send-keys -t cnode $NODE_HOME/startBlockProducingNode.sh Enter 
ExecStop        = killall cardano-node
Restart         = always

[Install]
WantedBy  = multi-user.target
EOF
```

**Relaynode1**

```bash
cat > $NODE_HOME/cardano-node.service << EOF 
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service 

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = $(whoami)
Type            = forking
WorkingDirectory= $NODE_HOME
ExecStart       = /usr/bin/tmux new -d -s cnode
ExecStartPost   = /usr/bin/tmux send-keys -t cnode $NODE_HOME/startRelayNode1.sh Enter 
ExecStop        = killall cardano-node
Restart         = always

[Install]
WantedBy  = multi-user.target
EOF
```

Copia la unidad de archivo a `/etc/systemd/system` y otórgale permisos.

```bash
sudo cp $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
```

```bash
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

Ejecuta lo siguiente para habilitar el auto-inicio al momento de encender la computadora y luego iniciar tu servicio del stake pool.

```text
sudo systemctl daemon-reload
sudo systemctl enable cardano-node
sudo systemctl start cardano-node
```

Bien hecho. Tu stake pool ahora es dirigida por la fiabilidad y solidez de systemd. Acontinuacióin encontrarás algunos comandos para usar con systemd.

\*\*\*\*⛓ Vuelve a adjuntarte a la sesión tmux de tu stake pool luego del inicio del sistema.

```text
tmux a
```

**🚧 Sepárate de la sesión tmux y deja el nodo ejecutándose en el fondo**

```text
press Ctrl + b + d
```

**✅ Chequear si el nodo del stake pool está activo**

```text
sudo systemctl is-active cardano-node
```

**🔎 Ver el estado del servicio del stake pool**

```text
sudo systemctl status cardano-node
```

**🔄 Reiniciar el servicio del stake pool**

```text
sudo systemctl reload-or-restart cardano-node
```

**🛑 Deteniendo el servicio del stake pool**

```text
sudo systemctl stop cardano-node
```

**🗄 Filtrando registros**

```bash
journalctl --unit=cardano-node --since=yesterday
journalctl --unit=cardano-node --since=today
journalctl --unit=cardano-node --since='2020-07-29 00:00:00' --until='2020-07-29 12:00:00'
```

#### ✅ 18.7 Verifica el ticker de tu stake pool con la llave de ITN

Para defender contra falsificación y apropiación de las stake pools con buena reputación, un dueño puede verificar su ticker proporcionando titularidad de un stake pool en ITN.

La fase de la Testnet Incentivada de la era Shelley de Cardano se llevó a cabo desde finales de noviembre del 2019 hasta finales de junio 2020. Si participaste, puedes verificar tu ticker.

Asegúrate que los binarios `jcli` de la ITN estén presentes en `$NODE_HOME`. Usa `jcli` para firmar tu stake pook id con tu `itn_owner.skey`

**Máquina fuera de línea, aislada del internet**

```bash
./jcli key sign --secret-key itn_owner.skey stakepoolid.txt --output stakepoolid.sig
```

Visita [pooltool.io](https://pooltool.io/) e introduce tu llaver pública de propietario y los datos de tu testigo de pool id en la sección de metadatos.

Encuentra tu testigo de pool id con el siguiente comando.

**Máquina fuera de línea, aislada del internet**

```text
cat stakepoolid.sig
```

Encuentra tu llave pública de propietario en el archivo que creaste en la ITN. Estos datos pueden ser almacenados en un archivo con terminación `.pub`

Finalmete, realiza las instrucciones de la sección 18.4 para actualizar los datos del registro de tu pool con el **`metadata-url`** y el **`metadata-hash`** generados por pooltool . Nota que los metadatos tienen un campo "expandible" lo cual comprueba la titularidad de tu ticker desde ITN.

#### 📚 18.8 Actualizando los archivos de configuración de tu nodo

Manten tus archivos de configuración actualizados descargando los archivos .json más recientes.

```bash
NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')
cd $NODE_HOME
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-byron-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-shelley-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json
sed -i ${NODE_CONFIG}-config.json \
    -e "s/SimpleView/LiveView/g" \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
```

#### 💸 18.9 Ejemplo de enviar una simple transacción

Veamos el ejemplo de enviar **10 ADA** a la **dirección de donaciones de CoinCashew** o la **dirección de donaciones de The Legend of ₳da \[TLOA\]** 🙃

Primeramente, consulta el **tip** de la blockchain para tener el parámetro **ttl** apropiado.

**Nodo Productor de Bloques**

```bash
currentSlot=$(cardano-cli shelley query tip --mainnet | jq -r '.slotNo')
echo Slot Actual: $currentSlot
```

Decide la cantidad a enviar en lovelaces. ✨ Recuerda que **1 ADA** = **1,000,000 lovelaces**.

**Nodo Productor de Bloques**

```bash
amountToSend=10000000
echo MontoAEnviar: $amountToSend
```

Estable la dirección destinataria, a la cual enviarás los fondos.

**Nodo Productor de Bloques**

**Para enviar 10 ADA a CoinCashew, usa el siguiente comando:**

```bash
destinationAddress=addr1qxhazv2dp8yvqwyxxlt7n7ufwhw582uqtcn9llqak736ptfyf8d2zwjceymcq6l5gxht0nx9zwazvtvnn22sl84tgkyq7guw7q
echo direccionDestinataria: $destinationAddress
```

**Para enviar 10 ADA a The Legend of ₳da, usa el siguiente comando:**

```bash
destinationAddress=addr1q87d37clyu4ctaz5ah8lrjwzyrsrqvpt0u83wghvdl66ea6gvzmayvajt7rstn79xtcxmuxk84k3s0qypq7af74lfemsvlzktu
echo direccionDestinataria: $destinationAddress
```

**Nodo Productor de Bloques**

Consulta tu saldo y **UTXOs**.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Saldo Total de ADA: ${total_balance}
echo Numero de UTXOs: ${txcnt}
```

Ejecuta el comando de build-raw.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --tx-out ${destinationAddress}+0 \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp
```

Calcula el costo mínimo actual:

**Nodo Productor de Bloques**

```bash
fee=$(cardano-cli shelley transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 2 \
    --mainnet \
    --witness-count 1 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo costoMinimo: $fee
```

Calcula el output de tu cambio.

**Nodo Productor de Bloques**

```bash
txOut=$((${total_balance}-${fee}-${amountToSend}))
echo Change Output: ${txOut}
```

Construye tu transacción.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --tx-out ${destinationAddress}+${amountToSend} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --out-file tx.raw
```

Copia **tx.raw** a tu **ambiente frío**

Firma la transacción con ambas llaves de pago y de stake.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```

Copia **tx.signed** a tu **ambiente caliente**.

Envía la transacción firmada.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --mainnet
```

Revisa que los fondos hayan llegado.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address ${destinationAddress} \
    --mainnet
```

Deberías de recibir un output similar a el siguiente, mostrando los fondos que enviaste.

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        10000000
```

#### 🍰 18.10 Reclama tus recompensas

Vamos a guíarte en el ejemplo de cómo reclamar las recompensas de tu stake pool.

Las recompensas están acumuladas en la dirección `stake.addr`.

Primero, encuentra el **tip** de la blockchain para establecer el parámetro **ttl** apropiadamente.

**Nodo Productor de Bloques**

```bash
currentSlot=$(cardano-cli shelley query tip --mainnet | jq -r '.slotNo')
echo Slot Actual: $currentSlot
```

Indica el monto de lovelaces que quieres enviar. ✨ Recuerda **1 ADA** = **1,000,000 lovelaces.**

**Nodo Productor de Bloques**

```bash
rewardBalance=$(cardano-cli shelley query stake-address-info \
    --mainnet \
    --address $(cat stake.addr) | jq -r ".[0].rewardAccountBalance")
echo rewardBalance: $rewardBalance
```

Indica la dirección destinataria a la cual enviarás tus recompensas. Esta dirección debe de tener un saldo positivo para pagar por el costo de la transacción.

**Nodo Productor de Bloques**

```bash
destinationAddress=$(cat payment.addr)
echo destinationAddress: $destinationAddress
```

Encuentra el saldo y los utxos de tu payment.addr balance y construye tu cadena de retiro \(withdrawal string\).

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}

withdrawalString="$(cat stake.addr)+${rewardBalance}"
```

Ejecuta el comando de transacción build-raw.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --withdrawal ${withdrawalString} \
    --out-file tx.tmp
```

Calcula el costo mínimo actual:

**Nodo Productor de Bloques**

```bash
fee=$(cardano-cli shelley transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```

Calcula el output de tu cambio.

**Nodo Productor de Bloques**

```bash
txOut=$((${total_balance}-${fee}+${rewardBalance}))
echo Change Output: ${txOut}
```

Construye tu transacción.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --withdrawal ${withdrawalString} \
    --out-file tx.raw
```

Copia **tx.raw** a tu **ambiente frío**.

Firma la transacción con ambas llaves de pago y de stake.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```

Copia **tx.signed** a tu **ambiente caliente**.

Envía la transacción firmada.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --mainnet
```

Revisa que los fondos hayan llegado.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address ${destinationAddress} \
    --mainnet
```

Deberías de recibir un output similar a el siguiente, mostrando los fondos que enviaste.

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....
```

### 🌜 19. Retirando tu stake pool

Encuentra los slots por epoch.

**Nodo Productor de Bloques**

```bash
epochLength=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.epochLength')
echo epochLength: ${epochLength}
```

Encuentra el slot actual consultando el tip.

**Nodo Productor de Bloques**

```bash
slotNo=$(cardano-cli shelley query tip --mainnet | jq -r '.slotNo')
echo slotNo: ${slotNo}
```

Calcula la epoch actual dividiendo el número del tip en el slot por la epochLength.

**Nodo Productor de Bloques**

```bash
epoch=$(( $((${slotNo} / ${epochLength})) + 1))
echo current epoch: ${epoch}
```

Encuentra el valor de eMax.

**Nodo Productor de Bloques**

```bash
eMax=$(cat $NODE_HOME/params.json | jq -r '.eMax')
echo eMax: ${eMax}
```

\*\*\*\*🚧 **Ejemplo**: si estamos en la epoch 39 y eMax es 18,

* la epoch más pronta para retirar es 40 \( epoch actual  + 1\).
* la epocj más tardía para retirar es 57 \( eMax + epoch actual\). 

Pretendamos quye deseamos retirarnos lo más pronto posible en la epoch 40.

Crea el certificado de cancelación de registro y guárdalo como `pool.dereg`:

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley stake-pool deregistration-certificate \
--cold-verification-key-file $HOME/cold-keys/node.vkey \
--epoch $((${epoch} + 1)) \
--out-file pool.dereg
echo pool will retire at end of epoch: $((${epoch} + 1))
```

Copia **pool.dereg** a tu**ambiente caliente**.

Encuentra tu saldo y **UTXOs**.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Saldo Total de ADA: ${total_balance}
echo Numero de UTXOs: ${txcnt}
```

Ejecuta el comando de transacción build-raw.

El valor del **ttl** debe de ser mayor al tip actual. En este ejemplo, usamos el slot actual + 10000.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${total_balance} \
    --ttl $(( ${slotNo} + 10000)) \
    --fee 0 \
    --certificate-file pool.dereg \
    --out-file tx.tmp
```

Calcula el costo a pagar:

**Nodo Productor de Bloques**

```bash
fee=$(cardano-cli shelley transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo costo: $fee
```

Calcula el output de tu cambio.

**Nodo Productor de Bloques**

```bash
txOut=$((${total_balance}-${fee}))
echo txOut: ${txOut}
```

Construye la transacción.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --ttl $(( ${slotNo} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.dereg \
    --out-file tx.raw
```

Copia **tx.raw** a tu **ambiente frío**.

Firma la transacción.

**Máquina fuera de línea, aislada del internet**

```bash
cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --mainnet \
    --out-file tx.signed
```

Envía la transacción.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --mainnet
```

Tu pool será retirado al final de tu epoch especificada. En este ejemplo, el retiro ocurrirá al final de la epoch 40.

Si cambias de parecer, puedes crear y enviar un nuevo certificado de registro antes de que termine la epoch 40, lo cual anulará el certificado de cancelación de registro.

Luego de la epoch de retiro, puede verificar que el pool fuer retirado exitosamente utilizando el siguiente comando el cual debería de regresar una cadena vacía.

**Nodo Productor de Bloques**

```bash
cardano-cli shelley query ledger-state --mainnet --out-file ledger-state.json
jq -r '.esLState._delegationState._pstate._pParams."'"$(cat stakepoolid.txt)"'"  // empty' ledger-state.json
```


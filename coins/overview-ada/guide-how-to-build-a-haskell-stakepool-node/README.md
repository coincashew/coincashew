---
description: >-
  Esta guía mostrará la manera de instalar y configurar un Stake Pool de Cardano desde su código fuente en una configuración de dos nodos, con 1 Nodo Productor de Bloques y 1 Nodo Relevador.
---

# Guía: ¿Cómo implementar una Stake Pool en Cardano?

{% hint style="info" %}
¡Muchas gracias por todo el apoyo y los mensajes! Realmente nos motiva a seguir creando las mejores guías de criptomonedas. Si deseas donar [estas son las direcciones](https://cointr.ee/coincashew) a las que puedes depositar 🙏 
{% endhint %}

{% hint style="success" %}
Última actualización: 7 de Abril de 2021. 
La guía está en su **versión 3.2.0** y está escrita para la  **mainnet de cardano** versión **1.26.1** 😁 
{% endhint %}

### 🏁 0. Prerrequisitos

#### 🧙 Habilidades necesarias para los operadores

Como operador de un nodo de Cardano, tendrás que tener las siguientes habilidades:

* Conocimientos de cómo implementar, iniciar y mantener un nodo de Cardano de manera continua.
* Compromiso de mantener tu nodo funcionando 24/7/365.
* Habilidad para operar sistemas.
* Habilidad para la administración de servidores \(operación y mantenimiento\).

### 🧙 Experiencia necesaria para los operadores

* Experiencia en DevOps.
* Experiencia [reforzando](https://www.lifewire.com/harden-ubuntu-server-security-4178243) y [aumentando la seguridad de un servidor](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3).
* [Haber tomado el curso oficial de Stake Pool.](https://cardano-foundation.gitbook.io/stake-pool-course/) 

{% hint style="danger" %}
🛑 **Antes de continuar, es NECESARIO cumplir con los requisitos anteriores.** 🚧 
{% endhint %}

#### 🎗 Hardware mínimo

* **Dos servidores independientes:** 1 para el nodo productor, 1 para el nodo relevador.
* **Una máquina fuera de línea \(Ambiente frío\)**
* **Sistema Operativo:** Linux 64-bit \(por ejemplo Ubuntu Server 20.04 LTS\).
* **Procesador:** Un procesador AMD o Intel de x86 con dos o más núcleos, de 2GHz o mayor.
* **Memoria:** 8GB de RAM.
* **Almacenamiento:** Al menos 20GB de almacenamiento disponible.
* **Internet:** Conexión con una velocidad de al menos 10Mbps.
* **Plan de Datos**: De al menos 1GB por hora. 720GB al mes.
* **Alimentación:** Alimentación eléctrica confiable.
* **ADA:** Al menos 505 ADA para el registro del Stake Pool y tarifas de transacción.

#### 🏋♂ Hardware recomendado a futuro

* **Tres servidores independientes:** 1 para el nodo productor de bloques, 2 para los nodos relevadores.
* **Una máquina fuera de línea \(Ambiente frío\)**
* **Sistema Operativo:** Linux 64-bit \(por ejemplo Ubuntu Server 20.04 LTS\).
* **Procesador:** Un procesador de 4 núcleos o mayor.
* **Memoria:** Más de 8GB de RAM.
* **Almacenamiento:** Un SSD 256GB o más.
* **Internet:** Conexión con una velocidad de al menos 100Mbps.
* **Plan de Datos**: Ilimitado.
* **Alimentación:** Alimentación eléctrica confiable con UPS.
* **ADA:** Dependerá del parámetro **a0**, entre más ADA en el Stake Pool será mejor a futuro.

#### 🔓 Medidas de Seguridad

Si deseas mejorar la seguridad de tus nodos, puedes consultar el siguiente enlace:

{% page-ref page="how-to-harden-ubuntu-server.md" %}

### 🛠 Instalación de Ubuntu

Si necesitas ayuda instalando **Ubuntu Server**, puedes consultar el siguiente enlace:

{% embed url="https://ubuntu.com/tutorials/install-ubuntu-server\#1-overview" %}

Si necesitas ayuda instalando **Ubuntu Desktop**, puedes consultar el siguiente enlace:

{% page-ref page="../../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}


### 🧱 Reconstruyendo Nodos

Si estás reconstruyendo o reutilizando una instalación previa de `cardano-node`, consulta la [sección 18.2 ¿Cómo reiniciar la instalación?.](./#18-2-resetting-the-installation)

### 🏭 1. Instalar Cabal y GHC

Si estás usando Ubuntu Desktop, **presionar** Ctrl+Alt+T abrirá una nueva sesión en la terminal.

Actualizamos el sistema e instalamos las dependencias de Ubuntu.

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

Instalamos Cabal y sus dependencias.

```bash
sudo apt-get -y install pkg-config libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev build-essential curl libgmp-dev libffi-dev libncurses-dev libtinfo5
```

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

Respondemos **NO** cuando se nos pida instalar haskell-language-server \(HLS\).

Respondemos **YES** para agregar de manera automática la variable PATH al archivo ".bashrc".

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
ghcup upgrade
ghcup install cabal 3.4.0.0
ghcup set cabal 3.4.0.0
```

Instalamos GHC.

```bash
ghcup install ghc 8.10.4
ghcup set ghc 8.10.4
```

Actualizamos la variable PATH para que incluya a Cabal y GHC y exportamos rutas y variables. La localización del nodo estará en **$NODE\_HOME**. La [configuración del cluster](https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html) está dada por **$NODE\_CONFIG** y **$NODE\_BUILD\_NUM**. 

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

En cada parámetro de ****CLI parameter**** donde aparezca: 

 `--mainnet` 

lo reemplazaremos por:

`--testnet-magic 1097911063`
{% endhint %}

Actualizamos Cabal, y una vez terminado nos aseguramos de que la versión sea la correcta.

```bash
cabal update
cabal --version
ghc --version
```

{% hint style="info" %}
Cabal debe ser versión 3.4.0.0 y GHC versión 8.10.4
{% endhint %}


### 🏗 2. Construyendo el nodo desde su código fuente

Descargamos el código fuente y cambiamos la etiqueta de versión a descargar para que corresponda a la 1.26.1.

```bash
cd $HOME/git
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node
git fetch --all --recurse-submodules --tags
git checkout tags/1.26.1
```

Configuramos las opciones de construcción.

```text
cabal configure -O0 -w ghc-8.10.4
```

Actualizamos la configuración de Cabal, los parámetros del proyecto y reiniciamos la carpeta donde se va a construir.

```bash
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
sed -i $HOME/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
rm -rf $HOME/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.10.4
```

¡Ahora construimos el nodo!

```text
cabal build cardano-cli cardano-node
```

{% hint style="info" %}
El proceso de construcción puede tomar de unos cuantos minutos a unas cuantas horas, dependiendo de la capacidad de procesamiento de la computadora.
{% endhint %}

Copiamos los archivos **cardano-cli** y **cardano-node** a la carpeta bin.

```bash
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
```

```bash
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

Verificamos que las versiones de **cardano-cli** y **cardano-node** sean las correctas (En este caso, la 1.26.1).

```text
cardano-node version
cardano-cli version
```


### 📐 3. Configuración de los nodos

Descargamos los archivos config.json, genesis.json y topology.json, los cuales son necesarios para la configuración y arranque del nodo.

```bash
mkdir $NODE_HOME
cd $NODE_HOME
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-byron-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-topology.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-shelley-genesis.json
wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/${NODE_CONFIG}-config.json
```

Ejecutamos los siguientes comandos para modificar el archivo **mainnet-config.json** y actualizar la línea:
* update TraceBlockFetchDecisions a "true"

```bash
sed -i ${NODE_CONFIG}-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
```

{% hint style="info" %}
\*\*\*\*✨ **Tip**: En el Nodo Relevador es posible reducir el consumo de memoria y de CPU cambiando el parámetro "TraceMemPool" a "false" en el archivo **mainnet-config.json**  
{% endhint %}

Actualizamos nuestro archivo **.bashrc** con las nuevas variables de Shell.

```bash
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> $HOME/.bashrc
source $HOME/.bashrc
```

#### 🔮 4. Configurar el Nodo Productor

{% hint style="info" %}
Un Nodo Productor de Bloques es aquel que está configurado con varios pares de claves \(Frías,KES y VRF\), las cuales son necesarias para la producción de bloques. Solamente debe de tener conexión con sus Nodos Relevadores.
{% endhint %}

{% hint style="info" %}
Un Nodo Relevador no tendrá ningún tipo de clave y por lo tanto no será capaz de producir ningún bloque. Estará conectado a su Nodo Productor, aotros relevadores y nodos externos en la red.
{% endhint %}

![](../../../.gitbook/assets/producer-relay-diagram.png)

{% hint style="success" %}
Para propósitos de la guía, vamos a trabajar **dos nodos** en **dos servidores independientes**. Uno será llamado el **NodoProductor** y el otro será su Nodo Relevador, llamado **NodoRelevador1**.
{% endhint %}

{% hint style="danger" %}
Editamos el archivo **topology.json** para que: 

* El/Los Nodo(s) Relevadore(s) se conecten a los Relevadores Públicos \(como los de  IOHK y los Nodos de amigos\) y a tu Nodo Productor de Bloques.
* El Nodo Productor de Bloques **SOLAMENTE** debe de tener conexión con el/los Nodo(s) Relevadore(s). 
{% endhint %}

En el **Nodo Productor de Bloques,** ejecuta los siguientes comandos. Cambia el campo **addr** con la IP pública de tu Nodo Relevador (En caso de que ambos estén en una red local, deberás colocar la IP privada de tu Nodo Relevador).

{% tabs %}
{% tab title="NodoProductor" %}
```bash
cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "DIRECCION IP DEL NODO RELEVADOR",
        "port": 6000,
        "valency": 1
      }
    ]
  }
EOF
```
{% endtab %}
{% endtabs %}

### 🛸 5. Configurar el Nodo Relevador

{% hint style="warning" %}
🚧 En el otro servidor que será designado como tu Nodo Relevador, o como lo llamamos en la guía: **NodoRelevador1**, repite los pasos del **1 al 3** para construir los archivos binarios del nodo de Cardano.
{% endhint %}

{% hint style="info" %}
Puedes tener múltiples Nodos Relevadores a manera que escales la arquitectura de tu Stake Pool. Simplemente reemplaza el número de **NodoRelevadorN** y adapta las instrucciones de la guía para generar otro Nodo Relevador. 
{% endhint %}

En el **NodoRelevador1** ejectuta el siguiente comando, **recuerda cambiar la dirección IP del Nodo Productor** (En caso de que ambos estén en una red local, deberás colocar la IP privada de tu Nodo Productor de Bloques).

{% tabs %}
{% tab title="NodoRelevador1" %}
```bash
cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "IP DEL NODO PRODUCTOR DE BLOQUES",
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
{% endtab %}
{% endtabs %}

{% hint style="info" %}
La valencia, **valency**, le indica a tu nodo cuántas conexiones mantener abiertas. Solamente afecta a las direcciones en modo de DNS. Si el valor es 0, la dirección es ignorada.
{% endhint %}

{% hint style="danger" %}
\*\*\*\*✨ **Abrir los Puertos:** Necesitarás abrir el puerto 6000 de tus nodos para que se puedan comunicar entre sí. Puedes ver el estado del puerto en las siguientes páginas: [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) , [https://canyouseeme.org/](https://canyouseeme.org/) .
{% endhint %}

### 🔏 6. Configurar la máquina fuera de línea

{% hint style="info" %}
Una máquina fuera de línea se conoce como un **ambiente frío**. 

* Está protegida contra intentos de key-logging, ataques basados en virus o otro tipo de exploit del firewall.
* Físicamente aislada del resto de la red.
* No debe estar conectada a la red por cable Ethernet ni vía Inalámbrica. 
* No es una máquina virtual con conexión a la red.
* Puedes aprender más acerca de esta medida de seguridad en [Air-Gapping, en Wikipedia](https://en.wikipedia.org/wiki/Air_gap_%28networking%29).
{% endhint %}

{% tabs %}
{% tab title="Máquina Fuera de Línea" %}
```bash
echo export NODE_HOME=$HOME/cardano-my-node >> $HOME/.bashrc
source $HOME/.bashrc
mkdir -p $NODE_HOME
```
{% endtab %}
{% endtabs %}

Copia de tu **ambiente caliente**, también conocido como el Nodo Productor de Bloques, una copia del archivo **`cardano-cli`** hacia tu **ambiente frío**, y colócalo en la carpeta de binarios. 

{% hint style="danger" %}
Para que verdaderamente se considere una Máquina Fuera de Línea, debes de mover los archivos de manera física entre los dos usando una USB o otro dispositivo portátil.
{% endhint %}


### 🤖 7. Creación de Scripts de arranque

El script de arranque contiene todas las variables necesarias para ejecutar el Nodo de Cardano, tales como el directorio, puerto, ruta a la base de datos, archivos de configuración y el archivo de la topología.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
#!/bin/bash
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
/usr/local/bin/cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```
{% endtab %}

{% tab title="NodoRelevador1" %}
```bash
cat > $NODE_HOME/startRelayNode1.sh << EOF 
#!/bin/bash
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
DB_PATH=\${DIRECTORY}/db
SOCKET_PATH=\${DIRECTORY}/db/socket
CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
/usr/local/bin/cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
EOF
```
{% endtab %}
{% endtabs %}

Le damos permisos de ejecución a los scripts de arranque.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
chmod +x $NODE_HOME/startBlockProducingNode.sh
```
{% endtab %}

{% tab title="NodoRelevador1" %}
```bash
chmod +x $NODE_HOME/startRelayNode1.sh 
```
{% endtab %}
{% endtabs %}

Introduce los siguientes comandos para crear un **archivo de unidad en systemd** esto nos permitirá hacer un servicio llamado cardano-node.

{% hint style="info" %}
#### 🍰 Ventajas de usar systemd para una Stake Pool

1. Reinicio automático del Stake Pool ante cualquier reinicio inesperado.
2. Reinicio automático en caso de falla de un proceso.
3. Maximiza el tiempo que se mantiene en línea la Stake Pool y mejora su desempeño.
{% endhint %}

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cat > $NODE_HOME/cardano-node.service << EOF 
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service 

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = ${USER}
Type            = simple
WorkingDirectory= ${NODE_HOME}
ExecStart       = /bin/bash -c '${NODE_HOME}/startBlockProducingNode.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
LimitNOFILE=32768
Restart=always
RestartSec=5
SyslogIdentifier=cardano-node

[Install]
WantedBy	= multi-user.target
EOF
```
{% endtab %}

{% tab title="NodoRelevador1" %}
```bash
cat > $NODE_HOME/cardano-node.service << EOF 
# The Cardano node service (part of systemd)
# file: /etc/systemd/system/cardano-node.service 

[Unit]
Description     = Cardano node service
Wants           = network-online.target
After           = network-online.target 

[Service]
User            = ${USER}
Type            = simple
WorkingDirectory= ${NODE_HOME}
ExecStart       = /bin/bash -c '${NODE_HOME}/startRelayNode1.sh'
KillSignal=SIGINT
RestartKillSignal=SIGINT
TimeoutStopSec=2
LimitNOFILE=32768
Restart=always
RestartSec=5
SyslogIdentifier=cardano-node

[Install]
WantedBy	= multi-user.target
EOF
```
{% endtab %}
{% endtabs %}

Movemos el archivo hacia `/etc/systemd/system` y le damos permisos de ejecución, lectura y escritura para el usuario.

```bash
sudo mv $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
```

```bash
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

Ejecutamos los siguientes comandos para habilitar el inicio automático de nuestro servicio al arranque del sistema.

```text
sudo systemctl daemon-reload
sudo systemctl enable cardano-node
```

{% hint style="success" %}
Tu Stake Pool ahora está administrada por la robustez y confiabilidad de Systemd. A continuación hay varios comandos para utilizar systemd
{% endhint %}

#### 🔎 Ver el estado actual del Nodo

```text
sudo systemctl status cardano-node
```

#### 🔄 Reiniciar el Nodo

```text
sudo systemctl reload-or-restart cardano-node
```

#### 🛑 Detemer el Nodo

```text
sudo systemctl stop cardano-node
```

#### 🗄 Ver y filtrar registros

```bash
journalctl --unit=cardano-node --follow
```

```bash
journalctl --unit=cardano-node --since=yesterday
```

```text
journalctl --unit=cardano-node --since=today
```

```text
journalctl --unit=cardano-node --since='2020-07-29 00:00:00' --until='2020-07-29 12:00:00'
```


### ✅ 8. Iniciando los Nodos

¡Vamos a iniciar la sincronización de los nodos con la cadena de bloques!

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
sudo systemctl start cardano-node
```
{% endtab %}

{% tab title="NodoRelevador1" %}
```bash
sudo systemctl start cardano-node
```
{% endtab %}
{% endtabs %}

Instalamos gLiveView, una herramienta de monitoreo.

{% hint style="info" %}
gLiveView muestra información importante de nuestro nodo y funciona bien con los servicios controlados con systemd. Créditos a [Guild Operators](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview) por desarrollar esta herramienta.
{% endhint %}

```bash
cd $NODE_HOME
sudo apt install bc tcptraceroute -y
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh
```

Ejecutamos lo siguiente para modificar el archivo **env** con las rutas y variables de nuestro nodo.

```bash
sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
```

{% hint style="warning" %}
El nodo debe de alcanzar el epoch 208 \(lanzamiento de Shelley\), antes de que **gLiveView** pueda empezar a mostrar información acerca de la sincronización del nodo. Por el momento puedes usar `journalctl` en lo que el nodo alcanza el epoch 208.

```text
journalctl --unit=cardano-node --follow
```
{% endhint %}

Mandamos a ejecutar gLiveView para monitorear el proceso de sincronización de nuestro nodo.

```text
./gLiveView.sh
```

Vista de ejemplo de gLiveView

![](../../../.gitbook/assets/glive.png)

Para más información, puedes ir a la [página Oficial de Guild Live View](https://cardano-community.github.io/guild-operators/#/Scripts/gliveview)

{% hint style="info" %}
\*\*\*\*✨ **Super Tip**: Si terminas de sincronizar la base de datos de un nodo, puedes copiar el directorio completo al otro nodo para reducir el tiempo de sincronización.
{% endhint %}

{% hint style="success" %}
¡Felicidades! Tu nodo ahora se encuentra corriendo, déjalo sincronizar.
{% endhint %}

### ⚙ 9. Generación de claves para el Nodo Productor de Bloques
El nodo Productor de Bloques requiere la creación de 3 claves, las cuales están definidas [en el documento de Shelley](https://hydra.iohk.io/build/2473732/download/1/ledger-spec.pdf):

* Clave fría del Stake Pool \(node.cert\)
* Clave caliente del Stake Pool \(kes.skey\)
* Clave VRF del Stake Pool \(vrf.skey\)

Primero, generamos el par de claves KES.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cd $NODE_HOME
cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Las claves KES \(Key Evolving Signature\) están hechas para prevenir ataques de hackers que pudieran comprometer la seguridad de tus claves.

**En la mainnet, las claves KES deben ser generadas cada 90 días.**
{% endhint %}

{% hint style="danger" %}
\*\*\*\*🔥 **Las claves frías** **deben ser creadas y resguardadas en tu máquina fuera de línea** Las claves frías se almacenan en la ruta `$HOME/cold-keys.`
{% endhint %}

Hacemos un directorio para almacenar nuestras claves frías.

{% tabs %}
{% tab title="Máquina Fuera de Línea" %}
```text
mkdir $HOME/cold-keys
pushd $HOME/cold-keys
```
{% endtab %}
{% endtabs %}

Generamos el par de claves frías y creamos el archivo node.counter.

{% tabs %}
{% tab title="Máquina Fuera de Línea" %}
```bash
cardano-cli node key-gen \
    --cold-verification-key-file node.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
Asegúrate de **respaldar todas tus claves** en otro dispositivo de almacenamiento seguro. Es recomendable tener múltiples copias.
{% endhint %}

Determinamos el número de slots por periodo KES del archivo genesis.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
pushd +1
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
echo slotsPerKESPeriod: ${slotsPerKESPeriod}
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
Antes de continuar, tu nodo debe de estar completamente sincronizado a la cadena de bloques. De lo contrario no podrás calcular el periodo KES. Tu nodo se encuentra sincronizado cuando el epoch y el slot en gLiveView son iguales a los que muestra un explorador de bloques, tal como [https://pooltool.io/](https://pooltool.io/)
{% endhint %}

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo slotNo: ${slotNo}
```
{% endtab %}
{% endtabs %}

Encontramos **kesPeriod** dividiendo número de slot entre los slots por periodoKES.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
echo kesPeriod: ${kesPeriod}
startKesPeriod=${kesPeriod}
echo startKesPeriod: ${startKesPeriod}
```
{% endtab %}
{% endtabs %}

Con este cálculo, ya podemos generar el certificado de operación para el Stake Pool. 

Copia **kes.vkey** a tu **ambiente frío**. 

Cambiamos &lt;**startKesPeriod&gt;** al valor calculado anteriormente.

{% hint style="info" %}
Los operadores deben de proveer un certificado de operación para verificar que el Stake Pool tiene la autorización de funcionar. El certificado incluye la firma del operador e información clave acerca del Stake Pool \(direcciones, claves, etc.\). Los certificados de operación representan el vínculo entre las claves fuera de línea y sus claves de operación.
{% endhint %}

{% tabs %}
{% tab title="Máquina Fuera de Línea" %}
```bash
cardano-cli node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period <startKesPeriod> \
    --out-file node.cert
```
{% endtab %}
{% endtabs %}

Copia **node.cert** a tu **ambiente caliente**.

Hacemos un par de claves VRF.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
```
{% endtab %}
{% endtabs %}

Actualizamos los permisos de la clave VRF para ser solo lectura.

```text
chmod 400 vrf.skey
```

Detenemos la ****Stake Pool ejecutando el siguiente código:

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
sudo systemctl stop cardano-node
```
{% endtab %}
{% endtabs %}

Actualizamos el script de arranque con nuestros nuevos archivos **KES, VRF y el Certificato de Operación.**

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cat > $NODE_HOME/startBlockProducingNode.sh << EOF 
DIRECTORY=$NODE_HOME
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
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Para operar una Stake Pool, necesitas los archivos KES, VRF y el Certificado de Operación. Las llaves frías generan nuevos certificados de operación de manera periódica.
{% endhint %}

Iniciamos el Nodo Productor de Bloques.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
sudo systemctl start cardano-node

# Monitor with gLiveView
./gLiveView.sh
```
{% endtab %}
{% endtabs %}

### 🔐 10. Establecer las claves de pago y stake


Primero obtenemos los parámetros del protocolo.

{% hint style="info" %}
Si aparece el siguiente mensaje al momento de obtener los parámetros, debes de esperar a que tu Nodo Productor de Bloques comience a sincronizar de nuevo.

`cardano-cli: Network.Socket.connect: : does not exist (No such file or directory)`
{% endhint %}

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli query protocol-parameters \
    --mainnet \
    --out-file params.json
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Las claves de pago son usadas para mandar y recibir pagos, mientras que las claves de stake son usadas para administrar las delegaciones.
{% endhint %}

Hay dos maneras de crear tu par de claves de `pago` y `stake`. Elige la que cumpla mejor con tus necesidades.

{% hint style="danger" %}
🔥 **Consejo Crítico de Seguridad:** Las claves de `pago` y `stake` deben de ser generadas y usadas para construir transacciones en un ambiente frío, en otras palabras tu **Máquina Fuera de Línea**. Copia el binario `cardano-cli` a tu Máquina Fuera de Línea y ejecuta el método CLI o el método de la mnemónica. Los únicos pasos que son hechos en el Nodo Productor son aquellos que requieren información actualizada. Específicamente los siguientes pasos:  

* Consultar el slot actual en la red.
* Consultar el balance de una dirección.
* Enviar una transacción.
{% endhint %}

{% tabs %}
{% tab title="Método CLI" %}
Creamos un nuevo par de claves de pago:  `payment.skey` y `payment.vkey`

```bash
###
### En la máquina fuera de línea,
###
cd $NODE_HOME
cardano-cli address key-gen \
    --verification-key-file payment.vkey \
    --signing-key-file payment.skey
```

Creamos un nuevo par de claves de stake: `stake.skey` y `stake.vkey`

```bash
###
### En la máquina fuera de línea,
###
cardano-cli stake-address key-gen \
    --verification-key-file stake.vkey \
    --signing-key-file stake.skey
```

Creamos una dirección de stake usando `stake.vkey` y la guardamos en `stake.addr`

```bash
###
### En la máquina fuera de línea,
###
cardano-cli stake-address build \
    --stake-verification-key-file stake.vkey \
    --out-file stake.addr \
    --mainnet
```

Construimos una dirección de pago para la clave de pago `payment.vkey` la cual delegará a la dirección de stake `stake.vkey`

```bash
###
### En la máquina fuera de línea,
###
cardano-cli address build \
    --payment-verification-key-file payment.vkey \
    --stake-verification-key-file stake.vkey \
    --out-file payment.addr \
    --mainnet
```
{% endtab %}

{% tab title="Método de la Mnemónica" %}
{% hint style="info" %}
Créditos a [ilap](https://gist.github.com/ilap/3fd57e39520c90f084d25b0ef2b96894) por crear este proceso.
{% endhint %}

{% hint style="success" %}
**Beneficios**: Monitorear y controlar las recompensas desde cualquier wallet \(Deadalus, Yoroi o cualquier otra\) que soporte staking.
{% endhint %}

Crea una wallet compatible con Shelley con mnemonica de 15 o 24 palabras en [Daedalus](https://daedaluswallet.io/) o con [Yoroi](../../../wallets/browser-wallets/yoroi-wallet-cardano.md), de preferencia en una máquina fuera de línea.

Usando el Nodo Productor de Bloques, descargamos `cardano-wallet`

```bash
###
### En el nodo productor,
###
cd $NODE_HOME
wget https://hydra.iohk.io/build/3662127/download/1/cardano-wallet-shelley-2020.7.28-linux64.tar.gz
```

Verificamos la legitimidad de la descarga de `cardano-wallet` revisando el [hash sha256 encontrado en el botón **Details**](https://hydra.iohk.io/build/3662127/).

```bash
echo "f75e5b2b4cc5f373d6b1c1235818bcab696d86232cb2c5905b2d91b4805bae84 *cardano-wallet-shelley-2020.7.28-linux64.tar.gz" | shasum -a 256 --check
```

Si aparece la siguiente línea en la terminal, significa que el hash es válido.

> cardano-wallet-shelley-2020.7.28-linux64.tar.gz: OK

{% hint style="danger" %}
Procede con los siguiente pasos solamente si sha256 retorna un **OK**!
{% endhint %}

Transfiere el archivo **cardano-wallet** a tu **Máquina Fuera de Línea** por USB o otro dispositivo.

Extraemos los archivos y eliminamos el comprimido.

```bash
###
### On air-gapped offline machine,
###
tar -xvf cardano-wallet-shelley-2020.7.28-linux64.tar.gz
rm cardano-wallet-shelley-2020.7.28-linux64.tar.gz
```

Creamos el script `extractPoolStakingKeys.sh`.

```bash
###
### On air-gapped offline machine,
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

# Generate the master key from mnemonics and derive the stake account keys 
# as extended private and public keys (xpub, xprv)
echo "\$MNEMONIC" |\
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
echo "Generated from 1852H/1815H/0H/{0,2}/0"
cat base.addr_candidate
echo

# XPrv/XPub conversion to normal private and public key, keep in mind the 
# keypars are not a valind Ed25519 signing keypairs.
TESTNET_MAGIC="--testnet-magic 1097911063"
MAINNET_MAGIC="--mainnet"
MAGIC="\$MAINNET_MAGIC"

SESKEY=\$( cat stake.xprv | bech32 | cut -b -128 )\$( cat stake.xpub | bech32)
PESKEY=\$( cat payment.xprv | bech32 | cut -b -128 )\$( cat payment.xpub | bech32)

cat << EOF > stake.skey
{
    "type": "StakeExtendedSigningKeyShelley_ed25519_bip32",
    "description": "",
    "cborHex": "5880\$SESKEY"
}
EOF

cat << EOF > payment.skey
{
    "type": "PaymentExtendedSigningKeyShelley_ed25519_bip32",
    "description": "Payment Signing Key",
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

echo "Important the base.addr and the base.addr_candidate must be the same"
diff base.addr base.addr_candidate
popd >/dev/null
HERE
```

Añadimos permisos de ejecución y exportamos la variable PATH para usar los binarios.

```bash
###
### On air-gapped offline machine,
###
chmod +x extractPoolStakingKeys.sh
export PATH="$(pwd)/cardano-wallet-shelley-2020.7.28:$PATH"
```

Extramos las claves, coloca en el comando tu frase mnemónica con la que se generó la wallet.

```bash
###
### On air-gapped offline machine,
###
./extractPoolStakingKeys.sh extractedPoolKeys/ <Frase Mnemónica de 15/24 palabras>
```

{% hint style="danger" %}
**Importante**: **base.addr** y **base.addr\_candidate** deben ser exactamente iguales. Revisa la terminal para confirmarlo.
{% endhint %}

Tus claves recien generadas se encontrarán en el directorio `extractedPoolKeys/`

Ahora transifiere los pares de claves `payment y stake` hacia `$NODE_HOME` para usarlas en tu Stake Pool.

```bash
###
### On air-gapped offline machine,
###
cd extractedPoolKeys/
cp stake.vkey stake.skey stake.addr payment.vkey payment.skey base.addr $NODE_HOME
cd $NODE_HOME
#Rename to base.addr file to payment.addr
mv base.addr payment.addr
```

{% hint style="info" %}
**payment.addr**, o también conocida como base.addr en el script de extracción, será la dirección de Cardano que almacene el pledge de tu Stake Pool.
{% endhint %}

Limpia el historial del bash para proteger tu frase mnemónica, eliminamos también los archivos de `cardano-wallet`.

```bash
###
### On air-gapped offline machine,
###
history -c && history -w
rm -rf $NODE_HOME/cardano-wallet-shelley-2020.7.28
```

Finalmente cierra todas las ventanas de terminal y abre una nueva sesión con cero historial.

{% hint style="success" %}
¡Genial! Ahora puedes monitorear las recompensas de tu Stake Pool desde una wallet.
{% endhint %}
{% endtab %}
{% endtabs %}

Ahora hay que añadir fondos a tu dirección de pago. 

Copia **payment.addr** a tu **entorno caliente**.

Las direcciones de pago pueden ser fondeadas desde Deadalus o Yoroi.

Ejecuta el siguiente comando para conocer tu dirección de pago.

```bash
cat payment.addr
```

Después de fondear tu cuenta, revisa el balance actual de tu dirección de pago.

{% hint style="danger" %}
Antes de continuar, tus nodos deben estar completamente sincronizados a la cadena de bloques. De otra manera no serás capaz de revisar tus fondos.
{% endhint %}

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet
```
{% endtab %}
{% endtabs %}

Deberías de ver una respuesta en la terminal similar a esto. Estás son tus UxTO \(Undspent transaction output\).

```text
                           TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
100322a39d02c2ead....                                              0        1000000000
```

### 👩💻 11. Registrando la dirección de Stake

Creamos el certificado `stake.cert`, usando `stake.vkey`

{% tabs %}
{% tab title="Máquina Fuera de Línea" %}
```text
cardano-cli stake-address registration-certificate \
    --stake-verification-key-file stake.vkey \
    --out-file stake.cert
```
{% endtab %}
{% endtabs %}

Copia **stake.cert** a tu **entorno caliente.**

Necesitarás encontrar el tip actual de la cadena de bloques para que el parámetro **invalid-hereafter** sea el correcto.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Consulta tu balance y tus **UTXOs**.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli query utxo \
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
```
{% endtab %}
{% endtabs %}

Encontramos el valor de **keyDeposit**

{% tabs %}
{% tab title="block producer node" %}
```bash
keyDeposit=$(cat $NODE_HOME/params.json | jq -r '.keyDeposit')
echo keyDeposit: $keyDeposit
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Registrar un certificado de dirección de stake \(keyDeposit\) cuesta 2000000 lovelace, o 2ADA.
{% endhint %}

Ejecutamos el comando para generar una nueva transacción.

{% hint style="info" %}
El valor de **invalid-hereafter** debe ser mayor al tip actual de la red. Para este ejemplo usamos **current slot + 10000**. Esto significa que la transacción no será valida pasando 10000 slots en la cadena de bloques.
{% endhint %}

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp \
    --certificate stake.cert
```
{% endtab %}
{% endtabs %}

Calculamos la tarifa mínima:

{% tabs %}
{% tab title="Nodo productor de Bloques" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Asegurate que el balance es mayor a la suma de la tarifa + keyDeposit, de otra manera no el registro no se hará.
{% endhint %}

Calculamos el balance restante, después de la transacción.

{% tabs %}
{% tab title="block producer node" %}
```bash
txOut=$((${total_balance}-${keyDeposit}-${fee}))
echo Change Output: ${txOut}
```
{% endtab %}
{% endtabs %}

Construimos la transacción que registrará la dirección de Stake.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file stake.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copia **tx.raw** a tu **entorno frío**
 
Firmamos la transacción con las claves secretas de pago y stake.

{% tabs %}
{% tab title="Máquina Fuera de Línea" %}
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

Copia **tx.signed** a tu **entorno caliente.**

Enviamos la transacción a la red.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

### 📄 12. Registrando el Stake Pool

Crea la metadata de tu Stake Pool con un archivo .JSON y actualiza la información de tu Stake Pool.

{% hint style="warning" %}
**ticker** debe de ser un valor de 3-5 caracteres. Solamente se pueden usar de la A-Z y del 0-9
{% endhint %}

{% hint style="warning" %}
**description** no puede exceder los 255 caracteres.
{% endhint %}

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cat > poolMetaData.json << EOF
{
"name": "Nombre de mi Stake Pool",
"description": "Descripcion de mi Stake Pool",
"ticker": "MEX",
"homepage": "https://mystakepoolrifa.com"
}
EOF
```
{% endtab %}
{% endtabs %}

Calcula el hash del archivo metadata.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
```
{% endtab %}
{% endtabs %}

Ahora sube el archivo **poolMetaData.json** a tu propio sito web o en un sitio web público tal como [https://pages.github.com/](https://pages.github.com/)

Consulta la siguiente guía si necesitas ayuda subiendo tu archivo a github.com

{% page-ref page="how-to-upload-poolmetadata.json-to-github.md" %}

Encontramos el costo mínimo del Stake Pool:

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
minPoolCost=$(cat $NODE_HOME/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Actualmente el costo mínimo es de 340000000 lovelace o 340ADA. Por lo tanto `--pool-cost` debe ser al menos esta cantidad.
{% endhint %}

Creamos un certificado de registro para la Stake Pool. Actualiza los campos de **metadata URL** y **relay node information**. Puedes elegir una de las tres opciones disponibles para configurar tus Nodos Relevadores -- En base a DNS, Round Robin en base a DNS o en base en IP.

{% hint style="info" %}
DNS based relays are recommended for simplicity of node management. In other words, you don't need to re-submit this **registration certificate** transaction every time your IP changes. Also you can easily update the DNS to point towards a new IP should you re-locate or re-build a relay node, for example.

Los relevadores en base a DNS son recomendados por las simplicidad de administración. En otras palabras, no necesitas volver a ennviar el **certificado de registro** cada que la IP del relevador cambia. También puedes actualizar más fácilmente el DNS para apuntar hacia otra dirección IP en caso de que tengas que reubicar o reconstruir el Nodo Relevador.
{% endhint %}

{% hint style="info" %}
#### \*\*\*\*✨ **¿Cómo configurar múltiples relevadores?** 

Update the next operation
Actualiza la siguiente operación para que sea ejecutada en tu máquina fuera de línea de manera apropiada

`cardano-cli stake-pool registration-certificate`

**Relevadores en base a DNS, 1 registro por DNS **

```bash
    --single-host-pool-relay relaynode1.myadapoolnamerocks.com\
    --pool-relay-port 6000 \
    --single-host-pool-relay relaynode2.myadapoolnamerocks.com\
    --pool-relay-port 6000 \
```
**Relevadores en base a Round Robin de DNS, 1 registro por** [**SRV DNS record**](https://support.dnsimple.com/articles/srv-record/)\*\*\*\*

```bash
    --multi-host-pool-relay relayNodes.myadapoolnamerocks.com\
    --pool-relay-port 6000 \
```

**Relevadores en base a IP, 1 registro por dirección IP**

```bash
    --pool-relay-port 6000 \
    --pool-relay-ipv4 DIRECCION IP DEL PRIMER RELEVADOR \
    --pool-relay-port 6000 \
    --pool-relay-ipv4 DIRECCION IP DEL SEGUNDO RELEVADOR \
```
{% endhint %}

{% hint style="warning" %}
La longitud del url de **metadata-url**, no debe ser mayor a 64 caracteres. 
{% endhint %}

{% tabs %}
{% tab title="Máquina Fuera de Línea" %}
```bash
cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000 \
    --pool-cost 340000000 \
    --pool-margin 0.01 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --single-host-pool-relay <dns based relay, example ~ relaynode1.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
    --metadata-url <url where you uploaded poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
En este ejemplo, tenemos un pledge de 100ADA con un costo fijo de 340 ADA y un margen del 1%.
{% endhint %}

Copia **pool.cert** a tu **entorno caliente.**

{% tabs %}
{% tab title="air-gapped offline machine" %}
```bash
cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
```
{% endtab %}
{% endtabs %}

Copia **deleg.cert** a tu **entorno caliente**.

{% hint style="info" %}
Esta operación crea un certificado de delegación, el cual delega los fondos de todas las direcciones de stake asociadas a la clave `stake.vkey` a la Stake Pool a la cual pertenece la clave fría `node.vkey`.  
{% endhint %}

{% hint style="info" %}
La promesa de colocar fondo a una Stake Pool propia se le conoce como el **Pledge**.

* El balance debe de ser mayor a la cantidad de pledge declarada.
* Tus fondos nunca se transfieren. El pledge se mantiene en la dirección asociada a `payment.addr`.
* En caso de no cumplir con la cantidad declarada de pledge la Stake Pool puede perder oportunidad de construir un bloque, por lo que las recompensas pueden disminuir.
* Tu pledge no se congela, eres libre de transferir tus fondos en cualquier momento.
{% endhint %}

Ahora necesitarás encontrar el **tip** de la cadena para una vez más, para que el parámetro **invalid-hereafter** sea el correcto.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slot')
echo Current Slot: $currentSlot
```
{% endtab %}
{% endtabs %}

Consulta tu balance y las **UTXOs**

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli query utxo \
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
```
{% endtab %}
{% endtabs %}

Consulta la tarifa de depósito para una Stake Pool

{% tabs %}
{% tab title="block producer node" %}
```bash
poolDeposit=$(cat $NODE_HOME/params.json | jq -r '.poolDeposit')
echo poolDeposit: $poolDeposit
```
{% endtab %}
{% endtabs %}

Ejecuta el comando para construir la transacción.

{% hint style="info" %}
El valor de **invalid-hereafter** debe ser mayor al tip actual de la red. Para este ejemplo usamos **current slot + 10000**. Esto significa que la transacción no será valida pasando 10000 slots en la cadena de bloques.
{% endhint %}

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${poolDeposit}))  \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.tmp
```
{% endtab %}
{% endtabs %}

Calculamos la tarifa mínima.

{% tabs %}
{% tab title="block producer node" %}
```bash
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Asegurate que tu balance sea mayor que la suma de la tarifa y minPoolCost, de otra manera el registro no funcionará.
{% endhint %}

Calculamos el balance después de la transacción.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
txOut=$((${total_balance}-${poolDeposit}-${fee}))
echo txOut: ${txOut}
```
{% endtab %}
{% endtabs %}

Construimos la transacción.

{% tabs %}
{% tab title="Nodo Productor de Bloques" %}
```bash
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw
```
{% endtab %}
{% endtabs %}

Copia **tx.raw** a tu **entorno frío**

Firmamos la transacción.

{% tabs %}
{% tab title="Máquina Fuera de Línea" %}
```bash
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
```
{% endtab %}
{% endtabs %}

Copia **tx.signed** a tu **entorno caliente**

Envía la transacción.

{% tabs %}
{% tab title="block producer node" %}
```bash
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
```
{% endtab %}
{% endtabs %}

### 🐣 13. Localiza tu Stake pool ID y verifica que todo funcione

### ⚙ 14. Configura tus archivos de topología

### 🎇 15. Revisando las Recompensas del Stake Pool

### 🔮 16. Configura tu Consola de Control con Prometheus y Grafana

#### 🐣 16.1 Instalación

#### 📶 16.2 Configurando la Consola de Control de Grafana

### 👏 17. Agradeciemientos, Telegram de Coincashew y Material de Referencia

#### 😁 17.1 Agradecimientos

#### \*\*\*\*💬 **17.2 Canal de Chat en Telegram**

#### 😊 17.3 Donaciones y Propinas

#### 🙃 17.4 Contribuyentes, Donadores y Stake Pool Amistosas de CoinCashew

#### 📚 17.5 Material de Referencia

### 🛠 18. Consejos Operacionales y de Mantenimiento

#### 🤖 18.1 Actualizando el certificado funcional con un nuevo Periodo KES

#### 🔥 18.2 Reseteando la instalación

#### 🌊 18.3 Reseteando las bases de datos

#### 📝 18.4 Modificando el pledge, los costos operacionales, el margen del pool, etc.

#### 🧩 18.5 Transfiriendo archivos via SSH

#### 🏃♂ 18.6 Auto-inicio con servicios systemd

#### ✅ 18.7 Verifica el ticker de tu stake pool con la llave de ITN

#### 📚 18.8 Actualizando los archivos de configuración de tu nodo

#### 💸 18.9 Ejemplo de enviar una simple transacción

#### 🍰 18.10 Reclama tus recompensas

### 🌜 19. Retirando tu stake pool

## 🚀 20. Al inifinito y más allá...



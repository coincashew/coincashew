---
description: >-
Esta guía mostrará la forma de instalar y configurar una Stake Pool de Cardano desde su código fuente, usando una configuración de dos nodos, con 1 nodo productor de bloques y 1 nodo relevador.
---

# Guía: ¿Cómo implementar una Stake Pool en Cardano?

{% hint style="info" %}
¡Muchas gracias por todo el apoyo y los mensajes! Realmente nos motiva a seguir creando las mejores guías de criptomonedas. Si deseas donar [estas son las direcciones](https://cointr.ee/coincashew) a las que puedes depositar 🙏 
{% endhint %}

{% hint style="success" %}
Esta guía fue actualizada el 7 de Abril de 2021, con **versión 3.2.0**, escrita para la  **mainnet de cardano** en su versión **1.26.1** 😁 
{% endhint %}

### 🏁 0. Prerrequisitos

#### 🧙 Habilidades necesarias para los Operadores de una Stake Pool

Como operador de un nodo de Cardano, tendrás que tener las siguientes habilidades:

* Conocimientos de como implementar, iniciar y mantener un nodo de Cardano de manera continua.
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
* **Una máquina fuera de línea \(Ambiente frío\)**
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
* **Una máquina fuera de línea \(Ambiente frío\)**
* **Sistema Operativo:** Linux 64-bit \(por ejemplo Ubuntu Server 20.04 LTS\)
* **Procesador:** Un procesador de 4 núcleos o mayor.}
* **Memoria:** Más de 8GB de RAM
* **Almacenamiento:** Un SSD 256GB o más.
* **Internet:** Concexión con una velocidad de al menos 100Mbps.
* **Plan de Datos**: Ilimitado
* **Alimentación:** Alimentación eléctrica confiable con UPS.
* **ADA:** Dependerá del parámetro **a0**, entre más ADA en el Stake Pool será mejor a futuro. Actualmente el valor no es relevante.

#### 🔓 Acciones de Seguridad Recomendadas

Si necesitas ideas de cómo aumentar la seguridad de tus nodos, puedes ir a:

{% page-ref page="how-to-harden-ubuntu-server.md" %}

### 🛠 Instalación de Ubuntu

Si requieres instalar **Ubuntu Server**, puedes ir a:

{% embed url="https://ubuntu.com/tutorials/install-ubuntu-server\#1-overview" %}

Si requieres instalar **Ubuntu Desktop**, puedes ir a:

{% page-ref page="../../overview-xtz/guide-how-to-setup-a-baker/install-ubuntu.md" %}


### 🧱 Reconstruyendo Nodos

Si estás reconstruyendo o reutilizando una instalación existente de `cardano-node`, ve a la [sección 18.2 ¿Cómo reiniciar la instalación?.](./#18-2-resetting-the-installation)

### 🏭 1. Instalar Cabal y GHC

Si estás usando Ubuntu Desktop, **presiona** Ctrl+Alt+T. Esto abrirá la terminal.

Primero, actualizaremos el sistema e instalaremos todas las dependencias para Ubuntu.

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

Respondemos **NO** cuando se nos pregunte instalar haskell-language-server \(HLS\).

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

Actualizamos la variable PATH para que incluya a Cabal y GHC y exportamos varias rutas. La localización del nodo estará en **$NODE\_HOME**. La [configuración del cluster](https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html) está dada por **$NODE\_CONFIG** y **$NODE\_BUILD\_NUM**. 

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

Ahora actualizamos Cabal, una vez terminado nos aseguramos de que la versión sea la correcta.

```bash
cabal update
cabal --version
ghc --version
```

{% hint style="info" %}
La librería de Cabal debe de ser versión 3.4.0.0 y la de GHC debe ser versión 8.10.4
{% endhint %}


### 🏗 2. Construyendo el nodo desde su código fuente

Descargamos el código fuente y cambiamos la etiqueta de versión a descargar para que corresponda a la 1.26.1

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

Actualizamos la configuración de cabal, los parámetros del proyecto y reiniciamos la carpeta donde se va a construir.

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

Copiamos los archivos **cardano-cli** y **cardano-node** a la carpeta bin

```bash
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
```

```bash
sudo cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

Verificamos que las versiones de **cardano-cli** y **cardano-node** sean las correctas (En este caso, la 1.26.1)

```text
cardano-node version
cardano-cli version
```


### 📐 3. Configuración de los nodos

En este punto, vamos a descargar los archivos config.json, genesis.json y topology.json, los cuales son necesarios para la configuración del nodo.

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
\*\*\*\*✨ **Consejo para Nodo Relevador**: Es posible reducir el consumo de memoria y de cpu cambiando el parámetro "TraceMemPool" a "false" en el archivo **mainnet-config.json**  
{% endhint %}

Actualizamos nuestro archivo **.bashrc** con las nuevas variables de shell.

```bash
echo export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket" >> $HOME/.bashrc
source $HOME/.bashrc
```

#### 🔮 4. Configurar el Nodo Productor

{% hint style="info" %}
Un Nodo Productor de Bloques es aquel que está configurado con varios pares de llaves \(Llaves Frías, KES y VRF\), las cuales son necesarias para la producción de bloques. Solamente debe de tener conexión con sus Nodos Relevadores.
{% endhint %}

{% hint style="info" %}
Un Nodo Relevador no tendrá ningún tipo de llaves y por lo  tanto no será capaz de producir ningún bloque. Estará conectado a su Nodo Productor y a otros relevadores y nodos externos en la red.
{% endhint %}

![](../../../.gitbook/assets/producer-relay-diagram.png)

{% hint style="success" %}
Para propósitos de la guía, haremos **dos nodos** en **dos servidores independientes**. Uno nodo será llamado el **NodoProductor** y el otro será su Nodo Relevador, llamado **NodoRelevador1**.
{% endhint %}

{% hint style="danger" %}
Edita el archivo **topology.json** para que: 

* El/Los Nodo(s) Relevadore(s) se conecten a los Relevadores Públicos \(como los de  IOHK y los Nodos de amigos\) y a tu Nodo Productor de Bloques.
* El Nodo Productor de Bloques **SOLAMENTE** debe de tener conexión con el/los Nodo(s) Relevadore(s). 
{% endhint %}

En el **Nodo Productor de Bloques,** ejecuta lo siguiente. Actualiza el campo **addr** con la IP pública de tu Nodo Relevador (En caso de que ambos estén en una red local, deberás colocar la IP privada de tu Nodo Relevador)

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

En el **NodoRelevador1** ejectuta el siguiente comando, **recuerda actualizar la dirección IP del Nodo Productor**(En caso de que ambos estén en una red local, deberás colocar la IP privada de tu Nodo Productor de Bloques).

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
\*\*\*\*✨ **Abrir los Puertos:** Necesitarás abrir el puerto 6000 de tus nodos, para que se puedan comunicar entre sí. Puedes ver el estado del puerto en las siguientes páginas: [https://www.yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/) , [https://canyouseeme.org/](https://canyouseeme.org/) .
{% endhint %}

### 🔏 6. Configurar la máquina fuera de línea

{% hint style="info" %}
Una máquina fuera de línea se conoce como un **ambiente frío**. 

* Está protegida contra intentos de key-logging, ataques basados en virus o otro tipo de exploit del firewall.
* Físicamente aislada del resto de la red.
* No debe estar conectada a la red por cable Ethernet ni vía Inalámbrica. 
* No es una máquina virtual con conexión a la red.
* Puedes aprender más acerca de esta medida de seguridad en [Air-Gapping en Wikipedia](https://en.wikipedia.org/wiki/Air_gap_%28networking%29).
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
Para que verdaderamente se considere una Máquina Fuera de Línea, debes de mover los archivos de manera física entre máquinas usando una USB o otro dispositivo portátil para transferir archivos.
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

Introduce los siguientes comandos para crear un **archivo de unidad en systemd** para definir la configuración de un servicio de cardano-node.

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

Movemos el archivo de la unidad hacia `/etc/systemd/system` y le damos permisos de ejecución, lectura y escritura para el usuario.

```bash
sudo mv $NODE_HOME/cardano-node.service /etc/systemd/system/cardano-node.service
```

```bash
sudo chmod 644 /etc/systemd/system/cardano-node.service
```

Ejecutamos los siguientes comandos para activar el inicio automático al arranque del sistema.

```text
sudo systemctl daemon-reload
sudo systemctl enable cardano-node
```

{% hint style="success" %}
Tu Stake Pool ahora está administrada por la robustez y confiabilidad de Systemd. A continuación hay varios comandos para utilizar systemd
{% endhint %}

#### 🔎 Ver el estado del Nodo

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

#### 🗄 Ver y filtrar los registos

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

### ⚙ 9. Crea las llaves para el nodo productor de bloques

### 🔐 10. Prepara las llaves de pago y de staking

### 👩💻 11. Registra tu dirección de stake

### 📄 12. Registra tu stake pool

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



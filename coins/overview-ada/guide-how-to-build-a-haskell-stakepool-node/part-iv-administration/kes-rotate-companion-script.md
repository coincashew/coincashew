# KES key rotation / Operational certificate Companion Script

Every Cardano Pool Operator has to generate a new KES key pair and Operational Certificate every 90 days. A full guide is available here.
In order to help Pool Operators during the process, a Companion Script is available in addition to the guide linked above.

## What the Companion Script does

- Checks KES period and counter on chain
- Reminds user about the good practice and counter cases
- Asks user if he wants to backup current KES keys and NODE cert
- Asks user if he wants to rotate KES keys
- Calculates Starting KES Period
- Provides next-steps to generate new OP cert on air-gapped machine

## How to use Companion Script

### Download the Script

The script can be found on this [GitHub repository](https://github.com/Kirael12/Cardano-KES-Rotate-Companion/)

```bash
cd $HOME/git
git clone https://github.com/Kirael12/Cardano-KES-Rotate-Companion/
```

### Make script executable

```bash
cd $HOME/git/Cardano-KES-Rotate-Companion/
chmod +x rotateKES.sh
```

### Run the script

```bash
sudo -E ./rotateKES.sh
```

**1. Script will ask if you want to backup current KES Keys and OP certificate**

If you answer yes : 

- 3 files kes.vkey.bak, kes.skey.bak and node.cert.bak will be created in your $NODE_HOME directory
- Previous backup will be deleted

If you answer no :

- No backup will be created
  
**2. Script will ask if you want to generate a new KES key pair**

If you answer yes :

- 2 files will be created : kes.skey and kes.key. Those are your new KES key pair

If you answer no :

- No new KES key pair will be generated and the script will stop

**3. Script will calculate for your the KES starting period**

**4. Script will then provide you with the next steps and the cardano-cli command to execute on your Air-Gapped machine**

- The command includes the KES starting perdiod you need to use
  

---
description: >-
  Scenario: How do I figure out and confirm that everything is working properly
  (eth 1 node in sync, eth 2 beacon chain in sync, eth 2 beacon node able to
  communicate with eth 1 node, etc etc.
---

# Checklist | Confirming a healthy functional ETH staking node

{% hint style="info" %}
**2022-6 Gitcoin Grant Round 14**

[Help fund us and earn a **POAP NFT**](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew). Appreciate your support!🙏
{% endhint %}

## :fast\_forward: Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](../). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

### :rocket: Execution client Checklist

| Concern                                       | Solution                                                                                                                                                                                                                                                                                                                                          |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Execution client in sync                      | <p>Ensure your node's block number matches the tip block of a <a href="http://etherscan.io">public block explorer</a>. Find your eth1's block # with command <code>journalctl -fu eth1</code></p><p><strong><code>Example log output:</code></strong><code>INFO [12-06</code></p>                                                                 |
| Ports open                                    | <p>Confirm ports are reachable with an external port checker such as</p><p><a href="https://www.yougetsignal.com/tools/open-ports/">https://www.yougetsignal.com/tools/open-ports/</a></p><p>Find <a href="../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall">Port # information here</a>.</p> |
| Check execution client logs for errors        | Use the command `journalctl -fu eth1`                                                                                                                                                                                                                                                                                                             |
| Understand how to stop/start Execution client | <p><code>sudo systemctl stop eth1</code></p><p><code>sudo systemctl start eth1</code></p>                                                                                                                                                                                                                                                         |
| Understand how to update my Execution client  | Refer to this [quick guide.](updating-your-execution-client.md)                                                                                                                                                                                                                                                                                   |
| Reduce bandwidth usage                        | Refer to [the mainnet guide.](../part-iii-tips/reducing-network-bandwidth-usage.md)                                                                                                                                                                                                                                                               |
| Execution client node redundancy              | Refer to [the mainnet guide.](../part-iii-tips/improving-validator-attestation-effectiveness.md#strategy-2-eth1-redundancy)                                                                                                                                                                                                                       |

### :dna: Consensus client Checklist

| Concern                                             | Solution                                                                                                                                                                                                                                                                                                                                                                                                                   |
| --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Installed latest stable release                     | Refer to [how to update consensus client.](updating-your-consensus-client.md)                                                                                                                                                                                                                                                                                                                                              |
| Beacon chain client can connect to Execution client | <p>Check for a response with the command:<code>curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}' http://localhost:8545</code></p><p>You should receive a response similar to:</p><p><code>{"jsonrpc":"2.0","id":67,"result":"Geth/v1.9.24-stable-cc05b050/linux-amd64/go1.15.5"}</code></p>                                                    |
| Beacon chain is sync'd to mainnet                   | Ensure your block number matches the slot# of a [public block explorer](https://beaconcha.in). Find your consensus client's beacon chain slot # with in logs with command `journalctl -fu beacon-chain`                                                                                                                                                                                                                    |
| Check beacon chain logs for errors                  | Use the command `journalctl -fu beacon-chain`                                                                                                                                                                                                                                                                                                                                                                              |
| Ports open                                          | <p>Confirm ports are reachable with an external port checker such as</p><p><a href="https://www.yougetsignal.com/tools/open-ports/">https://www.yougetsignal.com/tools/open-ports/</a> or <a href="https://canyouseeme.org">https://canyouseeme.org/</a> .</p><p><a href="../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall">Click here for Port # information</a>.</p> |
| Understand how to stop/start beacon-chain           | <p><code>sudo systemctl stop beacon-chain</code></p><p><code>sudo systemctl start beacon-chain</code></p>                                                                                                                                                                                                                                                                                                                  |
| Understand how to update my beacon chain            | Refer to this [quick guide.](updating-your-consensus-client.md)                                                                                                                                                                                                                                                                                                                                                            |
| Join Discord                                        | Refer to [the mainnet guide](../joining-the-community-on-discord-and-reddit.md)                                                                                                                                                                                                                                                                                                                                            |

### :key2: Consensus Validator Client Checklist

| Concern                                          | Solution                                                                                                                                                                                       |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Verify keystores are properly imported           | Refer to the mainnet guide's section on [importing keys.](../part-i-installation/configuring-consensus-client-beaconchain-and-validator.md#4-configure-a-eth2-beacon-chain-node-and-validator) |
| Check validator logs for errors                  | Use the command `journalctl -fu validator`                                                                                                                                                     |
| Verify attestations are working                  | Check your validators pubkey against a [public block explorer.](https://beaconscan.com)                                                                                                        |
| Setup a graffiti flag / [POAP](https://poap.fun) | Refer to [the mainnet guide.](../part-iii-tips/adding-or-changing-poap-graffiti-flag.md)                                                                                                       |
| Verified my mnemonic phrase can be restored.     | Refer to [the mainnet guide.](../part-iii-tips/verifying-your-mnemonic-phrase.md)                                                                                                              |
| Understand how to add more validators            | Refer to this [quick guide.](../part-iii-tips/adding-a-new-validator-to-an-existing-setup.md)                                                                                                  |
| Understand how to update my consensus client     | Refer to this [quick guide.](updating-your-consensus-client.md)                                                                                                                                |
| Know how to stop/start validator                 | <p><code>sudo systemctl stop validator</code></p><p><code>sudo systemctl start validator</code></p>                                                                                            |
| Beacon-node redundancy                           | Refer to [the mainnet guide.](../part-iii-tips/improving-validator-attestation-effectiveness.md#strategy-4-beacon-node-redundancy)                                                             |

### :bricks: Validator Node Security Checklist

| Concern                                          | Solution                                                                                                                                                                                                     |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Secure the root account                          | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#create-a-non-root-user-with-sudo-privileges)               |
| Connect with SSH Keys Only                       | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#disable-ssh-password-authentication-and-use-ssh-keys-only) |
| Harden SSH on a random port                      | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#disable-ssh-password-authentication-and-use-ssh-keys-only) |
| Setup 2-FA for SSH (Optional)                    | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#setup-two-factor-authentication-for-ssh-optional)          |
| Secure the Shared Memory                         | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#secure-shared-memory)                                      |
| Setup a firewall                                 | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall)                                   |
| Setup port forwarding on my router               | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall)                                   |
| Setup intrusion-prevention monitoring            | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#install-fail-2-ban)                                        |
| Whitelisted my local machine in the ufw firewall | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall)                                   |
| Whitelisted my local machine in Fail2ban         | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#install-fail-2-ban)                                        |
| Verify the listening ports                       | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#verify-listening-ports)                                    |

### :vertical\_traffic\_light: Validator Node Maintenance and Best Practices Checklist

| Concern                                                  | Solution                                                                                                                                                                                                                                                                    |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Enabled automatic OS patching                            | Refer to the [best security practices document.](../part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#update-your-system)                                                                                                       |
| Setup chrony or other NTP time sync service              | Refer to [the mainnet guide.](../part-i-installation/synchronizing-time-with-chrony.md)                                                                                                                                                                                     |
| Setup Prometheus and Grafana Monitoring/Alerts/Dashboard | Refer to [the mainnet guide.](../part-i-installation/monitoring-your-validator-with-grafana-and-prometheus.md)                                                                                                                                                              |
| Understand how to handle a power outage                  | In case of power outage, you want your validator machine to restart as soon as power is available. In the BIOS settings, change the **Restore on AC / Power Loss** or **After Power Loss** setting to always on. Better yet, install an Uninterruptable Power Supply (UPS). |
| Understand how to migrate consensus clients              | Refer to the [mainnet guide.](../part-iii-tips/switching-migrating-consensus-client.md)                                                                                                                                                                                     |
| Understand how to voluntary exit                         | Refer to the [mainnet guide.](../part-iii-tips/voluntary-exiting-a-validator.md)                                                                                                                                                                                            |
| Used all available LVM disk space                        | Refer to the [mainnet guide.](../part-iii-tips/using-all-available-lvm-disk-space.md)                                                                                                                                                                                       |
| Understand important directory locations                 | Refer to the [mainnet guide.](../part-iii-tips/important-directory-locations.md)                                                                                                                                                                                            |

## :robot: Start staking by building a validator <a href="#start-staking-by-building-a-validator" id="start-staking-by-building-a-validator"></a>

### Visit here for our [Mainnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet)

{% hint style="success" %}
Congrats on completing the guide. ✨

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it.

It really energizes us to keep creating the best crypto guides.

Use [cointr.ee to find our donation](https://cointr.ee/coincashew) addresses. 🙏

Any feedback and all pull requests much appreciated. 🌛
{% endhint %}

---
description: >-
  Scenario: How do I figure out and confirm that everything is working properly
  (execution client in sync, consensus client in sync, etc.)
---

# Checklist | Confirming a healthy functional ETH staking node

## :fast\_forward: Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](../). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

### :rocket: Execution client Checklist

| Concern                                       | Solution                                                                                                                                                                                                                                                                                         |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Execution client in sync                      | <p>Ensure your node's block number matches the tip block of a <a href="http://etherscan.io">public block explorer</a>. Find your execution client block # with command <code>journalctl -fu execution</code></p><p><strong><code>Example log output:</code></strong><code>INFO [12-06</code></p> |
| Ports open                                    | <p>Confirm ports are reachable with an external port checker such as</p><p><a href="https://www.yougetsignal.com/tools/open-ports/">https://www.yougetsignal.com/tools/open-ports/</a></p>                                                                                                       |
| Check execution client logs for errors        | Use the command `journalctl -fu eth1`                                                                                                                                                                                                                                                            |
| Understand how to stop/start Execution client | <p><code>sudo systemctl stop execution</code></p><p><code>sudo systemctl start execution</code></p>                                                                                                                                                                                              |
| Understand how to update my Execution client  | Refer to [this quick guide](../../archived-guides/guide-or-how-to-setup-a-validator-on-eth2-testnet-prater-1/maintenance/updating-execution-client.md).                                                                                                                                          |
| Reduce bandwidth usage                        | Refer to [the mainnet guide.](../part-iii-tips/reducing-network-bandwidth-usage.md)                                                                                                                                                                                                              |
| Execution client node redundancy              | Refer to [the mainnet guide.](../part-iii-tips/improving-validator-attestation-effectiveness.md#strategy-2-eth1-redundancy)                                                                                                                                                                      |

### :dna: Consensus client Checklist

| Concern                                               | Solution                                                                                                                                                                                                                                                                                                                                                                |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Installed latest stable release                       | Refer to [how to update consensus client.](updating-consensus-client.md)                                                                                                                                                                                                                                                                                                |
| Beacon chain client can connect to Execution client   | <p>Check for a response with the command:<code>curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}' http://localhost:8545</code></p><p>You should receive a response similar to:</p><p><code>{"jsonrpc":"2.0","id":67,"result":"Geth/v1.9.24-stable-cc05b050/linux-amd64/go1.15.5"}</code></p> |
| Beacon chain is sync'd to mainnet                     | Ensure your block number matches the slot# of a [public block explorer](https://beaconcha.in). Find your consensus client's beacon chain slot # with in logs with command `journalctl -fu beacon-chain`                                                                                                                                                                 |
| Check consensus client's beacon chain logs for errors | Use the command `journalctl -fu consensus`                                                                                                                                                                                                                                                                                                                              |
| Ports open                                            | <p>Confirm ports are reachable with an external port checker such as</p><p><a href="https://www.yougetsignal.com/tools/open-ports/">https://www.yougetsignal.com/tools/open-ports/</a> or <a href="https://canyouseeme.org">https://canyouseeme.org/</a> .</p><p><a href="broken-reference">Click here for Port # information</a>.</p>                                  |
| Understand how to stop/start consensus client         | <p><code>sudo systemctl stop consensus</code></p><p><code>sudo systemctl start consensus</code></p>                                                                                                                                                                                                                                                                     |
| Understand how to update my consensus client          | Refer to this quick guide.                                                                                                                                                                                                                                                                                                                                              |
| Join Discord                                          | Refer to [the mainnet guide](../joining-the-community-on-discord-and-reddit.md)                                                                                                                                                                                                                                                                                         |

### :key2: Consensus Validator Client Checklist

| Concern                                      | Solution                                                                                                                           |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Verify keystores are properly imported       | Refer to the mainnet guide's section on importing keys.                                                                            |
| Check validator logs for errors              | Use the command `journalctl -fu validator`                                                                                         |
| Verify attestations are working              | Check your validators pubkey against a [public block explorer.](https://beaconscan.com)                                            |
| Verified my mnemonic phrase can be restored. | Refer to [the mainnet guide.](../part-iii-tips/verifying-your-mnemonic-phrase.md)                                                  |
| Understand how to add more validators        | Refer to this [quick guide.](../part-iii-tips/adding-a-new-validator-to-an-existing-setup.md)                                      |
| Know how to stop/start validator             | <p><code>sudo systemctl stop validator</code></p><p><code>sudo systemctl start validator</code></p>                                |
| Beacon-node redundancy                       | Refer to [the mainnet guide.](../part-iii-tips/improving-validator-attestation-effectiveness.md#strategy-4-beacon-node-redundancy) |

### :bricks: Validator Node Security Checklist

| Concern                                          | Solution                                       |
| ------------------------------------------------ | ---------------------------------------------- |
| Secure the root account                          | Refer to the best security practices document. |
| Connect with SSH Keys Only                       | Refer to the best security practices document. |
| Harden SSH on a random port                      | Refer to the best security practices document. |
| Setup 2-FA for SSH (Optional)                    | Refer to the best security practices document. |
| Secure the Shared Memory                         | Refer to the best security practices document. |
| Setup a firewall                                 | Refer to the best security practices document. |
| Setup port forwarding on my router               | Refer to the best security practices document. |
| Setup intrusion-prevention monitoring            | Refer to the best security practices document. |
| Whitelisted my local machine in the ufw firewall | Refer to the best security practices document. |
| Whitelisted my local machine in Fail2ban         | Refer to the best security practices document. |
| Verify the listening ports                       | Refer to the best security practices document. |

### :vertical\_traffic\_light: Validator Node Maintenance and Best Practices Checklist

| Concern                                                  | Solution                                                                                                                                                                                                                                                                    |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Enabled automatic OS patching                            | Refer to the best security practices document.                                                                                                                                                                                                                              |
| Setup chrony or other NTP time sync service              | Refer to the mainnet guide.                                                                                                                                                                                                                                                 |
| Setup Prometheus and Grafana Monitoring/Alerts/Dashboard | Refer to the mainnet guide.                                                                                                                                                                                                                                                 |
| Understand how to handle a power outage                  | In case of power outage, you want your validator machine to restart as soon as power is available. In the BIOS settings, change the **Restore on AC / Power Loss** or **After Power Loss** setting to always on. Better yet, install an Uninterruptable Power Supply (UPS). |
| Understand how to migrate consensus clients              | Refer to the mainnet guide.                                                                                                                                                                                                                                                 |
| Understand how to voluntary exit                         | Refer to the mainnet guide.                                                                                                                                                                                                                                                 |
| Used all available LVM disk space                        | Refer to the mainnet guide.                                                                                                                                                                                                                                                 |
| Understand important directory locations                 | Refer to the mainnet guide.                                                                                                                                                                                                                                                 |

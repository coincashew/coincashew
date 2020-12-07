---
description: >-
  Scenario: How do I figure out and confirm that everything is working properly
  (eth 1 node in sync, eth 2 beacon chain in sync, eth 2 beacon node able to
  communicate with eth 1 node, etc etc.
---

# Checklist \| How to confirm a healthy functional ETH2 validator

## ⏩ Quick steps guide

{% hint style="info" %}
The following steps align with our [mainnet guide](./). You may need to adjust file names and directory locations where appropriate. The core concepts remain the same.
{% endhint %}

### 🚀 Eth1 Node Checklist

<table>
  <thead>
    <tr>
      <th style="text-align:left">Concern</th>
      <th style="text-align:left">Solution</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">Eth1 in sync</td>
      <td style="text-align:left">
        <p>Ensure your node&apos;s block number matches the tip block of a <a href="http://etherscan.io/">public block explorer</a>.
          Find your eth1&apos;s block # with in eth1 logs with command <code>journalctl -fu eth1 </code>
        </p>
        <p><b><code>Example log output:</code></b><code>INFO [12-06|14:50:05.314] Imported new chain ... number=11301130</code>
        </p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Ports open</td>
      <td style="text-align:left">
        <p>Confirm ports are reachable with an external port checker such as</p>
        <p><a href="https://www.yougetsignal.com/tools/open-ports/">https://www.yougetsignal.com/tools/open-ports/</a> 
        </p>
        <p>Find <a href="../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall">Port # information here</a>.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Check eth1 logs for errors</td>
      <td style="text-align:left">Use the command <code>journalctl -fu eth1</code>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Understand how to stop/start eth1 node</td>
      <td style="text-align:left">
        <p><code>sudo systemctl stop eth1</code>
        </p>
        <p><code>sudo systemctl start eth1</code>
        </p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Understand how to update my eth1 node</td>
      <td style="text-align:left">Refer to this <a href="how-to-update-your-eth1-node.md">quick guide.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Reduce bandwidth usage</td>
      <td style="text-align:left">Refer to <a href="./#8-6-reduce-network-bandwidth-usage">the mainnet guide.</a>
      </td>
    </tr>
  </tbody>
</table>

### 🧬 Eth2 Beacon Chain Checklist

<table>
  <thead>
    <tr>
      <th style="text-align:left">Concern</th>
      <th style="text-align:left">Solution</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">Installed latest stable release</td>
      <td style="text-align:left">Refer to <a href="how-to-update-your-eth2-client.md">how to update eth2 client.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Beacon chain client can connect to Eth1 node</td>
      <td style="text-align:left">
        <p>Check for a response with the command:<code>curl -H &quot;Content-Type: application/json&quot; -X POST --data &apos;{&quot;jsonrpc&quot;:&quot;2.0&quot;,&quot;method&quot;:&quot;web3_clientVersion&quot;,&quot;params&quot;:[],&quot;id&quot;:67}&apos; http://localhost:8545  </code>
        </p>
        <p>You should receive a response similar to:</p>
        <p><code>{&quot;jsonrpc&quot;:&quot;2.0&quot;,&quot;id&quot;:67,&quot;result&quot;:&quot;Geth/v1.9.24-stable-cc05b050/linux-amd64/go1.15.5&quot;}</code>
        </p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Beacon chain is sync&apos;d to mainnet</td>
      <td style="text-align:left">Ensure your block number matches the slot# of a <a href="https://beaconcha.in/">public block explorer</a>.
        Find your eth2&apos;s beacon chain slot # with in logs with command <code>journalctl -fu beacon-chain</code>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Check beacon chain logs for errors</td>
      <td style="text-align:left">Use the command <code>journalctl -fu beacon-chain</code>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Ports open</td>
      <td style="text-align:left">
        <p>Confirm ports are reachable with an external port checker such as</p>
        <p><a href="https://www.yougetsignal.com/tools/open-ports/">https://www.yougetsignal.com/tools/open-ports/</a> or
          <a
          href="https://canyouseeme.org/">https://canyouseeme.org/</a>.</p>
        <p> <a href="../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall">Click here for Port # information</a>.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Understand how to stop/start beacon-chain</td>
      <td style="text-align:left">
        <p><code>sudo systemctl stop beacon-chain</code>
        </p>
        <p><code>sudo systemctl start beacon-chain</code>
        </p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Understand how to update my beacon chain</td>
      <td style="text-align:left">Refer to this <a href="how-to-update-your-eth2-client.md">quick guide.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Join Discord</td>
      <td style="text-align:left">Refer to <a href="../guide-how-to-stake-on-eth2-with-lighthouse.md#14-bonus-links">the mainnet guide</a>
      </td>
    </tr>
  </tbody>
</table>

### 🗝 Eth2 Validator Checklist

<table>
  <thead>
    <tr>
      <th style="text-align:left">Concern</th>
      <th style="text-align:left">Solution</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left">Verify keystores are properly imported</td>
      <td style="text-align:left">Refer to the mainnet guide&apos;s section on <a href="./#4-configure-a-eth2-beacon-chain-node-and-validator">importing keys.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Check validator logs for errors</td>
      <td style="text-align:left">Use the command <code>journalctl -fu validator</code>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Verify attestations are working</td>
      <td style="text-align:left">Check your validators pubkey against a <a href="https://beaconscan.com/">public block explorer.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Setup a graffiti flag / <a href="https://poap.fun/">POAP</a>
      </td>
      <td style="text-align:left">Refer to <a href="./#8-9-add-or-change-poap-graffiti-flag">the mainnet guide.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Verified my mnemonic phrase can be restored.</td>
      <td style="text-align:left">Refer to <a href="./#8-2-verify-your-mnemonic-phrase">the mainnet guide.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Understand how to add more validators</td>
      <td style="text-align:left">Refer to this <a href="how-to-add-a-new-validator-to-an-existing-setup.md">quick guide.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Understand how to update my validator</td>
      <td style="text-align:left">Refer to this <a href="how-to-update-your-eth2-client.md">quick guide.</a>
      </td>
    </tr>
    <tr>
      <td style="text-align:left">Know how to stop/start validator</td>
      <td style="text-align:left">
        <p><code>sudo systemctl stop validator</code>
        </p>
        <p><code>sudo systemctl start validator</code>
        </p>
      </td>
    </tr>
  </tbody>
</table>

### 🧱 Validator Node Security Checklist

| Concern | Solution |
| :--- | :--- |
| Secure the root account | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#create-a-non-root-user-with-sudo-privileges) |
| Connect with SSH Keys Only | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#disable-ssh-password-authentication-and-use-ssh-keys-only) |
| Harden SSH on a random port | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#disable-ssh-password-authentication-and-use-ssh-keys-only) |
| Setup 2-FA for SSH \(Optional\) | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#setup-two-factor-authentication-for-ssh-optional) |
| Secure the Shared Memory | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#secure-shared-memory) |
| Setup a firewall | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall) |
| Setup port forwarding on my router | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall) |
| Setup intrusion-prevention monitoring | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#install-fail-2-ban) |
| Whitelisted my local machine in the ufw firewall | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#configure-your-firewall) |
| Whitelisted my local machine in Fail2ban | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#install-fail-2-ban) |
| Verify the listening ports | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#verify-listening-ports) |

### 🚦 Validator Node Maintenance and Best Practices Checklist

| Concern | Solution |
| :--- | :--- |
| Enabled automatic OS patching | Refer to the [best security practices document.](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md#update-your-system) |
| Setup chrony or other NTP time sync | Refer to [the mainnet guide.](./#5-time-synchronization) |
| Setup Prometheus and Grafana Monitoring/Alerts/Dashboard | Refer to [the mainnet guide.](./#6-2-setting-up-grafana-dashboards) |
| Understand how to handle a power outage | In case of power outage, you want your validator machine to restart as soon as power is available. In the BIOS settings, change the **Restore on AC / Power Loss** or **After Power Loss** setting to always on.  |
| Understand how to migrate eth2 clients | Refer to the [mainnet guide.](./#8-4-switch-migrate-eth2-clients-with-slash-protection) |
| Understand how to voluntary exit | Refer to the [mainnet guide.](./#8-1-voluntary-exit-a-validator) |
| Used all available LVM disk space | Refer to the [mainnet guide.](./#8-5-use-all-available-lvm-disk-space) |
| Understand important directory locations | Refer to the [mainnet guide.](./#8-7-important-directory-locations) |

##  🤖 Start staking by building a validator <a id="start-staking-by-building-a-validator"></a>

### Visit here for our [Mainnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet) and here for our [Testnet guide](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-testnet). <a id="visit-here-for-our-mainnet-guide-and-here-for-our-testnet-guide"></a>

{% hint style="success" %}
Congrats on completing the guide. ✨

Did you find our guide useful? Send us a signal with a tip and we'll keep updating it.

It really energizes us to keep creating the best crypto guides.

Use [cointr.ee to find our donation](https://cointr.ee/coincashew) addresses. 🙏

Any feedback and all pull requests much appreciated. 🌛

Hang out and chat with fellow stakers on Discord @

​[https://discord.gg/w8Bx8W2HPW](https://discord.gg/w8Bx8W2HPW) 😃
{% endhint %}

![](../../../.gitbook/assets/gg.jpg)

\*\*\*\*🎊 **2020-12 Update**: We're on [Gitcoin](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew), where you can contribute via [quadratic funding](https://vitalik.ca/general/2019/12/07/quadratic.html) and make a big impact.  Your **1 DAI** contribution equals a **28 DAI** match. 

Please [check us out](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew). Thank you!🙏

{% embed url="https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew" %}


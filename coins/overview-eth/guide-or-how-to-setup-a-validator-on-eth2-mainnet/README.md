---
description: >-
  Become a validator, start staking and help secure Ethereum, a proof-of-stake
  blockchain. Anyone with 32 ETH can join.
---

# Guide | How to setup a validator for Ethereum staking on mainnet

## :new:Announcements

{% hint style="info" %}
:confetti\_ball: **2022-03 Gitcoin Grant Round 13**

[Help fund us and earn a **POAP NFT**](https://gitcoin.co/grants/1653/eth2-staking-guides-by-coincashew). Appreciate your support!🙏
{% endhint %}

{% hint style="success" %}
As of March 8 2022, this is **guide version 4.0.0** and written for **Ethereum mainnet**:grin:
{% endhint %}

{% hint style="info" %}
:sparkles: [**PRATER testnet guide**](../guide-or-how-to-setup-a-validator-on-eth2-testnet-prater.md). Always test and practice on testnet.
{% endhint %}

### :page\_facing\_up: Changelog - **Update Notes -** **Dec 1 2021**

* Added how to check your [Validator's Sync Committee duties](part-ii-maintenance/checking-my-eth-validators-sync-committee-duties.md)
* Added new Formatting fixes and updated Teku initial state API.
* Updated with consensus layer (CL), the execution layer (EL), formerly known as eth2 and eth1.
* Added erigon build dependencies.
* Added Teku and Lodestar Checkpoint Sync feature, the quickest way to sync a Ethereum beacon chain client.
* geth + erigon pruning / Altair hard fork changes / nimbus eth1 fallback
* lighthouse + prysm doppelganger protection enabled. Doppelganger protection intentionally misses an epoch on startup and listens for attestations to make sure your keys are not still running on the old validator client.
* OpenEthereum will no longer be supported post London hard fork. Gnosis, maintainers of OpenEthereum, suggest users migrate to their new Erigon Ethererum client. Added setup instructions for **Erigon** under eth1 node section.
* Added [Mobile App Node Monitoring by beaconcha.in](part-i-installation/mobile-app-node-monitoring-by-beaconchain.md)
* Updated [eth2.0-deposit-cli to v.1.2.0](https://github.com/ethereum/eth2.0-deposit-cli/releases/tag/v1.2.0) and added section on eth1 withdrawal address
* Added generating mnemonic seeds on **Tails OS** by [punggolzenith](https://github.com/punggolzenith)
* Iancoleman.io BLS12-381 Key Generation Tool [how-to added](part-iii-tips/eip2333-key-generator-by-iancoleman-io.md)
* Testnet guide forked for [Prater testnet](../guide-or-how-to-setup-a-validator-on-eth2-testnet-prater.md) staking
* [Geth pruning guide](part-ii-maintenance/pruning-the-execution-client-to-free-up-disk-space.md) created
* Major changes to Lodestar guide
* Additional [Grafana Dashboards](part-i-installation/monitoring-your-validator-with-grafana-and-prometheus.md) for Prysm, Lighthouse and Nimbus
* [Validator Security Best Practices added](../guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node.md)
* Translations now available for Japanese, Chinese and Spanish (access by changing site language)
* Generate keystore files on [Ledger Nano X, Nano S and Trezor Model T](part-i-installation/signing-up-to-be-a-validator-at-the-launchpad.md) with tool from [allnodes.com](https://twitter.com/Allnodes/status/1390020240541618177?s=20)
* [Batch deposit tool](part-i-installation/signing-up-to-be-a-validator-at-the-launchpad.md) by [abyss.finance](https://twitter.com/AbyssFinance/status/1379732382044069888) now added

### :page\_facing\_up: Latest Essential Ethereum Staking Reading

* [Modelling the Impact of Altair by pintail.xyz](https://pintail.xyz/posts/modelling-the-impact-of-altair/)
* [Update on the Merge after the Amphora Interop by Consensys.net](https://consensys.net/blog/ethereum-2-0/an-update-on-the-merge-after-the-amphora-interop-event-in-greece/)
* [Ethereum Merge Mainnet Readiness Updates](https://github.com/ethereum/pm/blob/master/Merge/mainnet-readiness.md)






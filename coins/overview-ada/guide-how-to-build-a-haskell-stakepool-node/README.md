---
description: >-
  On Ubuntu/Debian, this guide will illustrate how to install and configure a
  Cardano stake pool from source code on a two-node setup with 1 block producer
  node and 1 relay node.
---

# Guide: How to Set Up a Cardano Stake Pool

## :thumbsup: Your GitHub Contributions Welcome

The _How to Set Up a Cardano Stake Pool_ guide is fully open source and fully powered by stake pool operators like you.

Pull requests or issues can be submitted on [github](https://github.com/coincashew/coincashew):

{% embed url="https://github.com/coincashew/coincashew" %}

## :wrench: About This Guide

Available since 2021 and one of the first resources available online to support Cardano stake pool operations, the _How to Set Up a Cardano Stake Pool_ guide provides open source educational content that continues to play an essential role in welcoming newcomers to the Cardano ecosystem while also serving as a valuable resource for experienced Cardano community members.

The guide offers complete, accurate and up-to-date information and step-by-step procedures on topics related to operating the Cardano Node and supporting software in practical, real-world stake pool configurations. The guide also explains in detail how to upgrade Cardano Node software.

The design of the guide allows you to scan ahead easily if you read something that you already know. Ongoing support and application of industry standards uniquely differentiate the guide amongst Cardano technical documentation.

[Change Pool](https://change.paradoxicalsphere.com) is the official stake pool of the _How to Set Up a Cardano Stake Pool_ guide available on [CoinCashew](https://www.coincashew.com/). Created in 2021 using the guide, [Change Pool](https://change.paradoxicalsphere.com) makes a commitment to maintaining the guide over time. [Change Pool](https://change.paradoxicalsphere.com) also shares a portion of pool fees received with CoinCashew.

As an alternative to contributing content or making a one-time [donation](https://cointr.ee/coincashew), your delegation to [Change Pool](https://change.paradoxicalsphere.com) offers direct, ongoing financial support for development and maintenance of content for the _How to Set Up a Cardano Stake Pool_ guide while you receive a return on your investment.

{% hint style="info" %}
Your delegation is much appreciated in advance. :pray:
{% endhint %}

## :tada: Introduction

The _How to Set Up a Cardano Stake Pool_ guide aims to give you complete, step-by-step instructions to implement a secure Cardano stake pool using the currently recommended software versions.

The guide also aims to give you the understanding and skills you need to perform administrative tasks related to managing and maintaining a stake pool successfully over time.

The guide includes the following parts:

* [**Part I - Installation**](part-i-installation/) describes how to secure the Linux computers hosting your Cardano stake pool, as well as how to install Cardano node software and dependent software packages.
* [**Part II - Configuration**](part-ii-configuration/) explains how to set up Cardano nodes to create a stake pool.
* [**Part III - Operation**](part-iii-operation/) discusses how to create your stake pool.
* [**Part IV - Administration & Maintenance**](part-iv-administration/) provides procedures that you need to manage your stake pool.
* [**Part V - Tips**](part-v-tips/) contains additional procedures to simplify managing your stake pool.

{% hint style="info" %}
To search the _How to Set Up a Cardano Stake Pool_ guide, click the magnifying glass (![](../../../.gitbook/assets/search-icon.png)) icon in the top right corner of the left navigation.
{% endhint %}

## :page\_facing\_up: Change Log

* November 12, 2024
  * Updating version numbers for Cardano Node software
  * Updating secp256k1 installation procedure
  * Improving instructions for using the stake snapshot query
  * Incorporating minor fixes and improvements
* October 12, 2024
  * Updating version numbers to Cardano Node 9.2.1
  * Adding version numbers for Cardano CLI
  * Updating jquery (jq) commands to reflect the JSON schema for results of the `cardano-cli conway query ledger-state` command
  * Updating gLiveView dashboard image
* September 20, 2024
  * Adding contributions by ([Change Pool](https://change.paradoxicalsphere.com)) and [Latin Stake Pools](https://latinstakepools.com/)
    * Incorporating revisions for Cardano Node 9.2.0
	* Removing references to legacy network topology
	* Revising material related to peer-to-peer networking
	* Creating the [Delegating to a Representative](part-iv-administration/delegating-to-a-representative.md) topic
	* Creating the [Implementing Peer Sharing](part-v-tips/implementing-peer-sharing.md) topic
	* Increasing precision of transaction fee calculations
	* Updating the procedure to install pre-built binaries in the [Upgrading a Node](part-iv-administration/upgrading-a-node.md) topic
	* Updating `cardano-cli` commands to specify a network era
	* Adding resources related to governance in the [Cardano Resource Index](appendix-b-resource-index.md)
	* Including miscellaneous minor updates and improvements
* July 8, 2024
  * Adding contributions by ([Change Pool](https://change.paradoxicalsphere.com))
    * Incorporating revisions for Cardano Node 9.0.0
* April 10, 2024
  * Adding contributions by ([Change Pool](https://change.paradoxicalsphere.com))
    * Incorporating updates for Cardano Node 8.9.1
    * Creating the *Enabling Peer-to-peer Network Topology* topic
    * Adapting existing content to reflect peer-to-peer network topology
* February 3, 2024
  * Adding contributions by ([Change Pool](https://change.paradoxicalsphere.com))
    * Creating the [Cardano Resource Index](appendix-b-resource-index.md)
    * Removing out-of-date information related to delegation strategies that founding entities no longer use
    * Distinguishing between legacy and peer-to-peer topologies
    * Updating system requirements
    * Incorporating miscellaneous minor improvements to procedures
    * Updating broken hyperlinks
* January 2, 2024
  * Adding contributions by ([Change Pool](https://change.paradoxicalsphere.com))
    * Updating prerequisites and procedures for Cardano Node 8.7.2
    * Updating information on [Reducing Missed Slot Leader Checks and Improving Cardano Node Performance](part-v-tips/reducing-missed-slot-leader-checks.md)
* June 29, 2023
  * Adding contributions by \[[FRADA](https://cardano-france-stakepool.org/)] pool
    * [Auditing Your Nodes Configuration](part-iv-administration/audit-node-configuration.md)
    * [Using KES Keys / OP Certificate Rotate Companion Script](part-iv-administration/kes-rotate-companion-script.md)
* May 18, 2023
  * Improving details on [issuing a new operational certificate](part-iv-administration/issuing-new-opcert.md) for stake pools prior to minting a first block
* May 9, 2023
  * Updating procedures for Cardano Node 8.0.0
* January 27, 2023
  * Updating procedures for Cardano Node 1.35.5
* August 22, 2022
  * Updating procedures for Cardano Node 1.35.3 ([Change Pool](https://change.paradoxicalsphere.com))
* June 8, 2022
  * Testing and revising procedures in [Part I - Installation](part-i-installation/) and [Part II - Configuration](part-ii-configuration/) ([Change Pool](https://change.paradoxicalsphere.com))
* April 23, 2022
  * Updating Cardano Node installation procedures to reflect current software versions ([Change Pool](https://change.paradoxicalsphere.com))
* March 22, 2022
  * Updating the [Upgrading a Node](part-iv-administration/upgrading-a-node.md) topic to reflect current software versions ([Change Pool](https://change.paradoxicalsphere.com))
  * Re-organizing content to improve loading speed
  * Improving Table of Contents (massive contribution by [Change Pool](https://change.paradoxicalsphere.com))
* November 10, 2021
  * Adding high-level explanation of Topology API
  * Increasing the cardano-node service unit file timeout from 2 to 300 seconds
  * Adding a collection of [Community Inspired Projects](see-also.md#projects) built by this amazing community
  * Adding cardano-node RTS flags to reduce chance of missed slot leader checks
  * Adding Leaderlog changes and improvements
  * Increasing minimum RAM requirements to 12GB
* August 27, 2021
  * Updating guide for Alonzo release 1.29.0.
  * Incorporating various fixes to testnet / alonzo / storage requirements / cli commands
  * Adding the section [Running Leaderlog Using the stake-snapshot Command](part-iii-operation/configuring-slot-leader-calculation.md#stakesnapshot)
  * Adding the section [Installing CNCLI](part-iii-operation/configuring-slot-leader-calculation.md#cncli)
* May 13, 2021
  * Updating guide for release cardano-node/cli v1.27.0 changes
  * Adding Stake Pool Operator's [Best Practices Checklist](appendix-a-best-practices-checklist.md)
  * Adding the topic [Monitoring Node Security Using OSSEC Server and Slack](part-v-tips/monitoring-node-security-using-ossec-server-and-slack.md) (contribution by Billionaire Pool)
  * Adding the topic how to [Securing Your Stake Pool Using a Hardware Wallet](part-iii-operation/securing-your-stake-pool-using-a-hardware-wallet.md)

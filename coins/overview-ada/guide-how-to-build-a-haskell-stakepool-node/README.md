---
description: >-
  On Ubuntu/Debian, this guide will illustrate how to install and configure a
  Cardano stake pool from source code on a two node setup with 1 block producer
  node and 1 relay node.
---

# Guide: How to Set Up a Cardano Stake Pool

## :wrench: About This Guide

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

## :tada: Introduction

{% hint style="info" %}
If you want to support this free educational Cardano content or found this helpful, visit [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. Much appreciated in advance. :pray:
{% endhint %}

## :page\_facing\_up: Change Log

* August 22, 2022
  - Updating procedures for Cardano Node 1.35.3 ([Change Pool](https://change.paradoxicalsphere.com))
* June 8, 2022
  - Testing and revising procedures in [Part I - Installation](part-i-installation/) and [Part II - Configuration](part-ii-configuration/) ([Change Pool](https://change.paradoxicalsphere.com))
* April 23, 2022
  - Updating Cardano Node installation procedures to reflect current software versions ([Change Pool](https://change.paradoxicalsphere.com))
* March 22, 2022
  - Updating the [Upgrading a Node](./part-iv-administration/upgrading-a-node.md) topic to reflect current software versions ([Change Pool](https://change.paradoxicalsphere.com))
  - Re-organizing content to improve loading speed
  - Improving Table of Contents (massive contribution by [Change Pool](https://change.paradoxicalsphere.com))
* November 10, 2021
  - Adding high-level explanation of Topology API
  - Increasing the cardano-node service unit file timeout from 2 to 300 seconds
  - Adding a collection of [Community Inspired Projects](see-also.md#projects) built by this amazing community
  - Adding cardano-node RTS flags to reduce chance of missed slot leader checks
  - Adding Leaderlog changes and improvements
  - Increasing minimum RAM requirements to 12GB
* August 27, 2021
  - Updating guide for Alonzo release 1.29.0.
  - Incorporating various fixes to testnet / alonzo / storage requirements / cli commands
  - Adding the section [Running Leaderlog Using the stake-snapshot Command](part-iii-operation/configuring-slot-leader-calculation.md#stakesnapshot)
  - Adding the section [Installing CNCLI](part-iii-operation/configuring-slot-leader-calculation.md#cncli)
* May 13, 2021
  - Updating guide for release cardano-node/cli v1.27.0 changes
  - Adding Stake Pool Operator's [Best Practices Checklist](./appendix-best-practices-checklist.md)
  - Adding the topic [Monitoring Node Security Using OSSEC Server and Slack](./part-v-tips/monitoring-node-security-using-ossec-server-and-slack.md) (contribution by Billionaire Pool)
  - Adding the topic how to [Securing Your Stake Pool Using a Hardware Wallet](./part-iii-operation/securing-your-stake-pool-using-a-hardware-wallet.md)

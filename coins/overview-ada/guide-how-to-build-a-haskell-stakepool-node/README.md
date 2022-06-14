---
description:
  After completing this guide, you will have a Cardano stake pool running on the Ubuntu Linux distribution, registered and operating on the mainnet blockchain using a two-node configuration comprised of one block-producing node and one relay node.
---

# Guide: How to Set Up a Cardano Stake Pool

## :wrench: About This Guide

The _How to Set Up a Cardano Stake Pool_ guide aims to give you complete, step-by-step instructions to implement a secure Cardano stake pool using the currently recommended software versions. The guide also aims to give you the thorough understanding you need to perform administrative tasks related to managing and maintaining your stake pool successfully, over time.

The guide includes the following parts:

* ****[**Part I - Installation**](part-i-installation.md) describes how to secure the Linux computers hosting your Cardano stake pool, as well as how to install Cardano node software and dependent software packages.
* ****[**Part II - Configuration**](part-ii-configuration.md) explains how to set up Cardano nodes to create a stake pool.
* ****[**Part III - Operation**](part-iii-operation.md) discusses how to create your stake pool.
* ****[**Part IV - Administration & Maintenance**](part-iv-administration.md) provides procedures that you need to manage your stake pool.
* ****[**Part V - Tips**](part-v-tips.md) contains additional procedures to simplify managing your stake pool.

{% hint style="info" %}
To search the _How to Set Up a Cardano Stake Pool_ guide, click the magnifying glass (![](../../../.gitbook/assets/search-icon.png)) icon in the top right corner of the left navigation. If you need help when working through the guide, the [Cardano Forum](https://forum.cardano.org/) is available as a resource. The Cardano community welcomes you.
{% endhint %}

## :tada: Introduction

{% hint style="info" %}
If you want to support this free educational Cardano content or found this helpful, visit [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. Much appreciated in advance. :pray:
{% endhint %}

## :page\_facing\_up: Change Log

* June 8, 2022
  - Testing procedures and updating style in [Part I - Installation](part-i-installation.md) and [Part II - Configuration](part-ii-configuration.md) ([Change Pool](https://change.paradoxicalsphere.com))
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

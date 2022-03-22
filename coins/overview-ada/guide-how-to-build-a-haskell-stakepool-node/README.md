---
description: >-
  On Ubuntu/Debian, this guide will illustrate how to install and configure a
  Cardano stake pool from source code on a two node setup with 1 block producer
  node and 1 relay node.
---

# Guide: How to Set Up a Cardano Stake Pool

## :wrench: About This Guide

The _How to Set Up a Cardano Stake Pool_ guide aims to give you complete, step-by-step instructions to implement and maintain a secure Cardano stake pool operating on the Cardano mainnet blockchain using the currently recommended software versions.

The guide includes the following parts:

* ****[**Part I - Installation**](part-i-installation.md) describes how to secure the Linux computers hosting your Cardano stake pool, as well as how to install Cardano node software and dependent software packages.
* ****[**Part II - Configuration**](part-ii-configuration.md) explains how to set up Cardano nodes to create a stake pool.
* ****[**Part III - Operation**](part-iii-operation.md) discusses how to create your stake pool.
* ****[**Part IV - Administration & Maintenance**](part-iv-administration.md) provides procedures that you need to manage your stake pool.
* ****[**Part V - Tips**](part-v-tips.md) contains additional procedures to simplify managing your stake pool.

## :tada: Introduction

{% hint style="info" %}
If you want to support this free educational Cardano content or found this helpful, visit [cointr.ee to find our donation ](https://cointr.ee/coincashew)addresses. Much appreciated in advance. :pray:
{% endhint %}

{% hint style="success" %}
As of March 9 2022, this is **guide version 6.0.0** and written for **cardano mainnet** with **release v.1.30.1** :grin:
{% endhint %}

## :page\_facing\_up: Changelog - **Update Notes -** **March 22 2022**

* Update the [Upgrading a Node](./part-iv-administration/upgrading-a-node.md) topic
* Re-organized content to improve loading speed.
* Massive contribution by [Change Pool](https://change.paradoxicalsphere.com) Improved Table of Contents
* Added high-level explanation of Topology API.
* Increased the cardano-node service unit file timeout from 2 to 300 seconds.
* Added a [collection of projects](see-also.md#projects) built by this amazing community.
* Added cardano-node RTS flags to reduce chance of missed slot leader checks.
* Added Leaderlog changes and improvements
* Increased minimum RAM requirements to 12GB.
* Updated for Alonzo release 1.29.0.
* Various fixes to testnet / alonzo / storage requirements / cli commands
* Updated CNCLI's Leaderlog command with the [stake-snapshot approach](part-iii-operation/configuring-slot-leader-calculation.md)
* Added [CNCLI tool](part-iii-operation/configuring-slot-leader-calculation.md) for sending slot to Pooltool and for LeaderLog scripts
* Updated guide for release cardano-node/cli v1.27.0 changes <
* Added [Stake Pool Operator's Best Practices Checklist](./#18-15-stake-pool-operators-best-practices-checklist)
* Contribution By [Billionaire Pool](https://www.billionairepool.com) - [Guide to monitor your node security with OSSEC and Slack.](how-to-monitor-security-with-ossec.md)
* Added how to [Secure your pool pledge with a 2nd pool owner using a hardware wallet](./#18-14-secure-your-pool-pledge-with-a-2nd-pool-owner-using-a-hardware-wallet)

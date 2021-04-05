---
description: Guide to monitor your node security with OSSEC and Slack.
---

# How to Monitor Security with OSSEC server and Slack

{% hint style="success" %}
{% endhint %}

## 🤖 Pre-requisites

* Ubuntu Server or Ubuntu Desktop installed
* SSH server installed
* a SSH client or terminal window access
* (optional) a mail server for mail notifications

## 🔓 Recommended Stake Pool Security

If you need ideas on how to harden your stake pool's nodes, refer to

{% page-ref page="how-to-harden-ubuntu-server.md" %}

## Download OSSEC

First of all, we will need to get a fresh copy of OSSEC. We will download it from github and then checkout the latest stable version

Go to this page and find out the latest version number

https://github.com/ossec/ossec-hids/releases

Then, login to your server and

mkdir -p $HOME/git
cd $HOME/git
git clone https://github.com/ossec/ossec-hids.git
cd ossec-hids
git checkout 3.6.0

## 🛠 Install OSSEC

OSSEC can be installed in **server**, **agent**, **local** or **hybrid** mode. This installation is for monitoring the server that OSSEC is installed on. That means a **local** installation.

You will be guided in the installation by a bash script. To initiate it, type

./install.sh


## Create a new service for OSSEC autostart

## Configure your Slack workspace

## Let OSSEC talk to your Slack API

## Stake pool specific configuration for OSSEC

## Fine-tuning



{% hint style="success" %}
Congrats on completing the guide. ✨ 

Did you find our guide useful? Please consider delegating to Billionaire Pool

{% embed url="www.billionairepool.com" %}

{% endhint %}

## 🚀 References

{% embed url="https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ossec-security-notifications-on-ubuntu-14-04" %}


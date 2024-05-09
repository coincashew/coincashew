# Next Steps

## :track\_next: Next Steps

{% hint style="info" %}
**Sync Timeline:** Syncing the consensus client is instantaneous with checkpoint sync but the execution client can take up to a day. On nodes with fast NVME drives and gigabit internet, expect your node to be fully synced in a few hours.
{% endhint %}

{% hint style="warning" %}
**Patience required**: If you're checking the logs and see any warnings or errors, please be patient as these will normally resolve once both your execution and consensus clients are fully synced to the Ethereum network.\\

**How do I know I'm fully synced?**

* Check your execution client's logs and compare the block number against the most recent block on [https://goerli.etherscan.io/](https://goerli.etherscan.io/)
  * Check EL logs: `journalctl -fu execution`
* Check your consensus client's logs and compare the slot number against the most recent slot on [https://goerli.beaconcha.in](https://goerli.beaconcha.in/)
  * Check CL logs: `journalctl -fu consensus`
{% endhint %}

{% hint style="info" %}
**Activation Queue**: Once your EL+CL is synced, validator up and running, you just wait for activation. This process can take 24+ hours. Only 900 new validators can join per day. Check the queue length: [https://wenmerge.com](https://wenmerge.com)

**Activated**: When you're activated, your validator will begin creating and voting on blocks while earning staking rewards.

**Quick monitoring**: Use [https://goerli.beaconcha.in/](https://goerli.beaconcha.in) to create alerts and track your validator's performance.
{% endhint %}

{% hint style="success" %}
:tada: Congrats! You've finished the primary steps of setting up your validator. You're now an Ethereum staker!
{% endhint %}

### :thumbsup: Recommended Steps

* Subscribe to your Execution Client and Consensus Client's Github repository to be notified of new releases. Find the Github links on each EL/CL's Overview section. At your EL or CL's github page while logged in, click the **Watch** button > **Custom** > click the checkbox for "**Release**".
* Join the [community on Discord and Reddit](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/joining-the-community-on-discord-and-reddit.md#discord) to discuss all things staking related.
* Familiarize yourself with [Part II - Maintenance](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/) section, as you'll need to keep your staking node running at its best.
* Up your staking understanding with the [EthStaker Knowledge Base](https://docs.ethstaker.cc/ethstaker-knowledge-base/).
* Review your staking validator backups!
* **Finished testing?** Before decommissioning your validator, it's good practice to properly [exit your validator](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-iii-tips/voluntary-exiting-a-validator.md) as this improves staking network health.

### :checkered\_flag: Optional Steps

* Setup [MEV-boost](../../../mev-boost/) for extra staking rewards!
* Setup [Monitoring with Grafana and Prometheus](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/monitoring-your-validator-with-grafana-and-prometheus.md)
* Setup [Mobile App Notifications and Monitoring by beaconcha.in](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/mobile-app-node-monitoring-by-beaconchain.md)
* Setup [External Monitoring with Uptime Check by Google Cloud](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/monitoring-with-uptime-check-by-google-cloud.md)
* Familiarize yourself with [Part III - Tips](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-iii-tips/) section, as you dive deeper into staking.

### :telephone: **Need extra live support?**

* Find Ethstaker frens on the [Ethstaker](https://discord.io/ethstaker) Discord and [coincashew](https://discord.gg/w8Bx8W2HPW) Discord.
* Use reddit: [r/Ethstaker](https://www.reddit.com/r/ethstaker/), or [DMs](https://www.reddit.com/user/coincashew), or [r/coincashew](https://www.reddit.com/r/coincashew/)

### :heart\_decoration: Like these guides?

* **Audience-funded guide**: If you found this helpful, [please consider supporting it directly.](../../../../../donations.md) :pray:
* **Support us on Gitcoin Grants:** We build this guide exclusively by community support!
* **Feedback or pull-requests**: [https://github.com/coincashew/coincashew](https://github.com/coincashew/coincashew)

{% hint style="success" %}
#### Ready for mainnet staking? [**Mainnet guide available here.**](../../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/)
{% endhint %}

## Last Words

> I stand upon the shoulders of giants and as such, invite you to stand upon mine. Use my work with or without attribution; I make no claim of "intellectual property." My ideas are the result of countless millenia of evolution - they belong to humanity.

<figure><img src="../../../../../.gitbook/assets/leslie-solo.png" alt=""><figcaption><p>This is Leslie, the official mascot of Eth Staking</p></figcaption></figure>

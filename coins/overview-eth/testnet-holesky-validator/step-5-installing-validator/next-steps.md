# Next Steps

{% hint style="success" %}
:tada: Congrats! You've finished the primary steps of setting up your validator. You're now an Ethereum staker!
{% endhint %}

## :track\_next: FAQ

<details>

<summary>Wen staking rewards?</summary>

**Activation Queue**: Once your EL+CL is synced, validator up and running, you just wait for activation. This process can take 24+ hours. Only 900 new validators can join per day. Check the queue length: [https://wenmerge.com ](https://wenmerge.com)

**Activated**: When you're activated, your validator will begin creating and voting on blocks while earning staking rewards.

**Quick monitoring**: Use [https://beaconcha.in/](https://beaconcha.in) to create alerts and track your validator's performance.

</details>

<details>

<summary>Sync Timeline</summary>

Syncing the consensus client is instantaneous with checkpoint sync but the execution client can take up to a day. On nodes with fast NVME drives and gigabit internet, expect your node to be fully synced in a few hours.



**How do I know I'm fully synced?**

* Check your execution client's logs and compare the block number against the most recent block on [https://etherscan.io](https://etherscan.io/)
  * Check EL logs: `journalctl -fu execution`
* Thanks to checkpoint sync, your consensus client's is instantly synched. You can compare the slot number against the most recent slot on [https://beaconcha.in](https://beaconcha.in/)
  * Check CL logs: `journalctl -fu consensus`



</details>

### :thumbsup: Recommended Steps

{% hint style="info" %}
:pill:**Install** [**EthPillar**](../../ethpillar.md): a simple companion UI for node management! Command line use is greatly reduced. Update your software with a keystroke.

![](../../../../.gitbook/assets/ethpillar.png)
{% endhint %}

* :newspaper2:**Subscribe to your Execution Client and Consensus Client's Github repository**: Be notified of new releases. Find the Github links on each EL/CL's Overview section. At your EL or CL's github page while logged in, click the **Watch** button > **Custom** > click the checkbox for "**Release**".
* :smile:**Join Community**: Join the [community on Discord and Reddit](../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/joining-the-community-on-discord-and-reddit.md#discord) to discuss all things staking related.
* :tools:**Node** **Maintenance**: Familiarize yourself with [Part II - Maintenance](../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-ii-maintenance/) section, as you'll need to keep your staking node running at its best.
* :books:**Study** [**EthStaker Knowledge Base**](https://docs.ethstaker.cc/ethstaker-knowledge-base/): Increase your staking understanding
* :cd:**Backups**: Review your staking validator backups!
* :fingers\_crossed:**Finished testing?** Before decommissioning your validator, it's good practice to properly [exit your validator](../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-iii-tips/voluntary-exiting-a-validator.md) as this improves staking network health.

### :checkered\_flag: Optional Steps

* :robot:**MEV-boost**: Setup [MEV-boost](../../mev-boost/) for extra staking rewards!
* :bar\_chart:**Monitoring**: Setup [Monitoring with Grafana and Prometheus](../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/monitoring-your-validator-with-grafana-and-prometheus.md)
* :chains:**RPC**: Setup using your own [Node as a RPC endpoint](../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-iii-tips/using-staking-node-as-rpc-url-endpoint.md).
* :mobile\_phone:**Notifications**: Setup [Mobile App Notifications and Monitoring by beaconcha.in](../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/mobile-app-node-monitoring-by-beaconchain.md)
* :up:**External Monitoring**: Setup [External Monitoring with Uptime Check by Google Cloud](../../archived-guides/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/monitoring-with-uptime-check-by-google-cloud.md)
* :books:**Knowledge**: Familiarize yourself with [Part III - Tips](../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-iii-tips/) section, as you dive deeper into staking.

### :telephone: **Need extra live support?**

* Find Ethstaker frens on the [Ethstaker](https://discord.io/ethstaker) Discord and [coincashew](https://discord.gg/w8Bx8W2HPW) Discord.
* Use reddit: [r/Ethstaker](https://www.reddit.com/r/ethstaker/), or [DMs](https://www.reddit.com/user/coincashew), or [r/coincashew](https://www.reddit.com/r/coincashew/)

### :heart\_decoration: Like these guides?

* **Audience-funded guide**: If you found this helpful, [please consider supporting it directly.](../../../../donations.md) :pray:
* **Support us on Gitcoin Grants:** We build this guide exclusively by community support!
* **Feedback or pull-requests**: [https://github.com/coincashew/coincashew](https://github.com/coincashew/coincashew)

{% hint style="success" %}
#### Ready for mainnet staking? [**Mainnet guide available here.**](../../guide-or-how-to-setup-a-validator-on-eth2-mainnet/)
{% endhint %}

## Last Words

> I stand upon the shoulders of giants and as such, invite you to stand upon mine. Use my work with or without attribution; I make no claim of "intellectual property." My ideas are the result of countless millenia of evolution - they belong to humanity.

<figure><img src="../../../../.gitbook/assets/leslie-solo.png" alt=""><figcaption><p>This is Leslie, the official mascot of Eth Staking</p></figcaption></figure>

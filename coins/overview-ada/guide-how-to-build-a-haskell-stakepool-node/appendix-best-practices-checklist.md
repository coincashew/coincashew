# Appendix - Best Practices Checklist

Here are the top problems a stake pool can experience and how to solve them:

1. **Pool configuration / metadata issues** - Check with [https://pool.vet](https://pool.vet) If problems are detected, fix by [updating your pool registration](part-iv-administration/updating-stake-pool-information.md).
2. **Relay status** - check your pool's relays on [ADApools](https://adapools.org) under About Tab
3. **Block producer in/out connections** - should match your environment. At least 1 in and 1 out connection is required. Check your firewall or IP/port configurations.
4. **TX processed count** - must be non-zero on your block producer node. Check your network config.
5. **Time synchronization** - install [chrony](how-to-setup-chrony.md) on all BP/relay nodes.
6. **Declared pledge is met** - check your pool on [PoolTool](https://pooltool.io) or [ADApools](https://adapools.org). Add more ADA to pledge address.

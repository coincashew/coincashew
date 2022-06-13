# :fishing_pole_and_fish:Operating Costs and Operator Margin

Any stake pool minting blocks receives a minimum **fixed fee** set by the blockchain protocol. At the discretion of the stake pool operator, a pool may also collect an additional **margin**, also called a **variable fee**. The fixed fee is subtracted from the total pool rewards for an epoch, and then any margin is applied. The remainder is paid to pool delegators in proportion to their stake.

The following example demonstrates how to calculate rewards shared by delegators staking to a pool receiving 340 ADA fixed fee and collecting an additional one percent margin, where `<TotalPoolRewards>` represents the total rewards that the pool receives for an epoch:

```
(<TotalPoolRewards> ADA - 340 ADA) * (100% - 1%)
```
{% hint style="info" %}
An epoch is five days in duration.
{% endhint %}

Some stake pools donate a portion of collected fees to charities or other social causes.

Margin may range from 0 percent to 100 percent. A pool having 0 percent margin collects no fees in addition to the fixed fee. A pool having 100 percent margin is considered a private pool and pays no rewards to delegators.

Every 1 percent increase in margin means delegators receive ≈ 0.037% annual percentage yield (APY) **less** rewards.

By pledging more, the pool operator may set a higher operator margin while still being attractive to delegators. As a rule of thumb, 2.3 million ADA pledge and 1 percent margin offset each other.

Fixed fee affects delegator rewards proportional to pool size. If a pool has little total stake, then each delegator pays more of the fee from their share of the rewards. Currently, the minimum fixed fee is 340 ADA per epoch for stake pools minting blocks. Stake pools that do not mint blocks do not receive the fixed fee.

**Saturation** is the level at which a pool becomes too large. A pool is saturated at 100 percent. A saturated pool is offering the best returns. If a pool becomes oversaturated, then rewards drop drastically.
# :top: Obtaining a PoolTool API Key

You can display the following data for your stake pool on [PoolTool](https://pooltool.io):

- Current block height
- The number of slots in which your stake pool is currently elected to mint blocks

To submit data for your stake pool to PoolTool, you need an API key.

**To get your PoolTool API key:**

1. In your Web browser, navigate to [PoolTool](https://pooltool.io/)
2. In the Search field, type your stake pool name or ticker.
3. In the search results, click the **Pool Details** button in the Actions column next to your stake pool.
4. On the Pool Details page, click the **Address Details** button next to the Reward Account or Owner Accounts addresses.
5. On the Address Detail page, click the **Claim Address** button next to the Bech32 address for your stake pool.
6. In the Claim Address dialog, click the **Claim Address** button, then type a secure password for your PoolTool account in the Password field, and then click **Claim Address**
7. Send exactly the amount of ADA requested in the Cardano PoolTool dialog from a payment address for the same wallet as the stake address that you want to claim to the requested address.
8. When the transaction you submitted in step 7 is confirmed, click **Sign In** on the Cardano PoolTool dialog.
9. After signing in, click **Profile** in the left navigation.
10. To get your API key, click the **Copy** button next to the API Key field, and then paste the API key as needed.

For more details on using your PoolTool API key, see the section [Integrating with PoolTool](../part-iii-operation/configuring-slot-leader-calculation.md#ptintegration)

{% hint style="info" %}
If your API key fails to connect with PoolTool, then open a new issue on [GitHub](https://github.com/papacarp/pooltool.io/issues).
{% endhint %}
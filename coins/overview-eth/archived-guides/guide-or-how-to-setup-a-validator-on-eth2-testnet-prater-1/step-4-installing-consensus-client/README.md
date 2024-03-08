# Step 4: Installing consensus client

## Pick a consensus client

**Consensus Client Diversity**: To strengthen Ethereum's resilience against potential attacks or consensus bugs, it's best practice to run a minority client in order to increase client diversity. Find the latest distribution of consensus clients here: [https://clientdiversity.org](https://clientdiversity.org/)

<figure><img src="../../../../../.gitbook/assets/clidiv.png" alt=""><figcaption><p>May 2023 Client Diversity</p></figcaption></figure>

{% hint style="warning" %}
Only one consensus client is required per node.
{% endhint %}

{% hint style="info" %}
:shield: **Recommendation** :shield:: Lodestar
{% endhint %}

### Select your desired consensus client for further instructions.

**Lighthouse** is an Ethereum client with a heavy focus on speed and security. Lighthouse is built in Rust.

{% content-ref url="lighthouse.md" %}
[lighthouse.md](lighthouse.md)
{% endcontent-ref %}

**Lodestar** is a Typescript implementation by the Chainsafe.io team. The Lodestar team is leading the Ethereum space in light client research.

{% content-ref url="lodestar.md" %}
[lodestar.md](lodestar.md)
{% endcontent-ref %}

**Teku** is a Java-based Ethereum client designed & built to meet institutional needs and security requirements.

{% content-ref url="teku.md" %}
[teku.md](teku.md)
{% endcontent-ref %}

**Nimbus** is designed to perform well on embedded systems and personal mobile devices. Written in Nim, a language with Python-like syntax that compiles to C.

{% content-ref url="nimbus.md" %}
[nimbus.md](nimbus.md)
{% endcontent-ref %}

**Prysm** is a Go implementation with a focus on usability, security, and reliability.

{% content-ref url="prysm.md" %}
[prysm.md](prysm.md)
{% endcontent-ref %}

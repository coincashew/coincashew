# Configuring Glasgow Haskell Compiler Runtime System Options

In some implementations, depending on hardware limitations configuring runtime system (RTS) options available for the Glasgow Haskell Compiler (GHC) may improve the performance and/or stability of an instance of Cardano Node.

The RTS offers many options for controlling behaviour. For example, depending on your system specifications and the Cardano Node version, your block-producing node may miss slot leader checks as reported using the [gLiveView](../part-iii-operation/starting-the-nodes.md#gliveview) dashboard due to time spent in garbage collection (GC). Using custom RTS options, you may seek to reduce significantly the number of slot leader checks that your block producer misses due to GC.

{% hint style="info" %}
Currently, missing more slot leader checks during the transition between epochs is expected behaviour for Cardano Node.
{% endhint %}

**To display the default RTS options for Cardano Node:**

- In a terminal window, type:
```bash
cardano-node +RTS --info
```

In the results, the value of the `Flag -with-rtsopts` key displays the default RTS options. For example:

```bash
-T -I0 -A16m -N2 --disable-delayed-os-memory-return
```

For details on available RTS options and setting RTS options using the command line, in the [GHC User's Guide](https://downloads.haskell.org/ghc/8.10.4/docs/users_guide.pdf) see the sections _RTS Options for SMP Parallelism_ on page 122 and _Running a Compiled Program_ on page 158.

For example, to produce runtime system statistics for each garbage collection in addition to using default RTS options, include the following RTS option in your `cardano-node run` command where `<FileName>` is the name of the file in the current folder where you want to output statistics and `<Options>` is the list of options that you use when running your node:

`/usr/local/bin/cardano-node run +RTS -S<FileName> -RTS <Options>`

If you are not satisfied with the performance or stability of an instance of Cardano Node, then subjectively you may notice improvement using custom RTS options such as:

```bash
+RTS -N -qg -qb -RTS
```

```bash
+RTS -I0.3 -Iw600 -F1.5 -H2500M -RTS
```
<!-- Reference:
https://forum.cardano.org/t/solving-the-cardano-node-huge-memory-usage-done/67032 -->

If you identify different RTS options that noticably improve the performance or stability of your Cardano Node instance, then please consider contributing your findings to [Coin Cashew](https://www.coincashew.com/) for the potential benefit of other stake pools operating in the Cardano network.


# :fire: Resetting an Installation

Want a clean start? Re-using existing server? Forked blockchain?

To delete your local git repo, and then rename or remove your previous `$NODE_HOME` and `cold-keys` directories, type:

```bash
rm -rf $HOME/git/cardano-node/ $HOME/git/libsodium/
mv $NODE_HOME $(basename $NODE_HOME)_backup_$(date -I)
mv $HOME/cold-keys $HOME/cold-keys_backup_$(date -I)
```

Then, you can start your installation again from the [beginning](../README.md).
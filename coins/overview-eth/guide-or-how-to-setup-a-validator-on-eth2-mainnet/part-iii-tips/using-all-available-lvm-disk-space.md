# :desktop: Using All Available LVM Disk Space

During installation of Ubuntu Server, a common issue arises where your hard drive's space is not fully available for use.

```bash
# View your disk drives
sudo -s lvm

# Change the logical volume filesystem path if required
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

#exit lvextend
exit

# Resize file system to use the new available space in the logical volume
resize2fs /dev/ubuntu-vg/ubuntu-lv

## Verify new available space
df -h

# Example output of a 2TB drive where 25% is used
# Filesystem                         Size   Used Avail Use% Mounted on
# /dev/ubuntu-vg/ubuntu-lv           2000G  500G  1500G  25% /
```

**Source reference**: [https://askubuntu.com/questions/1106795/ubuntu-server-18-04-lvm-out-of-space-with-improper-default-partitioning](https://askubuntu.com/questions/1106795/ubuntu-server-18-04-lvm-out-of-space-with-improper-default-partitioning)
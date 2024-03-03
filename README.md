# Opinionated NixOS getting-started guide

Install flake-enabled nix through any method on any computer. <https://zero-to-nix.com/> has a good
installer. Clone this repo and play around a little with its NixOS configuration that can be run in
a VM and installed in a completely automated way.

At the very least, you should change all items marked `FIXME` in this repo, including:

-   Hostname
-   Username
-   Amd/Intel microcode and kvm
-   Initrd kernel modules (hardware dependent)
-   Disk id to overwrite
    The latter 2 requires running Linux on the computer to install to, but not necessarily NixOS.

When you feel ready to actually switch to NixOS,

## Useful commands

To test automated install in a VM, including partitioning:

```
nixos-anywhere --vm-test --flake .#myhostname
```

Run the system in a VM, but without partitioning:

```
nix run .#nixosConfigurations.myhostname.config.system.build.vm
```

Note that this VM lacks GPU acceleration and is therefore somewhat slow.

From within target machine, check hardware info:

```
lsblk --output ID,FSTYPE,PARTLABEL,TYPE,SIZE,MOUNTPOINTS
nix shell nixpkgs#nixos-install-tools --command \
  nixos-generate-config --no-filesystems --show-hardware-config
```

## Install on remote machine that you have ssh access to (e.g. over LAN)

Note: This will erase any data on the previously specified disk

```
nixos-anywhere --flake .#myhostname root@target.ip.or.hostname
```

## Install on local machine

Note: This will erase any data on the previously specified disk

1. Boot from the NixOS installation media
2. Set keyboard layout, internet connectivity etc, for the installer
3. Acquire this repo, by cloning or wormholing or otherwise

Then, within the installer, run

```
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko \
  -- --mode disko ./disko.nix
```

Verify correct mounting with `mount | grep /mnt`, then copy over this repo and install:

```
cp -r . /mnt/etc/nixos
nixos-install
reboot
```

## Other resources

-   Local installation using disko: <https://github.com/nix-community/disko/blob/master/docs/quickstart.md>
-   <https://github.com/nix-community/nixos-anywhere>
-   Official nix documentation: <https://nix.dev/>

## Going beyond

This installation can be extended to support full-disk encryption and zfs and much more, but this
example excludes them to be simpler.

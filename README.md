# Opinionated NixOS getting-started guide

Install flake-enabled nix through any method on any computer. <https://zero-to-nix.com/> has a good
installer. Clone this repo and play around a little with its NixOS configuration that can be run in
a VM and installed in a completely automated way.

At the very least, you should change all items marked `FIXME` in this repo, including:
* Hostname
* Username
* Amd/Intel microcode and kvm
* Initrd kernel modules (hardware dependent)
* Disk id to overwrite
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

Check hardware info:
```
lsblk --output ID,FSTYPE,PARTLABEL,TYPE,SIZE,MOUNTPOINTS
nix shell nixpkgs#nixos-install-tools --command nixos-generate-config --no-filesystems --show-hardware-config
```

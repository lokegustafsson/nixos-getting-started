{ config, lib, pkgs, ... }: {
  networking.hostName = "myhostname"; # FIXME
  nixpkgs.hostPlatform = "x86_64-linux";

  # ========== HARDWARE ==========
  # FIXME: Replace this list with the corresponding list from
  # `nixos-generate-config --no-filesystems --show-hardware-config`
  boot.initrd.availableKernelModules =
    [ "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "nvme" "xhci_pci" "ahci" "usbhid" ];

  # FIXME
  #boot.kernelModules = [ "kvm-amd" ];
  #boot.kernelModules = [ "kvm-intel" ];
  #hardware.cpu.amd.updateMicrocode = true;
  #hardware.cpu.intel.updateMicrocode = true;

  hardware.enableAllFirmware = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.useDHCP = lib.mkDefault true;

  # ========== USERS ==========
  users.users = {
    root.shell = pkgs.zsh;
    myusername = { # FIXME
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "1234";
    };
  };

  # ========== DESKTOP ENVIRONMENT ==========
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_DK.UTF-8";

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "se";
      options = "caps:escape";
    };
  };
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  networking.networkmanager.enable = true;

  # ========== PROGRAMS ==========
  environment.systemPackages = let p = pkgs;
  in [
    p.binutils
    p.file
    p.gcc
    p.gnumake
    p.linuxPackages.perf
    p.magic-wormhole-rs
    p.ripgrep
    p.tree
    p.unzip
    p.util-linux
    p.wget
    p.which
    p.zip
    (p.python3.withPackages
      (py: [ py.matplotlib py.numpy py.pwntools py.requests ]))
  ];

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    promptInit = ''
      PRIMARY="%F{red}"
      ((UID)) && PRIMARY="%F{blue}"
      NEWLINE=$'\n'
      if [[ -n $IN_NIX_SHELL ]]; then
        NIXPROMPT=" - %B%F{cyan}(devshell)%b%f"
      else
        NIXPROMPT=""
      fi
      CODE="%(?.. - %F{red}[%?]%f)"
      PS1="%B$PRIMARY%n@%M%b%f$NIXPROMPT$CODE - %F{green}%d%f$NEWLINE%B%F{cyan}%# %b%f"
    '';
    interactiveShellInit = ''
      eval $(dircolors)

      [ "$(systemctl --failed | wc -l)" = 2 ] \
        || SYSTEMD_COLORS=1 systemctl --failed | head -n-5
    '';
  };
  programs.git = {
    enable = true;
    config = {
      alias.s = "status";
      branch.autosetuprebase = "always";
      merge.conflictStyle = "diff3";
      pull.ff = "only";
    };
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
  security = {
    sudo.enable = false;
    doas.enable = true;
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}

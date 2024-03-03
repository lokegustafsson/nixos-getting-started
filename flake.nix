{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      system = "x86_64-linux";

      lib = inputs.nixpkgs.lib;
      pkgs = import inputs.nixpkgs { inherit system; };

      # This is a NixOS module just like ./configuration.nix, but is conveniently defined inline as
      # it refers to `inputs.self` and `inputs.nixpkgs` directly.
      metaModule = {
        system.configurationRevision =
          lib.mkIf (inputs.self ? rev) inputs.self.rev;
        nix = {
          channel.enable = false;
          nixPath = [
            # Point to a stable path so system updates immediately update
            "nixpkgs=/run/current-system/nixpkgs"
          ];
          # Pinning flake registry entries, to avoid unpredictable cache invalidation and
          # corresponding large downloads
          registry.nixpkgs.flake = inputs.nixpkgs;
          registry.nixfiles.flake = inputs.self;
          settings = {
            auto-optimise-store = true;
            flake-registry = "";
          };
          extraOptions = "experimental-features = nix-command flakes";
        };
        system.extraSystemBuilderCmds = ''
          ln -s ${inputs.nixpkgs.outPath} $out/nixpkgs
        '';
        nixpkgs.config.allowUnfree = true;
      };
    in {
      # To access `nixos-anywhere` using `nix develop`
      devShell.${system} = pkgs.mkShell { packages = [ pkgs.nixos-anywhere ]; };

      # To format all nix code using `nix fmt`
      formatter.${system} = pkgs.writeShellApplication {
        name = "format";
        runtimeInputs = [ pkgs.nixfmt ];
        text = "find . -name '*.nix' -exec nixfmt {} +";
      };

      # Your actual system, for example rebuilt using `nixos-rebuild switch`
      nixosConfigurations.myhostname = lib.nixosSystem {
        inherit system;
        modules =
          [ inputs.disko.nixosModules.disko metaModule ./disko.nix ./configuration.nix ];
      };
    };
}

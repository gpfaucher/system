{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # Agenix - Age-encrypted secrets for NixOS
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Impermanence - Ephemeral root filesystem support
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    # Disko - Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser - Privacy-focused Firefox-based browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nvf,
      stylix,

      ghostty,
      agenix,
      impermanence,
      disko,
      zen-browser,
      opencode,
      treefmt-nix,
      pre-commit-hooks,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "gabriel";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Laptop configuration (AMD + NVIDIA hybrid, WiFi)
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs username self; };
        modules = [
          {
            nixpkgs.hostPlatform = system;
            nixpkgs.config.allowUnfree = true;
          }
          stylix.nixosModules.stylix
          agenix.nixosModules.default
          impermanence.nixosModules.impermanence
          ./hosts/laptop
          ./secrets # Agenix secrets configuration
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit inputs username self; };
              sharedModules = [
                inputs.nvf.homeManagerModules.default
                inputs.stylix.homeModules.stylix

              ];
              users.${username} = import ./modules/home;
            };
          }
        ];
      };

      # Server configuration (NVIDIA RTX 3070, wired, Jellyfin + Kubernetes)
      nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs username self; };
        modules = [
          {
            nixpkgs.hostPlatform = system;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.cudaSupport = true;
          }
          stylix.nixosModules.stylix
          agenix.nixosModules.default
          ./hosts/nixbox
          ./secrets # Agenix secrets configuration
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit inputs username self; };
              sharedModules = [
                inputs.nvf.homeManagerModules.default
                inputs.stylix.homeModules.stylix

              ];
              users.${username} = import ./modules/home;
            };
          }
        ];
      };

      # Formatter configuration using treefmt-nix
      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          prettier.enable = true;
          shfmt.enable = true;
        };
      };

      # Development shell with pre-commit hooks
      devShells.${system}.default =
        let
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
              shellcheck.enable = true;
            };
          };
        in
        pkgs.mkShell {
          packages = with pkgs; [
            nil # Nix LSP
            nixfmt # Nix formatter
          ];
          shellHook = pre-commit.shellHook;
        };
    };
}

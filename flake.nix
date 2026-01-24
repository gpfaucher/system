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

    # Beads - Git-backed issue tracker for AI agents
    # Provides persistent task memory across agent sessions
    # Task memory: .beads/issues/ (committed to git)
    # Cache: .beads/cache/ (local only, gitignored)
    beads = {
      url = "github:steveyegge/beads";
      inputs.nixpkgs.follows = "nixpkgs";
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

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      beads,
      agenix,
      impermanence,
      disko,
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
        # Add beads overlay for easy package access
        overlays = [
          (final: prev: {
            beads = beads.packages.${system}.default;
          })
        ];
      };
    in
    {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs username self; };
        modules = [
          {
            nixpkgs.hostPlatform = system;
            nixpkgs.config.allowUnfree = true;
            # Add beads overlay for system-level access
            nixpkgs.overlays = [
              (final: prev: {
                beads = beads.packages.${system}.default;
              })
            ];
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

      homeConfigurations."${username}@laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs username; };
        modules = [
          ./modules/home
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

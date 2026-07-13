{
  description = "Gabriel's macOS and NixOS server configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LNL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      ...
    }@inputs:
    let
      macUsername = "gabrielfaucher";
      serverUsername = "gabriel";
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forAllSystems =
        fn:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          fn (
            import nixpkgs {
              inherit system;
              config.allowUnsupportedSystem = true;
            }
          )
        );

      mkHomeManager =
        {
          isDarwin,
          isLinux,
          username,
        }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            inherit
              inputs
              isDarwin
              isLinux
              username
              ;
          };
          home-manager.users.${username} = import ./modules/home;
        };

      mkDarwinHost =
        name: system:
        let
          username = macUsername;
        in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            { nixpkgs.config.allowUnsupportedSystem = true; }
            inputs.stylix.darwinModules.stylix
            ./modules/theme.nix
            ./hosts/${name}
            home-manager.darwinModules.home-manager
            (mkHomeManager {
              isDarwin = true;
              isLinux = false;
              inherit username;
            })
          ];
        };

      mkNixosHost =
        name: system: username:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            inputs.stylix.nixosModules.stylix
            ./modules/theme.nix
            ./hosts/${name}
            home-manager.nixosModules.home-manager
            (mkHomeManager {
              isDarwin = false;
              isLinux = true;
              inherit username;
            })
          ];
        };
    in
    {
      darwinConfigurations.macbook = mkDarwinHost "macbook" "aarch64-darwin";

      nixosConfigurations.server = mkNixosHost "server" "x86_64-linux" serverUsername;

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            git
            jq
            nixfmt
            yq-go
          ];
        };

        kubernetes-learning = pkgs.mkShellNoCC {
          packages = with pkgs; [
            argocd
            fluxcd
            jq
            k9s
            kubeconform
            kubectl
            kubectx
            kubernetes-helm
            kustomize
            stern
            yq-go
          ];

          shellHook = ''
            echo "Kubernetes learning shell"
            echo "Target cluster:      NixOS server k3s"
            echo "Check access:        kubectl cluster-info"
            echo "Explore:             kubectl get nodes && kubectl get pods -A"
          '';
        };
      });

      formatter = forAllSystems (
        pkgs:
        pkgs.writeShellApplication {
          name = "format-nix-files";
          runtimeInputs = with pkgs; [
            findutils
            nixfmt
          ];
          text = ''
            find . -name '*.nix' -not -path './.git/*' -print0 | xargs -0 nixfmt
          '';
        }
      );
    };
}

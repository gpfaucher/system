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
      username = "gabrielfaucher";
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
        }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
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
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            { nixpkgs.config.allowUnsupportedSystem = true; }
            ./hosts/${name}
            home-manager.darwinModules.home-manager
            (mkHomeManager {
              isDarwin = true;
              isLinux = false;
            })
          ];
        };

      mkNixosHost =
        name: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            ./hosts/${name}
            home-manager.nixosModules.home-manager
            (mkHomeManager {
              isDarwin = false;
              isLinux = true;
            })
          ];
        };
    in
    {
      darwinConfigurations.macbook = mkDarwinHost "macbook" "aarch64-darwin";

      nixosConfigurations.server = mkNixosHost "server" "x86_64-linux";

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
            kind
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
            echo "Start local cluster: kind create cluster --config labs/kubernetes/kind/cluster.yaml"
            echo "Use kubeconfig:      kubectl cluster-info --context kind-learning"
            echo "Sample app:          kubectl apply -f labs/kubernetes/kind/manifests/whoami.yaml"
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

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
    };
}

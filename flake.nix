{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:nix-community/stylix";
  };

  outputs =
    { self
    , nixpkgs
    , stylix
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      username = "gabriel";
    in
    {
      nixosConfigurations = {
        nexus = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "nexus";
            inherit inputs outputs username;
          };
          modules = [ ./hosts/nexus ];
        };
        voyager = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "voyager";
            inherit inputs outputs username;
          };
          modules = [
            stylix.nixosModules.stylix
            ./hosts/voyager
          ];
        };
      };
    };
}

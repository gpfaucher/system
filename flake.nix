{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    home-manager.url = "github:nix-community/home-manager";
    nixvim.url = "github:nix-community/nixvim";
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
          modules = [
            stylix.nixosModules.stylix
            ./hosts/nexus
          ];
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

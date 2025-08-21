{
  description = "Your new nix config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nixvim.url = "github:nix-community/nixvim";
    stylix.url = "github:nix-community/stylix";
  };
  outputs =
    {
      self,
      nixpkgs,
      stylix,
      home-manager,
      ...
    }@inputs:
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
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs outputs username;
              };
            }
            ./hosts/nexus
            stylix.nixosModules.stylix
          ];
        };
        voyager = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "voyager";
            inherit inputs outputs username;
          };
          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs outputs username;
              };
            }
            ./hosts/voyager
            stylix.nixosModules.stylix
          ];
        };
      };
    };
}

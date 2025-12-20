{
  description = "Your new nix config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nixvim.url = "github:nix-community/nixvim";

    # System-wide theming
    stylix.url = "github:danth/stylix";
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    username = "gabriel";
  in {
    nixosConfigurations = {
      voyager = nixpkgs.lib.nixosSystem {
        specialArgs = {
          host = "voyager";
          inherit inputs outputs username;
        };
        modules = [
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs outputs username;
            };
          }
          ./hosts/voyager
        ];
      };
    };
  };
}

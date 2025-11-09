{
  description = "Your new nix config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nixvim.url = "github:nix-community/nixvim";
    hyprland.url = "github:hyprwm/Hyprland";
    plasma-manager = {
      url = "github:AlexNabokikh/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      username = "gabriel";
    in
    {
      nixosConfigurations = {
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
          ];
        };
      };
    };
}

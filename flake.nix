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
  };

  

  outputs = { self, nixpkgs, home-manager, nvf, stylix, ghostty, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "gabriel";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs username; };
        modules = [
          {
            nixpkgs.hostPlatform = system;
            nixpkgs.config.allowUnfree = true;
          }
          stylix.nixosModules.stylix
          ./hosts/laptop
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username; };
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
    };
}

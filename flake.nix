{
  description = "Gabriel's macOS + NixOS Configurations";

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
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs: {
    
    # --- MACBOOK CONFIGURATION (Apple Silicon M4) ---
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = "aarch64-darwin"; 
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/macbook.nix
        
        # We integrate Home Manager to manage the user account
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."gabriel" = import ./modules/home-darwin.nix;
        }
      ];
    };

    # --- LINUX CONFIGURATION (Future use) ---
    nixosConfigurations = {
      # laptop = inputs.nixpkgs.lib.nixosSystem { ... };
    };
  };
}
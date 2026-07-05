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

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs: {
    
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.config.allowUnsupportedSystem = true; }
        ./hosts/macbook.nix
        
        # We integrate Home Manager to manage the user account
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users."gabrielfaucher" = import ./modules/home-darwin.nix;
        }
      ];
    };

    darwinOptions = { nixpkgs.hostPlatform = "aarch64-darwin"; };

    # TODO: Future Linux installs (Homelab / VPS) go here.
    nixosConfigurations = {
      # laptop = inputs.nixpkgs.lib.nixosSystem { ... };
    };
  };
}
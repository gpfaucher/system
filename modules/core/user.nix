{
  pkgs,
  inputs,
  username,
  host,
  ...
}:
{
  # Remove this line - it's already imported in flake.nix
  # imports = [ inputs.home-manager.nixosModules.home-manager ];
  
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs username host; };
    backupFileExtension = "backup";
    users.${username} = {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnfreePredicate = _: true;
      
      imports = if (host == "nexus") then [ ./../home/default.desktop.nix ] else [ ./../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "22.11";
      };
      programs.home-manager.enable = true;
    };
  };
  
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
    ];
    shell = pkgs.fish;
  };
  nix.settings.allowed-users = [ "${username}" ];
}

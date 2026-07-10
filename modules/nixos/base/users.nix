{ pkgs, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "systemd-journal"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMshKw/HbLHTO7UshikMrq4LOy7oxf/VP2ngj5QGbVM1 gabrielfaucher@Gabriels-MacBook-Pro.local"
    ];
  };

  programs.fish.enable = true;
}

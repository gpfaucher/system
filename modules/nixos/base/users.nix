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
      # Add your MacBook public SSH key before installing the server.
    ];
  };

  programs.fish.enable = true;
}

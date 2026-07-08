{
  pkgs,
  username,
  ...
}:

{
  users.users.${username} = {
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
  };

  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: ALL
  '';

  programs.fish.enable = true;
}

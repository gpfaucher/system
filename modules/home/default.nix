{
  config,
  isDarwin,
  isLinux,
  lib,
  pkgs,
  username,
  ...
}:

let
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  imports = [
    ./common/git.nix
    ./neovim.nix
    ./shell.nix
    ./ssh.nix
    ./tmux.nix
  ]
  ++ lib.optionals isDarwin [
    ./platforms/darwin.nix
    ./profiles/macbook.nix
  ]
  ++ lib.optionals isLinux [
    ./platforms/linux.nix
    ./profiles/server-admin.nix
  ];

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = if isDarwin then "23.05" else "24.11";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = lib.mkDefault "nvim";
    };
  };

  programs.home-manager.enable = true;
}

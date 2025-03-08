{ pkgs, ... } :
{
  programs.git = {
    enable = true;
    userEmail = "gpfaucher@gmail.com";
    userName = "Gabriel Faucher";

    extraConfig = { 
      init.defaultBranch = "master";
      credential.helper = "store";
      alias.stat = "status";
      alias.lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%Creset' --abbrev-commit";
    };

  };

  home.packages = [ pkgs.gh  pkgs.git-lfs  pkgs.lazygit ];
}

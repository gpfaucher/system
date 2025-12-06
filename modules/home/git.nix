{pkgs, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "gpfaucher@gmail.com";
        name = "Gabriel Faucher";
      };
      init.defaultBranch = "master";
      credential.helper = "store";
      alias.stat = "status";
      alias.lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%Creset' --abbrev-commit";
    };
  };

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      diffToolMode = true;
    };
    options = {
      background = "dark";
    };
  };

  home.packages = with pkgs; [
    delta
    gh
    git-lfs
    lazygit
  ];
}

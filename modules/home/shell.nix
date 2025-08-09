_: {
  programs.zsh = {
    enable = true;

    antidote = {
      enable = true;
      plugins = [
        "zsh-users/zsh-autosuggestions"
        "jeffreytse/zsh-vi-mode"
      ];
    };

    autosuggestion = {
      enable = true;
      highlight = "fg=#5C6773";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "sudo"
        "direnv"
      ];
    };
  };
}

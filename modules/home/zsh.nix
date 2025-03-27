_: {
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    antidote = {
      enable = true;
      plugins = [
        "marlonrichert/zsh-autocomplete"
        "zsh-users/zsh-autosuggestions"
      ];
    };
    initExtra = ''
      export NIX_BUILD_SHELL="zsh"
    '';
  };
}

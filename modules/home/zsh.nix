_: {
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    prezto = {
      enable = true;
      editor.keymap = "vi";
    };
    autosuggestion = {
      enable = true;
    };
    initExtra = ''
      export NIX_BUILD_SHELL="zsh"
    '';
  };
}

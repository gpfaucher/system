_: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "ghostty";
        layer = "overlay";
        prompt = "> ";
        icons-enabled = "no";
        width = 50;
        lines = 15;
        horizontal-pad = 20;
        vertical-pad = 15;
        inner-pad = 5;
      };
      # Colors handled by Stylix
      border = {
        width = 2;
        radius = 0;
      };
      dmenu = {
        exit-immediately-if-empty = "yes";
      };
    };
  };
}

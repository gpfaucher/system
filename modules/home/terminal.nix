{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    ghostty
    alacritty
  ];

  # Ghostty configuration
  home.file."${config.xdg.configHome}/ghostty/config".text = ''
    # Font configuration
    font-family = JetBrainsMono Nerd Font Mono
    font-size = 14

    # Theme (Carbon/Oxocarbon inspired)
    background = 161616
    foreground = ffffff

    # Cursor
    cursor-color = ffffff

    # Colors
    palette = 0=#262626
    palette = 1=#ff7eb6
    palette = 2=#42be65
    palette = 3=#ffe97b
    palette = 4=#33b1ff
    palette = 5=#ee5396
    palette = 6=#3ddbd9
    palette = 7=#dde1e6
    palette = 8=#393939
    palette = 9=#ff7eb6
    palette = 10=#42be65
    palette = 11=#ffe97b
    palette = 12=#33b1ff
    palette = 13=#ee5396
    palette = 14=#3ddbd9
    palette = 15=#ffffff

    # Window settings
    window-padding-x = 4
    window-padding-y = 4
  '';
}

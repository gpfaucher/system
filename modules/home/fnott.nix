{
  config,
  pkgs,
  ...
}: let
  colors = config.lib.stylix.colors;
in {
  home.packages = with pkgs; [
    fnott
    libnotify
  ];

  xdg.configFile."fnott/fnott.ini".text = ''
    [main]
    output=
    min-width=300
    max-width=400
    max-height=200
    stacking-order=top-down
    anchor=top-right
    edge-margin-vertical=10
    edge-margin-horizontal=10
    icon-theme=Adwaita
    max-icon-size=32
    selection-helper=fuzzel --dmenu

    [low]
    background=${colors.base00}dd
    title-color=${colors.base05}ff
    summary-color=${colors.base05}ff
    body-color=${colors.base04}ff
    border-color=${colors.base03}ff
    border-size=2
    title-font=JetBrainsMono Nerd Font:size=10:weight=bold
    summary-font=JetBrainsMono Nerd Font:size=10
    body-font=JetBrainsMono Nerd Font:size=9
    default-timeout=5
    progress-bar-color=${colors.base0D}ff

    [normal]
    background=${colors.base00}dd
    title-color=${colors.base05}ff
    summary-color=${colors.base05}ff
    body-color=${colors.base04}ff
    border-color=${colors.base0D}ff
    border-size=2
    title-font=JetBrainsMono Nerd Font:size=10:weight=bold
    summary-font=JetBrainsMono Nerd Font:size=10
    body-font=JetBrainsMono Nerd Font:size=9
    default-timeout=10
    progress-bar-color=${colors.base0D}ff

    [critical]
    background=${colors.base00}ee
    title-color=${colors.base08}ff
    summary-color=${colors.base08}ff
    body-color=${colors.base05}ff
    border-color=${colors.base08}ff
    border-size=3
    title-font=JetBrainsMono Nerd Font:size=10:weight=bold
    summary-font=JetBrainsMono Nerd Font:size=10
    body-font=JetBrainsMono Nerd Font:size=9
    default-timeout=0
    progress-bar-color=${colors.base08}ff
  '';
}

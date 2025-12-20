{
  config,
  pkgs,
  ...
}: let
  colors = config.lib.stylix.colors;
in {
  home.packages = with pkgs; [
    waylock
    chayang
  ];

  xdg.configFile."waylock/waylock.toml".text = ''
    [flags]
    ignore-empty-password = true

    [colors]
    init-color = "${colors.base00}"
    input-color = "${colors.base0D}"
    fail-color = "${colors.base08}"
  '';
}

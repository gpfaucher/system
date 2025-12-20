{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.wpaperd];

  xdg.configFile."wpaperd/config.toml".text = ''
    [default]
    path = "${config.stylix.image}"
    mode = "stretch"
  '';
}

{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  home.packages = with pkgs; [
    kdePackages.kcalc
    kdotool
    tela-circle-icon-theme
    kdePackages.xdg-desktop-portal-kde
    xdg-desktop-portal-gtk
    wireplumber
  ];

  services.gpg-agent = {
    pinentry.package = lib.mkForce pkgs.kwalletcli;
    extraConfig = "pinentry-program ${pkgs.kwalletcli}/bin/pinentry-kwallet";
  };

  programs.plasma = {
    enable = true;
    workspace = {
      # Use a dark scheme; true Oxocarbon Plasma theme requires an external package.
      colorScheme = "BreezeDark";
    };
  };

  # GTK theming can be added if an Oxocarbon package is provided; skipped for now.
}

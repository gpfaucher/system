{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  home.packages = with pkgs; [
    (catppuccin-kde.override {
      flavour = [ "macchiato" ];
      accents = [ "lavender" ];
    })
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
  };
}

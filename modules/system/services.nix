{
  config,
  lib,
  pkgs,
  ...
}:

{
  # dconf for GTK/GNOME settings (required by stylix)
  programs.dconf.enable = true;

  # CUPS printing service
  services.printing.enable = true;

  # UPower service for battery/power management info
  services.upower.enable = true;

  # Bluetooth support (blueman-applet provides UI in systray)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Polkit for authentication dialogs
  security.polkit.enable = true;

  # nix-ld: run dynamically linked binaries (e.g. JetBrains Toolbox IDEs, pip-installed tools)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # X11/GUI libraries needed by JetBrains IDEs (bundled JBR)
    xorg.libXext
    xorg.libX11
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    xorg.libXrandr
    fontconfig
    freetype
    zlib
    # Wayland libraries (JetBrains IDEs on Wayland)
    wayland
    libxkbcommon
  ];

  # Docker
  virtualisation.docker.enable = true;

  # Enable coredumps for crash diagnosis
  systemd.coredump = {
    enable = true;
    extraConfig = ''
      Storage=external
      MaxUse=5G
    '';
  };
}

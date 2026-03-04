{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Required by Stylix
  programs.dconf.enable = true;

  services.printing.enable = true;

  services.upower.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.polkit.enable = true;

  # nix-ld: run dynamically linked binaries (e.g. JetBrains Toolbox IDEs, pip-installed tools)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # X11/GUI libraries needed by JetBrains IDEs (bundled JBR)
    libxext
    libx11
    libxrender
    libxtst
    libxi
    libxrandr
    fontconfig
    freetype
    zlib
    # Wayland libraries (JetBrains IDEs on Wayland)
    wayland
    libxkbcommon
  ];

  virtualisation.docker.enable = true;

  systemd.coredump = {
    enable = true;
    extraConfig = ''
      Storage=external
      MaxUse=5G
    '';
  };
}

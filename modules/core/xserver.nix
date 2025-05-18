{ config
, pkgs
, ...
}: {
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  programs.light.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
  ];
  # For 32 bit applications
  hardware.graphics.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = false;

  #   powerManagement.enable = true;
  #   # nvidiaPersistenced = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.beta;
  # };

  powerManagement.resumeCommands = ''
    wlr-randr --output DP-2 --mode 3440x1440@144 &
    rm -rf ~/Documents ~/Desktop/ ~/Downloads/
    sudo evremap remap ~/.config/evremap/config.toml &
  '';

  programs.river = {
    enable = true;
  };
  programs.hyprland = {
    enable = true;
  };

  services.xserver = {
    enable = true;
    # videoDrivers = [ "nvidia" ];
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
}

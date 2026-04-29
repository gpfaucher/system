# NVIDIA-only graphics stack for the workstation (RTX 3070 Ti, Ampere).
#
# Differs from modules/system/graphics.nix (laptop) in that there is no
# AMD iGPU and therefore no PRIME render-offload setup.
{
  config,
  pkgs,
  lib,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      libva
      vulkan-loader
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # RTX 3070 Ti (Ampere) is supported by the open kernel modules. Flip to
    # false if you hit stability issues and prefer the proprietary modules.
    open = true;
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    libva-utils
    nvtopPackages.nvidia
  ];
}

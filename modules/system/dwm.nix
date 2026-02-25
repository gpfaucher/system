{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors;

  # Generate config.h with Stylix colors substituted
  # replaceVars replaces @varname@ patterns (only include colors actually used in config.h)
  configFile = pkgs.replaceVars ../home/dwm/config.h {
    base00 = "#${colors.base00}";
    base01 = "#${colors.base01}";
    base05 = "#${colors.base05}";
    base0D = "#${colors.base0D}";
  };

  customDwm = pkgs.dwm.overrideAttrs (old: {
    # Single combined patch with all 25 DWM patches pre-merged and conflicts resolved.
    # Config.def.h changes are excluded — a custom config.h is provided via replaceVars.
    patches = [
      ../home/dwm/patches/dwm-combined.patch
    ];

    postPatch = (old.postPatch or "") + ''
      cp ${configFile} config.def.h
    '';

    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.xorg.libxcb
      pkgs.xorg.xcbutilwm
      pkgs.libxcursor
    ];
  });
in
{
  services.xserver.windowManager.dwm.package = customDwm;
}

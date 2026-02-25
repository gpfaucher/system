{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors;

  # Generate config.h with Stylix colors substituted
  # replaceVars replaces @varname@ patterns (only include colors actually used in config.h)
  configFile = pkgs.replaceVars ../home/dwm/config.h {
    base00 = "#${colors.base00}";
    base01 = "#${colors.base01}";
    base02 = "#${colors.base02}";
    base05 = "#${colors.base05}";
    base08 = "#${colors.base08}";
    # Pass through wpctl PipeWire targets literally (avoid replaceVars check)
    DEFAULT_AUDIO_SINK = "@DEFAULT_AUDIO_SINK@";
    DEFAULT_AUDIO_SOURCE = "@DEFAULT_AUDIO_SOURCE@";
  };

  customDwm = pkgs.dwm.overrideAttrs (old: {
    # Single combined patch with all 25 DWM patches pre-merged and conflicts resolved.
    # Config.def.h changes are excluded — a custom config.h is provided via replaceVars.
    patches = [
      ../home/dwm/patches/dwm-combined.patch
    ];

    postPatch = (old.postPatch or "") + ''
      cp ${configFile} config.def.h
      # Fix systray background: use normal bg instead of selected bg
      sed -i 's/scheme\[SchemeSel\]\[ColBg\]\.pixel/scheme[SchemeNorm][ColBg].pixel/g' dwm.c
      # Add internal bar padding (~6px above/below text)
      sed -i 's/bh = drw->fonts->h + 2;/bh = drw->fonts->h + 8;/' dwm.c
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

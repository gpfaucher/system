{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors;

  # Generate config.h with Stylix colors substituted.
  # Uses substitute instead of replaceVars to avoid the strict @-pattern check,
  # since wpctl targets like @DEFAULT_AUDIO_SINK@ must remain literal.
  configFile = pkgs.runCommand "config.h" { } ''
    substitute ${../home/dwm/config.h} $out \
      --subst-var-by base00 "#${colors.base00}" \
      --subst-var-by base01 "#${colors.base01}" \
      --subst-var-by base02 "#${colors.base02}" \
      --subst-var-by base05 "#${colors.base05}" \
      --subst-var-by base08 "#${colors.base08}"
  '';

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

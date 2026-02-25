{ config, pkgs, ... }:

let
  colors = config.lib.stylix.colors;

  dmenuConfig = pkgs.writeText "dmenu-config.h" ''
    /* See LICENSE file for copyright and license details. */
    /* Default settings; can be overriden by command line. */

    static int topbar = 1;
    static const char *fonts[] = {
    	"Monaspace Neon:size=13:weight=medium",
    	"Symbols Nerd Font:size=14"
    };
    static const char *prompt      = NULL;
    static const char *colors[SchemeLast][2] = {
    	/*     fg         bg       */
    	[SchemeNorm] = { "#${colors.base05}", "#${colors.base01}" },
    	[SchemeSel] = { "#${colors.base00}", "#${colors.base0B}" },
    	[SchemeOut] = { "#${colors.base05}", "#${colors.base02}" },
    };
    static unsigned int lines      = 0;
    static const char worddelimiters[] = " ";
  '';

  customDmenu = pkgs.dmenu.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      cp ${dmenuConfig} config.def.h
    '';
  });
in
{
  home.packages = [ customDmenu ];
}

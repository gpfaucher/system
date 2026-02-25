{ config, pkgs, ... }:

let
  colors = config.lib.stylix.colors;

  customDmenu = pkgs.dmenu.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i 's/static const char \*fonts\[\] = .*/static const char *fonts[] = { "Monaspace Neon:size=11", "Symbols Nerd Font:size=11" };/' config.def.h
      sed -i 's/\[SchemeNorm\] = .*/[SchemeNorm] = { "#${colors.base05}", "#${colors.base00}" },/' config.def.h
      sed -i 's/\[SchemeSel\] = .*/[SchemeSel] = { "#${colors.base00}", "#${colors.base0D}" },/' config.def.h
      sed -i 's/\[SchemeOut\] = .*/[SchemeOut] = { "#${colors.base05}", "#${colors.base02}" },/' config.def.h
    '';
  });
in
{
  home.packages = [ customDmenu ];
}

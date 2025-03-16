{ pkgs, ... }:
let
  rofi-powermenu = pkgs.writeShellScriptBin "rofi-powermenu" (builtins.readFile ./rofi-powermenu.sh);
in
{
  home.packages = with pkgs; [
    rofi-powermenu
  ];
}

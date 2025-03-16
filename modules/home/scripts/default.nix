{ pkgs, ... }:
let
  rofi-powermenu = pkgs.writeShellScriptBin "rofi-powermenu" (builtins.readFile ./rofi-powermenu.sh);
  rofi-powermenu-cmd = pkgs.writeShellScriptBin "rofi-powermenu-cmd" (builtins.readFile ./rofi-powermenu-cmd.sh);
in
{
  home.packages = with pkgs; [
    rofi-powermenu
    rofi-powermenu-cmd
  ];
}

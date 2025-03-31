{ pkgs, ... }:
let
  rofi-powermenu = pkgs.writeShellScriptBin "rofi-powermenu" (builtins.readFile ./rofi-powermenu.sh);
  zathura-picker = pkgs.writeShellScriptBin "zathura-picker" (builtins.readFile ./zathura-picker.sh);
in
{
  home.packages = with pkgs; [
    rofi-powermenu
    zathura-picker
  ];
}

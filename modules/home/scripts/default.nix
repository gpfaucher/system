{ pkgs, ... }:
let
  rofi-powermenu = pkgs.writeShellScriptBin "rofi-powermenu" (builtins.readFile ./rofi-powermenu.sh);
  zathura-picker = pkgs.writeShellScriptBin "zathura-picker" (builtins.readFile ./zathura-picker.sh);
  wofi-bluetooth = pkgs.writeShellScriptBin "wofi-bluetooth" (builtins.readFile ./wofi-bluetooth.sh);
  fix-display = pkgs.writeShellScriptBin "fix-display" (builtins.readFile ./fix-display.sh);
in
{
  home.packages = with pkgs; [
    rofi-powermenu
    zathura-picker
    wofi-bluetooth
    fix-display
  ];
}

{ pkgs, ... }:

let
  vpn = pkgs.writeShellApplication {
    name = "vpn";
    text = ''
      usage() {
        echo "Usage: vpn <connect|disconnect|status> <gn2|gn3>" >&2
        exit 2
      }

      action="''${1:-}"
      target="''${2:-gn2}"

      case "$target" in
        gn2) profile="SP Beheer GN2 (UDP)" ;;
        gn3) profile="SP Beheer GN3 (TCP)" ;;
        *) usage ;;
      esac

      case "$action" in
        connect)
          /usr/bin/open -a Tunnelblick
          /usr/bin/osascript -e "tell application \"Tunnelblick\" to connect \"$profile\""
          ;;
        disconnect)
          /usr/bin/osascript -e "tell application \"Tunnelblick\" to disconnect \"$profile\""
          ;;
        status)
          /usr/bin/osascript -e "tell application \"Tunnelblick\" to get state of first configuration where name is \"$profile\""
          ;;
        *) usage ;;
      esac
    '';
  };
in
{
  home.packages = [ vpn ];

  programs.fish.interactiveShellInit = ''
    fish_add_path -g /opt/homebrew/bin
  '';
}

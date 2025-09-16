{ pkgs, lib, ... }:
let
  kmonad-dynamic = pkgs.writeShellApplication {
    name = "kmonad-dynamic";
    runtimeInputs = [
      pkgs.kmonad
      pkgs.coreutils
      pkgs.findutils
      pkgs.gawk
      pkgs.inotify-tools
    ];
    text = ''
            #!/usr/bin/env bash
            set -euo pipefail

            RUNTIME_DIR="$XDG_RUNTIME_DIR"
            if [ -z "$RUNTIME_DIR" ]; then
              RUNTIME_DIR="/run/user/$(id -u)"
            fi
            STATE_DIR="$RUNTIME_DIR/kmonad-dynamic"
            mkdir -p "$STATE_DIR"
            PIDS_FILE="$STATE_DIR/pids"

            kill_all() {
              if [ -f "$PIDS_FILE" ]; then
                while read -r pid; do
                  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                    kill "$pid" || true
                  fi
                done < "$PIDS_FILE"
                : > "$PIDS_FILE"
              fi
              pkill -f "kmonad .*kmonad-dyn" || true
            }

            make_cfg() {
              local dev="$1"; shift
              local out="$1"; shift
              cat >"$out" <<'KBD'
              (defcfg
                input  (device-file "__DEVICE__")
                output (uinput-sink "kmonad-dyn")
                fallthrough true
                allow-cmd true)

              (defsrc
                esc    f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12
                prnt   sclk pause
                grave  1 2 3 4 5 6 7 8 9 0 minus equal bs
                ins    home pgup
                tab    q w e r t y u i o p lbracket rbracket backslash
                del    end  pgdn
                caps   a s d f g h j k l semicolon quote enter
                lshift z x c v b n m comma dot slash rshift
                up
                lctrl  lmeta lalt space ralt rmeta menu rctrl
                left   down right)

              (deflayer base
                __     __ __ __ __ __ __ __ __ __  __  __  __
                __     __   __   __
                __     __ __ __ __ __ __ __ __ __  __   __    __
                __     __   __
                __     __ __ __ __ __ __ __ __ __  __        __
                __     __   __
                (tap-hold-next esc lctl) __ __ __ __ __ __ __ __ __ __     __
                __     __ __ __ __ __ __ __ __ __ __ __     __
                __
                __     __    __   __    __   __    __   __
                __     __   __)
      KBD
              sed -e "s|__DEVICE__|$dev|g" -i "$out"
            }

            start_all() {
              kill_all || true
              local have_any=false
              while IFS= read -r link; do
                [ -e "$link" ] || continue
                local dev
                dev=$(readlink -f "$link")
                local base
                base=$(basename "$link")
                local cfg="$STATE_DIR/$base.kbd"
                make_cfg "$dev" "$cfg"
                kmonad "$cfg" &
                echo $! >> "$PIDS_FILE"
                have_any=true
              done < <(ls -1 /dev/input/by-id/*-kbd 2>/dev/null || true)

              if [ "$have_any" = false ]; then
                echo "No keyboards found (by-id *-kbd). Will monitor for hotplug." >&2
              fi
            }

            monitor() {
              # Watch for keyboard add/remove and reconfigure
              while true; do
                inotifywait -q -e create,delete,move /dev/input/by-id >/dev/null 2>&1 || true
                start_all
              done
            }

            start_all
            monitor
    '';
  };
in
{
  home.packages = [
    pkgs.kmonad
    pkgs.inotify-tools
  ];

  systemd.user.services.kmonad-dynamic = {
    Unit = {
      Description = "KMonad dynamic launcher for all keyboards";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = lib.getExe kmonad-dynamic;
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

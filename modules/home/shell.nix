{ pkgs, ... }:

{
  # Fish shell
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Vi keybindings
      set -g fish_key_bindings fish_vi_key_bindings

      # Disable greeting
      set fish_greeting

      # Add local bin to PATH
      fish_add_path -g ~/.local/bin

      # Go
      set -gx GOPATH ~/.local/share/go
      fish_add_path -g $GOPATH/bin

      # Start River on tty1
      if test (tty) = "/dev/tty1"
        exec river
      end
    '';

    shellAbbrs = {
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gs = "git status";
      lg = "lazygit";
    };

    functions = {
      # Yazi shell wrapper (cd on exit)
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';

      # Venv switcher for monorepos
      venv = ''
        # Find project root (git root or current dir)
        set -l root (git rev-parse --show-toplevel 2>/dev/null; or echo $PWD)

        # Find all venvs in project
        set -l venvs (find $root -maxdepth 4 -type f -path "*/.venv/bin/activate.fish" -o -path "*/venv/bin/activate.fish" 2>/dev/null)

        if test (count $argv) -eq 0
          # List available venvs
          if test (count $venvs) -eq 0
            echo "No venvs found in $root"
            return 1
          end
          echo "Available venvs:"
          for v in $venvs
            set -l name (string replace "$root/" "" (dirname (dirname (dirname $v))))
            set -l marker ""
            if set -q VIRTUAL_ENV; and test (dirname (dirname $v)) = "$VIRTUAL_ENV"
              set marker " (active)"
            end
            echo "  $name$marker"
          end
          return 0
        end

        if test "$argv[1]" = "off"
          if set -q VIRTUAL_ENV
            deactivate
            echo "Deactivated venv"
          end
          return 0
        end

        # Find matching venv
        for v in $venvs
          if string match -q "*$argv[1]*" $v
            source $v
            echo "Activated: $VIRTUAL_ENV"
            return 0
          end
        end

        echo "No venv matching '$argv[1]' found"
        return 1
      '';
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      add_newline = false;

      format = ''
        $username\
        $hostname\
        $directory\
        $git_branch\
        $git_state\
        $git_status\
        $cmd_duration\
        $line_break\
        $python\
        $character'';

      directory = {
        style = "blue";
      };

      character = {
        success_symbol = "[->](purple)";
        error_symbol = "[->](red)";
        vimcmd_symbol = "[<-](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        untracked = "";
        modified = "";
        staged = "";
        renamed = "";
        deleted = "";
        stashed = "=";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };
    };
  };

  # Direnv with nix-direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Shell utilities
  home.packages = with pkgs; [
    yazi
    lazygit
    btop
    fd
    ripgrep
    fzf
    jq
  ];
}

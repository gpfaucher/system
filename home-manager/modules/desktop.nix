_ :
{
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./xdg/xmonad.hs; # Assumes this file is in the same directory
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 52.992752;
    longitude = 6.564228;
  };

  services.picom = {
    enable = true;
    backend = "glx";
    fade = true;
    fadeDelta = 5;
    opacityRule = [
      "100:name *= 'i3lock'"
      "99:fullscreen"
      "90:class_g = 'Alacritty' && focused"
      "65:class_g = 'Alacritty' && !focused"
    ];

    shadow = true;
    shadowOpacity = 0.75;
    settings = {
      xrender-sync-fence = true;
      mark-ovredir-focused = false;
      use-ewmh-active-win = true;

      unredir-if-possible = false;
      backend = "glx";
      vsync = true;
    };
  };

  programs = {
    rofi.enable = true;
    starship.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting

        # Kanagawa Fish shell theme
        set -l foreground DCD7BA normal
        set -l selection 2D4F67 brcyan
        set -l comment 727169 brblack
        set -l red C34043 red
        set -l orange FF9E64 brred
        set -l yellow C0A36E yellow
        set -l green 76946A green
        set -l purple 957FB8 magenta
        set -l cyan 7AA89F cyan
        set -l pink D27E99 brmagenta

        # Syntax Highlighting Colors
        set -g fish_color_normal $foreground
        set -g fish_color_command $cyan
        set -g fish_color_keyword $pink
        set -g fish_color_quote $yellow
        set -g fish_color_redirection $foreground
        set -g fish_color_end $orange
        set -g fish_color_error $red
        set -g fish_color_param $purple
        set -g fish_color_comment $comment
        set -g fish_color_selection --background=$selection
        set -g fish_color_search_match --background=$selection
        set -g fish_color_operator $green
        set -g fish_color_escape $pink
        set -g fish_color_autosuggestion $comment

        # Completion Pager Colors
        set -g fish_pager_color_progress $comment
        set -g fish_pager_color_prefix $cyan
        set -g fish_pager_color_completion $foreground
        set -g fish_pager_color_description $comment
      '';
    };

    alacritty = {
      enable = true;
      settings = {
        font = {
          size = 11;
          normal.family = "JetBrainsMono Nerd Font Mono";
          bold.family = "JetBrainsMono Nerd Font Mono";
          italic.family = "JetBrainsMono Nerd Font Mono";
          bold_italic.family = "JetBrainsMono Nerd Font Mono";
        };
        colors = {
          primary = {
            background = "#1f1f28";
            foreground = "#dcd7ba";
          };
          normal = {
            black = "#090618";
            red = "#c34043";
            green = "#76946a";
            yellow = "#c0a36e";
            blue = "#7e9cd8";
            magenta = "#957fb8";
            cyan = "#6a9589";
            white = "#c8c093";
          };
          bright = {
            black = "#727169";
            red = "#e82424";
            green = "#98bb6c";
            yellow = "#e6c384";
            blue = "#7fb4ca";
            magenta = "#938aa9";
            cyan = "#7aa89f";
            white = "#dcd7ba";
          };
          selection = {
            background = "#2d4f67";
            foreground = "#c8c093";
          };
          indexed_colors = [
            { index = 16; color = "#ffa066"; }
            { index = 17; color = "#ff5d62"; }
          ];
        };
      };
    };
  };


}

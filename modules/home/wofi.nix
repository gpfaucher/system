{pkgs, ...}: {
  programs.wofi = {
    enable = true;
    settings = {
      fullscreen = true;
      location = "center";
      background-color = "transparent";
      show = "drun";
      prompt = "";
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = false;
      gtk_dark = true;
      hide_scroll = false;
      columns = 1;
      lines = 15;
    };
    style = ''
      @define-color rosewater #f5e0dc;
      @define-color flamingo #f2cdcd;
      @define-color pink #f5c2e7;
      @define-color mauve #cba6f7;
      @define-color red #f38ba8;
      @define-color maroon #eba0ac;
      @define-color peach #fab387;
      @define-color yellow #f9e2af;
      @define-color green #a6e3a1;
      @define-color teal #94e2d5;
      @define-color sky #89dceb;
      @define-color sapphire #74c7ec;
      @define-color blue #89b4fa;
      @define-color lavender #b4befe;
      @define-color text #cdd6f4;
      @define-color subtext1 #bac2de;
      @define-color subtext0 #a6adc8;
      @define-color overlay2 #9399b2;
      @define-color overlay1 #7f849c;
      @define-color overlay0 #6c7086;
      @define-color surface2 #585b70;
      @define-color surface1 #45475a;
      @define-color surface0 #313244;
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;

      * {
          font-family: 'MonaspiceAr Nerd Font Mono', monospace;
          font-size: 15px;
      }

      window {
          margin: 0px;
          padding: 5px;
          border: 0;
          background-color: rgba(30, 30, 46, 0.82);
          color: @text;
      }

      #inner-box {
          margin: 0;
          padding: 0;
          border: none;
          background-color: transparent;
          spacing: 30px;
      }

      #outer-box {
          margin: 0;
          padding: 0;
          border: none;
          background-color: transparent;
      }

      #scroll {
          margin: 0px;
          padding: 20px 0px 0px;
          border: none;
          background-color: transparent;
      }

      #scroll scrollbar {
          width: 4px;
          handle-color: @text;
          background-color: transparent;
      }

      #input {
          margin: 0;
          padding: 1px;
          border: none;
          color: @text;
          background-color: transparent;
          spacing: 0;
      }

      #input:focus {
          outline: none;
          border: none;
      }

      #text {
          margin: 0;
          padding: 5px;
          border: none;
          color: @text;
          background-color: transparent;
      }

      #entry {
          margin: 0;
          padding: 5px;
          border: 0;
          background-color: transparent;
          color: @text;
          spacing: 5px;
      }

      #entry:selected {
          background-color: @text;
          color: @mantle;
        outline: none;
      }

      #entry:selected #text {
          color: @mantle;
          font-weight: normal;
      }

      *:focus {
          outline: none;
      }

      #inner-box > * {
          margin-bottom: 2px;
      }
    '';
  };

  home.packages = with pkgs; [
    wofi
  ];
}

{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
        show_symlink = true;
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
        image_filter = "lanczos3";
      };
      opener = {
        edit = [
          {
            run = "nvim \"$@\"";
            block = true;
            for = "unix";
          }
        ];
        open = [
          {
            run = "xdg-open \"$@\"";
            desc = "Open";
          }
        ];
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = ["g" "h"];
          run = "cd ~";
          desc = "Go home";
        }
        {
          on = ["g" "c"];
          run = "cd ~/.config";
          desc = "Go config";
        }
        {
          on = ["g" "d"];
          run = "cd ~/Downloads";
          desc = "Go downloads";
        }
        {
          on = ["g" "w"];
          run = "cd ~/Work";
          desc = "Go work";
        }
        {
          on = ["g" "s"];
          run = "cd ~/Work/system";
          desc = "Go system config";
        }
        {
          on = ["g" "n"];
          run = "cd ~/Notes";
          desc = "Go notes";
        }
        {
          on = ["<C-n>"];
          run = "shell 'ghostty &' --confirm";
          desc = "Open terminal here";
        }
      ];
    };
  };

  # Image preview dependencies
  home.packages = with pkgs; [
    ueberzugpp
    ffmpegthumbnailer
    poppler
    fd
    ripgrep
    fzf
    jq
    imagemagick
  ];
}

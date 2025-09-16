_: {
  programs.nixvim.plugins.which-key = {
    enable = true;

    # lazyLoad.settings.event = "DeferredUIEnter";

    settings = {
      spec = [
        {
          __unkeyed-1 = "<leader>s";
          group = "Search";
        }
        {
          __unkeyed-1 = "<leader>x";
          group = "Trouble";
        }
        {
          __unkeyed-1 = "<leader>q";
          group = "Quickfix";
        }
        {
          __unkeyed-1 = "<leader>bs";
          group = "󰒺 Sort";
          icon = "";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "Git";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "Find";
        }
        {
          __unkeyed-1 = "<leader>sr";
          group = "Recent Files";
        }
        {
          __unkeyed-1 = "<leader>r";
          group = "Refactor";
          icon = " ";
        }
        {
          __unkeyed-1 = "<leader>u";
          group = "UI/UX";
        }
        {
          __unkeyed-1 = "<leader>gg";
          group = "Git (LazyGit)";
        }
        {
          __unkeyed-1 = "s";
          group = "Flash Jump";
        }
        {
          __unkeyed-1 = "<leader>h";
          group = "Harpoon";
        }
        {
          __unkeyed-1 = "<leader>t";
          group = "Tasks";
        }
        {
          __unkeyed-1 = "<leader>d";
          group = "Diagnostics";
        }
        {
          __unkeyed-1 = "<C-f>";
          group = "Tmux Sessionizer";
        }
        {
          __unkeyed-1 = "<M-h>";
          group = "Tmux Session 0";
        }
        {
          __unkeyed-1 = "<M-t>";
          group = "Tmux Session 1";
        }
        {
          __unkeyed-1 = "<M-n>";
          group = "Tmux Session 2";
        }
        {
          __unkeyed-1 = "<M-s>";
          group = "Tmux Session 3";
        }
      ];

      replace = {
        # key = [
        #   [
        #     "<Space>"
        #     "SPC"
        #   ]
        # ];

        desc = [
          [
            "<space>"
            "SPACE"
          ]
          [
            "<leader>"
            "SPACE"
          ]
          [
            "<[cC][rR]>"
            "RETURN"
          ]
          [
            "<[tT][aA][bB]>"
            "TAB"
          ]
          [
            "<[bB][sS]>"
            "BACKSPACE"
          ]
        ];
      };
      win = {
        border = "single";
      };
    };
  };
}

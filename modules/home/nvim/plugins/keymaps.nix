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
        # Remove Trouble group
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
        { __unkeyed-1 = "<leader>sr"; group = "Recent"; }
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
        { __unkeyed-1 = "s"; group = "Flash"; }
        { __unkeyed-1 = "<leader>h"; group = "Harpoon"; }

        # New: Taskwarrior
        { __unkeyed-1 = "<leader>t"; group = "Tasks"; }
        { __unkeyed-1 = "<leader>tt"; group = "Next"; }
        { __unkeyed-1 = "<leader>ta"; group = "Add"; }
        { __unkeyed-1 = "<leader>td"; group = "Done"; }
        { __unkeyed-1 = "<leader>tp"; group = "Project"; }
        {
          __unkeyed-1 = "<leader>t";
          group = "Tasks";
        }
        {
          __unkeyed-1 = "<leader>d";
          group = "Diagnostics";
        }
        # Remove tmux sessionizer from which-key — key is outside <leader>
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

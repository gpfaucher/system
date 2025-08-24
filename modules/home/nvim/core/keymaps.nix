{
  programs.nixvim.keymaps = [
    {
      action = "<cmd>Telescope find_files<cr>";
      key = "<leader>sf";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Telescope live_grep<cr>";
      key = "<leader>sg";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
      key = "<leader>sb";
      options = {
        silent = true;
      };
    }

    {
      action = "<cmd>Telescope buffers<cr>";
      key = "<leader><space>";
      options = {
        silent = true;
      };
    }

    {
      action = "<cmd>Telescope git_commits<cr>";
      key = "<leader>gc"; # git commits
      options = {
        silent = true;
      };
    }

    {
      action = "<cmd>Telescope help_tags<cr>";
      key = "<leader>sh"; # help help-tags
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Telescope man_pages<cr>";
      key = "<leader>sm"; # help man-pages
      options = {
        silent = true;
      };
    }
  ];
}

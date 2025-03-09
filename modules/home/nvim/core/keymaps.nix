_ :
{
  programs.nixvim.keymaps = [
    {
      action = "<cmd>Neotree find_files<cr>";
      key = "<leader>e";
      options = {
        silent = true;
      };
    }
    # Telescope.nvim
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
      action = "<cmd>Telescope buffers<cr>";
      key = "<leader><space>";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Telescope git_commits<cr>";
      key = "<leader>sc";
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
      action = "<cmd>Telescope help_tags<cr>";
      key = "<leader>sh";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Telescope man_pages<cr>";
      key = "<leader>sm";
      options = {
        silent = true;
      };
    }
    {
      action = "<cmd>Telescope quickfix<cr>";
      key = "<leader>sq";
      options = {
        silent = true;
      };
    }
  ];
}

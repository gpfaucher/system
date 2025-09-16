_: {
  programs.nixvim = {
    plugins = {
      oil.enable = true;
      nvim-tree.enable = true;
    };
    keymaps = [
      {
        action = "<cmd>NvimTreeToggle<cr>";
        key = "<leader>e";
        options = {
          silent = true;
        };
      }
      {
        action = "<cmd>Oil --float<cr>";
        key = "<leader>f";
        options = {
          silent = true;
        };
      }
    ];
  };
}

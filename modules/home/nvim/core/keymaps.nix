_ :
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
  ];
}

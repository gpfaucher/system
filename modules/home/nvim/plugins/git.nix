_: {
  programs.nixvim = {
    plugins = {
      lazygit = {
        enable = true;
      };
    };
    keymaps = [
      {
        action = "<cmd>LazyGit <cr>";
        key = "<leader>gl";
      }
    ];
  };
}

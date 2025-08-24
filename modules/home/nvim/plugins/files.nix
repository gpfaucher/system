_: {
  programs.nixvim = {
    plugins = {
      oil = {
        enable = true;
      };
    };
    keymaps = [
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

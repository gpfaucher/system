_: {
  programs.nixvim = {
    globals.mapleader = " ";
    colorschemes.oxocarbon.enable = true;
    opts = {
      number = true;
      relativenumber = true;
      mouse = "a";
      clipboard = "unnamedplus";
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 500;
      splitright = true;
      splitbelow = true;
      list = true;
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
      showmode = false;
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      ruler = true;
      autoindent = true;
      smartindent = true;
    };
  };
}

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
      timeoutlen = 300; # Faster for home row mods (was 500)
      ttimeoutlen = 10; # Fast key code timeout
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
      virtualedit = "block"; # Allow cursor beyond line end in visual block
      hlsearch = true;
      incsearch = true;
    };
  };
}

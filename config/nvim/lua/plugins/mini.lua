return {
  'echasnovski/mini.nvim',
  version = '*',
  config = function()
    require('mini.starter').setup();
    require('mini.pairs').setup();
    -- require('mini.statusline').setup();
  end
}

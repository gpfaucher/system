-- Editor Options
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.showmode = false
opt.wrap = false
opt.linebreak = true

-- Scrolling
opt.scrolloff = 10
opt.sidescrolloff = 8

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Clipboard
opt.clipboard = "unnamedplus"

-- Timeouts (fast for home row mods)
opt.timeout = true
opt.timeoutlen = 300
opt.ttimeoutlen = 10
opt.updatetime = 250

-- Undo
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10

-- Misc
opt.mouse = "a"
opt.hidden = true
opt.iskeyword:append("-")
opt.shortmess:append("c")
opt.whichwrap:append("<,>,[,],h,l")
opt.fillchars = { eob = " " }

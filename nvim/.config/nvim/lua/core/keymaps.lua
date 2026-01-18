-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Exit insert mode
map("i", "jk", "<Esc>", opts)

-- Save
map({ "n", "i", "v" }, "<C-s>", "<Cmd>w<CR><Esc>", { desc = "Save file" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Buffer navigation
map("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Centered scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next search centered" })
map("n", "N", "Nzzzv", { desc = "Prev search centered" })

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Clear search highlight
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", opts)

-- Resize windows
map("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase height" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease height" })
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- Keep cursor centered when joining lines
map("n", "J", "mzJ`z", opts)

-- Paste without losing register
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yank" })

-- Quickfix navigation
map("n", "<leader>cn", "<Cmd>cnext<CR>zz", { desc = "Next quickfix" })
map("n", "<leader>cp", "<Cmd>cprev<CR>zz", { desc = "Prev quickfix" })

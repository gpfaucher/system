# System Architecture Overhaul — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate from Hyprland + nvf + Zellij to KDE Plasma 6 + pure Lua Neovim + tmux, with improved Bluetooth and Flatpak for Teams/Zoom.

**Architecture:** NixOS (nixos-unstable) stays as the base. KDE Plasma 6 Wayland replaces Hyprland for reliable monitor hotplugging and display profiles. Neovim moves from nvf (Lua-in-Nix-strings) to pure Lua config with lazy.nvim managed by `mkOutOfStoreSymlink`. tmux replaces Zellij for persistent sessions. Teams/Zoom move to Flatpak via nix-flatpak.

**Tech Stack:** NixOS, KDE Plasma 6, plasma-manager, nix-flatpak, tmux, Neovim + lazy.nvim, PipeWire/WirePlumber, Stylix (Ayu Dark)

**Reference:** Design doc at `docs/plans/2026-03-04-system-architecture-design.md`

---

## Task 1: Bluetooth Tuning

**Files:**
- Modify: `modules/system/audio.nix:82-93` (WirePlumber bluez config)
- Modify: `modules/system/audio.nix:203-209` (Bluetooth settings)

**Step 1: Add native HFP backend to WirePlumber config**

In `modules/system/audio.nix`, add `"bluez5.hfphsp-backend"` to the existing `"10-bluez"` config block:

```nix
# In "10-bluez" section, add to "monitor.bluez.properties":
"bluez5.hfphsp-backend" = "native";
```

This goes inside the existing `"monitor.bluez.properties"` attrset at line 83, alongside the existing `bluez5.enable-sbc-xq`, `bluez5.enable-msbc`, etc.

**Step 2: Rebuild and verify**

```bash
sudo nixos-rebuild switch --flake .
```

Expected: builds successfully, no errors.

**Step 3: Verify Bluetooth config applied**

```bash
# Check WirePlumber picked up the config
wpctl status
# Check Bose headphones still connect and play audio
pactl list cards | grep -A5 "bluez_card"
```

Expected: Bose QC Ultra 2 HP shows active profile `a2dp-sink`.

**Step 4: Manual step — disable multipoint on Bose**

Open the Bose Music app on your phone → Settings → Multipoint → disable.
This cannot be automated — it is a headphone firmware setting.

**Step 5: Test a call**

Join a Teams/Zoom test call. Verify:
- Audio output works (A2DP → headphones)
- Mic works (auto-switch to HFP/mSBC)
- No buzzing after profile switch
- Disconnect/reconnect is clean

**Step 6: Commit**

```bash
git add modules/system/audio.nix
git commit -m "fix: add native HFP backend for Bluetooth, reduce profile switching issues"
```

---

## Task 2: Add nix-flatpak Flake Input

**Files:**
- Modify: `flake.nix:4-47` (inputs section)

**Step 1: Add nix-flatpak input**

In `flake.nix`, add after the `pre-commit-hooks` input:

```nix
nix-flatpak.url = "github:gmodena/nix-flatpak";
```

**Step 2: Add to outputs function parameters**

In `flake.nix` line 51, add `nix-flatpak` to the destructured inputs:

```nix
{
  self,
  nixpkgs,
  home-manager,
  nvf,
  stylix,
  ghostty,
  agenix,
  zen-browser,
  opencode,
  treefmt-nix,
  pre-commit-hooks,
  nix-flatpak,
  ...
}@inputs:
```

**Step 3: Add nix-flatpak NixOS module**

In `flake.nix`, add `nix-flatpak.nixosModules.nix-flatpak` to the modules list (after `agenix.nixosModules.default` at line 82):

```nix
nix-flatpak.nixosModules.nix-flatpak
```

**Step 4: Verify flake evaluates**

```bash
nix flake check --no-build
```

Expected: no errors.

**Step 5: Commit**

```bash
git add flake.nix
git commit -m "feat: add nix-flatpak flake input for declarative Flatpak management"
```

---

## Task 3: Configure Flatpak for Teams and Zoom

**Files:**
- Create: `modules/system/flatpak.nix`
- Modify: `hosts/laptop/default.nix:10-26` (imports)
- Modify: `modules/home/default.nix:123-125` (remove zoom-us, teams-for-linux packages)

**Step 1: Create the Flatpak module**

Create `modules/system/flatpak.nix`:

```nix
{ pkgs, ... }:

{
  # Flatpak for apps that fight with NixOS FHS paths
  services.flatpak = {
    enable = true;

    # Declarative package list (managed by nix-flatpak)
    packages = [
      "us.zoom.Zoom"
      "com.github.nickvergessen.teams-for-linux"
    ];

    # Update on rebuild
    update.onActivation = true;

    # Weekly auto-update
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    # Remove Flatpaks not declared here
    uninstallUnmanaged = false;
  };
}
```

**Step 2: Import Flatpak module in laptop host**

In `hosts/laptop/default.nix`, add to imports:

```nix
../../modules/system/flatpak.nix
```

**Step 3: Remove zoom-us and teams-for-linux from home packages**

In `modules/home/default.nix`, remove these two lines from `home.packages`:

```nix
zoom-us # Video conferencing
teams-for-linux
```

**Step 4: Rebuild**

```bash
sudo nixos-rebuild switch --flake .
```

Expected: builds successfully. Flatpak runtime downloads on first activation (needs internet).

**Step 5: Verify Flatpak apps installed**

```bash
flatpak list
```

Expected: Shows `us.zoom.Zoom` and `com.github.nickvergessen.teams-for-linux`.

**Step 6: Launch Teams and Zoom, verify they work**

```bash
flatpak run com.github.nickvergessen.teams-for-linux
flatpak run us.zoom.Zoom
```

Expected: both launch. Test screen sharing and audio.

**Step 7: Commit**

```bash
git add modules/system/flatpak.nix hosts/laptop/default.nix modules/home/default.nix
git commit -m "feat: move Teams and Zoom to Flatpak for FHS compatibility"
```

---

## Task 4: Configure tmux

**Files:**
- Create: `modules/home/tmux.nix`
- Modify: `modules/home/default.nix:11-22` (imports — add tmux, keep zellij for now)
- Modify: `modules/home/default.nix:171` (remove tmux from home.packages since it's now managed)

**Step 1: Create tmux module**

Create `modules/home/tmux.nix`:

```nix
{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    keyMode = "vi";
    prefix = "C-a";
    escapeTime = 10;
    baseIndex = 1;
    historyLimit = 50000;
    mouse = true;
    sensibleOnTop = true;
    focusEvents = true;

    plugins = with pkgs.tmuxPlugins; [
      # Seamless Ctrl+hjkl between Neovim and tmux panes
      vim-tmux-navigator

      # Session persistence across reboots
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }

      # Auto-save sessions (must come after resurrect)
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      # True color support for Neovim
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",xterm-ghostty:RGB"

      # Ayu Dark status bar colors
      set -g status-style "bg=#0b0e14,fg=#e6e1cf"
      set -g status-left "#[fg=#59c2ff,bold] #S "
      set -g status-right "#[fg=#e6e1cf]%H:%M "
      set -g status-left-length 20
      set -g window-status-current-style "fg=#aad94c,bold"
      set -g window-status-style "fg=#565b66"
      set -g pane-border-style "fg=#1c2029"
      set -g pane-active-border-style "fg=#59c2ff"
      set -g message-style "bg=#0b0e14,fg=#e6e1cf"

      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # New windows in current path
      bind c new-window -c "#{pane_current_path}"

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # Resize panes with vim keys
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Undercurl support (for Neovim diagnostics)
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';
  };
}
```

**Step 2: Import tmux module in home-manager**

In `modules/home/default.nix`, add to imports:

```nix
./tmux.nix
```

**Step 3: Remove tmux from home.packages**

In `modules/home/default.nix`, remove:

```nix
tmux # Terminal multiplexer
```

(It's now managed by `programs.tmux`.)

**Step 4: Rebuild and verify**

```bash
sudo nixos-rebuild switch --flake .
tmux new -s test
```

Expected: tmux starts with Ayu Dark colors, fish shell, Ctrl+a prefix.

**Step 5: Verify vim-tmux-navigator works**

Open Neovim in a tmux pane, split, and test Ctrl+hjkl navigation between panes.

**Step 6: Verify session persistence**

```bash
# Detach from tmux
# Close terminal
# Open new terminal
tmux attach -t test
```

Expected: session is restored.

**Step 7: Commit**

```bash
git add modules/home/tmux.nix modules/home/default.nix
git commit -m "feat: add tmux config with Ayu Dark theme, vim-tmux-navigator, session persistence"
```

---

## Task 5: Create Neovim Lua Config Structure

**Files:**
- Create: `modules/home/nvim/default.nix` (new — Nix module for deps + symlink)
- Create: `modules/home/nvim/config/init.lua`
- Create: `modules/home/nvim/config/lua/config/options.lua`
- Create: `modules/home/nvim/config/lua/config/keymaps.lua`
- Create: `modules/home/nvim/config/lua/config/autocmds.lua`

This task creates the skeleton. Subsequent tasks fill in plugins.

**Step 1: Create the Nix module**

Create `modules/home/nvim/default.nix` (this replaces the nvf import):

```nix
{
  pkgs,
  config,
  inputs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-unwrapped;
    vimAlias = true;
    viAlias = true;

    extraPackages = with pkgs; [
      # LSP servers
      nil # Nix
      lua-language-server
      basedpyright # Python
      nodePackages.typescript-language-server
      rust-analyzer
      gopls
      terraform-ls

      # Formatters
      nixfmt-rfc-style
      nodePackages.prettier
      stylua
      shfmt
      ruff

      # Tools needed by plugins
      ripgrep
      fd
      gcc # treesitter compilation
      tree-sitter
    ];
  };

  # Symlink Lua config from flake repo (writable — instant iteration)
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/projects/system/modules/home/nvim/config";
}
```

**Step 2: Create init.lua**

Create `modules/home/nvim/config/init.lua`:

```lua
-- Set leader before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core config
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/ directory
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = { lazy = true },
  install = { colorscheme = { "base16-ayu-dark" } },
  checker = { enabled = false }, -- don't auto-check for updates
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

**Step 3: Create options.lua**

Create `modules/home/nvim/config/lua/config/options.lua`:

```lua
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
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

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.wrap = false
opt.showmode = false

-- Mouse
opt.mouse = "a"

-- Clipboard
opt.clipboard = "unnamedplus"

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Undo
opt.undofile = true
opt.undolevels = 10000

-- Whitespace display
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Misc
opt.confirm = true
opt.conceallevel = 2
```

**Step 4: Create keymaps.lua**

Create `modules/home/nvim/config/lua/config/keymaps.lua`:

```lua
local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window resize
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Save
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear highlights" })

-- Centered movements
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next search centered" })
map("n", "N", "Nzzzv", { desc = "Prev search centered" })

-- Quickfix
map("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<cr>zz", { desc = "Prev quickfix" })
map("n", "<leader>qq", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines in visual mode
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move lines down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move lines up" })

-- Format
map("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file" })
```

**Step 5: Create autocmds.lua**

Create `modules/home/nvim/config/lua/config/autocmds.lua`:

```lua
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Resize splits on window resize
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
  group = augroup("last_loc", { clear = true }),
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Markdown settings
autocmd("FileType", {
  group = augroup("markdown_settings", { clear = true }),
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = false
    vim.opt_local.conceallevel = 2
  end,
})
```

**Step 6: Verify directory structure**

```bash
find modules/home/nvim/config -type f | sort
```

Expected:
```
modules/home/nvim/config/init.lua
modules/home/nvim/config/lua/config/autocmds.lua
modules/home/nvim/config/lua/config/keymaps.lua
modules/home/nvim/config/lua/config/options.lua
```

**Step 7: Commit**

```bash
git add modules/home/nvim/config/ modules/home/nvim/default.nix
git commit -m "feat: create Neovim pure Lua config skeleton with options, keymaps, autocmds"
```

---

## Task 6: Create Neovim Plugin Configs (Core)

**Files:**
- Create: `modules/home/nvim/config/lua/plugins/ui.lua`
- Create: `modules/home/nvim/config/lua/plugins/editor.lua`
- Create: `modules/home/nvim/config/lua/plugins/telescope.lua`
- Create: `modules/home/nvim/config/lua/plugins/treesitter.lua`

**Step 1: Create ui.lua (theme + statusline)**

Create `modules/home/nvim/config/lua/plugins/ui.lua`:

```lua
return {
  -- Base16 Ayu Dark theme (matches Stylix)
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("base16-ayu-dark")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "base16",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>g", group = "git" },
        { "<leader>G", group = "git hunks" },
        { "<leader>n", group = "notes" },
        { "<leader>o", group = "opencode" },
        { "<leader>q", group = "quickfix" },
        { "<leader>s", group = "search" },
      })
    end,
  },
}
```

**Step 2: Create editor.lua (oil, harpoon, flash, autopairs)**

Create `modules/home/nvim/config/lua/plugins/editor.lua`:

```lua
return {
  -- Oil file browser
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>f", "<cmd>Oil<cr>", desc = "Open file browser" },
    },
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
    },
  },

  -- Harpoon 2 (quick file jumping)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- Flash (jump motions)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash jump" },
      { "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash treesitter" },
      { "r", function() require("flash").remote() end, mode = "o", desc = "Flash remote" },
    },
    opts = {},
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- vim-tmux-navigator (seamless pane navigation)
  {
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
  },
}
```

**Step 3: Create telescope.lua**

Create `modules/home/nvim/config/lua/plugins/telescope.lua`:

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", "*.lock" },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob", "!.git/",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },
}
```

**Step 4: Create treesitter.lua**

Create `modules/home/nvim/config/lua/plugins/treesitter.lua`:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "javascript", "typescript", "tsx",
          "python", "rust", "go",
          "nix", "terraform", "hcl",
          "json", "yaml", "toml",
          "html", "css", "markdown", "markdown_inline",
          "bash", "fish", "dockerfile",
          "gitcommit", "gitignore", "diff",
        },
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_prev_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = { ["<leader>a"] = "@parameter.inner" },
            swap_previous = { ["<leader>A"] = "@parameter.inner" },
          },
        },
      })
    end,
  },
}
```

**Step 5: Commit**

```bash
git add modules/home/nvim/config/lua/plugins/
git commit -m "feat: add core Neovim plugins — theme, editor, telescope, treesitter"
```

---

## Task 7: Create Neovim Plugin Configs (LSP, Completion, Formatting, Git)

**Files:**
- Create: `modules/home/nvim/config/lua/plugins/lsp.lua`
- Create: `modules/home/nvim/config/lua/plugins/completion.lua`
- Create: `modules/home/nvim/config/lua/plugins/formatting.lua`
- Create: `modules/home/nvim/config/lua/plugins/git.lua`

**Step 1: Create lsp.lua**

Create `modules/home/nvim/config/lua/plugins/lsp.lua`:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require("lspconfig")

      -- Shared on_attach
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gr", vim.lsp.buf.references, "Go to references")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gy", vim.lsp.buf.type_definition, "Go to type definition")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<leader>r", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")

        -- Visual mode code action
        vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
      end

      -- Diagnostics config
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = true },
      })

      -- Diagnostic keymaps
      vim.keymap.set("n", "<leader>dn", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>dp", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
      vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Float diagnostic" })

      -- Server configs (all binaries provided by Nix on PATH)
      local servers = {
        nil_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        basedpyright = {},
        ts_ls = {},
        rust_analyzer = {},
        gopls = {},
        terraformls = {},
      }

      for server, config in pairs(servers) do
        config.on_attach = on_attach
        lspconfig[server].setup(config)
      end
    end,
  },

  -- Trouble (diagnostics list)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
    },
    opts = {},
  },
}
```

**Step 2: Create completion.lua**

Create `modules/home/nvim/config/lua/plugins/completion.lua`:

```lua
return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    version = "*",
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
      completion = {
        documentation = {
          auto_show = true,
          window = { border = "rounded" },
        },
      },
    },
  },
}
```

**Step 3: Create formatting.lua**

Create `modules/home/nvim/config/lua/plugins/formatting.lua`:

```lua
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        python = { "ruff_organize_imports", "ruff_format" },
        nix = { "nixfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        lua = { "stylua" },
        go = { "gofmt" },
        rust = { "rustfmt" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
  },
}
```

**Step 4: Create git.lua**

Create `modules/home/nvim/config/lua/plugins/git.lua`:

```lua
return {
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Prev hunk")

        -- Actions
        map("n", "<leader>Gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>Gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>Gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
        map("v", "<leader>Gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
        map("n", "<leader>GS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>Gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>Gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>Gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>Gd", gs.diffthis, "Diff this")
        map("n", "<leader>Gt", gs.toggle_deleted, "Toggle deleted")
      end,
    },
  },

  -- Lazygit
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
```

**Step 5: Commit**

```bash
git add modules/home/nvim/config/lua/plugins/
git commit -m "feat: add Neovim LSP, completion, formatting, and git plugins"
```

---

## Task 8: Create Neovim Plugin Configs (AI, Markdown, Debug)

**Files:**
- Create: `modules/home/nvim/config/lua/plugins/ai.lua`
- Create: `modules/home/nvim/config/lua/plugins/markdown.lua`
- Create: `modules/home/nvim/config/lua/plugins/debug.lua`

**Step 1: Create ai.lua**

Create `modules/home/nvim/config/lua/plugins/ai.lua`:

```lua
return {
  -- OpenCode.nvim
  {
    "nickjvandyke/opencode.nvim",
    keys = {
      { "<leader>oo", function() require("opencode").menu() end, desc = "OpenCode menu" },
      { "<leader>oa", function() require("opencode").ask() end, desc = "OpenCode ask" },
      { "<leader>oe", function() require("opencode").explain() end, desc = "OpenCode explain" },
      { "<leader>or", function() require("opencode").review() end, desc = "OpenCode review" },
      { "<leader>of", function() require("opencode").fix() end, desc = "OpenCode fix" },
      { "<leader>ot", function() require("opencode").test() end, desc = "OpenCode test" },
      { "<leader>oi", function() require("opencode").implement() end, desc = "OpenCode implement" },
      { "<leader>op", function() require("opencode").optimize() end, desc = "OpenCode optimize" },
      { "<leader>oc", function() require("opencode").document() end, desc = "OpenCode document" },
      { "<leader>od", function() require("opencode").diagnostics() end, desc = "OpenCode diagnostics" },
      { "<leader>og", function() require("opencode").git_diff_review() end, desc = "OpenCode git diff" },
    },
    dependencies = { "folke/snacks.nvim" },
    opts = {},
  },

  -- Claude Code integration (MCP-based)
  {
    "coder/claudecode.nvim",
    keys = {
      { "<leader>cc", "<cmd>ClaudeCodeStart<cr>", desc = "Claude Code start" },
    },
    opts = {},
  },
}
```

**Step 2: Create markdown.lua**

Create `modules/home/nvim/config/lua/plugins/markdown.lua`:

```lua
return {
  -- Markdown inline editing
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    opts = {
      mappings = {
        inline_surround_toggle = "gs",
        inline_surround_toggle_line = "gss",
        inline_surround_delete = "ds",
        inline_surround_change = "cs",
        link_add = "gl",
        link_follow = "gx",
        go_curr_heading = "]c",
        go_parent_heading = "]p",
        go_next_heading = "]]",
        go_prev_heading = "[[",
      },
      on_attach = function(bufnr)
        local map = vim.keymap.set
        map("n", "<leader>mc", function()
          local line = vim.api.nvim_get_current_line()
          local new_line
          if line:match("%- %[x%]") then
            new_line = line:gsub("%- %[x%]", "- [ ]")
          elseif line:match("%- %[ %]") then
            new_line = line:gsub("%- %[ %]", "- [x]")
          else
            return
          end
          vim.api.nvim_set_current_line(new_line)
        end, { buffer = bufnr, desc = "Toggle checkbox" })
      end,
    },
  },

  -- Table mode
  {
    "dhruvasagar/vim-table-mode",
    ft = "markdown",
    keys = {
      { "<leader>mt", "<cmd>TableModeToggle<cr>", desc = "Toggle table mode" },
    },
    init = function()
      vim.g.table_mode_corner = "|"
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && npx --yes yarn install",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" },
    },
  },

  -- Render markdown beautifully
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      },
      checkbox = {
        unchecked = { icon = "☐ " },
        checked = { icon = "☑ " },
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
    },
  },
}
```

**Step 3: Create debug.lua**

Create `modules/home/nvim/config/lua/plugins/debug.lua`:

```lua
return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug step out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    },
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap, dapui = require("dap"), require("dapui")
          dapui.setup()
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
    },
  },
}
```

**Step 4: Commit**

```bash
git add modules/home/nvim/config/lua/plugins/
git commit -m "feat: add Neovim AI, markdown, and debug plugins"
```

---

## Task 9: Switch Home-Manager from nvf to Pure Lua Neovim

**Files:**
- Modify: `modules/home/default.nix:11-22` (replace `./nvf` import with `./nvim`)
- Modify: `modules/home/default.nix:120-170` (clean up packages already in neovim extraPackages)
- Modify: `modules/home/theme.nix:30` (disable nvf neovim Stylix target)

**Step 1: Replace nvf import with nvim import**

In `modules/home/default.nix`, change line 12:

```nix
# Old:
./nvf
# New:
./nvim
```

**Step 2: Remove duplicate packages from home.packages**

In `modules/home/default.nix`, remove these from `home.packages` since they're now in `programs.neovim.extraPackages`:

```nix
nixd # Nix language server — replaced by nil in nvim/default.nix
fd # For telescope find_files — now in extraPackages
ripgrep # For telescope live_grep — now in extraPackages
gcc — now in extraPackages
tree-sitter — now in extraPackages
```

Keep `claude-code` and the `opencode` override in home.packages — those are standalone CLI tools, not Neovim deps.

**Step 3: Update Stylix theme targets**

In `modules/home/theme.nix`, change:

```nix
# The base16-nvim plugin handles theming now, not Stylix's nvf integration
neovim.enable = false;
```

Also update:
```nix
# Remove Hyprland/Dunst targets (will be replaced by KDE in a later task)
dunst.enable = false;
hyprland.enable = false;
```

**Step 4: Rebuild and test**

```bash
sudo nixos-rebuild switch --flake .
nvim
```

Expected: Neovim opens with Ayu Dark theme, lazy.nvim bootstraps and installs plugins on first launch.

**Step 5: Verify LSP works**

Open a `.nix` file — nil_ls should attach. Open a `.lua` file — lua_ls should attach. Check with `:LspInfo`.

**Step 6: Verify keybindings work**

Test: `<leader>sf` (telescope find files), `<leader>sg` (live grep), `s` (flash jump), `<leader>f` (oil).

**Step 7: Commit**

```bash
git add modules/home/default.nix modules/home/theme.nix
git commit -m "feat: switch from nvf to pure Lua Neovim config with lazy.nvim"
```

---

## Task 10: Add plasma-manager Flake Input

**Files:**
- Modify: `flake.nix` (add plasma-manager input + home-manager shared module)

**Step 1: Add plasma-manager input**

In `flake.nix` inputs, add:

```nix
plasma-manager = {
  url = "github:nix-community/plasma-manager";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

**Step 2: Add to outputs function parameters**

Add `plasma-manager` to the destructured inputs.

**Step 3: Add plasma-manager to home-manager shared modules**

In `flake.nix`, add to `sharedModules` (line 92-95):

```nix
sharedModules = [
  inputs.nvf.homeManagerModules.default  # keep for now, remove in cleanup
  inputs.stylix.homeModules.stylix
  inputs.plasma-manager.homeManagerModules.plasma-manager
];
```

Note: the nvf shared module can be removed after verifying the pure Lua config works. Keep it for now to allow rollback.

**Step 4: Verify flake evaluates**

```bash
nix flake check --no-build
```

**Step 5: Commit**

```bash
git add flake.nix
git commit -m "feat: add plasma-manager flake input for declarative KDE config"
```

---

## Task 11: Create KDE Plasma 6 System Module

**Files:**
- Create: `modules/system/kde.nix`
- Modify: `hosts/laptop/default.nix` (add KDE import, keep Hyprland for now)

**Step 1: Create KDE system module**

Create `modules/system/kde.nix`:

```nix
{ pkgs, ... }:

{
  # KDE Plasma 6 Wayland
  services.desktopManager.plasma6.enable = true;

  # SDDM display manager (KDE's native DM)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # X server needed for XWayland
  services.xserver.enable = true;

  # Wayland environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Polonium tiling extension
  environment.systemPackages = with pkgs; [
    kdePackages.polonium
  ];

  # Exclude unnecessary KDE apps (we use our own tools)
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole # using Ghostty
    kate # using Neovim
    elisa # not needed
    gwenview # using imv
    okular # using zathura
    plasma-browser-integration # not needed
  ];
}
```

**Step 2: Add KDE import to laptop host**

In `hosts/laptop/default.nix`, add to imports:

```nix
../../modules/system/kde.nix
```

**Step 3: Comment out Hyprland import (don't remove yet)**

In `hosts/laptop/default.nix`, comment out:

```nix
# ../../modules/system/hyprland.nix  # TODO: remove after KDE is verified
```

**Step 4: Disable greetd (conflicts with SDDM)**

Since the Hyprland module enables greetd, commenting it out will disable greetd. SDDM takes over as the display manager. If greetd is enabled elsewhere, explicitly disable it.

**Step 5: Rebuild**

```bash
sudo nixos-rebuild switch --flake .
```

Expected: builds successfully. After reboot, SDDM login screen appears with Plasma Wayland session.

**Step 6: Log in and verify KDE works**

- Log in to Plasma Wayland session
- Open Ghostty terminal
- Verify monitor detection (System Settings > Display)
- Verify audio works (System Settings > Audio)

**Step 7: Commit**

```bash
git add modules/system/kde.nix hosts/laptop/default.nix
git commit -m "feat: add KDE Plasma 6 Wayland as desktop environment"
```

---

## Task 12: Configure KDE Theming and Keybindings via plasma-manager

**Files:**
- Create: `modules/home/kde.nix`
- Modify: `modules/home/default.nix` (add KDE import, remove Hyprland imports)
- Modify: `modules/home/theme.nix` (disable Stylix KDE/Qt targets to avoid startup bug)

**Step 1: Create KDE home-manager module**

Create `modules/home/kde.nix`:

```nix
{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor.theme = "breeze_cursors";
      cursor.size = 24;
      iconTheme = "breeze-dark";
    };

    panels = [
      {
        location = "top";
        height = 36;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            name = "org.kde.plasma.taskmanager";
            config.General = {
              launchers = [];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    # Custom keybindings matching Hyprland muscle memory
    hotkeys.commands = {
      "launch-terminal" = {
        key = "Meta+Return";
        command = "ghostty";
      };
      "launch-nmtui" = {
        key = "Meta+N";
        command = "ghostty -e nmtui";
      };
      "launch-btop" = {
        key = "Meta+O";
        command = "ghostty -e btop";
      };
      "launch-pulsemixer" = {
        key = "Meta+A";
        command = "ghostty -e pulsemixer";
      };
      "launch-lazygit" = {
        key = "Meta+G";
        command = "ghostty -e lazygit";
      };
      "launch-yazi" = {
        key = "Meta+E";
        command = "ghostty -e yazi";
      };
      "launch-bluetuith" = {
        key = "Meta+X";
        command = "ghostty -e bluetuith";
      };
    };

    shortcuts = {
      kwin = {
        "Window Close" = "Meta+Q";
        "Window Fullscreen" = "Meta+F";
        "Window Minimize" = "Meta+M";
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";
        "Switch to Desktop 6" = "Meta+6";
        "Switch to Desktop 7" = "Meta+7";
        "Switch to Desktop 8" = "Meta+8";
        "Switch to Desktop 9" = "Meta+9";
      };
      "org.kde.krunner.desktop"."_launch" = "Meta+D";
      ksmserver."Lock Session" = "Meta+Shift+L";
    };

    kwin = {
      virtualDesktops = {
        rows = 1;
        number = 9;
      };
    };

    # Ayu Dark colors via configFile (for values Stylix can't set)
    configFile = {
      "kdeglobals"."General"."fixed" = "JetBrainsMono Nerd Font,14,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    };
  };
}
```

**Step 2: Update home-manager imports**

In `modules/home/default.nix`, replace Hyprland imports:

```nix
# Remove these:
# ./hyprland
# ./kanshi.nix

# Add:
./kde.nix
```

Also remove `./zellij.nix` if present (replaced by tmux).

**Step 3: Disable Stylix KDE/Qt targets**

In `modules/home/theme.nix`, ensure:

```nix
targets = {
  # ... existing targets ...
  kde.enable = false;   # avoid startup bug (stylix#1092)
  qt.enable = false;    # plasma-manager handles KDE theming
  dunst.enable = false; # using KDE notifications
  hyprland.enable = false; # no longer using Hyprland
};
```

**Step 4: Update Qt theming**

In `modules/home/default.nix`, update the Qt section to work with KDE:

```nix
# Remove or update the qt block — KDE manages its own Qt theming:
# qt = {
#   enable = true;
#   platformTheme.name = "gtk2";
#   style.name = "gtk2";
# };
```

Replace with:

```nix
qt = {
  enable = true;
  platformTheme.name = "kde";
};
```

**Step 5: Update cursor config**

In `modules/home/default.nix`, remove `hyprcursor.enable = true;` from `pointerCursor`:

```nix
pointerCursor = {
  name = "breeze_cursors";
  package = pkgs.kdePackages.breeze;
  size = 24;
  gtk.enable = true;
};
```

**Step 6: Rebuild and test**

```bash
sudo nixos-rebuild switch --flake .
```

Log out and back in. Verify:
- Top panel appears with correct widgets
- `Meta+Return` opens Ghostty
- `Meta+D` opens KRunner
- `Meta+1-9` switches desktops
- `Meta+Q` closes windows
- Dark theme applied

**Step 7: Commit**

```bash
git add modules/home/kde.nix modules/home/default.nix modules/home/theme.nix
git commit -m "feat: configure KDE theming, keybindings, and panels via plasma-manager"
```

---

## Task 13: Remove Hyprland and Clean Up

**Files:**
- Modify: `hosts/laptop/default.nix` (remove Hyprland import)
- Modify: `flake.nix` (remove nvf from sharedModules after verifying pure Lua works)
- Modify: `modules/home/default.nix` (remove Hyprland-specific packages)
- Delete (or archive): `modules/home/hyprland/` directory
- Delete (or archive): `modules/home/kanshi.nix`
- Delete (or archive): `modules/home/zellij.nix`
- Delete (or archive): `modules/system/hyprland.nix`
- Delete (or archive): `modules/home/nvf/` directory

**Step 1: Remove Hyprland system module import**

In `hosts/laptop/default.nix`, remove the commented-out Hyprland import entirely.

**Step 2: Remove Hyprland-specific packages from home.packages**

In `modules/home/default.nix`, review and remove packages only needed for Hyprland:

```nix
# These are now handled by KDE:
# wl-clipboard — KDE has Klipper
# wf-recorder — keep if you still want it, or use OBS
```

Keep `wl-clipboard` if Neovim's clipboard integration needs it.

**Step 3: Remove nvf from sharedModules**

In `flake.nix`, remove from `sharedModules`:

```nix
inputs.nvf.homeManagerModules.default
```

Optionally remove the `nvf` flake input entirely if nothing else uses it.

**Step 4: Remove Hyprland session variables**

The session variables in `modules/system/hyprland.nix` (`XDG_CURRENT_DESKTOP = "Hyprland"`, etc.) are no longer needed. KDE sets these automatically. Verify `modules/system/kde.nix` has the needed env vars.

**Step 5: Move old configs to archive (optional)**

```bash
mkdir -p archive/
mv modules/home/hyprland/ archive/
mv modules/home/kanshi.nix archive/
mv modules/home/zellij.nix archive/
mv modules/system/hyprland.nix archive/
mv modules/home/nvf/ archive/
```

Or simply `git rm` them if you're confident.

**Step 6: Rebuild and verify everything works**

```bash
sudo nixos-rebuild switch --flake .
```

Test:
- KDE session starts cleanly
- All keybindings work
- Neovim with all plugins works
- tmux sessions persist
- Teams/Zoom via Flatpak work
- Bluetooth audio works
- Monitor hotplugging works (dock/undock)
- Gaming (launch Steam, test a game)

**Step 7: Commit**

```bash
git add -A
git commit -m "chore: remove Hyprland, nvf, Zellij, kanshi — fully migrated to KDE + pure Lua Neovim + tmux"
```

---

## Task 14: Polish — Ayu Dark Consistency Audit

**Files:**
- Modify: `modules/home/kde.nix` (refine colors if needed)
- Modify: `modules/home/tmux.nix` (verify colors match)

**Step 1: Verify Ayu Dark colors are consistent**

Ayu Dark base16 palette reference:
- `base00` (bg): `#0b0e14`
- `base01`: `#131721`
- `base02`: `#202229`
- `base03`: `#3d424d`
- `base04`: `#565b66`
- `base05` (fg): `#e6e1cf`
- `base06`: `#e6e1cf`
- `base07`: `#f3f0e7`
- `base08` (red): `#f07178`
- `base09` (orange): `#ff8f40`
- `base0A` (yellow): `#ffb454`
- `base0B` (green): `#aad94c`
- `base0C` (cyan): `#95e6cb`
- `base0D` (blue): `#59c2ff`
- `base0E` (purple): `#d2a6ff`
- `base0F`: `#e6b673`

**Step 2: Check each component**

Walk through each themed component and verify colors match:
- [ ] KDE panels and window decorations
- [ ] Ghostty terminal
- [ ] tmux status bar
- [ ] Neovim (base16-ayu-dark)
- [ ] Fish shell (Stylix)
- [ ] Flatpak apps (may need theme override)
- [ ] Firefox (userChrome.css)

**Step 3: Adjust any mismatches**

Update the relevant config files for any color inconsistencies found.

**Step 4: Final commit**

```bash
git add -A
git commit -m "style: Ayu Dark consistency audit and color refinements"
```

---

## Verification Checklist

After all tasks are complete, verify each requirement from the design doc:

- [ ] Monitor hotplugging: dock/undock with KDE display profiles
- [ ] Mixed DPI: laptop (3840x2400 @ 2x) + ultrawide (3440x1440 @ 1x)
- [ ] Teams call: join, screen share, audio works via Flatpak
- [ ] Zoom call: join, screen share, audio works via Flatpak
- [ ] Bluetooth: Bose QC Ultra 2 HP connects, A2DP for music, HFP for calls
- [ ] Bluetooth: no buzzing after profile switch (multipoint disabled)
- [ ] Neovim: all plugins load, LSP works, formatting works
- [ ] AI: OpenCode keybindings work in Neovim
- [ ] AI: Claude Code runs in tmux pane alongside Neovim
- [ ] tmux: sessions persist across terminal close/reopen
- [ ] tmux: Ctrl+hjkl navigates between Neovim and tmux panes
- [ ] Gaming: Steam launches, a game runs with NVIDIA offload
- [ ] Theme: Ayu Dark consistent across all components
- [ ] Keybindings: Meta+Return, Meta+D, Meta+Q, etc. all work

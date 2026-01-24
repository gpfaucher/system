# Neovim Markdown Plugins Research Report

## Current Setup
- **Neovim Version**: v0.11.5
- **Status**: No existing neovim configuration found at `~/.config/nvim/`
- **Opportunity**: Clean slate to build an optimized markdown editing workflow

---

## Top 7 Markdown Quality-of-Life Plugins for Neovim

### 1. **obsidian.nvim** ⭐ (5.9k stars)
**Category**: Vault Management & Note-Taking  
**Language**: Lua  
**Minimal Version**: Neovim 0.8.0+

#### Features
- **Wiki-style linking**: `[[note-title]]` with auto-completion
- **Obsidian vault integration**: Full sync with Obsidian app vaults
- **Completion system**: Ultra-fast wiki links, tags, and markdown link completion via `nvim-cmp`
- **Navigation**: Follow links with `gf`, backlinks, link suggestions
- **Daily notes**: Auto-create/open daily, weekly, monthly notes
- **Templates**: Insert templates with variable substitution
- **Renaming**: Rename notes and update all backlinks across vault
- **Image pasting**: Paste images directly from clipboard
- **Search**: `ObsidianSearch` with ripgrep integration
- **UI enhancements**: Syntax highlighting for checkboxes, tags, links

#### Configuration Example
```lua
{
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/personal",
      },
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    daily_notes = {
      folder = "notes/dailies",
      date_format = "%Y-%m-%d",
      template = "daily",
    },
    preferred_link_style = "wiki",
    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
      },
    },
  },
}
```

#### Best For
- Obsidian vault users (best-in-class)
- Knowledge base & wiki management
- Zettelkasten-style note taking
- Multi-vault setups

#### Dependencies
- **Required**: plenary.nvim, ripgrep
- **Recommended**: nvim-cmp (completion), telescope.nvim (search), nvim-treesitter (syntax)

---

### 2. **markdown-preview.nvim** ⭐ (7.7k stars)
**Category**: Preview & Rendering  
**Language**: JavaScript/TypeScript/Vim Script  
**Minimal Version**: Vim 8.1+, Neovim 0.4.0+

#### Features
- **Live preview**: Markdown rendered in browser with synchronized scrolling
- **Math support**: KaTeX for inline and block math equations
- **Diagrams**: Mermaid, PlantUML, Flowchart.js support
- **Charts**: Chart.js integration for data visualization
- **Syntax support**: Task lists, emoji, sequences, table of contents
- **Flexible rendering**: Customizable CSS and highlight styles
- **Auto-refresh**: Real-time updates as you edit
- **Dark/Light theme**: System preference-aware with toggle button

#### Configuration Example
```lua
{
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function() vim.fn["mkdp#util#install"]() end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_theme = "dark"
  end,
}
```

#### Keybindings Example
```lua
vim.keymap.set("n", "<C-s>", "<Plug>MarkdownPreview")
vim.keymap.set("n", "<C-p>", "<Plug>MarkdownPreviewToggle")
```

#### Best For
- Technical documentation
- Blog writing
- Presentations with rendered output
- Math-heavy notes

---

### 3. **telekasten.nvim** ⭐ (1.6k stars)
**Category**: Zettelkasten & Journal Management  
**Language**: Lua  
**Minimal Version**: Neovim 0.6.0+

#### Features
- **Zettelkasten workflow**: Permanent notes with auto-linking
- **Multi-vault support**: Manage multiple separate note collections
- **Journal integration**: Daily, weekly, monthly, quarterly, yearly notes
- **Tag system**: Search and organize by `#tags`, `@tags`, `:tags:`
- **Link navigation**: Search-based with telescope picker for every action
- **Media management**: Image pasting and preview (catimg, viu)
- **Calendar integration**: Visual date picker with calendar-vim
- **Link-based navigation**: Find backlinks, related notes, follow links
- **Aliases**: Keep clean link notation with internal aliases
- **TODOs**: Toggle checkbox status with custom symbols

#### Configuration Example
```lua
{
  "renerocksai/telekasten.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telekasten").setup({
      home = vim.fn.expand("~/zettelkasten"),
      dailies = vim.fn.expand("~/zettelkasten/daily"),
      weeklies = vim.fn.expand("~/zettelkasten/weekly"),
      templates = vim.fn.expand("~/zettelkasten/templates"),
      image_subdir = "img",
      new_note_filename = "uuid-title",
      uuid_type = "uuidgen",
      uuid_sep = "-",
      follow_creates_nonexisting = true,
      auto_tag_enable = true,
      tag_notation = "#tag",
      command_palette_theme = "ivy",
      show_tags_tag = "#taglist",
    })

    -- Add keymaps
    vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>")
    vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
    vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>")
    vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>")
  end,
}
```

#### Best For
- Zettelkasten practitioners
- Journal/Daily log writers
- Researchers with cross-referenced notes
- Structured knowledge management

#### Dependencies
- **Required**: telescope.nvim, plenary.nvim
- **Recommended**: calendar-vim (date picker), telescope-media-files.nvim (image preview)

---

### 4. **neorg** ⭐ (7.2k stars)
**Category**: Advanced Organization & Project Management  
**Language**: Lua  
**Minimal Version**: Neovim 0.10.0+

#### Features
- **Org-mode alternative**: Structured document format (.norg)
- **GTD system**: Built-in Getting Things Done workflow
- **Time tracking**: Pomodoro timers and time management
- **Project management**: Tasks, projects, and goals
- **Slideshows**: Present directly from Neovim
- **Syntax highlighting**: Rich `.norg` format with treesitter
- **Extensible**: Modular plugin architecture
- **Integrated features**: All-in-one organization tool
- **Document generation**: Export to various formats
- **Links**: Bidirectional linking system

#### Configuration Example (Lazy.nvim)
```lua
{
  "nvim-neorg/neorg",
  lazy = false,
  version = "*",
  config = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  init = function()
    vim.g.neorg_embed_external_markdown = true
  end,
}
```

#### Best For
- Comprehensive life organization
- Project tracking (not just notes)
- Time management and GTD
- Advanced org-mode users
- Heavy-weight organization systems

#### Learning Curve
- **Steeper learning curve**: Requires understanding `.norg` format
- **More powerful**: Significantly more features than simple markdown

---

### 5. **vim-table-mode** ⭐ (2.2k stars)
**Category**: Table Creation & Formatting  
**Language**: Vim Script  
**Works With**: Vim 8+, Neovim

#### Features
- **Live table editing**: Type `|` to auto-format tables on the fly
- **Markdown compatibility**: Supports both GitHub and ReST tables
- **Spreadsheet formulas**: `$2 = $1 * 2` style cell formulas
- **Cell manipulation**: Insert/delete rows and columns
- **Text objects**: `i|` and `a|` for vim motions
- **Smart formatting**: Auto-aligns column widths
- **Content-based highlighting**: Color cells by content (yes/no/maybe)
- **Easy activation**: Toggle with `:TableModeToggle`

#### Configuration Example
```lua
{
  "dhruvasagar/vim-table-mode",
  ft = { "markdown" },
  init = function()
    -- Enable for markdown files
    vim.g.table_mode_corner = "|"
    -- Keybindings
    vim.keymap.set("n", "<leader>tm", ":TableModeToggle<CR>")
    vim.keymap.set("n", "<leader>tr", ":TableModeRealign<CR>")
  end,
}
```

#### Example Usage
```
Type this:          Creates this:
| Name | Age |      | Name | Age |
|      |     |  ->  |------|-----|
| John | 30  |      | John | 30  |
```

#### Best For
- Markdown tables (GitHub, documentation)
- Data entry into tables
- Quick table creation
- Light spreadsheet functionality

---

### 6. **markdown.nvim** ⭐ (223 stars, modern)
**Category**: Markdown Editing Tools  
**Language**: Lua  
**Minimal Version**: Neovim 0.10.0+

#### Features
- **Inline styling**: Toggle bold, italic, code, strikethrough
- **Link management**: Add/follow links, URL pasting as links
- **Table of contents**: Auto-generate or display in location list
- **List operations**: Insert items, auto-number, toggle tasks
- **Navigation**: Jump between headings (current, parent, next, prev)
- **Configurable**: Heavily customizable keybindings
- **Treesitter support**: Module for nvim-treesitter integration
- **Emphasis control**: Line-wise and motion-based toggling

#### Configuration Example
```lua
{
  "tadmccorkle/markdown.nvim",
  ft = "markdown",
  opts = {
    mappings = {
      inline_surround_toggle = "gs",
      inline_surround_delete = "ds",
      inline_surround_change = "cs",
      link_add = "gl",
      link_follow = "gx",
      go_curr_heading = "]c",
      go_next_heading = "]]",
    },
    inline_surround = {
      emphasis = { key = "i", txt = "*" },
      strong = { key = "b", txt = "**" },
      strikethrough = { key = "s", txt = "~~" },
      code = { key = "c", txt = "`" },
    },
    toc = {
      markers = { "-" },
      omit_heading = "toc omit heading",
    },
  },
  on_attach = function(bufnr)
    -- Custom keymaps per buffer
    vim.keymap.set("x", "<C-b>", function()
      require("markdown.inline").toggle_emphasis_visual("b")
    end, { buffer = bufnr })
  end,
}
```

#### Best For
- Lightweight markdown editing
- Inline formatting without heavy features
- Vim-style keybinding preference
- Quick markdown operations

---

### 7. **vim-markdown** ⭐ (4.8k stars, traditional)
**Category**: Syntax & Navigation  
**Language**: Vim Script  
**Works With**: Vim 7.4+, Neovim

#### Features
- **Syntax highlighting**: Complete markdown syntax support
- **Folding**: Header-based code folding (customizable)
- **Concealing**: Hide markdown syntax for cleaner display
- **Navigation**: Jump between headers with `]]`, `[[`, `][`, `[]`
- **TOC**: Generate table of contents (`:Toc`, `:Toch`, `:Toct`)
- **Link following**: Follow links with `ge` command
- **Header manipulation**: Increase/decrease header levels
- **Strikethrough**: Optional strikethrough support
- **LaTeX math**: Optional math support
- **Front matter**: YAML, TOML, JSON front matter support

#### Configuration Example
```lua
{
  "preservim/vim-markdown",
  dependencies = { "godlygeek/tabular" },
  ft = "markdown",
  init = function()
    vim.g.vim_markdown_folding_disabled = 0
    vim.g.vim_markdown_folding_level = 1
    vim.g.vim_markdown_conceal = 1
    vim.g.vim_markdown_math = 1
    vim.g.vim_markdown_frontmatter = 1
    vim.g.vim_markdown_strikethrough = 1
    vim.g.vim_markdown_no_default_key_mappings = 0
  end,
}
```

#### Key Mappings
```
]]  - go to next header
[[  - go to previous header
][  - go to next sibling header
[]  - go to previous sibling header
]h  - go to current header
]u  - go to parent header
ge  - follow link for editing
gx  - open URL under cursor
```

#### Best For
- Traditional markdown editing
- Header-focused navigation
- Code folding workflows
- Syntax highlighting without heavy features

---

## Recommended Plugin Combinations for Different Workflows

### 🎯 **Workflow 1: Obsidian Vault User**
```lua
-- Best Stack for Obsidian users
{
  "epwalsh/obsidian.nvim",
  "iamcco/markdown-preview.nvim",
  "dhruvasagar/vim-table-mode",
  "tadmccorkle/markdown.nvim",
}
```
**Why**: Obsidian integration + preview + table support + quick editing

### 📚 **Workflow 2: Zettelkasten Researcher**
```lua
-- Best Stack for knowledge work
{
  "renerocksai/telekasten.nvim",
  "preservim/vim-markdown",
  "dhruvasagar/vim-table-mode",
  "tadmccorkle/markdown.nvim",
}
```
**Why**: Zettelkasten workflow + robust syntax + table management + editing

### 📊 **Workflow 3: Technical Writer/Blogger**
```lua
-- Best Stack for documentation
{
  "iamcco/markdown-preview.nvim",
  "tadmccorkle/markdown.nvim",
  "dhruvasagar/vim-table-mode",
  "preservim/vim-markdown",
}
```
**Why**: Live preview + inline editing + tables + syntax highlighting

### 🚀 **Workflow 4: Advanced Organization (GTD)**
```lua
-- Best Stack for life organization
{
  "nvim-neorg/neorg",
  "iamcco/markdown-preview.nvim",
  "dhruvasagar/vim-table-mode",
}
```
**Why**: Comprehensive org system + preview + table support

### 🎨 **Workflow 5: Lightweight Markdown Only**
```lua
-- Minimal Stack for pure markdown
{
  "tadmccorkle/markdown.nvim",
  "preservim/vim-markdown",
}
```
**Why**: Fast, no overhead, vim-native styling

---

## Plugin Comparison Matrix

| Feature | obsidian.nvim | telekasten.nvim | neorg | markdown-preview | vim-table-mode | markdown.nvim | vim-markdown |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Wiki-style links | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ | ❌ |
| Live preview | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Vault sync | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Table creation | ⚠️ | ⚠️ | ⚠️ | ❌ | ✅ | ⚠️ | ❌ |
| Daily notes | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Header folding | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Inline formatting | ⚠️ | ⚠️ | ✅ | ❌ | ❌ | ✅ | ⚠️ |
| Search/ripgrep | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Math support | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ |
| Time tracking | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Easy setup | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ |

---

## Installation Paths

### For Lazy.nvim Users
```lua
-- Add to ~/.config/nvim/init.lua or plugins directory
require("lazy").setup({
  { "folke/lazy.nvim", ... },
  -- Add your chosen plugins here
})
```

### For Packer.nvim Users
```lua
-- Add to ~/.config/nvim/init.lua
return require('packer').startup(function(use)
  -- Add your chosen plugins here
end)
```

---

## Additional Quality-of-Life Plugins to Consider

### Supporting Plugins
- **nvim-treesitter**: Better syntax highlighting
- **telescope.nvim**: Fuzzy search and picker (used by obsidian, telekasten)
- **plenary.nvim**: Required for obsidian and telekasten
- **nvim-cmp**: Completion engine (pairs with obsidian)
- **which-key.nvim**: Keybinding discovery
- **trouble.nvim**: Diagnostic window (useful with note navigation)
- **mini.nvim**: Lightweight utility functions

### Text Manipulation
- **vim-surround**: Easy surround operations
- **nvim-autopairs**: Auto-closing pairs
- **Comment.nvim**: Quick commenting

---

## Performance Considerations

| Plugin | Load Time | Memory | Dependencies |
|--------|-----------|--------|--------------|
| obsidian.nvim | Medium | Medium | 1 required |
| telekasten.nvim | Medium | Medium | 2 required |
| neorg | High | High | Multiple |
| markdown-preview.nvim | Low | Medium | Node.js required |
| vim-table-mode | Very low | Low | None |
| markdown.nvim | Low | Low | None |
| vim-markdown | Very low | Low | 1 suggested |

---

## Configuration Tips

### Lazy-loading Recommendations
```lua
-- Load markdown plugins on markdown filetype
ft = { "markdown" }

-- Load on specific commands
cmd = { "MarkdownPreview", "Telekasten" }

-- Load on events
event = { "BufReadPre *.md", "BufNewFile *.md" }
```

### Performance Optimization
```lua
-- Disable features you don't use in vim-markdown
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_conceal_code_blocks = 0

-- Limit obsidian search to practical size
search_max_lines = 1000

-- Use lazy-loading to defer heavy plugins
lazy = true
```

---

## Recommended Starting Configuration

For a **balanced, production-ready markdown setup**:

```lua
-- ~/.config/nvim/lua/plugins/markdown.lua
return {
  -- Core markdown tools
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    opts = {
      mappings = {
        inline_surround_toggle = "gs",
        inline_surround_delete = "ds",
        link_follow = "gx",
      },
    },
  },

  -- Traditional markdown features
  {
    "preservim/vim-markdown",
    dependencies = { "godlygeek/tabular" },
    ft = "markdown",
    init = function()
      vim.g.vim_markdown_folding_disabled = 0
      vim.g.vim_markdown_conceal = 1
      vim.g.vim_markdown_math = 1
    end,
  },

  -- Table creation
  {
    "dhruvasagar/vim-table-mode",
    ft = "markdown",
    init = function()
      vim.keymap.set("n", "<leader>tm", ":TableModeToggle<CR>")
    end,
  },

  -- Live preview (optional, load on demand)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
}
```

---

## Summary

### Quick Recommendation Matrix

**Choose plugins based on your primary use case:**

1. **Already using Obsidian?** → `obsidian.nvim` (best integration)
2. **Doing research/Zettelkasten?** → `telekasten.nvim` + `vim-markdown`
3. **Writing technical docs?** → `markdown-preview.nvim` + `markdown.nvim`
4. **Need comprehensive organization?** → `neorg` (if willing to learn)
5. **Just want better markdown editing?** → `markdown.nvim` + `vim-markdown`
6. **Heavy table usage?** → `vim-table-mode` (pairs with any combo)

### Next Steps
1. Choose workflow that matches your use case
2. Install supporting dependencies (treesitter, telescope, etc.)
3. Configure keybindings to match your vim style
4. Test with sample markdown files
5. Iterate and customize as needed


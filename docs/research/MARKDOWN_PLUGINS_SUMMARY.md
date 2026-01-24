# Neovim Markdown Plugins - Executive Summary

## Current Environment

- **Neovim**: v0.11.5 (latest stable)
- **Configuration**: Not yet set up at `~/.config/nvim/`
- **Opportunity**: Fresh start for optimal configuration

---

## Top 7 Recommended Plugins (by category)

### 1️⃣ **obsidian.nvim** (5.9k ⭐)

- **Best for**: Obsidian vault users
- **Key features**: Wiki links `[[...]]`, vault sync, daily notes, completion
- **Setup**: Easy, one dependency (plenary.nvim)
- **Performance**: Medium load, medium memory

### 2️⃣ **markdown-preview.nvim** (7.7k ⭐)

- **Best for**: Live preview, technical docs, math/diagrams
- **Key features**: Browser preview, KaTeX, Mermaid, synchronized scrolling
- **Setup**: Requires Node.js build
- **Performance**: Low load, responsive

### 3️⃣ **telekasten.nvim** (1.6k ⭐)

- **Best for**: Zettelkasten, journaling, research
- **Key features**: Zettelkasten workflow, daily/weekly/monthly notes, calendar
- **Setup**: Moderate, requires telescope.nvim
- **Performance**: Medium load, good with large vaults

### 4️⃣ **neorg** (7.2k ⭐)

- **Best for**: Comprehensive org-mode alternative, GTD, project management
- **Key features**: .norg format, time tracking, slideshows, advanced
- **Setup**: Complex, worth it for power users
- **Performance**: Higher overhead but feature-rich

### 5️⃣ **vim-table-mode** (2.2k ⭐)

- **Best for**: Creating and editing markdown tables
- **Key features**: Live table editing, formulas, auto-align, ReST support
- **Setup**: Very easy, no dependencies
- **Performance**: Negligible impact

### 6️⃣ **markdown.nvim** (223 ⭐, modern)

- **Best for**: Lightweight inline editing, modern Lua implementation
- **Key features**: Bold/italic toggle, list management, navigation, TOC
- **Setup**: Easy, zero dependencies
- **Performance**: Very low load

### 7️⃣ **vim-markdown** (4.8k ⭐)

- **Best for**: Traditional markdown editing, folding, syntax
- **Key features**: Header folding, TOC generation, link navigation, math
- **Setup**: Very easy with tabular dependency
- **Performance**: Very low load

---

## Quick Decision Tree

```
START: "What's my primary markdown workflow?"
│
├─ "I use Obsidian" → obsidian.nvim ✅
│
├─ "I'm a researcher/knowledge worker" → telekasten.nvim + vim-markdown ✅
│
├─ "I write technical docs/blogs" → markdown-preview.nvim + markdown.nvim ✅
│
├─ "I do GTD/advanced organization" → neorg ✅
│
├─ "I mainly work with tables" → vim-table-mode (add to any combo) ✅
│
└─ "Just want basics" → markdown.nvim + vim-markdown ✅
```

---

## Plugin Stacks by Use Case

### 🎯 **Obsidian User**

```
obsidian.nvim + markdown-preview.nvim + vim-table-mode + markdown.nvim
```

Dependencies: plenary.nvim, nvim-cmp (optional), telescope.nvim (optional)

### 📚 **Knowledge Worker / Researcher**

```
telekasten.nvim + vim-markdown + vim-table-mode + markdown.nvim
```

Dependencies: telescope.nvim, plenary.nvim, calendar-vim (optional)

### 📝 **Technical Writer / Blogger**

```
markdown-preview.nvim + markdown.nvim + vim-table-mode + vim-markdown
```

Dependencies: Node.js (for preview), tabular (for markdown)

### 🚀 **Power User / GTD**

```
neorg + markdown-preview.nvim + vim-table-mode
```

Dependencies: nvim-treesitter, plenary.nvim, luarocks

### 🎨 **Minimalist**

```
markdown.nvim + vim-markdown
```

Dependencies: tabular (for markdown plugin)

---

## Feature Comparison at a Glance

| Feature              | obsidian | telekasten | neorg | preview | table-mode | markdown.nvim | vim-markdown |
| -------------------- | :------: | :--------: | :---: | :-----: | :--------: | :-----------: | :----------: |
| Wiki links `[[...]]` |    ✅    |     ✅     |  ⚠️   |   ❌    |     ❌     |      ❌       |      ❌      |
| Live browser preview |    ❌    |     ❌     |  ❌   |   ✅    |     ❌     |      ❌       |      ❌      |
| Vault integration    |    ✅    |     ❌     |  ❌   |   ❌    |     ❌     |      ❌       |      ❌      |
| Markdown tables      |    ⚠️    |     ⚠️     |  ⚠️   |   ❌    |     ✅     |      ⚠️       |      ❌      |
| Daily/Journal        |    ✅    |     ✅     |  ❌   |   ❌    |     ❌     |      ❌       |      ❌      |
| Code folding         |    ❌    |     ❌     |  ❌   |   ❌    |     ❌     |      ❌       |      ✅      |
| Inline editing       |    ⚠️    |     ⚠️     |  ✅   |   ❌    |     ❌     |      ✅       |      ⚠️      |
| Full-text search     |    ✅    |     ✅     |  ⚠️   |   ❌    |     ❌     |      ❌       |      ❌      |
| Math/KaTeX           |    ❌    |     ❌     |  ❌   |   ✅    |     ❌     |      ❌       |      ✅      |
| GTD/Task mgmt        |    ❌    |     ⚠️     |  ✅   |   ❌    |     ❌     |      ⚠️       |      ❌      |

**Legend**: ✅ = Excellent, ⚠️ = Partial support, ❌ = Not available

---

## Setup Complexity vs Features

```
COMPLEXITY ▲
         │
      10 │                           ▲ neorg
         │                          ╱
       8 │                    ▲    ╱
         │              ▲    ╱    ╱
       6 │        ▲    ╱    ╱    ╱
         │   ▲   ╱    ╱    ╱    ╱
       4 │  ╱   ╱    ╱    ╱    ╱ telekasten
         │ ╱   ╱    ╱    ╱    ╱
       2 │╱____╱____╱____╱____╱____ ▶ FEATURES
       0 ┤
          vim-markdown  markdown.nvim  obsidian  preview  neorg
```

---

## Installation Recommendation

### For Fresh Neovim Setup (lazy.nvim)

**Best balanced starting point**:

```lua
-- ~/.config/nvim/lua/plugins/markdown.lua
return {
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
  {
    "preservim/vim-markdown",
    dependencies = { "godlygeek/tabular" },
    ft = "markdown",
    init = function()
      vim.g.vim_markdown_folding_disabled = 0
      vim.g.vim_markdown_conceal = 1
    end,
  },
  {
    "dhruvasagar/vim-table-mode",
    ft = "markdown",
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview" },
    build = "cd app && npm install",
  },
}
```

**Why this combination**:

- ✅ Zero learning curve - just works
- ✅ Good syntax + inline editing + tables + preview
- ✅ Lazy-loaded - minimal startup impact
- ✅ Easy to extend with obsidian.nvim or telekasten.nvim later

---

## Next Steps

1. **Setup Neovim config** at `~/.config/nvim/init.lua`
2. **Choose your plugin manager**: lazy.nvim (recommended)
3. **Add one markdown stack** from above
4. **Install dependencies**: `npm install`, `pip install`, etc.
5. **Test with sample markdown file**
6. **Customize keybindings** to your workflow
7. **Iterate**: Add plugins as needed

---

## Documentation Links

- **Full Research Report**: `/docs/research/neovim-markdown-plugins-research.md`
- **obsidian.nvim**: https://github.com/epwalsh/obsidian.nvim
- **telekasten.nvim**: https://github.com/nvim-telekasten/telekasten.nvim
- **markdown-preview.nvim**: https://github.com/iamcco/markdown-preview.nvim
- **markdown.nvim**: https://github.com/tadmccorkle/markdown.nvim
- **vim-table-mode**: https://github.com/dhruvasagar/vim-table-mode
- **vim-markdown**: https://github.com/preservim/vim-markdown
- **neorg**: https://github.com/nvim-neorg/neorg

---

## Key Takeaways

1. **Best for Obsidian users**: `obsidian.nvim` (5.9k ⭐, production-ready)
2. **Best for knowledge workers**: `telekasten.nvim` + `vim-markdown`
3. **Best for technical writing**: `markdown-preview.nvim` + `markdown.nvim`
4. **Best for power users**: `neorg` (comprehensive)
5. **Best lightweight setup**: `markdown.nvim` + `vim-markdown`
6. **Best table support**: Add `vim-table-mode` to any combo

**Pro tip**: Start with a balanced combo, expand as needed. All plugins are well-maintained and production-ready.

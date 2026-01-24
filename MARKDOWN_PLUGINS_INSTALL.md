# Markdown Plugins Installation Guide

## Status: Configuration Ready ✅

The markdown plugin configuration has been added to your NixOS system configuration.
You just need to rebuild the system to apply the changes.

## Plugins Configured (Option 3 - Lightweight)

1. **markdown.nvim** - Modern inline editing tools
   - Toggle bold/italic with `gs`
   - Link operations with `gl`, `gx`
   - Heading navigation with `]]`, `[[`
   - Checkbox toggle with `<leader>mc`

2. **vim-markdown** - Traditional syntax highlighting and folding
   - Markdown folding enabled
   - Frontmatter support (YAML, TOML, JSON)
   - Math syntax highlighting
   - Concealment enabled

3. **vim-table-mode** - Smart table formatting
   - Toggle table mode: `<leader>mt`
   - Realign table: `<leader>mtr`
   - Convert to table: `<leader>mts`

4. **markdown-preview.nvim** - Live browser preview
   - Toggle preview: `<leader>mp`
   - KaTeX math support
   - Mermaid diagrams support
   - Dark theme by default

## Installation Steps

### 1. Rebuild the NixOS System

Run the rebuild script:

```bash
cd ~/projects/system
./scripts/rebuild.sh
```

You will be prompted for your sudo password. This will:

- Build the new system configuration
- Install all markdown plugins via Nix
- Update your Neovim setup

### 2. Verify Installation

After rebuild completes, check if plugins are installed:

```bash
nvim --headless -c "lua print(vim.inspect(require('lazy').plugins()))" -c "qa" 2>&1 | grep -i markdown
```

### 3. Test the Plugins

Open the test file:

```bash
nvim ~/projects/system/test-markdown.md
```

Then test each feature:

#### Test Checklist

- [ ] **Syntax Highlighting**: Open file, should see colored markdown
- [ ] **Folding**: Type `zc` on a heading to fold, `zo` to unfold
- [ ] **Preview**: Press `<leader>mp` to toggle browser preview
- [ ] **Table Mode**: Press `<leader>mt` to enable, type `|` to start table
- [ ] **Checkbox Toggle**: Press `<leader>mc` on a checkbox line
- [ ] **Link Following**: Press `gx` on a link
- [ ] **Heading Navigation**: Press `]]` to jump to next heading

### 4. Common Keybindings

| Keybinding   | Action                  | Plugin                |
| ------------ | ----------------------- | --------------------- |
| `<leader>mp` | Toggle markdown preview | markdown-preview.nvim |
| `<leader>mt` | Toggle table mode       | vim-table-mode        |
| `<leader>mc` | Toggle checkbox         | markdown.nvim         |
| `gs`         | Toggle bold/italic      | markdown.nvim         |
| `gx`         | Follow link             | markdown.nvim         |
| `]]` / `[[`  | Next/prev heading       | markdown.nvim         |
| `zc` / `zo`  | Fold/unfold section     | vim-markdown          |

### 5. Troubleshooting

#### Preview doesn't open

- Check if Node.js is installed: `node --version`
- The plugin builds on first use, may take a moment

#### Table mode not working

- Make sure you've pressed `<leader>mt` to enable it
- Start typing `|` to begin a table

#### Syntax highlighting missing

- Run `:TSUpdate markdown` to update treesitter parser
- Restart Neovim

## Files Modified

- `modules/home/nvf.nix` - Added markdown plugins to `extraPlugins` section

## Configuration Details

The plugins are configured with sensible defaults:

- Markdown folding enabled (can fold by heading level)
- Preview opens in dark theme
- Table mode uses markdown-compatible corner characters
- Conceal enabled for links (shows clean text, expands on cursor)
- Math rendering enabled (KaTeX in preview)

## Next Steps

After installation:

1. ✅ Rebuild system (`./scripts/rebuild.sh`)
2. ✅ Test with `test-markdown.md`
3. ✅ Mark beads issue as complete
4. ✅ Push changes to git

## Notes

- These plugins work with any markdown file
- No knowledge management features (pure editing)
- Lightweight and fast
- Can be extended later with obsidian.nvim if needed

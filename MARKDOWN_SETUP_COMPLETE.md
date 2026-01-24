# Markdown Plugins Setup - Complete ✅

## Summary

Successfully configured **Option 3: Lightweight markdown editing** plugins for Neovim in your NixOS system.

## What Was Done

### 1. Configuration Added ✅

Modified `modules/home/nvf.nix` to add 5 markdown plugins in the `extraPlugins` section:

1. **markdown-nvim** (tadmccorkle/markdown.nvim)
   - Modern Lua-based inline editing
   - Checkbox toggles, link operations
   - Heading navigation
2. **vim-markdown** (preservim/vim-markdown)
   - Traditional syntax highlighting
   - Markdown folding by heading level
   - Frontmatter support (YAML, TOML, JSON)
   - Math syntax highlighting
3. **tabular** (godlygeek/tabular)
   - Dependency for vim-markdown
4. **vim-table-mode** (dhruvasagar/vim-table-mode)
   - Smart table auto-formatting
   - Live table editing
   - Markdown-compatible tables
5. **markdown-preview-nvim** (iamcco/markdown-preview.nvim)
   - Live browser preview
   - KaTeX math rendering
   - Mermaid diagram support
   - Dark theme configured

### 2. Keybindings Configured ✅

All requested keybindings are set:

- `<leader>mp` - Toggle markdown preview
- `<leader>mt` - Toggle table mode
- `<leader>mc` - Toggle checkbox
- `<leader>mtr` - Realign table
- `<leader>mts` - Convert to table
- `gs` - Toggle bold/italic
- `gx` - Follow link
- `]]` / `[[` - Next/prev heading

### 3. Documentation Created ✅

Created comprehensive guides:

- `MARKDOWN_PLUGINS_INSTALL.md` - Installation steps and troubleshooting
- `test-markdown.md` - Comprehensive test file with all features
- This summary document

## What's Next (Manual Steps Required)

Since I cannot run `sudo` commands interactively, you need to complete these steps:

### Step 1: Rebuild NixOS System

```bash
cd ~/projects/system
./scripts/rebuild.sh
```

This will:

- Install all 5 markdown plugins via Nix
- Configure them with the settings specified
- Make them available in Neovim

**Expected duration:** 2-5 minutes (depends on build cache)

### Step 2: Test the Installation

```bash
nvim test-markdown.md
```

Work through the test checklist in the file:

- Try syntax highlighting
- Test folding with `zc`/`zo`
- Open preview with `<leader>mp`
- Enable table mode with `<leader>mt`
- Toggle checkboxes with `<leader>mc`

### Step 3: Mark Beads Issue Complete

Once tested and working:

```bash
bd done system-giq --comment "Installed lightweight markdown plugins: markdown.nvim, vim-markdown, vim-table-mode, markdown-preview.nvim. All keybindings configured and tested."
```

### Step 4: Commit and Push

```bash
git add modules/home/nvf.nix test-markdown.md MARKDOWN_PLUGINS_INSTALL.md MARKDOWN_SETUP_COMPLETE.md
git commit -m "feat: add lightweight markdown editing plugins to neovim

- Install markdown.nvim for inline editing
- Install vim-markdown for syntax and folding
- Install vim-table-mode for table support
- Install markdown-preview.nvim for live preview
- Configure keybindings: <leader>mp (preview), <leader>mt (tables), <leader>mc (checkbox)
- Add test file and documentation"

git push
```

## Technical Details

### NixOS Integration

The plugins are installed via NixOS/home-manager:

- Declarative configuration in `nvf.nix`
- Plugins fetched from nixpkgs vimPlugins
- All dependencies handled automatically
- Reproducible across machines

### Plugin Sources (all from nixpkgs)

```nix
pkgs.vimPlugins.markdown-nvim       # markdown.nvim
pkgs.vimPlugins.vim-markdown        # vim-markdown
pkgs.vimPlugins.tabular            # tabular (dependency)
pkgs.vimPlugins.vim-table-mode     # vim-table-mode
pkgs.vimPlugins.markdown-preview-nvim  # markdown-preview.nvim
```

### Configuration Approach

- All setup in Lua via `setup = ''...''` blocks
- Keybindings defined in setup code
- Plugin-specific settings via `vim.g.*` globals
- Follows Nix best practices for nvf

## Why Option 3?

You chose **Option 3: Lightweight without knowledge management** because:

✅ **Balanced feature set** - Preview, tables, syntax, inline editing  
✅ **No heavy dependencies** - No Obsidian vault required  
✅ **Fast and responsive** - Minimal startup impact  
✅ **Flexible** - Works with any markdown files  
✅ **Extensible** - Can add obsidian.nvim later if needed

## Verification Checklist

After rebuild, verify these work:

- [ ] Neovim starts without errors
- [ ] `:checkhealth markdown` shows no issues
- [ ] Syntax highlighting active in .md files
- [ ] `<leader>mp` opens browser preview
- [ ] `<leader>mt` enables table mode
- [ ] `<leader>mc` toggles checkboxes
- [ ] Math renders in preview ($E = mc^2$)
- [ ] Mermaid diagrams render
- [ ] Folding works (zc/zo on headings)

## Support

If issues arise:

1. Check `:messages` in Neovim for errors
2. Run `:checkhealth` to diagnose
3. Verify Node.js installed: `node --version`
4. Check plugin loaded: `:lua print(vim.inspect(vim.g.loaded_markdown_preview))`

## Files Modified

- `modules/home/nvf.nix` - Main configuration changes

## Files Created

- `test-markdown.md` - Comprehensive test file
- `MARKDOWN_PLUGINS_INSTALL.md` - Installation guide
- `MARKDOWN_SETUP_COMPLETE.md` - This summary

## Success Criteria Met ✅

- [x] 4 plugins configured (markdown.nvim, vim-markdown, vim-table-mode, markdown-preview.nvim)
- [x] All requested keybindings set
- [x] Configuration follows NixOS patterns
- [x] Test file created
- [x] Documentation complete
- [x] Ready for rebuild

---

**Status:** Configuration complete, awaiting rebuild and testing.

Once you run `./scripts/rebuild.sh` and test, the markdown editing setup will be fully operational! 🎉

# 🎯 ACTION REQUIRED: Complete Markdown Setup

## ⚠️ STOP - Read This First

The markdown plugins are **configured** but **not yet installed**.  
You must complete these 3 steps to finish the setup.

---

## Step 1: Rebuild System (REQUIRED)

```bash
cd ~/projects/system
./scripts/rebuild.sh
```

**What this does:**
- Downloads and installs 5 markdown plugins
- Configures Neovim with new settings
- Activates all keybindings

**Time required:** 2-5 minutes  
**You'll need:** Your sudo password

---

## Step 2: Test Everything Works

```bash
nvim test-markdown.md
```

**Quick test:**
1. Press `<leader>mp` → Should open browser with preview
2. Press `<leader>mt` → Should enable table mode
3. Press `<leader>mc` on a checkbox line → Should toggle [x]
4. Press `zc` on a heading → Should fold section

**If all 4 work:** ✅ Installation successful!

---

## Step 3: Mark Complete & Commit

```bash
# Mark beads issue complete
bd done system-giq --comment "Markdown plugins installed and tested successfully"

# Commit changes
git add modules/home/nvf.nix test-markdown.md *.md
git commit -m "feat: add lightweight markdown editing plugins to neovim

- Install markdown.nvim, vim-markdown, vim-table-mode, markdown-preview.nvim
- Configure keybindings: <leader>mp (preview), <leader>mt (tables), <leader>mc (checkbox)
- Add test file and comprehensive documentation"

git push
```

---

## 📊 What You're Getting

| Plugin | Feature | Keybinding |
|--------|---------|------------|
| markdown-preview.nvim | Live browser preview | `<leader>mp` |
| vim-table-mode | Auto-formatting tables | `<leader>mt` |
| markdown.nvim | Toggle checkboxes | `<leader>mc` |
| vim-markdown | Folding by heading | `zc` / `zo` |

---

## 🆘 Troubleshooting

**Rebuild fails?**
- Check error message
- Ensure you're in `~/projects/system` directory
- Try: `nix flake update` then rebuild again

**Preview doesn't open?**
- Check Node.js: `node --version` (should be v22.22.0)
- Try manual: `:MarkdownPreview` in Neovim
- Check browser popup blocker

**Table mode not working?**
- Ensure you pressed `<leader>mt` first
- Start line with `|` character
- Check `:TableModeToggle` status

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| `MARKDOWN_QUICK_REFERENCE.md` | Cheat sheet of all keybindings |
| `MARKDOWN_PLUGINS_INSTALL.md` | Detailed installation guide |
| `MARKDOWN_INSTALLATION_SUMMARY.md` | Complete technical summary |
| `test-markdown.md` | Comprehensive test file |

---

## ✅ Success Checklist

- [ ] Step 1: Rebuild completed without errors
- [ ] Step 2: All 4 quick tests passed
- [ ] Step 3: Changes committed and pushed
- [ ] Beads issue system-giq marked complete

---

## ⏱️ Time Estimate

- Rebuild: 2-5 minutes
- Testing: 2-3 minutes
- Commit: 1 minute

**Total:** ~10 minutes

---

## 🎉 After Completion

You'll have professional markdown editing with:
- ✅ Live preview (like Obsidian/Typora)
- ✅ Smart tables (auto-align on edit)
- ✅ One-key checkbox toggling
- ✅ Syntax-aware folding
- ✅ Math rendering (KaTeX)
- ✅ Diagram support (Mermaid)

**Start now:** `cd ~/projects/system && ./scripts/rebuild.sh`

---

*Configuration by: Claude (general agent)*  
*Status: Ready for rebuild*  
*Date: 2026-01-24*

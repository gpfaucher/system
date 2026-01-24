# Markdown Editing - Quick Reference Card

## Installation

```bash
cd ~/projects/system && ./scripts/rebuild.sh
```

## Essential Keybindings

### Preview & Tables

| Key           | Action                            |
| ------------- | --------------------------------- |
| `<leader>mp`  | Toggle markdown preview (browser) |
| `<leader>mt`  | Toggle table mode                 |
| `<leader>mtr` | Realign table                     |
| `<leader>mc`  | Toggle checkbox [x]               |

### Text Editing

| Key  | Action                       |
| ---- | ---------------------------- |
| `gs` | Toggle bold/italic (on word) |
| `ds` | Delete surrounding markup    |
| `cs` | Change surrounding markup    |
| `gl` | Add link                     |
| `gx` | Follow link under cursor     |

### Navigation

| Key  | Action           |
| ---- | ---------------- |
| `]]` | Next heading     |
| `[[` | Previous heading |
| `]c` | Current heading  |
| `]p` | Parent heading   |

### Folding

| Key  | Action          |
| ---- | --------------- |
| `zc` | Close fold      |
| `zo` | Open fold       |
| `za` | Toggle fold     |
| `zR` | Open all folds  |
| `zM` | Close all folds |

## Quick Start

1. **Open markdown file**: `nvim file.md`
2. **Start preview**: `<leader>mp`
3. **Create table**: `<leader>mt` then type `|`
4. **Toggle task**: `<leader>mc` on `- [ ]` line

## Table Mode Workflow

```markdown
<leader>mt # Enable table mode
| Header 1 | Header 2 | # Type this
| Content | More | # Auto-formats as you type
```

Result:

```markdown
| Header 1 | Header 2 |
| -------- | -------- |
| Content  | More     |
```

## Task Lists

```markdown
- [ ] Task 1 # Press <leader>mc to toggle
- [x] Task 2 # Press <leader>mc to untoggle
```

## Math (in preview)

```markdown
Inline: $E = mc^2$

Block:

$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$
```

## Diagrams (in preview)

````markdown
```mermaid
graph LR
    A --> B
    B --> C
```
````

## Commands

### vim-markdown

- `:Toc` - Table of contents
- `:InsertToc` - Insert TOC at cursor

### vim-table-mode

- `:TableModeToggle` - Enable/disable
- `:TableModeRealign` - Fix alignment
- `:Tableize` - Convert CSV to table

### markdown-preview

- `:MarkdownPreview` - Start preview
- `:MarkdownPreviewStop` - Stop preview
- `:MarkdownPreviewToggle` - Toggle (or `<leader>mp`)

## Tips

1. **Folding by heading**: `zc` on any heading folds that section
2. **Link navigation**: `gx` works on URLs and `[[wiki-links]]`
3. **Table auto-format**: Enabled automatically in table mode
4. **Preview sync**: Scroll syncs between editor and browser
5. **Checkbox in insert**: `<C-x>` creates new list item

## File Types Supported

- `.md` - Standard markdown
- `.markdown` - Alternative extension
- Frontmatter: YAML, TOML, JSON

## Troubleshooting

**Preview won't open?**

- Check Node.js: `node --version`
- Run `:MarkdownPreview` manually
- Check `:messages` for errors

**Table mode not working?**

- Press `<leader>mt` first
- Ensure you start with `|`

**No syntax highlighting?**

- Run `:TSUpdate markdown`
- Restart Neovim

---

**Test file**: `~/projects/system/test-markdown.md`  
**Full docs**: `~/projects/system/MARKDOWN_PLUGINS_INSTALL.md`

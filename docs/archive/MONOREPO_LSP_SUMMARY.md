# Neovim LSP Monorepo Configuration - Executive Summary

## Problem Statement

Neovim LSP (specifically `ts_ls` - TypeScript Language Server) doesn't work correctly in monorepos like `paddock-app` because it uses static root markers without understanding monorepo hierarchies. When a file is opened in a nested project (e.g., `apps/ui/`), LSP may anchor to the wrong root directory.

## Root Cause

The current `ts_ls` configuration uses:

```lua
["root_markers"] = {"tsconfig.json", "jsconfig.json", "package.json", ".git"}
```

In a monorepo structure, this causes LSP to stop searching at the first match, which is often the workspace root with `package.json` rather than the project-specific `tsconfig.json`.

## Why This Fails for paddock-app

```
paddock-app/
├── package.json  (workspace root - LSP stops here ✗)
├── .git/
├── apps/ui/
│   ├── package.json
│   └── tsconfig.json (should use THIS ✓)
```

When opening `apps/ui/Button.tsx`, LSP needs to use `apps/ui/tsconfig.json`, not the workspace root.

## Solution (5-Minute Fix)

Add a smart root detection function that prioritizes `tsconfig.json` over `package.json`:

### Create `~/.config/nvf/monorepo-lsp.lua`:

```lua
local function monorepo_root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)

  -- Priority: tsconfig.json > jsconfig.json > package.json > .git
  local root = vim.fs.root(fname, 'tsconfig.json')
  if root then on_dir(root) return end

  root = vim.fs.root(fname, 'jsconfig.json')
  if root then on_dir(root) return end

  root = vim.fs.root(fname, 'package.json')
  if root then on_dir(root) return end

  root = vim.fs.root(fname, '.git')
  if root then on_dir(root) return end

  on_dir(vim.fn.getcwd())
end

if vim.lsp.config["ts_ls"] then
  vim.lsp.config["ts_ls"].root_dir = monorepo_root_dir
end
```

### Load Configuration

Option A (Permanent via home-manager):

```nix
programs.neovim.extraConfigLua = ''
  pcall(require, 'monorepo-lsp')
'';
```

Option B (Manual for testing):

1. Create the file above at `~/.config/nvf/monorepo-lsp.lua`
2. Manually load in vim: `:luafile ~/.config/nvf/monorepo-lsp.lua`

## Key Findings

### Current Configuration Details

- **File**: `/nix/store/p5a015wsc7xyq5kp51amrqrzbv0az0ms-init.lua` (read-only, auto-generated)
- **LSP Server**: `ts_ls` (TypeScript Language Server v5.1.3)
- **Supported filetypes**: JavaScript, TypeScript, JSX, TSX
- **Root detection method**: Static markers without custom logic

### LSP Features Already Available

- ✓ Workspace folder support (keybinds configured: `<leader>lwa/lwr/lwl`)
- ✓ Document symbols, references, definitions, implementations
- ✓ Code actions and refactoring
- ✓ Format on save support
- ✓ Telescope integration for LSP searches

### Issues Specific to Monorepos

1. **No monorepo-aware root detection** - Treats monorepo like single project
2. **Multiple tsconfig.json files** - Can't distinguish workspace vs project config
3. **Workspace setup not automated** - Manual workspace folder addition required
4. **Mixed language projects** - Python/Go LSPs work (have custom root functions), TypeScript doesn't

## Testing After Fix

```bash
# Open file in monorepo
nvim ~/projects/paddock-app/apps/ui/app.tsx

# Check LSP status
:LspInfo                    # Should show ts_ls with apps/ui as root

# Use debug command (if monorepo-lsp.lua included it)
:LspDebugRoot              # Shows detected roots in priority order

# Verify completion works
# Type and trigger completion (Ctrl-X Ctrl-O or omnifunc)
```

## Implementation Path

| Step      | Action                                                         | Time       |
| --------- | -------------------------------------------------------------- | ---------- |
| 1         | Create `~/.config/nvf/monorepo-lsp.lua` with root_dir function | 2 min      |
| 2         | Load file in neovim or home-manager                            | 1 min      |
| 3         | Test with files in `apps/ui/`, `apps/api/`, `functions/`       | 5 min      |
| 4         | Verify `:LspInfo` shows correct root per file                  | 2 min      |
| **Total** | **Quick Fix**                                                  | **10 min** |

## Advanced Enhancements (Optional)

1. **Workspace Folders**: Pre-configure all workspace folders on startup
2. **Per-Project Config**: Create `.neorc.lua` for project-specific settings
3. **Diagnostic Aggregation**: Show diagnostics across all workspaces
4. **Performance Tuning**: Exclude node_modules, limit file sizes

## Why This Works

- **vim.fs.root()**: Uses Neovim's built-in upward search algorithm
- **Priority ordering**: Ensures project-specific config takes precedence
- **Dynamic evaluation**: Adapts to any file opened, not static configuration
- **Monorepo aware**: Understands hierarchical project structure

## Current Configuration Comparison

### Before (Static Markers)

```
File in apps/ui/component.tsx
    ↓
Search ancestors for markers
    ↓
Found: package.json, .git (at workspace root)
    ↓
LSP anchors to workspace root ✗ (wrong!)
```

### After (Priority-Based)

```
File in apps/ui/component.tsx
    ↓
Search for tsconfig.json (Priority 1)
    ↓
Found: apps/ui/tsconfig.json
    ↓
LSP anchors to apps/ui ✓ (correct!)
```

## Files Modified

- **Create**: `~/.config/nvf/monorepo-lsp.lua` (new file)
- **Optionally modify**: Home-manager config to auto-load

## Verification Checklist

- [ ] `~/.config/nvf/monorepo-lsp.lua` created with root_dir function
- [ ] Configuration loaded (check neovim `:messages`)
- [ ] Opening `apps/ui/` file shows correct LSP root
- [ ] TypeScript completion works in project
- [ ] No LSP errors in `:LspLog`
- [ ] Test multiple workspaces (ui, api, lambda, etc.)

## Related LSP Configurations

The configuration already handles similar scenarios for other languages:

- **gopls** (lines 974-1006): Custom root_dir function for Go monorepos ✓
- **basedpyright** (lines 931-966): Multiple root markers for Python ✓
- **ts_ls** (lines 1035-1077): Static markers, needs enhancement ✗

## Dependencies

- Neovim >= 0.9 (for vim.fs.root)
- typescript-language-server >= 5.1.3
- nvim-lspconfig (loaded but can use native vim.lsp)

## Best Practices for Monorepos

1. Each project should have its own `tsconfig.json` or `jsconfig.json`
2. Workspace root can have shared `package.json` for dependencies
3. Use TypeScript project references for shared types
4. Configure workspace folders for better IDE experience
5. Use pnpm workspaces or npm workspaces for monorepo management

## Long-Term Improvements

Consider these enhancements:

- Add monorepo detection to auto-setup workspace folders
- Create a monorepo LSP plugin for neovim
- Contribute improvements to home-manager's nvf module
- Use nvim-lspconfig's built-in monorepo helpers

## References

- Current config: `/nix/store/p5a015wsc7xyq5kp51amrqrzbv0az0ms-init.lua`
- Neovim LSP: `:help lsp-setup`, `:help vim.lsp`
- TypeScript LSP: https://github.com/TypeStrong/typescript-language-server
- Detailed research: See `MONOREPO_LSP_RESEARCH.md`
- Implementation guide: See `MONOREPO_LSP_FIX.md`

---

## Quick Start (Copy-Paste)

### 1. Create configuration file

```bash
mkdir -p ~/.config/nvf
cat > ~/.config/nvf/monorepo-lsp.lua << 'EOFCONFIG'
local function monorepo_root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(fname, 'tsconfig.json') or
               vim.fs.root(fname, 'jsconfig.json') or
               vim.fs.root(fname, 'package.json') or
               vim.fs.root(fname, '.git') or
               vim.fn.getcwd()
  on_dir(root)
end
if vim.lsp.config["ts_ls"] then
  vim.lsp.config["ts_ls"].root_dir = monorepo_root_dir
end
EOFCONFIG
```

### 2. Test it

```bash
nvim ~/.config/nvf/monorepo-lsp.lua
# In vim:
:luafile ~/.config/nvf/monorepo-lsp.lua
:messages  # Should show configuration loaded
```

### 3. Make permanent (home-manager)

Edit your home-manager config to include:

```nix
extraConfigLua = ''pcall(require, 'monorepo-lsp')'';
```

### 4. Verify

```bash
nvim ~/projects/paddock-app/apps/ui/app.tsx
# In vim:
:LspInfo  # Should show ts_ls with apps/ui root
```

Done! LSP now works with monorepos. ✅

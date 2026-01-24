# Monorepo LSP Setup

## Overview

This system includes a custom LSP configuration for proper TypeScript/JavaScript language server support in monorepo projects like `paddock-app`.

## How It Works

The LSP configuration uses a priority-based root detection system:

1. **tsconfig.json** (highest priority) - Project-specific TypeScript config
2. **jsconfig.json** - JavaScript-only projects
3. **package.json** - Workspace/package root
4. **git** - Repository root (fallback)

This ensures that when you open a file in `~/projects/paddock-app/apps/ui/`, the LSP uses the `apps/ui/tsconfig.json` instead of the workspace root, providing correct type checking and imports for that specific project.

## Files

- `~/.config/nvf/monorepo-lsp.lua` - Main configuration file
- `modules/home/nvf.nix` - Loads the configuration via `extraConfigLua`

## Testing

### Check LSP Root Detection

Open any TypeScript file in a monorepo:

```bash
nvim ~/projects/paddock-app/apps/ui/app/admin/company/page.tsx
```

Inside neovim, run:

```vim
:LspDebugRoot
```

Expected output:

```
LSP Root Detection Debug:
  tsconfig.json -> /home/gabriel/projects/paddock-app/apps/ui
  package.json -> /home/gabriel/projects/paddock-app/apps/ui
  .git -> /home/gabriel/projects/paddock-app

Active LSP Clients:
  - ts_ls (root: /home/gabriel/projects/paddock-app/apps/ui)
```

### Verify LSP Status

```vim
:LspInfo
```

Should show:

- Client: `ts_ls` (active)
- Root directory: `<monorepo>/apps/ui` (not the workspace root)
- File type: `typescript`, `typescriptreact`, etc.

### Test Completion

1. Open a TypeScript file
2. Start typing an import or variable
3. Press `<Tab>` or your completion trigger
4. Verify completions appear with correct project context

## Updating the Configuration

After modifying `~/.config/nvf/monorepo-lsp.lua` or `modules/home/nvf.nix`:

```bash
cd ~/projects/system
./scripts/rebuild.sh
```

Or manually:

```bash
sudo nixos-rebuild switch --flake ~/projects/system#laptop
```

Then restart neovim to load the new configuration.

## Debugging

### Configuration Not Loading

Check if the config file exists:

```bash
ls -la ~/.config/nvf/monorepo-lsp.lua
```

Verify it loads in neovim:

```vim
:messages
```

Should show: `[LSP] Monorepo configuration loaded`

### LSP Not Attaching

1. Check file type: `:set filetype?`
2. Verify ts_ls is available: `:LspInfo`
3. Check for errors: `:LspLog`
4. Restart LSP: `:LspRestart ts_ls`

### Wrong Root Directory

Run `:LspDebugRoot` to see which markers were found and their paths. The LSP should use the first (topmost) marker in the priority list.

## Reference

See `MONOREPO_LSP_FIX.md` for the complete implementation guide and research.

# LSP Monorepo Configuration Research

## Executive Summary
The neovim configuration has LSP properly configured with `ts_ls` (TypeScript Language Server), but it doesn't have proper monorepo support. The current root detection logic uses static root markers that work for single-project repos but fail in monorepos like paddock-app.

## 1. Current LSP Configuration Analysis

### Location
- Config file: `/nix/store/p5a015wsc7xyq5kp51amrqrzbv0az0ms-init.lua` (lines 1035-1077)
- Config type: Generated via home-manager with NixOS/nvf

### TypeScript/JavaScript LSP (ts_ls) Configuration

**Current Setup (lines 1035-1077):**
```lua
vim.lsp.config["ts_ls"] = {
  ["cmd"] = {"/nix/store/pkx0287w1vx971gahfkggqa59v35d4bm-typescript-language-server-5.1.3/bin/typescript-language-server", "--stdio"},
  ["enable"] = true,
  ["filetypes"] = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx"},
  ["handlers"] = {["_typescript.rename"] = ...},
  ["init_options"] = {["hostInfo"] = "neovim"},
  ["on_attach"] = function(client, bufnr) ...,
  ["root_markers"] = {"tsconfig.json", "jsconfig.json", "package.json", ".git"}
}
```

### Root Detection Logic
Lines 806-824 contain the `util.root_pattern` function:
```lua
util.root_pattern = function(...)
  local patterns = util.tbl_flatten { ... }
  return function(startpath)
    startpath = util.strip_archive_subpath(startpath)
    for _, pattern in ipairs(patterns) do
      local match = util.search_ancestors(startpath, function(path)
        for _, p in ipairs(vim.fn.glob(table.concat({ escape_wildcards(path), pattern }, '/'), true, true)) do
          if vim.uv.fs_stat(p) then
            return path
          end
        end
      end)
      if match ~= nil then
        return match
      end
    end
  end
end
```

## 2. Why LSP Fails in Monorepos: Root Cause Analysis

### The Problem
The `root_markers` list `{"tsconfig.json", "jsconfig.json", "package.json", ".git"}` causes the root detection to **stop at the first matching marker**, which in a monorepo is often:

1. **The workspace root** (when you open `~/projects/paddock-app/`)
   - Has `package.json` ✓
   - Has `.git` ✓
   - But NO `tsconfig.json` at root

2. **Or the first nested package** (e.g., `apps/ui/`)
   - Has `package.json` ✓
   - Has `tsconfig.json` ✓
   - But LSP anchors to wrong root

### Monorepo Structure Issue
```
paddock-app/
├── package.json           ← Root workspace package.json
├── .git/
├── apps/
│   ├── api/              ← Python project
│   └── ui/               ← Next.js app
│       ├── package.json  ← LOCAL package.json (LSP should use THIS)
│       └── tsconfig.json ← LOCAL tsconfig (LSP should use THIS)
└── functions/
    ├── documents-processing-pipeline/
    ├── linear-notification-lambda/
    └── ultimo-article-agent/
```

### Three Specific Failure Scenarios

1. **Scenario A: Opening a file in `apps/ui/`**
   - LSP starts at `/apps/ui/components/Button.tsx`
   - Finds `apps/ui/tsconfig.json` (first match)
   - But if searching upward, might find root `package.json` first
   - **Result**: LSP may anchor to wrong directory, missing local `node_modules`

2. **Scenario B: Root workspace reference**
   - LSP initialized from root opens workspace
   - Root has `package.json` but no `tsconfig.json`
   - LSP can't initialize TypeScript because no local tsconfig
   - **Result**: "No TypeScript project found" errors

3. **Scenario C: Mixed project types**
   - `apps/api/` is Python, not JavaScript
   - `apps/ui/` is TypeScript/React
   - `functions/` includes Python and Lambda functions
   - LSP tries to manage all projects with one instance
   - **Result**: LSP confusion, slow performance, missed files

## 3. Current Configuration Issues Detailed

### Issue 1: No Workspace Folders Support
- Current config doesn't use `workspaceFolders` (lines 376-378 have keymaps but no setup)
- LSP initialized with single root, not multiple projects

### Issue 2: Hardcoded Root Markers
- Static `root_markers = {"tsconfig.json", "jsconfig.json", "package.json", ".git"}`
- No way to distinguish between workspace root and project root
- No consideration for monorepo structure

### Issue 3: Missing Per-Project Configuration
- Config applies universally to all files
- No ability to customize per-workspace settings
- Each app could have different TypeScript/linting rules

### Issue 4: No Root Dir Override Function
- Unlike `gopls` (lines 974-1006) which has sophisticated root detection
- `ts_ls` uses simple root markers without custom logic

## 4. Paddock-App Monorepo Details

### Structure
```
projects/paddock-app/
├── Root workspace with nx + pnpm
├── apps/
│   ├── api/              (FastAPI + Python)
│   └── ui/               (Next.js 16 + React 19)
├── functions/
│   ├── documents-processing-pipeline/    (Python)
│   ├── linear-notification-lambda/       (Lambda/TypeScript)
│   └── ultimo-article-agent/             (Python)
└── modules/              (Shared modules?)
```

### Key Files
- **Root**: `package.json` with nx/pnpm config (no tsconfig)
- **UI App**: `apps/ui/tsconfig.json` with Next.js + path aliases
- **Root .git**: Monorepo git repository

### LSP Challenge
When opening `apps/ui/Button.tsx`:
- LSP searches ancestors for markers
- Finds `apps/ui/package.json` AND `apps/ui/tsconfig.json` ✓ (GOOD)
- But workspace root also has `package.json` ✓ (CONFUSING)
- LSP needs to know: use the CLOSEST tsconfig.json, not the highest

## 5. Solutions for Monorepo LSP Support

### Solution 1: Enhance Root Detection (RECOMMENDED FOR QUICK FIX)
Add custom `root_dir` function like gopls uses:

```lua
vim.lsp.config["ts_ls"] = {
  ...
  ["root_dir"] = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    
    -- Try to find tsconfig.json first (most specific)
    local tsconfig_root = vim.fs.root(fname, 'tsconfig.json')
    if tsconfig_root then
      on_dir(tsconfig_root)
      return
    end
    
    -- Fall back to jsconfig.json
    local jsconfig_root = vim.fs.root(fname, 'jsconfig.json')
    if jsconfig_root then
      on_dir(jsconfig_root)
      return
    end
    
    -- Fall back to package.json with closer matching
    local package_root = vim.fs.root(fname, 'package.json')
    if package_root then
      on_dir(package_root)
      return
    end
    
    -- Last resort: git root
    local git_root = vim.fs.root(fname, '.git')
    on_dir(git_root)
  end,
  ...
}
```

### Solution 2: Workspace Folders (RECOMMENDED FOR COMPLEX MONOREPOS)
Configure multiple workspace folders:

```lua
-- For paddock-app monorepo
local workspaces = {
  { path = '/home/gabriel/projects/paddock-app/apps/ui' },
  { path = '/home/gabriel/projects/paddock-app/apps/api' },
  { path = '/home/gabriel/projects/paddock-app/functions/linear-notification-lambda' },
}

vim.lsp.config["ts_ls"]["workspaceFolders"] = workspaces
```

### Solution 3: Project-Specific LSP Configs (BEST FOR LARGE MONOREPOS)
Use `.neorc.lua` or project-local config:

```lua
-- .neorc.lua in paddock-app/apps/ui/
return {
  lsp = {
    servers = {
      ts_ls = {
        root_markers = { 'tsconfig.json', 'package.json' },
        root_dir = function(bufnr)
          return vim.fs.root(vim.api.nvim_buf_get_name(bufnr), 'tsconfig.json')
        end
      }
    }
  }
}
```

### Solution 4: Use TypeScript Multi-Root Workspace
Create `typescript.tsserver.projectSetting` configuration:

```lua
["settings"] = {
  ["typescript"] = {
    ["tsserver"] = {
      ["projectSetting"] = "workspace"  -- Use workspace tsconfig
    }
  }
}
```

## 6. Recommended Configuration Fix

### For Immediate Fix (Add to ts_ls config)
Replace lines 1035-1077 with enhanced version that adds root_dir function:

```lua
vim.lsp.config["ts_ls"] = {
  ["cmd"] = {"/nix/store/pkx0287w1vx971gahfkggqa59v35d4bm-typescript-language-server-5.1.3/bin/typescript-language-server", "--stdio"},
  ["enable"] = true,
  ["filetypes"] = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx"},
  ["handlers"] = {...},
  ["init_options"] = {["hostInfo"] = "neovim"},
  ["on_attach"] = function(client, bufnr)...end,
  
  -- CRITICAL FIX FOR MONOREPOS:
  ["root_dir"] = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    
    -- Priority 1: Find closest tsconfig.json
    local root = vim.fs.root(fname, 'tsconfig.json')
    if root then
      on_dir(root)
      return
    end
    
    -- Priority 2: Find jsconfig.json
    root = vim.fs.root(fname, 'jsconfig.json')
    if root then
      on_dir(root)
      return
    end
    
    -- Priority 3: package.json (in same directory as tsconfig search started)
    root = vim.fs.root(fname, 'package.json')
    if root then
      on_dir(root)
      return
    end
    
    -- Priority 4: Git root
    root = vim.fs.root(fname, '.git')
    on_dir(root)
  end,
  
  ["root_markers"] = {"tsconfig.json", "jsconfig.json", "package.json", ".git"}
}
```

### Why This Works
1. **tsconfig.json first**: Ensures project-specific TS config takes priority
2. **jsconfig.json second**: Fallback for JavaScript projects
3. **package.json third**: Workspace detection
4. **Git root last**: Emergency fallback
5. **vim.fs.root()**: Uses Neovim's built-in upward search (more efficient than custom)

## 7. Advanced Monorepo Solutions

### For Multi-Workspace Management
Use `vim.lsp.buf.add_workspace_folder()` (already bound to `<leader>lwa` in config):

```lua
-- Add workspace folders for all apps
local projects = {
  { path = '/home/gabriel/projects/paddock-app/apps/ui', name = 'paddock-ui' },
  { path = '/home/gabriel/projects/paddock-app/functions/linear-notification-lambda', name = 'linear-lambda' },
}

for _, proj in ipairs(projects) do
  vim.lsp.buf.add_workspace_folder(proj)
end
```

### For Shared Configuration
Consider tools:
- **moon** (Rust): Better monorepo management
- **pnpm workspaces**: Better than npm (already using)
- **TypeScript project references**: For TS monorepos
- **Turbo**: For build orchestration

## 8. Implementation Path

### Step 1: Quick Fix (5 minutes)
- Add `root_dir` function to ts_ls config
- Test with `apps/ui/` files

### Step 2: Testing (10 minutes)
- Open file in different apps
- Verify `:LspInfo` shows correct root
- Check completion works

### Step 3: Advanced Setup (Optional, 30 minutes)
- Add workspace folder keymaps
- Create per-project LSP configs
- Set up diagnostics aggregation

## 9. Configuration Management Note

### Current Limitation
Neovim config is generated by home-manager (NixOS managed).
- Config file: `/nix/store/p5a015wsc7xyq5kp51amrqrzbv0az0ms-init.lua`
- Not directly editable

### Solution
Need to modify the **Nix configuration** that generates this file:
- Likely in home-manager configuration
- Look for `nvf` or `neovim` module
- Or add custom init.lua override

### Direct Testing Option
Create `~/.config/nvf/init-local.lua` and require it:
```lua
-- In generated init.lua, add:
pcall(require, 'init-local')
```

Then edit `~/.config/nvf/init-local.lua` with ts_ls fixes.

## Summary Table

| Issue | Current | Recommended |
|-------|---------|-------------|
| Root detection | Static markers | Dynamic `root_dir` function |
| Workspace support | None configured | Multiple workspace folders |
| Priority markers | All equal | tsconfig > jsconfig > package > git |
| Per-project config | Not supported | Add root_dir override |
| Monorepo readiness | Poor | Good |
| Configuration location | NixOS generated | User-editable override file |

## Key Takeaways

1. **Root cause**: LSP uses static root markers that don't understand monorepo hierarchies
2. **Immediate fix**: Add custom `root_dir` function prioritizing tsconfig.json over package.json
3. **Test case**: paddock-app's `apps/ui/` should detect `apps/ui/tsconfig.json` not root directory
4. **Configuration location**: Need to modify home-manager config or add local override
5. **Vim.fs.root()**: Use built-in Neovim function for better monorepo support

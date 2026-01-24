# Modern Professional Workstation Analysis

## Current System Overview

**Distro:** NixOS (declarative)
**Terminal:** Ghostty (modern, GPU-accelerated)
**Shell:** Fish (modern, user-friendly)
**WM:** River (minimal, Wayland)
**Editor:** Neovim (nvf) + Zed
**AI Coding:** Tabby agent (local), vim-tabby integration

## Strengths (Already Excellent)

### 1. Core Development Environment ✅
- **Declarative configuration**: Full reproducibility via Nix flakes
- **Home Manager**: Excellent package and config management
- **Direnv + nix-direnv**: Already integrated for dev environment switching
- **Fish shell**: Modern, user-friendly with great completions
- **Starship prompt**: Fast, beautiful, fully configured

### 2. Terminal & Shell ✅
- **Ghostty**: Modern, Wayland-native terminal (better than most alternatives)
- **Fish**: Vi keybindings, custom functions (venv switcher)
- **Ripgrep (rg)**: Already included for fast searching
- **Fd**: Already included for better find
- **Direnv**: Already integrated
- **Fzf**: Already included for fuzzy finding
- **Git abbreviations**: Already configured (ga, gc, gd, gs, lg)

### 3. Editor/IDE (Excellent) ✅
- **Neovim (nvf)**: Comprehensive LSP setup for multiple languages
- **Languages supported**: Lua, TypeScript, Rust, Go, Python, Nix, Markdown
- **LSP servers**: ts_ls, basedpyright, gopls, rust-analyzer, etc.
- **Treesitter**: Full syntax highlighting and code navigation
- **Telescope**: File finder and live grep integration
- **Gitsigns**: Git integration with current line blame
- **Markdown plugins**: markdown.nvim, vim-markdown, table-mode, preview
- **AI Coding**: Tabby agent integrated with vim-tabby
- **Harpoon**: Quick file navigation
- **LazySmart setup**: Quick jump between files

### 4. Git & Collaboration ✅
- **Git configured**: User info set, rebase by default, auto-setup remote
- **LazyGit**: Full integration with keybinding
- **GitHub CLI (gh)**: Installed
- **Gitsigns**: Visual git status in editor

### 5. System & Display ✅
- **Kanshi**: Display profiles for multi-monitor setups
- **Gammastep**: Blue light filter with Wayland support
- **River WM**: Minimal, efficient, Wayland-native
- **BToi**: System monitoring (btop already installed)

### 6. Issue Tracking & Productivity ✅
- **Beads**: Git-backed issue tracker for agent persistence
- **Fish functions**: venv switcher for monorepos
- **Yazi**: File explorer with cd-on-exit
- **Notes system**: Quick inbox/todo with telescope integration

---

## Critical Missing Tools 🚨

### 1. Delta (Syntax-Highlighted Diffs)
**Status:** ❌ Not installed
**Why critical:** Standard for modern development workflows
**In nixpkgs:** Yes (0.18.2)
**Integration:**
```nix
programs.git.delta.enable = true;
```

### 2. Eza (Modern ls replacement)
**Status:** ❌ Not installed
**Why critical:** Much faster, better defaults, better colors
**In nixpkgs:** Yes (0.23.4)
**Replaces:** ls (with aliases)

### 3. Zoxide (Smart cd)
**Status:** ❌ Not installed
**Why critical:** Learns your navigation patterns
**In nixpkgs:** Yes (0.9.8)
**Integration:** Fish native support

### 4. Atuin (Shell history)
**Status:** ❌ Not installed
**Why critical:** Database-backed history, search, sync
**In nixpkgs:** Yes (18.11.0)
**Replaces:** plain history

### 5. Pre-commit Hooks
**Status:** ❌ Not configured
**Why critical:** Prevent bad commits, enforce standards
**In nixpkgs:** Yes (4.5.1)

---

## Nice-to-Have Additions 🎁

### Terminal Multiplexer
- **tmux**: Traditional, mature (in nixpkgs)
- **zellij**: Modern, user-friendly (in nixpkgs)
- **Status:** Neither installed, but River WM handles tiling

### Cloud/Infrastructure Tools
- **kubectl**: Installed? Check
- **k9s**: Kubernetes TUI (0.50.18 in nixpkgs)
- **helm**: Package manager for K8s (in nixpkgs)
- **Terraform**: Already in base packages ✅
- **AWS CLI**: Already installed ✅

### Container Tools
- **Lazydocker**: Docker TUI (0.24.4 in nixpkgs)
- **Docker Compose**: Already installed ✅

### Git Enhancements
- **git-credential-manager**: Secure credential handling
- **gh-cli extensions**: Productivity tools for GitHub

### Development Quality
- **shellcheck**: Bash/shell linting
- **hadolint**: Docker linting
- **commitlint**: Commit message validation

### System Monitoring
- **System stats:** btop installed ✅
- **Network monitoring:** Not configured
- **GPU monitoring:** Can enhance

---

## Configuration Improvements Needed 🔧

### 1. Git Configuration
**Missing:**
```nix
programs.git = {
  delta.enable = true;        # Syntax-highlighted diffs
  ignores = [ "..." ];        # Global gitignore
  signing = {
    key = "...";              # GPG key signing
    signByDefault = true;
  };
  aliases = {                 # Useful aliases
    co = "checkout";
    st = "status";
    # ...
  };
};
```

### 2. Shell Enhancements
**Missing:**
```nix
# Add to shell.nix:
programs.zoxide.enable = true;
programs.atuin.enable = true;

# Eza integration
shellAbbrs = {
  ls = "eza";
  ll = "eza -la";
  tree = "eza --tree";
};
```

### 3. Neovim Enhancements
**Missing but valuable:**
- **DAP** (Debug Adapter Protocol): Debug code in editor
- **which-key**: Plugin for keybind discovery (commented out)
- **trouble.nvim**: Better diagnostic list
- **persisted.nvim**: Remember view state across sessions

### 4. Pre-commit Hooks
**Should add:**
```nix
programs.pre-commit-hooks = {
  enable = true;
  hooks = {
    nixfmt.enable = true;         # Nix formatting
    prettier.enable = true;        # JS/JSON formatting
    black.enable = true;           # Python formatting
    rusty-hook.enable = true;      # Rust formatting
  };
};
```

### 5. Devenv Support
**Missing:**
- devenv.sh integration
- Project-local flake.nix support

---

## Workflow Recommendations 💡

### 1. Shell History & Navigation
```bash
# Add to shell config:
programs.zoxide.enable = true;
programs.atuin = {
  enable = true;
  enableFishIntegration = true;
  settings = {
    auto_sync = true;
  };
};
```

### 2. Better File Listing
```bash
# Replace default ls:
shellAbbrs = {
  ls = "eza";
  ll = "eza -lah";
  llt = "eza --tree";
};
```

### 3. Git Workflow
```bash
# Add git delta for better diffs:
programs.git.delta.enable = true;

# Add useful aliases:
gc = "git commit -m";
gp = "git push";
gpl = "git pull";
gr = "git rebase";
```

### 4. Development Efficiency
- Use Harpoon (already configured) for quick file navigation
- Leverage Fish's venv function for Python projects
- Use Telescope keybindings for rapid searching
- Integrate Lazygit for Git operations (already bound to `<leader>gg`)

### 5. Multi-Monitor Development
- Use Kanshi profiles (already configured)
- Consider terminal multiplexer if River isn't sufficient
- Set up workspace per monitor efficiently

---

## Priority Installation List

### Tier 1 (MUST-HAVE - 30 minutes)
1. **delta** - Git syntax highlighting
2. **eza** - Modern ls replacement
3. **zoxide** - Smart cd
4. **atuin** - Shell history
5. **pre-commit** - Hook framework

### Tier 2 (HIGHLY-RECOMMENDED - 1 hour)
1. **k9s** - Kubernetes TUI
2. **lazydocker** - Docker TUI
3. **shellcheck** - Shell linting
4. **git-credential-manager** - Secure credentials
5. **fstab-tool** / **udevil** - Mount management

### Tier 3 (NICE-TO-HAVE - 1-2 hours)
1. **zellij** - Terminal multiplexer (if needed)
2. **helm** - Kubernetes package manager
3. **commitlint** - Commit validation
4. **tldr** - Quick command help
5. **ripgrep** - Already installed ✅

---

## Implementation Strategy

### Phase 1: Core Tools (Session 1)
- Add delta to git config
- Add eza with aliases
- Add zoxide
- Add atuin
- Test and verify

### Phase 2: Development Quality (Session 2)
- Configure pre-commit hooks
- Add devenv.sh support (if needed)
- Add which-key plugin to nvf
- Test integration

### Phase 3: Cloud/Infrastructure (Session 3)
- Add k9s
- Verify kubectl + helm
- Add lazydocker
- Configure Kubernetes integration

### Phase 4: Polish & Optimization (Session 4)
- Add git aliases
- Optimize shell startup
- Tweak editor configs
- Document all changes

---

## Command Reference

### To search nixpkgs:
```bash
nix search nixpkgs <package-name>
```

### To add package to home.packages:
```nix
home.packages = with pkgs; [
  # ... existing packages
  delta
  eza
  zoxide
  atuin
  pre-commit
];
```

### To enable programs:
```nix
programs.delta.enable = true;
programs.zoxide.enable = true;
programs.atuin.enable = true;
programs.pre-commit-hooks.enable = true;
```

---

## Checklist for Implementation

- [ ] Phase 1 complete and tested
- [ ] Phase 2 complete and tested
- [ ] Phase 3 complete and tested
- [ ] Phase 4 complete and tested
- [ ] All changes documented
- [ ] Git push successful
- [ ] System rebuilt with new config


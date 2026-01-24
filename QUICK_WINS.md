# Quick Wins - Immediate Improvements (15-30 minutes)

## What to Add NOW

### 1. Delta (Syntax-Highlighted Diffs)
```nix
# In modules/home/default.nix, update git config:
programs.git = {
  enable = true;
  settings = {
    user.name = "Gabriel Faucher";
    user.email = "gpfaucher@gmail.com";
    init.defaultBranch = "main";
    pull.rebase = true;
    push.autoSetupRemote = true;
  };
  delta = {
    enable = true;
    options = {
      syntax-theme = "gruvbox";
      side-by-side = true;
      line-numbers = true;
    };
  };
};
```

### 2. Eza (Modern ls)
```nix
# In modules/home/shell.nix, add to packages:
home.packages = with pkgs; [
  # ... existing
  eza
];

# Add to Fish aliases:
shellAbbrs = {
  # ... existing
  ls = "eza";
  ll = "eza -lah";
  llt = "eza --tree";
  lt = "eza --tree --long";
};
```

### 3. Zoxide (Smart cd)
```nix
# In modules/home/shell.nix:
programs.zoxide = {
  enable = true;
  enableFishIntegration = true;
};
```

### 4. Atuin (Shell History)
```nix
# In modules/home/shell.nix:
programs.atuin = {
  enable = true;
  enableFishIntegration = true;
  settings = {
    auto_sync = true;
    sync_address = "";  # Or set to your server
    db_path = "~/.local/share/atuin/history.db";
  };
};
```

## Testing After Changes

```bash
# Rebuild your home configuration
home-manager switch -b backup

# Test delta
git diff

# Test eza
ls -la
ll
llt

# Test zoxide
z /tmp
zi  # Interactive selection

# Test atuin
history  # Or press Ctrl+R for search
```

## Files to Modify

1. `modules/home/default.nix` - Git config
2. `modules/home/shell.nix` - Zoxide, atuin, eza aliases

## Expected Time: 15-20 minutes (plus rebuild)

## Next Steps

After these work:
1. Add pre-commit hooks (session 2)
2. Add k9s for Kubernetes (session 3)
3. Optimize shell startup (ongoing)


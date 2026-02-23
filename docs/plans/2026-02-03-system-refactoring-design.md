# System Configuration Deep Refactoring Plan

**Date:** 2026-02-03
**Status:** Design - Awaiting Approval

## Overview

Comprehensive refactoring of the NixOS system configuration based on a 10-agent audit covering: flake structure, home modules, system modules, packages/overlays, documentation, secrets, git workflow, scripts, dependencies, and desktop/UI.

### Design Decisions (User-Confirmed)

| Decision | Choice |
|----------|--------|
| Parameterization | Per-host overlays |
| Module splitting | Split by concern (core/lsp/plugins/keybinds) |
| Graphics consolidation | Single module with options |
| Zed integration | Primary editor, add to home-manager |
| Worktree support | Remove entirely |
| Claude Code config | Remove module, keep `claude` command only |
| OpenCode | Remove entirely |

---

## Phase 1: Cleanup & Dead Code Removal

### 1.1 Remove Worktree Infrastructure

**Files to delete:**
- `modules/home/claude-code.nix` - Contains `paddock-workspace` and worktree scripts
- `modules/home/opencode.nix` - OpenCode AI assistant config
- `scripts/test-river-resume.sh` - River WM test script (River deleted)
- `.worktrees/` directory - All worktree directories

**Files to modify:**
- `modules/home/default.nix` - Remove claude-code.nix and opencode.nix imports
- `flake.nix` - Remove any worktree-related comments

**Shell abbreviations to remove:**
- `pw` → `paddock-workspace` (in shell.nix if present)

### 1.2 Remove Dead Code & Commented Sections

| File | Lines | Content to Remove |
|------|-------|-------------------|
| `modules/home/terminal.nix` | 37-43 | Commented Ghostty keybindings |
| `modules/home/services.nix` | 5+ | Commented EasyEffects config (or delete entire file if empty) |
| `modules/home/default.nix` | 25-28 | Beads module disable block (FIXME comment) |
| `modules/system/bluetooth-monitor.nix` | 72 | Commented notification line |
| `modules/system/bootloader.nix` | 22-30 | Commented Windows EFI section (move to docs if needed) |
| `modules/system/hardening.nix` | 109 | TODO comment for AppArmor (implement or document) |

### 1.3 Remove Unused Flake Inputs

**Remove from flake.nix inputs:**
- `nur` - Not referenced anywhere in configuration

**Update flake.lock:**
```bash
nix flake update
```

### 1.4 Documentation Cleanup

**Delete duplicate files:**
- `docs/RESEARCH-SUMMARY.md` OR `docs/RESEARCH_SUMMARY.md` (keep one)
- Consolidate wallpaper docs (3 files → 1)
- Consolidate worktree docs (4 files → 1 or delete if removing worktrees)

**Create:**
- `docs/README.md` - Navigation index for documentation

---

## Phase 2: Per-Host Overlay Parameterization

### 2.1 Create Host-Specific Overlays

**New file structure:**
```
hosts/
├── laptop/
│   ├── default.nix
│   ├── hardware.nix
│   └── overlay.nix      # NEW: Host-specific values
└── nixbox/
    ├── default.nix
    ├── hardware.nix
    └── overlay.nix      # NEW: Host-specific values
```

**hosts/laptop/overlay.nix:**
```nix
{ lib, ... }:
final: prev: {
  # Host-specific configuration values
  hostConfig = {
    username = "gabriel";
    homeDirectory = "/home/gabriel";
    
    # Hardware identifiers
    gpu = {
      amdBusId = "PCI:198:0:0";
      nvidiaBusId = "PCI:1:0:0";
      mode = "hybrid-sync";  # hybrid-sync | hybrid-offload | nvidia-only
    };
    
    # Bluetooth devices
    bluetooth = {
      boseHeadset = {
        mac = "E4:58:BC:BE:10:AA";
        name = "Bose QC Ultra";
      };
    };
    
    # Network
    network = {
      type = "wireless";  # wireless | wired
    };
    
    # AWS
    aws = {
      region = "eu-central-1";
    };
  };
}
```

**hosts/nixbox/overlay.nix:**
```nix
{ lib, ... }:
final: prev: {
  hostConfig = {
    username = "gabriel";
    homeDirectory = "/home/gabriel";
    
    gpu = {
      nvidiaBusId = "PCI:1:0:0";
      mode = "nvidia-only";
    };
    
    bluetooth = {};  # No Bluetooth devices
    
    network = {
      type = "wired";
    };
    
    aws = {
      region = "eu-central-1";
    };
  };
}
```

### 2.2 Update flake.nix to Use Host Overlays

```nix
nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ./hosts/laptop/default.nix
    {
      nixpkgs.overlays = [
        (import ./hosts/laptop/overlay.nix { inherit lib; })
        (final: prev: { beads = beads.packages.${system}.default; })
      ];
    }
    # ... rest of modules
  ];
};
```

### 2.3 Update Modules to Use hostConfig

**Example: modules/system/audio.nix**
```nix
{ config, pkgs, lib, ... }:
let
  cfg = pkgs.hostConfig;
  boseMAC = cfg.bluetooth.boseHeadset.mac or null;
in
{
  # Use cfg.username instead of hardcoded "gabriel"
  # Use boseMAC instead of hardcoded MAC address
}
```

**Files requiring hostConfig updates:**
- `modules/system/audio.nix` - Username, Bluetooth MAC
- `modules/system/graphics.nix` - GPU bus IDs
- `modules/system/graphics-vr.nix` - GPU bus IDs (before consolidation)
- `modules/system/nvidia-desktop.nix` - GPU config (before consolidation)
- `modules/system/kubernetes.nix` - Home directory paths
- `modules/system/vr.nix` - Username in paths
- `modules/home/default.nix` - Home directory, AWS region
- `modules/home/opencode.nix` - Project paths
- `modules/home/terminal.nix` - Home directory
- `secrets/default.nix` - SSH key path, credentials path

---

## Phase 3: Module Consolidation

### 3.1 Consolidate Graphics Modules

**Delete after consolidation:**
- `modules/system/graphics-vr.nix`
- `modules/system/nvidia-desktop.nix`

**Refactored modules/system/graphics.nix:**
```nix
{ config, pkgs, lib, ... }:
let
  cfg = pkgs.hostConfig.gpu;
  mode = cfg.mode;  # "hybrid-sync" | "hybrid-offload" | "nvidia-only"
in
{
  # Common Wayland environment variables (extracted, no duplication)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # ... other common vars
  };

  # Mode-specific configuration
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # NVIDIA configuration (all modes)
  hardware.nvidia = lib.mkIf (mode != "amd-only") {
    modesetting.enable = true;
    powerManagement.enable = mode == "hybrid-sync";
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    
    # PRIME configuration for hybrid modes
    prime = lib.mkIf (lib.hasPrefix "hybrid" mode) {
      sync.enable = mode == "hybrid-sync";
      offload = lib.mkIf (mode == "hybrid-offload") {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = cfg.amdBusId or null;
      nvidiaBusId = cfg.nvidiaBusId;
    };
  };

  # AMD configuration for hybrid modes
  hardware.amdgpu = lib.mkIf (lib.hasPrefix "hybrid" mode) {
    initrd.enable = true;
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    libva-utils
    nvtopPackages.nvidia
    vulkan-tools
  ];
}
```

### 3.2 Consolidate Beads Overlay

**Current (duplicated 3x in flake.nix):**
```nix
overlays = [
  (final: prev: { beads = beads.packages.${system}.default; })
];
```

**Refactored (single definition):**
```nix
# In flake.nix let block
sharedOverlays = system: [
  (final: prev: { beads = beads.packages.${system}.default; })
];

# Then in each nixosConfiguration
nixpkgs.overlays = (sharedOverlays system) ++ [
  (import ./hosts/laptop/overlay.nix { inherit lib; })
];
```

### 3.3 Split nvf.nix (774 lines → 4 files)

**New structure:**
```
modules/home/nvf/
├── default.nix     # Main entry, imports others (~50 lines)
├── core.nix        # Basic settings, theme, leader key (~100 lines)
├── lsp.nix         # LSP servers, treesitter, formatters (~300 lines)
├── plugins.nix     # Plugin configuration (~200 lines)
└── keybinds.nix    # All keybindings (~150 lines)
```

**modules/home/nvf/default.nix:**
```nix
{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./core.nix
    ./lsp.nix
    ./plugins.nix
    ./keybinds.nix
  ];

  programs.nvf.enable = true;
}
```

### 3.4 Split default.nix (288 lines → 5 files)

**New structure:**
```
modules/home/
├── default.nix     # Main entry, imports (~30 lines)
├── git.nix         # Git configuration (~25 lines)
├── firefox.nix     # Firefox + userChrome (~70 lines)
├── aws.nix         # AWS CLI config (~20 lines)
├── packages.nix    # Package list by category (~120 lines)
└── zed.nix         # NEW: Zed editor config
```

---

## Phase 4: Zed Editor Integration

### 4.1 Create Zed Module

**New file: modules/home/zed.nix**
```nix
{ config, pkgs, lib, ... }:
{
  programs.zed-editor = {
    enable = true;
    
    extensions = [
      "nix"
      "toml"
      "dockerfile"
      "git-firefly"
    ];
    
    userSettings = {
      theme = "Ayu Dark";
      
      ui_font_size = 16;
      buffer_font_size = 14;
      buffer_font_family = "Monaspace Neon";
      
      vim_mode = true;
      relative_line_numbers = true;
      
      terminal = {
        shell = {
          program = "fish";
        };
        font_family = "JetBrainsMono Nerd Font";
        font_size = 13;
      };
      
      # LSP configuration
      lsp = {
        nil = {
          initialization_options = {
            formatting.command = [ "nixfmt" ];
          };
        };
      };
      
      # Claude integration (Zed has built-in AI)
      assistant = {
        enabled = true;
        default_model = {
          provider = "anthropic";
          model = "claude-sonnet-4-20250514";
        };
      };
      
      # File associations
      file_types = {
        "Nix" = [ "*.nix" ];
      };
    };
    
    userKeymaps = [
      # Add custom keymaps if needed
    ];
  };
}
```

### 4.2 Update default.nix imports

```nix
imports = [
  ./git.nix
  ./firefox.nix
  ./aws.nix
  ./packages.nix
  ./shell.nix
  ./ssh.nix
  ./zellij.nix
  ./nvf
  ./terminal.nix
  ./theme.nix
  ./beads.nix
  ./opencode.nix
  ./zed.nix  # NEW
];
```

---

## Phase 5: Secrets & Security

### 5.1 Add Missing Secrets to Agenix

**New secrets to encrypt:**
- `secrets/github-token.age` - For MCP GitHub server
- `secrets/database-url.age` - For MCP PostgreSQL server (if used)

**Update secrets/secrets.nix:**
```nix
let
  gabriel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE07KLDWLqBJHPYzj3sREYGu/22AEWv+J2EpX2i81bHh";
in
{
  "aws-credentials.age".publicKeys = [ gabriel ];
  "github-token.age".publicKeys = [ gabriel ];
}
```

### 5.2 Enable AppArmor Hardening

**Update modules/system/hardening.nix:**
```nix
security.apparmor.killUnconfinedConfinables = true;  # Remove TODO, enable
```

---

## Phase 6: Dependency Hygiene

### 6.1 Update flake.nix Inputs

**Changes:**
```nix
inputs = {
  # Change from tarball to git ref for better reproducibility
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  # Remove NUR (unused)
  # nur.url = "github:nix-community/NUR";  # DELETE
  
  # Ensure all inputs follow root nixpkgs
  ghostty.inputs.nixpkgs.follows = "nixpkgs";  # ADD
  
  # ... rest unchanged
};
```

### 6.2 Update Lock File

```bash
# After flake.nix changes
nix flake update

# Verify build
nix flake check
```

---

## Phase 7: Documentation

### 7.1 Create docs/README.md

```markdown
# System Configuration Documentation

## Structure

- `plans/` - Implementation designs (dated)
- `archive/` - Completed research and old designs

## Active Plans

- [2026-02-03 System Refactoring](plans/2026-02-03-system-refactoring-design.md)

## Quick References

- [Beads Quickstart](BEADS_QUICKSTART.md)
- [Parallel Agent Workflow](PARALLEL-AGENT-QUICKSTART.md)

## Archived

See `archive/` for completed research on:
- River WM (migrated to KDE Plasma)
- Monorepo LSP setup
- Impermanence configuration
```

### 7.2 Archive Stale Documents

**Move to archive/:**
- All River WM documentation
- Worktree-related docs (after removal)
- `2026-01-21-nixos-migration-design.md` (completed)

---

## Implementation Order

### Wave 1: Cleanup (Low Risk)
1. Remove worktree infrastructure (1.1)
2. Remove dead code (1.2)
3. Remove unused flake inputs (1.3)
4. Documentation cleanup (1.4)

### Wave 2: Parameterization (Medium Risk)
5. Create host overlays (2.1)
6. Update flake.nix (2.2)
7. Update modules to use hostConfig (2.3)

### Wave 3: Module Refactoring (Medium Risk)
8. Consolidate graphics modules (3.1)
9. Consolidate beads overlay (3.2)
10. Split nvf.nix (3.3)
11. Split default.nix (3.4)

### Wave 4: New Features (Low Risk)
12. Add Zed editor (4.1, 4.2)

### Wave 5: Security & Dependencies (Low Risk)
13. Add missing secrets (5.1)
14. Enable AppArmor (5.2)
15. Update flake inputs (6.1, 6.2)

### Wave 6: Documentation (Low Risk)
16. Create docs/README.md (7.1)
17. Archive stale docs (7.2)

---

## Verification Checklist

After each wave:
- [ ] `nix flake check` passes
- [ ] `nixos-rebuild build --flake .#laptop` succeeds
- [ ] `nixos-rebuild build --flake .#nixbox` succeeds
- [ ] No new warnings in build output
- [ ] Test switch on laptop (if safe)

---

## Risk Assessment

| Change | Risk | Mitigation |
|--------|------|------------|
| Graphics consolidation | Medium | Test thoroughly before switch |
| Parameterization | Low | Values unchanged, just moved |
| Module splitting | Low | No functional changes |
| Worktree removal | Low | Backup scripts first |
| Zed addition | Low | New feature, no breaking changes |
| Flake update | Medium | Build before switch |

---

## Rollback Plan

1. Git branch before starting: `git checkout -b pre-refactor-backup`
2. Test builds after each wave before committing
3. Keep old modules commented (not deleted) until verified
4. Full system rebuild test before `nixos-rebuild switch`

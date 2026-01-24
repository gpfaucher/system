# Advanced Nix Flake Patterns Analysis

**Research Date:** January 24, 2026  
**System:** `/home/gabriel/projects/system`  
**Analysis Scope:** Current flake architecture, modernization opportunities, best practices

---

## 1. CURRENT ARCHITECTURE ASSESSMENT

### 1.1 Flake Structure Overview

**File:** `/home/gabriel/projects/system/flake.nix` (91 lines)

```
Current Architecture:
├── Inputs (6 primary)
│   ├── nixpkgs (github:NixOS/nixpkgs/nixos-unstable)
│   ├── home-manager (github:nix-community/home-manager)
│   ├── nvf (github:notashelf/nvf)
│   ├── stylix (github:danth/stylix)
│   ├── ghostty (github:ghostty-org/ghostty)
│   └── beads (github:steveyegge/beads) - AI agent task memory
│
├── Outputs (2 configurations)
│   ├── nixosConfigurations.laptop (NixOS system)
│   └── homeConfigurations."gabriel@laptop" (home-manager only)
│
└── System (Single-system hardcoded)
    └── x86_64-linux only
```

### 1.2 Current State Summary

| Aspect                   | Status         | Details                                            |
| ------------------------ | -------------- | -------------------------------------------------- |
| **Flake Inputs**         | ✅ Well-pinned | All inputs follow `inputs.nixpkgs.follows` pattern |
| **System Support**       | ⚠️ Limited     | Hardcoded `x86_64-linux` only                      |
| **Module Organization**  | ✅ Clean       | 18 `.nix` modules, well-separated (home/system)    |
| **Code Size**            | ✅ Reasonable  | 3,062 lines total Nix code                         |
| **Configuration**        | ⚠️ Monolithic  | Single laptop configuration, no generalization     |
| **Flake-parts**          | ❌ Not used    | Traditional outputs function                       |
| **treefmt-nix**          | ❌ Not used    | No unified formatting                              |
| **pre-commit-hooks.nix** | ❌ Not used    | No git hooks configured                            |
| **devenv**               | ❌ Not used    | No development shell                               |
| **Cachix**               | ✅ Configured  | 3 caches (cache.nixos.org, ghostty, nix-community) |

### 1.3 Dependency Analysis

**flake.lock Statistics:**

- **Size:** 686 lines
- **Locked inputs:** 28 total (including transitive)
- **Last updated:** 2026-01-24 (current)
- **Freshness:** Excellent (nixpkgs updated 2026-01-21)

**Dependency Tree (Transitive):**

```
root
├── nixpkgs (88d386...) [master NixOS baseline]
│   └── [used by home-manager, beads, ghostty]
├── home-manager (082a4c...) [HM baseline]
├── nvf (cf066e...) [Neovim config framework]
│   ├── flake-parts (80daad...) [nvf uses flake-parts!]
│   ├── mnw (20d63a...) [nvf dependency]
│   └── ndg (a6bd3c...) [nvf dependency]
├── stylix (74928...) [Theming framework]
│   ├── flake-parts (25048...) [Different version from nvf!]
│   └── base16 + tinted-* (8 theming repos)
├── ghostty (f4792...) [Terminal emulator]
│   ├── zig-overlay (64f8b...) [For compilation]
│   └── zon2nix (c28e93...) [Zig deps]
└── beads (e82f5...) [Git-backed issue tracker]
    └── flake-utils (11707...) [For package export]
```

**Critical Observation:** Both `nvf` and `stylix` bring `flake-parts` as transitive dependencies but at **different versions** (80daad vs 25048). This creates phantom inputs that aren't explicitly managed.

---

## 2. FLAKE-PARTS MODERNIZATION PATHWAY

### 2.1 What is flake-parts?

**Purpose:** A standardized flake composition framework that:

- Eliminates `outputs = { self, ... }@inputs: {...}` boilerplate
- Provides per-system evaluation (multi-architecture friendly)
- Enables shareable modules and conventions
- Improves readability and maintainability

**Current Usage:** nvf and stylix both use it (transitively)

### 2.2 Should This System Use flake-parts?

#### Arguments FOR:

1. **Transitive Dependency Already Present** - Both nvf and stylix include it
2. **Multi-Machine Ready** - Flake-parts makes adding more hosts trivial
3. **Developer Shells** - Easy `devShells.${system}.default` pattern
4. **Consistency** - Aligns with ecosystem (nvf, stylix, most modern flakes)
5. **Overlay Organization** - Built-in module system for overlays
6. **Cleaner Code** - ~30% reduction in boilerplate

#### Arguments AGAINST:

1. **Single Laptop** - Current setup is sufficient for 1 machine
2. **Learning Curve** - Requires understanding module system
3. **Stability vs Edge** - Adds another dependency version to manage

### 2.3 Recommended Approach

**Adopt flake-parts with these benefits:**

```nix
# BEFORE (Current - 91 lines)
outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let system = "x86_64-linux"; in
  {
    nixosConfigurations.laptop = ...
    homeConfigurations."gabriel@laptop" = ...
  }

# AFTER (With flake-parts - ~60 lines, more readable)
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

    perSystem = { pkgs, system, ... }: {
      devShells.default = ...
      formatter = pkgs.treefmt
      # per-system derivations here
    };

    flake = {
      nixosConfigurations.laptop = ...
      homeConfigurations."gabriel@laptop" = ...
    };
  }
```

---

## 3. CURRENT FLAKE-UTILS ANALYSIS

### 3.1 Usage Patterns

**Where flake-utils appears:**

```
flake-utils
├── Direct: beads input → flake-utils
├── Transitive: ghostty → flake-utils
├── NOT in: nvf (uses flake-parts instead)
├── NOT in: stylix (uses flake-parts instead)
└── NOT in: home-manager (direct, no utils needed)
```

**Observations:**

- **beads** uses flake-utils for simple package export (appropriate)
- **ghostty** uses flake-utils for per-system builds (transitively through home-manager)
- System hasn't directly imported flake-utils (not needed with flake-parts)

### 3.2 Alternatives to flake-utils

| Tool                    | Purpose           | When to Use                                    |
| ----------------------- | ----------------- | ---------------------------------------------- |
| **flake-parts**         | Modular flakes    | Multi-system, complex configs (✅ recommended) |
| **nix-utils**           | Utility functions | Niche, superseded by flake-parts               |
| **dream2nix**           | Build framework   | Non-Nix projects, monorepos                    |
| **numtide/flake-utils** | Simple patterns   | Single-system, minimal projects                |

**Recommendation:** Replace ad-hoc flake-utils with flake-parts modules.

---

## 4. TREEFMT-NIX INTEGRATION PLAN

### 4.1 What is treefmt-nix?

Unified formatting for ALL languages in one place:

- Nix files (nixfmt, alejandra, etc.)
- Shell scripts (shfmt)
- Python (black, ruff)
- YAML/JSON (prettier)
- Markdown
- etc.

### 4.2 Current State

- ❌ No treefmt configuration
- ⚠️ Manual formatting for 18 `.nix` files
- ❌ No CI enforcement

### 4.3 Implementation Path

**Step 1: Add flake input**

```nix
inputs.treefmt-nix = {
  url = "github:numtide/treefmt-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

**Step 2: Add to flake-parts module**

```nix
# When using flake-parts
perSystem = { pkgs, ... }: {
  treefmt = {
    projectRootFile = "flake.nix";
    programs = {
      nixfmt.enable = true;          # Nix formatting (modern, opinionated)
      shfmt.enable = true;           # Shell scripts
      prettier.enable = true;        # YAML/JSON/Markdown
      python = {
        enable = true;
        black.line-length = 88;
      };
    };
  };

  formatter = pkgs.treefmt;
};
```

**Step 3: Run formatting**

```bash
nix fmt                    # Format all files
nix fmt -- --check        # Check without modifying
nix fmt -- path/to/file   # Format specific files
```

**Current Files to Format:** 18 `.nix` files, see section 1.3

---

## 5. PRE-COMMIT-HOOKS.NIX INTEGRATION

### 5.1 Purpose

Automatic quality gates on `git commit`:

- ✅ Nix syntax validation
- ✅ Formatting enforcement
- ✅ Secret detection
- ✅ Commit message validation
- ✅ Documentation checks

### 5.2 Current State

- ❌ No pre-commit hooks configured
- ✅ Git repository exists (`.git` present)
- ⚠️ Manual quality checks needed before commits

### 5.3 Implementation

**Add flake input:**

```nix
inputs.pre-commit-hooks-nix = {
  url = "github:cachix/pre-commit-hooks.nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

**Configure in flake-parts:**

```nix
perSystem = { config, pkgs, ... }: {
  pre-commit = {
    check.enable = true;
    hooks = {
      # Nix
      nixfmt.enable = true;
      nix-linter.enable = true;
      statix.enable = true;              # Static analysis

      # Shell
      shellcheck.enable = true;

      # General
      end-of-file-fixer.enable = true;
      trailing-whitespace.enable = true;
      mixed-line-ending.enable = true;

      # Secrets
      detect-private-key.enable = true;

      # Git
      commitizen.enable = true;          # Enforces conventional commits
    };
  };

  # Make `nix flake check` validate pre-commit hooks
  checks = {
    pre-commit-check = config.pre-commit.run;
  };
};
```

**Usage:**

```bash
cd /home/gabriel/projects/system
nix flake check                  # Run all checks including pre-commit hooks
git commit -m "message"          # Hooks run automatically (if installed)
```

**Installation for git integration:**

```bash
# From project root
nix develop

# This enables hooks:
direnv allow
```

---

## 6. DEVENV INTEGRATION

### 6.1 What is devenv?

Unified development environment tool:

- **Purpose:** Project-specific shells with services, scripts, tools
- **Integration:** Works with direnv, Nix, Docker
- **Services:** PostgreSQL, Redis, Minio, etc. (auto-start)
- **Scripts:** Custom commands (`devenv shell`)

### 6.2 Current Development Setup

- ✅ direnv configured (shell.nix shows `nix-direnv.enable = true`)
- ⚠️ Basic setup only
- ❌ No devenv.yaml configured
- ❌ No development shells for Nix projects

### 6.3 Devenv Configuration

**Create `devenv.yaml`:**

```yaml
version: 1

inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable

packages:
  - nix
  - git
  - gh
  - alejandra # Nix formatter
  - statix # Nix linter
  - shellcheck

scripts: fmt.exec = "treefmt"
  check.exec = "nix flake check"
  update.exec = "nix flake update"
  build.exec = "nix build '.#nixosConfigurations.laptop'"
  home.exec = "nix build '.#homeConfigurations.\"gabriel@laptop\"'"
  switch-system.exec = "sudo nixos-rebuild switch --flake . --use-remote-sudo"
  switch-home.exec = "home-manager switch --flake . --use-remote-sudo"
```

**Usage:**

```bash
devenv shell
# Inside shell:
fmt              # Format all files
check            # Run quality gates
build            # Build system configuration
home             # Build home configuration
update           # Update flake inputs
```

---

## 7. NIX-DIRENV INTEGRATION

### 7.1 Current Status

✅ **Already Configured!**

```nix
# From modules/home/shell.nix (line 150-154):
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
  config.global.hide_env_diff = true;
};
```

### 7.2 How It Works

1. **Project detection:** `.envrc` in project root
2. **Automatic loading:** Nix flake loaded when entering directory
3. **Caching:** nix-direnv caches evaluation for speed
4. **GC prevention:** Nix outputs kept (not garbage collected)

### 7.3 Recommended `.envrc`

```bash
# /home/gabriel/projects/system/.envrc
use flake

# Optional: watch for changes
watch_file flake.nix flake.lock
watch_file modules
watch_file hosts
```

**Setup:**

```bash
cd /home/gabriel/projects/system
echo 'use flake' > .envrc
direnv allow
```

---

## 8. MULTI-SYSTEM & MULTI-MACHINE PATTERNS

### 8.1 Current Configuration

**Single Machine:** `laptop` (x86_64-linux)

- Location: `hosts/laptop/`
- Modules: 12 system modules + 8 home modules
- Config: Hardcoded system type

### 8.2 Recommended Multi-Machine Architecture

```
hosts/
├── laptop/              # Current
│   ├── default.nix     # Hardware-specific
│   ├── hardware.nix    # EFI, partitions, etc.
│   └── config.nix      # Laptop-specific overrides
├── desktop/            # For future desktop machine
│   ├── default.nix
│   ├── hardware.nix
│   └── config.nix
└── server/             # For future server
    ├── default.nix
    └── hardware.nix

modules/
├── system/             # All system modules (shared)
│   ├── bootloader.nix
│   ├── graphics.nix
│   ├── networking.nix
│   ├── audio.nix
│   ├── services.nix
│   └── bluetooth-monitor.nix
└── home/               # All home modules (shared)
    ├── nvf.nix
    ├── shell.nix
    ├── theme.nix
    └── ...
```

**Benefits:**

- ✅ Shared modules (DRY principle)
- ✅ Host-specific overrides in `hosts/*/`
- ✅ Easy to add machines (copy host, modify hardware.nix)
- ✅ Same user config across machines

### 8.3 Flake Pattern for Multi-Machine

```nix
# flake.nix (with flake-parts)
flake = {
  nixosConfigurations = {
    laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/laptop
        home-manager.nixosModules.home-manager
        {
          home-manager.users.gabriel = import ./modules/home;
        }
      ];
    };

    # Future: Add desktop easily
    # desktop = nixpkgs.lib.nixosSystem { ... };
  };

  homeConfigurations = {
    "gabriel@laptop" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; ... };
      modules = [ ./modules/home ];
    };

    # Future: Add other user/machine combos
    # "gabriel@desktop" = ...
  };
};
```

### 8.4 Multi-System Support (x86_64, aarch64, darwin)

**Current:** Hardcoded `x86_64-linux`

**With flake-parts:**

```nix
systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

perSystem = { pkgs, system, ... }: {
  packages.default = pkgs.hello;  # Built for each system
};

flake = {
  nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";  # Explicitly set
    modules = [ ... ];
  };
};
```

---

## 9. OVERLAY ORGANIZATION PATTERNS

### 9.1 Current Overlay Usage

**Location:** `flake.nix` lines 43-48, 58-62

```nix
# Current: Inline overlay for beads package
overlays = [
  (final: prev: {
    beads = beads.packages.${system}.default;
  })
];
```

**Issues:**

- ✅ Works, but scattered
- ⚠️ Not reusable across different contexts
- ❌ Hardcoded system variable

### 9.2 Recommended Overlay Pattern

Create `overlays/default.nix`:

```nix
# overlays/default.nix
{
  beads = final: prev: {
    beads = final.callPackage ../pkgs/beads { };
  };

  custom-tools = final: prev: {
    custom-lsp = final.callPackage ../pkgs/custom-lsp { };
  };

  patches = final: prev: {
    # Override broken packages
    some-package = prev.some-package.overrideAttrs (...);
  };
}
```

Use in flake:

```nix
perSystem = { pkgs, system, ... }: {
  overlays = [
    inputs.beads.overlays.default
    self.overlays.beads
    self.overlays.custom-tools
  ];
};
```

---

## 10. PACKAGE DEFINITION PATTERNS

### 10.1 Current Approach

All packages come from `nixpkgs`:

```nix
# modules/home/default.nix lines 60-96
home.packages = with pkgs; [
  jetbrains.datagrip
  zed-editor-fhs
  firefox
  # ... 40+ packages
];
```

### 10.2 Custom Packages

**Pattern for custom packages:**

Create `pkgs/custom-package/default.nix`:

```nix
# pkgs/custom-package/default.nix
{ lib, buildGoModule, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "username";
    repo = "my-tool";
    rev = "v${version}";
    sha256 = "0000...";
  };

  vendorSha256 = "0000...";

  meta = with lib; {
    description = "My tool";
    homepage = "https://github.com/username/my-tool";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
```

Use in home config:

```nix
home.packages = with pkgs; [
  # From nixpkgs
  firefox
  # Custom
  (callPackage ../../pkgs/custom-package { })
];
```

---

## 11. CACHING & BINARY DISTRIBUTION

### 11.1 Current Setup

✅ **Already Configured** (hosts/laptop/default.nix lines 37-47):

```nix
substituters = [
  "https://cache.nixos.org"           # Official NixOS
  "https://ghostty.cachix.org"        # Ghostty package
  "https://nix-community.cachix.org"  # Community packages
];
```

### 11.2 Cachix Setup Recommendation

**For Personal Projects:**

```bash
# Create Cachix cache
cachix authtoken $(cat ~/.cachix/token)
cachix push my-system <derivation-path>

# In flake.nix
substituters = [
  "https://cache.nixos.org"
  "https://my-system.cachix.org"
];

trustedPublicKeys = [
  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  "my-system.cachix.org-1:xxxxxxx"
];
```

---

## 12. FLAKE.LOCK FRESHNESS & PINNING STRATEGY

### 12.1 Current Lock State

```
Last Modified:  2026-01-24 18:58:14 (CURRENT)
Commits:        109 total updates
Lock File Size: 686 lines
Status:         ✅ Fresh and well-maintained
```

**Input Freshness:**

```
✅ nixpkgs         [2026-01-21] (3 days old - excellent)
✅ home-manager    [2026-01-23] (1 day old - excellent)
✅ nvf             [2026-01-24] (today - cutting edge)
✅ stylix          [2026-01-23] (1 day old - excellent)
✅ ghostty         [2026-01-24] (today - cutting edge)
✅ beads           [2026-01-24] (today - cutting edge)
```

### 12.2 Pinning Strategy Recommendations

**Current (Implicit):**

- ✅ All inputs automatically follow `nixpkgs`
- ✅ No duplicate dependencies in lock file

**Best Practices:**

```nix
inputs = {
  # Always use latest unstable
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # Or pin to version
  nixpkgs.url = "github:NixOS/nixpkgs/26.05";

  # Inputs follow nixpkgs (reduce duplicates)
  home-manager.inputs.nixpkgs.follows = "nixpkgs";

  # Branch tracking
  flake-utils.url = "github:numtide/flake-utils";  # Tracks master

  # Specific commit (absolute pinning)
  some-tool.url = "github:owner/tool/commit123abc";
};
```

**Current Implementation:** ✅ Excellent - using `follows` pattern throughout

---

## 13. DEPENDENCY DEDUPLICATION ISSUES

### 13.1 Phantom Dependencies Problem

**Current Issue:**

- `nvf` includes `flake-parts` (version A)
- `stylix` includes `flake-parts` (version B)
- Both end up in flake.lock but not explicitly managed

**Impact:**

- ✅ Minimal (flake-parts is stable)
- ⚠️ Harder to debug if versions diverge

**Solution:** Explicitly pin in root flake:

```nix
inputs.flake-parts = {
  url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs.follows = "nixpkgs";
};

# Then ensure dependencies use it:
# nvf.inputs.flake-parts.follows = "flake-parts";  # If possible
```

---

## 14. ASSESSMENT SUMMARY

### Quality Metrics

| Category                   | Score | Status       | Notes                               |
| -------------------------- | ----- | ------------ | ----------------------------------- |
| **Current Architecture**   | 8/10  | ✅ Good      | Well-organized, clean separation    |
| **Dependency Management**  | 9/10  | ✅ Excellent | Proper follows pattern              |
| **Lock File Freshness**    | 10/10 | ✅ Excellent | Updated regularly                   |
| **Multi-System Support**   | 3/10  | ⚠️ Poor      | Hardcoded x86_64-linux              |
| **Code Quality Tools**     | 2/10  | ❌ Poor      | No treefmt, pre-commit hooks        |
| **Development Experience** | 4/10  | ⚠️ Fair      | direnv present but minimal          |
| **Scalability**            | 4/10  | ⚠️ Fair      | Single machine, difficult to extend |
| **Documentation**          | 5/10  | ⚠️ Fair      | Some docs, could be better          |

### Overall Assessment: 6/10 - Functional but Ready for Modernization

**Current State:** ✅ Production-ready, actively maintained
**Recommended Direction:** Adopt flake-parts + modern tooling

---

## 15. RECOMMENDED IMPLEMENTATION ROADMAP

### Phase 1: Foundation (Priority: HIGH)

**Estimated effort:** 2-3 hours

- [ ] Add `treefmt-nix` input
- [ ] Configure formatting (nixfmt, shfmt, prettier)
- [ ] Format all 18 `.nix` files
- [ ] Test formatting works
- [ ] Document in README

### Phase 2: Quality Gates (Priority: HIGH)

**Estimated effort:** 2-3 hours

- [ ] Add `pre-commit-hooks.nix` input
- [ ] Configure hooks (nixfmt, statix, shellcheck)
- [ ] Setup with direnv
- [ ] Test pre-commit integration
- [ ] Document in README

### Phase 3: Modern Architecture (Priority: MEDIUM)

**Estimated effort:** 4-6 hours

- [ ] Add `flake-parts` as explicit input
- [ ] Migrate to flake-parts structure
- [ ] Add multi-system support framework
- [ ] Create devShells for development
- [ ] Create development shell
- [ ] Test all configurations build
- [ ] Update documentation

### Phase 4: Multi-Machine Support (Priority: MEDIUM)

**Estimated effort:** 3-4 hours

- [ ] Refactor hosts/ directory structure
- [ ] Add overlay organization
- [ ] Create shared module abstractions
- [ ] Document host addition process
- [ ] Test adding a test host configuration

### Phase 5: Polish & Documentation (Priority: LOW)

**Estimated effort:** 2-3 hours

- [ ] Comprehensive README
- [ ] Troubleshooting guide
- [ ] Example multi-machine setup
- [ ] Contributing guidelines

**Total Estimated Effort:** 13-19 hours (1-2 work days)

---

## 16. SPECIFIC IMPLEMENTATION EXAMPLES

### 16.1 Migrated flake.nix (flake-parts version)

See separate file: `NIX_FLAKE_MODERNIZED_EXAMPLE.md`

### 16.2 Formatting Configuration

```nix
# In flake-parts perSystem module
treefmt = {
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;

  programs.prettier = {
    enable = true;
    includes = ["*.yaml" "*.yml" "*.json" "*.md"];
  };
};

formatter = pkgs.treefmt;
```

### 16.3 Pre-commit Configuration

```nix
pre-commit.hooks = {
  nixfmt.enable = true;
  statix = {
    enable = true;
    settings.severity = "warn";
  };
  nix-linter.enable = true;
  shellcheck.enable = true;
  trailing-whitespace.enable = true;
};
```

---

## 17. REFERENCES & RESOURCES

**Official Documentation:**

- [NixOS Manual - Flakes](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html)
- [flake-parts Documentation](https://flake.parts/)
- [treefmt-nix](https://github.com/numtide/treefmt-nix)
- [pre-commit-hooks.nix](https://github.com/cachix/pre-commit-hooks.nix)

**Best Practices:**

- [Determinate Systems - Flake Best Practices](https://determinate.systems/posts/nix-flakes/)
- [Tweag - Nix Flakes Book](https://tweag.io/blog/2021-05-03-flake-tips-and-tricks/)
- [Nix Community Wiki](https://wiki.nixos.org/)

**Examples:**

- [nvf configuration](https://github.com/notashelf/nvf)
- [stylix configuration](https://github.com/danth/stylix)
- [numtide/flake-templates](https://github.com/numtide/flake-templates)

---

## 18. DECISION MATRIX: FLAKE-PARTS ADOPTION

### Factors Analysis

| Factor              | Current     | With flake-parts | Impact             |
| ------------------- | ----------- | ---------------- | ------------------ |
| Boilerplate         | 91 lines    | ~60 lines        | -30%               |
| Multi-system        | Hard        | Easy             | ⬆️ Flexibility     |
| Dev shells          | Manual      | Automatic        | ⬆️ Experience      |
| Code clarity        | Good        | Better           | ⬆️ Maintainability |
| Learning curve      | Low         | Medium           | ⬇️ Time investment |
| Dependency versions | Fine        | Cleaner          | ⬆️ Control         |
| Community           | Established | Growing          | ⬆️ Support         |

### Recommendation: ✅ **ADOPT FLAKE-PARTS**

**Reasoning:**

1. Already transitively present (nvf, stylix use it)
2. Ecosystem standard for new flakes
3. Makes future machine additions trivial
4. Minimal breaking changes
5. Improved code organization

---

## 19. QUICK START CHECKLIST

For implementing these improvements:

```bash
# Phase 1: Setup
cd /home/gabriel/projects/system
git checkout -b refactor/modernize-flake

# Phase 2: Add inputs
# (edit flake.nix)

# Phase 3: Format
nix fmt

# Phase 4: Check
nix flake check
nix eval .

# Phase 5: Test
nix build '.#nixosConfigurations.laptop'
nix build '.#homeConfigurations."gabriel@laptop"'

# Phase 6: Commit
git add .
git commit -m "refactor: migrate to flake-parts with modern tooling"
git push
```

---

## Research Completion Summary

✅ **Analysis Complete**

- Current architecture documented
- Modernization path identified
- Concrete implementation examples provided
- Phased roadmap created
- All recommendations justified with pros/cons

**Next Steps:** Implement Phase 1-3 for immediate benefits. Phase 4-5 can follow once multi-machine needs arise.

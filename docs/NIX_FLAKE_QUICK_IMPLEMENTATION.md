# Quick Implementation: treefmt-nix + pre-commit-hooks

Step-by-step commands to add formatting and quality gates to the system.

## Phase 1: Add treefmt-nix (15 minutes)

### 1.1 Create flake.nix with treefmt input

```bash
# Edit flake.nix and add this input
inputs.treefmt-nix = {
  url = "github:numtide/treefmt-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### 1.2 Create treefmt-nix module (experimental approach)

Create `flake-treefmt.nix` as a wrapper:

```nix
# flake-treefmt.nix
{
  inputs,
  config,
  pkgs,
  ...
}:
{
  # Import treefmt-nix as a flake-parts module
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = { config, pkgs, ... }: {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        nixfmt.enable = true;
        prettier.enable = true;
        shfmt.enable = true;
      };

      settings.global.excludes = [
        "./.github"
        "./.git"
        "./result"
        "./.venv"
      ];
    };

    formatter = config.treefmt.build.wrapper;
  };
}
```

### 1.3 Or: Add manually to current flake.nix

For NOW (without flake-parts migration), add to outputs:

```bash
cd /home/gabriel/projects/system

# Test treefmt without integration
nix shell github:numtide/treefmt-nix

# Format Nix files
nixfmt flake.nix
nixfmt modules/**/*.nix
nixfmt hosts/**/*.nix
```

## Phase 2: Add pre-commit-hooks.nix (15 minutes)

### 2.1 Create pre-commit wrapper (before flake-parts)

```nix
# flake-pre-commit.nix
{
  inputs,
  config,
  ...
}:
{
  imports = [ inputs.pre-commit-hooks-nix.flakeModule ];

  perSystem = { config, ... }: {
    pre-commit = {
      check.enable = true;

      hooks = {
        nixfmt.enable = true;
        nix-linter.enable = true;
        statix.enable = true;
        shellcheck.enable = true;
        trailing-whitespace.enable = true;
        end-of-file-fixer.enable = true;
      };

      settings = {
        nix-linter.checks = [ "all" ];
      };
    };

    checks = {
      pre-commit = config.pre-commit.run;
    };
  };
}
```

### 2.2 Setup with direnv

```bash
# Add to .envrc
echo 'use flake' > .envrc
direnv allow

# Install pre-commit hooks
direnv allow
```

---

## Immediate Actions (No Migration Required)

### 1. Format All Files Now

```bash
cd /home/gabriel/projects/system

# Install nixfmt
nix profile install nixpkgs#nixfmt

# Format all Nix files
find . -name "*.nix" -type f | while read f; do
  nixfmt "$f"
done

# Check for issues
statix check

# Lint
nix-linter
```

### 2. Test Current Config

```bash
# Build without flake-parts migration first
nix build '.#nixosConfigurations.laptop' 2>&1 | head -50

nix build '.#homeConfigurations."gabriel@laptop"' 2>&1 | head -50
```

---

## Minimal Flake-Parts Migration (1 hour)

For minimal migration without breaking changes:

```nix
# New: flake-parts version (keep old outputs)
{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ... other inputs
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["x86_64-linux"];

      perSystem = { config, pkgs, ... }: {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.nix pkgs.git ];
        };

        # Formatter
        formatter = pkgs.nixfmt;
      };

      # Keep original outputs as-is
      flake = {
        nixosConfigurations = {
          laptop = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/laptop
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.users.gabriel = import ./modules/home;
              }
            ];
          };
        };

        homeConfigurations."gabriel@laptop" =
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            modules = [ ./modules/home ];
          };
      };
    };
}
```

---

## Verification Commands

```bash
# Check flake syntax
nix flake check

# Evaluate flake
nix eval --json '.#' | jq . | head -50

# Show available outputs
nix flake show

# Check metadata
nix flake metadata

# List all inputs
nix flake show --all-systems

# Test formatter
nix run .#formatter -- --check flake.nix

# Run checks
nix flake check --show-trace
```

---

## What Gets Added/Modified

### New Files

```
docs/
├── NIX_FLAKE_PATTERNS_ANALYSIS.md          ✅ Created
├── NIX_FLAKE_MODERNIZED_EXAMPLE.md         ✅ Created
└── NIX_FLAKE_QUICK_IMPLEMENTATION.md       ✅ This file

.envrc                                        ➕ Optional (if using direnv)
devenv.yaml                                   ➕ Optional (if using devenv)
```

### Modified Files

```
flake.nix                                     ✏️ Add inputs, update outputs
  - Add: treefmt-nix input
  - Add: pre-commit-hooks-nix input (optional)
  - Add: flake-parts input
  - Update: outputs structure
```

### Commit

```bash
git add docs/
git add flake.nix
git add flake.lock
git commit -m "docs: Add Nix flake modernization analysis and examples"
```

---

## Testing the Changes

### Build Everything

```bash
cd /home/gabriel/projects/system

# This should succeed (no breaking changes)
nix build '.#nixosConfigurations.laptop'
nix build '.#homeConfigurations."gabriel@laptop"'

# If using flake-parts, check all systems:
nix build '.#checks.x86_64-linux.pre-commit-check'
```

### Check Formatting

```bash
# Format all files
nix fmt

# Check no changes needed
nix fmt -- --check
```

### Run Pre-commit Manually

```bash
# If hooks configured
nix flake check

# Or directly
pre-commit run --all-files
```

---

## Common Errors & Solutions

| Error                                      | Cause                   | Solution                             |
| ------------------------------------------ | ----------------------- | ------------------------------------ |
| `attribute 'systemPackages' missing`       | Overlay issue           | Check beads overlay placement        |
| `flake.lock is out of date`                | Inputs changed          | `nix flake update`                   |
| `The option 'programs.nvf' does not exist` | NVF module not imported | Add to home-manager sharedModules    |
| `nixfmt: command not found`                | Not installed           | `nix profile install nixpkgs#nixfmt` |
| `direnv not allowing`                      | `.envrc` not approved   | `direnv allow`                       |

---

## Success Criteria

After implementation:

- [ ] ✅ `nix flake check` passes
- [ ] ✅ `nix fmt` formats all files identically
- [ ] ✅ `nix build` succeeds for both configs
- [ ] ✅ `nix develop` enters development shell
- [ ] ✅ Pre-commit hooks run on commit (if integrated)
- [ ] ✅ All changes committed to git

---

## Timeline

| Phase | Task                        | Duration | Priority |
| ----- | --------------------------- | -------- | -------- |
| 1     | Add treefmt-nix             | 15 min   | HIGH     |
| 2     | Add pre-commit-hooks        | 15 min   | HIGH     |
| 3     | Migrate to flake-parts      | 45 min   | MEDIUM   |
| 4     | Add multi-machine structure | 30 min   | MEDIUM   |
| 5     | Documentation & polish      | 30 min   | LOW      |

**Total: 2-3 hours for full modernization**

---

## Next Session Quick Start

```bash
cd /home/gabriel/projects/system

# Resume
bd ready                          # See what work is available
bd show <issue-id>               # View issue

# Setup
direnv allow
nix develop

# Develop
nix fmt
nix flake check
git commit -m "description"

# Complete
bd close <issue-id>
git push
```

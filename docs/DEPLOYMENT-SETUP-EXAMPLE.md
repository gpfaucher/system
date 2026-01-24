# Deployment Setup - Complete Example

This document provides copy-paste ready code to implement deploy-rs in the current NixOS flake configuration.

## Current Flake Structure

```nix
# Current flake.nix (simplified)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    # ... other inputs ...
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs username self; };
        modules = [ ... ];
      };
    };
}
```

## Step 1: Add deploy-rs Input

Edit `flake.nix` and add to inputs section:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager = { ... };

  # ADD THIS:
  deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # ... rest of inputs ...
};
```

## Step 2: Add deploy-rs to Outputs

Update the outputs function signature:

```nix
outputs = { self, nixpkgs, home-manager, deploy-rs, ... }@inputs:
  # ↑ ADD deploy-rs HERE
```

Then add deploy configuration before closing the output set:

```nix
outputs = { self, nixpkgs, home-manager, deploy-rs, ... }@inputs:
  let
    system = "x86_64-linux";
    # ... existing let bindings ...
  in
  {
    # ... existing outputs (nixosConfigurations, homeConfigurations) ...

    # ADD THIS SECTION:
    deploy.nodes = {
      laptop = {
        hostname = "localhost";  # For local deployment, or "actual-hostname" for remote
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos
            self.nixosConfigurations.laptop;
        };
      };

      # OPTIONAL: Add more nodes for multi-host
      # server = {
      #   hostname = "server.example.com";
      #   profiles.system = {
      #     user = "root";
      #     path = deploy-rs.lib.${system}.activate.nixos
      #       self.nixosConfigurations.server;
      #   };
      # };
    };

    # Add deployment checks
    checks = builtins.mapAttrs
      (system: deployLib: deployLib.deployChecks self.deploy)
      deploy-rs.lib;
  };
```

## Step 3: Complete Flake Example

```nix
{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";
    ghostty.url = "github:ghostty-org/ghostty";

    beads = {
      url = "github:steveyegge/beads";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ADDED: Deploy-rs for deployment management
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nvf, stylix, ghostty, beads, deploy-rs, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "gabriel";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            beads = beads.packages.${system}.default;
          })
        ];
      };
    in
    {
      # EXISTING: NixOS configurations
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs username self; };
        modules = [
          {
            nixpkgs.hostPlatform = system;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              (final: prev: {
                beads = beads.packages.${system}.default;
              })
            ];
          }
          stylix.nixosModules.stylix
          ./hosts/laptop
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username self; };
              sharedModules = [
                inputs.nvf.homeManagerModules.default
                inputs.stylix.homeModules.stylix
              ];
              users.${username} = import ./modules/home;
            };
          }
        ];
      };

      # EXISTING: Home configurations
      homeConfigurations."${username}@laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs username; };
        modules = [
          ./modules/home
        ];
      };

      # NEW: Deploy-rs configuration
      deploy.nodes = {
        laptop = {
          hostname = "localhost";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos
              self.nixosConfigurations.laptop;
          };
        };
      };

      # NEW: Deployment checks
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        deploy-rs.lib;
    };
}
```

## Step 4: Test Deployment

```bash
# Test that configuration is valid
nix flake check

# Check deployment would work (dry-run)
nix run github:serokell/deploy-rs -- --checks .

# Actually deploy (requires sudo for system changes)
nix run github:serokell/deploy-rs -- --skip-checks .#laptop

# View what changed
nix run github:serokell/deploy-rs -- --dry-activate .#laptop

# Rollback if needed
nix run github:serokell/deploy-rs -- --rollback .#laptop
```

## Step 5: GitHub Actions Workflow

Create `.github/workflows/flake-check.yml`:

```yaml
name: "Flake Check"

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  flake-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: DeterminateSystems/nix-installer-action@main

      - uses: DeterminateSystems/magic-nix-cache-action@main

      - name: Check flake syntax
        run: nix flake check

      - name: Build laptop NixOS system
        run: nix build .#nixosConfigurations.laptop.config.system.build.toplevel

      - name: Build home-manager configuration
        run: nix build .#homeConfigurations.gabriel@laptop.activationPackage

      - name: Check deploy-rs configuration
        run: nix run github:serokell/deploy-rs -- --checks .

  flake-format:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: DeterminateSystems/nix-installer-action@main

      - name: Check Nix formatting
        run: nix fmt -- --check .

      - name: Shellcheck any shell scripts
        run: |
          find . -name "*.sh" -type f ! -path "./.git/*" \
            -exec nix run nixpkgs#shellcheck -- {} \;
```

## Step 6: Verify Changes

After updating `flake.nix`, verify everything works:

```bash
# Update flake lock file
nix flake update

# Check syntax
nix flake check

# Test dry-run
nixos-rebuild dry-run --flake .#laptop

# See what outputs are available
nix flake show
```

Should show:

```
deploy.nodes.laptop
nixosConfigurations.laptop
homeConfigurations
checks
```

## Step 7: Usage Examples

### Local Deployment

```bash
# Deploy changes to current system
sudo nix run github:serokell/deploy-rs -- --skip-checks .#laptop
```

### Dry Run (see what would change)

```bash
# Preview changes
nix run github:serokell/deploy-rs -- --dry-activate .#laptop
```

### Rollback

```bash
# Revert to previous generation
sudo nixos-rebuild switch --rollback
```

### Multiple Hosts (Future)

```bash
# Add to deploy.nodes in flake.nix
server = {
  hostname = "192.168.1.100";
  profiles.system = {
    user = "root";
    path = deploy-rs.lib.${system}.activate.nixos
      self.nixosConfigurations.server;
  };
};

# Then deploy
nix run github:serokell/deploy-rs -- .#server
```

## Step 8: CI/CD Integration

The GitHub Actions workflow above will:

1. ✅ Check flake syntax on every push/PR
2. ✅ Build the full system (catches breakage early)
3. ✅ Build home-manager configuration
4. ✅ Verify deploy-rs checks pass
5. ✅ Check Nix code formatting
6. ✅ Run shellcheck on any scripts

This prevents broken configurations from being merged.

## Troubleshooting

### "nix: command not found"

Make sure Nix is installed and flakes are enabled:

```bash
nix --version  # Should be >= 2.4
nix flake show  # Should show flake outputs
```

### Deploy fails with permission denied

```bash
# Most deployment requires root
sudo nix run github:serokell/deploy-rs -- .#laptop

# Or set up passwordless sudo for the deploy command (not recommended)
```

### Flake lock conflicts

```bash
# Reset lock file to original
git checkout flake.lock

# Then update carefully
nix flake update --override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable
```

### SSH key authentication issues

For remote deployment, ensure:

```bash
# SSH key is in ~/.ssh/id_ed25519 or ssh-add
ssh-add ~/.ssh/id_ed25519

# Can connect to remote
ssh root@server.example.com nixos-rebuild list-generations
```

## Performance Tips

### Speed up builds

```nix
# In hosts/laptop/default.nix, already optimized:
nix.settings = {
  max-jobs = "auto";
  cores = 0;
  keep-outputs = true;
  keep-derivations = true;
};
```

### Cache artifacts locally

```bash
# Build once, reuse
nix build .#nixosConfigurations.laptop.config.system.build.toplevel
# Next deploy will use cache

# CI caching via magic-nix-cache in GitHub Actions
# (already configured in workflow above)
```

## Next Steps

1. Apply the flake.nix changes above
2. Run `nix flake update` to lock versions
3. Test locally: `nix flake check`
4. Push to GitHub
5. Watch GitHub Actions run
6. If CI passes, configuration is validated!
7. Deploy with confidence: `sudo nix run github:serokell/deploy-rs -- .#laptop`

---

**For full deployment analysis:** See `DEPLOYMENT-ANALYSIS.md`

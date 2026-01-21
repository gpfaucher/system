# Project Shells with direnv + Nix Flakes

Auto-activate project-specific development environments when entering directories.

## Setup (already configured in NixOS)

```nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;  # Caches shells for instant activation
};
```

## Creating a Project Shell

### Step 1: Create `flake.nix` in project root

**Basic example:**
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.nodejs_22
          pkgs.pnpm
        ];
      };
    };
}
```

**Python project:**
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.python312
          pkgs.uv
          pkgs.ruff
        ];

        shellHook = ''
          if [ ! -d .venv ]; then
            uv venv
          fi
          source .venv/bin/activate
        '';
      };
    };
}
```

**Rust project:**
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.rustc
          pkgs.cargo
          pkgs.rust-analyzer
          pkgs.clippy
        ];

        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
      };
    };
}
```

**Go project:**
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.go
          pkgs.gopls
          pkgs.golangci-lint
        ];
      };
    };
}
```

**With system dependencies (e.g., PostgreSQL, Redis):**
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.python312
          pkgs.postgresql_16
          pkgs.redis
        ];

        shellHook = ''
          export PGDATA="$PWD/.postgres"
          export REDIS_DATA="$PWD/.redis"
        '';
      };
    };
}
```

### Step 2: Create `.envrc`

```bash
use flake
```

### Step 3: Allow direnv (one time per project)

```bash
cd ~/myproject
direnv allow
```

## Usage

```
~ $ cd myproject
direnv: loading .envrc
direnv: using flake
direnv: nix-direnv: using cached dev shell

~/myproject $ node --version
v22.0.0

~/myproject $ cd ..
direnv: unloading

~ $ node --version
command not found: node
```

## Commands

| Command | Description |
|---------|-------------|
| `direnv allow` | Trust .envrc in current directory |
| `direnv deny` | Untrust .envrc |
| `direnv reload` | Force reload after flake.nix changes |
| `direnv status` | Show current direnv state |

## Tips

**Update shell after changing flake.nix:**
```bash
direnv reload
```

**Rebuild without cache (nuclear option):**
```bash
rm -rf .direnv
direnv allow
```

**Add to .gitignore:**
```
.direnv/
.venv/
```

**Multiple shells in one flake:**
```nix
devShells.x86_64-linux = {
  default = pkgs.mkShell { ... };
  ci = pkgs.mkShell { ... };
};
```

Use with: `use flake .#ci` in `.envrc`

## Environment Variables

Set env vars in the shell:
```nix
pkgs.mkShell {
  packages = [ ... ];

  # Direct assignment
  DATABASE_URL = "postgres://localhost/mydb";

  # Or in shellHook
  shellHook = ''
    export API_KEY="$(cat ~/.secrets/api-key)"
  '';
};
```

## Troubleshooting

**Shell not activating:**
- Check `direnv status`
- Run `direnv allow`

**Old packages after flake update:**
- Run `direnv reload`

**Slow first load:**
- Normal - Nix is building. Subsequent loads are cached.

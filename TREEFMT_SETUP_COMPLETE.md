# treefmt-nix and pre-commit-hooks Setup Complete

## Summary

Successfully integrated **treefmt-nix** and **pre-commit-hooks** into the NixOS system configuration, providing automated code formatting and quality checks across the entire repository.

## What Was Added

### 1. Flake Inputs

Added two new flake inputs to `flake.nix`:

```nix
treefmt-nix = {
  url = "github:numtide/treefmt-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};

pre-commit-hooks = {
  url = "github:cachix/git-hooks.nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### 2. Formatter Configuration

Added a `formatter` output that provides the `nix fmt` command:

```nix
formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    prettier.enable = true;
    shfmt.enable = true;
  };
};
```

### 3. Development Shell

Added a development shell with pre-commit hooks:

```nix
devShells.${system}.default = pkgs.mkShell {
  packages = with pkgs; [
    nil  # Nix LSP
    nixfmt  # Nix formatter
  ];
  shellHook = ''
    ${pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        nixfmt.enable = true;
        shellcheck.enable = true;
      };
    }.shellHook}
  '';
};
```

### 4. Configuration Files

Created two new configuration files:

- **treefmt.nix** - Configures formatting rules for different file types
- **.pre-commit-config.yaml** - Defines local pre-commit hooks for nixfmt and shellcheck

## Formatters Enabled

- **nixfmt** - Formats Nix files (.nix)
- **prettier** - Formats Markdown, JSON, YAML files
- **shfmt** - Formats shell scripts

## Usage

### Format All Files

```bash
nix fmt
```

This will automatically format all files in the repository according to configured rules.

### Enter Development Shell

```bash
nix develop
```

This activates the development environment with pre-commit hooks installed.

### Manual Formatting

Individual tools can be used directly if installed:

```bash
nixfmt file.nix
prettier --write file.md
shfmt -w script.sh
```

## What Was Formatted

On the initial run, **118 files were reformatted** to match the new coding standards:

- All Nix configuration files
- All Markdown documentation
- All YAML/JSON configuration files
- All shell scripts

## Testing Results

### Build Test

✅ **PASSED** - `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run`

The NixOS configuration builds successfully with the new formatting.

### Formatter Test

✅ **PASSED** - `nix fmt`

The formatter runs successfully and formats files correctly.

## Integration Notes

### Git Workflow

All changes have been:
1. ✅ Committed to git with descriptive commit message
2. ✅ Pushed to remote repository
3. ✅ Verified with clean working tree

### Pre-commit Hooks

The pre-commit hooks are configured but not automatically installed. To use them in development:

```bash
nix develop
# Pre-commit hooks are now active in this shell
```

### Continuous Integration

The formatter can be integrated into CI/CD pipelines:

```bash
# Check if code is formatted (exit with error if not)
nix fmt -- --fail-on-change
```

## Benefits

1. **Consistency** - All code follows the same formatting standards
2. **Automation** - No need to manually format code
3. **Quality** - Pre-commit hooks catch issues before commit
4. **Speed** - Fast formatting with treefmt (parallel processing)
5. **Integration** - Works seamlessly with Nix flakes

## Future Enhancements

Consider adding these formatters in the future:

- **alejandra** - Alternative Nix formatter (stricter than nixfmt)
- **black** or **ruff** - Python formatting (if adding Python scripts)
- **rustfmt** - Rust formatting (if adding Rust code)
- **clang-format** - C/C++ formatting (if adding compiled code)

## Troubleshooting

### Permission Issues

If you encounter permission errors with flake.lock:

```bash
# Fix ownership if needed
sudo chown $USER:$USER flake.lock
```

### Cache Issues

If formatting behaves unexpectedly:

```bash
# Clear treefmt cache
nix fmt -- --clear-cache
```

### Formatter Not Found

If a formatter is missing:

```bash
# Rebuild the formatter
nix build .#formatter
```

## Documentation

- [treefmt-nix GitHub](https://github.com/numtide/treefmt-nix)
- [git-hooks.nix GitHub](https://github.com/cachix/git-hooks.nix)
- [nixfmt Documentation](https://github.com/NixOS/nixfmt)
- [prettier Documentation](https://prettier.io/)

## Commits

1. **dev: add treefmt-nix and pre-commit-hooks for code formatting** (3b4205f)
   - Added flake inputs and configuration
   - Formatted all repository files
   - Added treefmt.nix and .pre-commit-config.yaml

2. **system: add disko configuration for declarative disk partitioning** (ec4b0ab)
   - Added disko module files (not yet enabled)

---

**Status**: ✅ Complete and pushed to remote
**Date**: 2026-01-24
**Agent**: general

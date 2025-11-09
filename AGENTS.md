# AGENTS.md for NixOS Configuration Repository

## Build, Lint, Test Commands
- Validate flake: `nix flake check` — evaluates structure and runs checks.
- Build system: `nix build .#nixosConfigurations.&lt;host&gt;.config.system.build.toplevel` — builds without activation.
- Apply changes: `sudo nixos-rebuild switch --flake .#&lt;host&gt;` — builds and activates NixOS + Home-Manager.
- Test/Dry-run: `sudo nixos-rebuild test --flake .#&lt;host&gt;` — temporary activation for verification.
- Format/Lint: `nix fmt` or `alejandra .` — enforces Nix formatting. Run after changes.
- Testing: No unit tests; use `nix flake check` for evaluation. For single module test: `nix eval .#nixosConfigurations.&lt;host&gt;.config.modules.&lt;module&gt;` or dry-run specific services.

## Code Style Guidelines
- Formatting: 2-space indentation, trailing commas in attrsets, lines &lt; 100 chars. Use `nix fmt` for consistency.
- Naming Conventions: Lowercase, short, descriptive filenames (e.g., `networking.nix`, `packages.nix`). Variables: camelCase for attrs, kebab-case for options.
- Imports: Use relative paths; hosts import `../modules/core/default.nix` and `../modules/home/default.nix`. Avoid deep nesting.
- Types: Leverage Nix types (e.g., `lib.types.str`, `lib.types.bool`) for options. Define modules with `lib.mkOption`.
- Error Handling: Declarative; use `assertions` in modules for validation. Fail builds on errors rather than runtime.
- General: Expose attrsets from modules; avoid side effects. Prefer small, focused modules. Mimic Nixpkgs style. No comments unless requested.

## Additional Notes
- No Cursor rules (.cursor/rules/) or Copilot instructions (.github/copilot-instructions.md) found.
- Structure: Hosts in `hosts/&lt;name&gt;/`; shared modules in `modules/core/` and `modules/home/`.
- Security: Never commit secrets; use sops-nix or similar for management.

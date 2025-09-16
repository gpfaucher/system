# Repository Guidelines

## Project Structure & Module Organization
- Root: `flake.nix` (entrypoint), `flake.lock`, `hardware-configuration.nix`.
- Hosts: `hosts/<name>/` with `default.nix`, `hardware.nix`, `gpu.nix` (machine‑specific config). Example: `hosts/voyager/default.nix`.
- System modules: `modules/core/*.nix` (networking, security, packages, services).
- Home‑Manager: `modules/home/*.nix` (shell, tmux, terminal, KDE/Wayland, app configs) plus assets like `evremap.toml`.

Keep host‑specific details under `hosts/<name>/`; shareable logic lives under `modules/` and is imported by hosts.

## Build, Test, and Development Commands
- Validate flake: `nix flake check` — evaluates and runs flake checks.
- Build system closure: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` — builds without activating.
- Switch (apply config): `sudo nixos-rebuild switch --flake .#<host>` — builds and activates NixOS + Home‑Manager.
- Dry‑run: `sudo nixos-rebuild test --flake .#<host>` — activate temporarily for verification.
- Format (if configured): `nix fmt` or use your formatter of choice (e.g., `alejandra .` or `nixpkgs-fmt .`).

## Coding Style & Naming Conventions
- Nix style: 2‑space indentation, trailing commas in attrsets, keep lines < 100 chars.
- Filenames: lower‑case, short, descriptive (`networking.nix`, `packages.nix`).
- Module pattern: expose an attrset; avoid side effects; prefer small focused modules over monoliths.
- Imports: hosts import `modules/core/default.nix` and `modules/home/default.nix` as needed.

## Testing Guidelines
- Prefer evaluation checks before switching: `nix flake check`, then a targeted `nix build` of the host.
- For risky changes, use `nixos-rebuild test` and verify services start and displays/input behave as expected.
- Keep changes host‑scoped; add new options behind booleans where practical.

## Commit & Pull Request Guidelines
- Commit messages: follow Conventional Commits where possible (`feat:`, `fix:`, `chore:`, `refactor:`). Use imperative mood and scope host/module when relevant (e.g., `feat(home/wayland): add kanshi rule`).
- PRs should include: summary, affected host(s), before/after notes, and the exact build/switch command used. Include logs if activation touches critical services (audio, display, input).

## Security & Configuration Tips
- Do not commit secrets. Use external secret management if needed.
- Keep `hardware-configuration.nix` per‑host; avoid sharing hardware‑specific settings across machines.

# Neovim Rebuild And Kubernetes Learning Plan

Date: 2026-07-08

## Goal

Rebuild Neovim from scratch while also making this repo a good Kubernetes
learning environment.

The editor should feel small, understandable, and useful before it becomes
fancy. The Kubernetes workflow should start locally with kind and only later move
to the NixOS server.

## Current State

Neovim currently lives here:

```text
modules/home/nvim/
  default.nix
  config/
    init.lua
    lua/config/
    lua/plugins/
```

Home Manager installs Neovim and supporting command-line tools. The Lua config
is symlinked from the repo so edits are immediate.

This is good for iteration, but the plugin set has already grown into several
topic files. If the goal is learning, rebuild it in small layers instead of
tweaking the existing setup endlessly.

## Rebuild Rules

1. Keep Nix responsible for external tools.

   LSP servers, formatters, linters, tree-sitter CLI, ripgrep, fd, and
   Kubernetes tools should come from Nix.

2. Keep Lua responsible for editor behavior.

   Keymaps, plugin config, LSP attach behavior, completion behavior, telescope
   pickers, and UI should stay in Lua.

3. Do not start with AI plugins.

   First rebuild the editor you understand. Add AI integrations later.

4. Prefer fewer plugins.

   Every plugin should answer: what workflow does this make better?

5. Make Kubernetes support boring.

   YAML LSP, schema validation, Helm syntax, kubeconform, kubectl/k9s from the
   shell. Avoid turning Neovim into a full Kubernetes dashboard.

## Target Neovim Shape

```text
modules/home/nvim/
  default.nix
  config/
    init.lua
    lua/
      core/
        options.lua
        keymaps.lua
        autocmds.lua
      plugins/
        init.lua
        ui.lua
        editor.lua
        fuzzy.lua
        git.lua
        lsp.lua
        completion.lua
        formatting.lua
        treesitter.lua
        kubernetes.lua
```

The key change is that `plugins/init.lua` should be the readable table of what
is installed. Topic files should configure behavior, not hide the plugin list.

## Phase 1: Minimal Editor

Goal: make Neovim pleasant without plugins.

Keep only:

- options
- keymaps
- autocmds
- leader key
- sane clipboard behavior
- persistent undo
- search behavior
- diagnostic keymaps using built-in LSP APIs

No plugin manager yet.

Checkpoint:

```bash
nvim --clean
nvim
```

You should understand every line that runs.

## Phase 2: Add lazy.nvim

Goal: add plugin loading without adding a large plugin set.

Install only:

- color scheme
- which-key or mini.clue
- telescope
- oil.nvim or mini.files

Checkpoint:

- open files
- search files
- search text
- navigate project tree
- no LSP yet

## Phase 3: LSP And Completion

Goal: make coding support work for Nix, Lua, Python, TypeScript, YAML.

Nix packages should include:

- `nil`
- `lua-language-server`
- `basedpyright`
- `typescript-language-server`
- `yaml-language-server`
- `vscode-langservers-extracted`

Lua plugins:

- `neovim/nvim-lspconfig`
- `saghen/blink.cmp` or a minimal completion engine

Checkpoint:

- go to definition works
- hover works
- rename works
- diagnostics show
- completion works

## Phase 4: Formatting

Goal: one formatter path.

Use Nix packages:

- `nixfmt-rfc-style`
- `stylua`
- `ruff`
- `shfmt`
- `prettier`

Lua plugin:

- `stevearc/conform.nvim`

Checkpoint:

- format Nix
- format Lua
- format Python
- format YAML

## Phase 5: Kubernetes Editing

Goal: good YAML and Kubernetes feedback without magic.

Nix packages:

- `kubectl`
- `kubernetes-helm`
- `kustomize`
- `kubeconform`
- `k9s`
- `kind`
- `stern`

Neovim support:

- YAML LSP
- Helm syntax
- kubeconform command
- optional kubectl helper plugin only after the CLI workflow is comfortable

Learning workflow:

1. Edit manifest.
2. Validate with `kubeconform`.
3. Apply with `kubectl apply`.
4. Inspect with `kubectl describe`.
5. Read logs with `kubectl logs` or `stern`.

Do not start by adding a heavy Kubernetes Neovim UI.

## Phase 6: Git And Navigation

Add:

- gitsigns
- lazygit integration
- better quickfix/location-list workflow
- project-wide diagnostics picker

Checkpoint:

- review changed hunks
- stage/reset hunks if desired
- jump through diagnostics
- use quickfix confidently

## Phase 7: Debugging And AI

Only after the base editor is comfortable:

- DAP for languages you actually use
- AI plugins
- Markdown preview
- extra UI polish

Keep these as optional modules.

## Kubernetes Learning Flake

This repo now exposes:

```bash
nix develop .#kubernetes-learning
```

Use it for local Kubernetes practice with:

- kind
- kubectl
- helm
- k9s
- kustomize
- kubeconform
- stern
- Flux CLI
- Argo CD CLI

Local lab files live in:

```text
labs/kubernetes/kind/
```

Start with:

```bash
kind create cluster --config labs/kubernetes/kind/cluster.yaml
kubectl get nodes
kubectl apply -f labs/kubernetes/kind/manifests/whoami.yaml
```

## What Is Left

NixOS server:

- Replace `hosts/server/hardware.nix` with real generated hardware config.
- Add your MacBook SSH public key to `modules/nixos/base/users.nix`.
- Install the old workstation as `.#server`.
- Set a DHCP reservation or local DNS name for the server.
- Test remote rebuild from the MacBook.
- Decide when to enable restic scheduled backups.
- Add real encrypted secret management with agenix or sops-nix.

Kubernetes:

- Learn locally with kind first.
- Decide whether k3s should be enabled immediately on the server or after the
  base server is proven stable.
- Keep Kubernetes API private to LAN.
- Expose only HTTP/HTTPS publicly.
- Add cert-manager after ingress basics are understood.
- Add backups before hosting important stateful apps.

Neovim:

- Rebuild from a minimal core.
- Add LSP/completion only after base editing feels good.
- Add Kubernetes/YAML support as a small focused layer.
- Add AI/debugging last.

Repo hygiene:

- Add `bd` to the environment or remove the Beads requirement from `AGENTS.md`.
- Add/maintain `formatter` support so `nix fmt` works.
- Keep `nix flake check --no-build` clean before every push.

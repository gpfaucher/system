# System Architecture Design

Date: 2026-03-04

## Goals

- Bleeding edge, fully customizable, terminal-centric workflow
- Monitor hotplugging, scaling, and display profiles that just work
- Reliable Teams/Zoom video calling with Bluetooth (Bose QC Ultra 2 HP)
- AI-assisted coding (pair programming, not vibecoding)
- Gaming support (Steam, AAA titles, NVIDIA PRIME offload)
- Minimal distractions, maximum focus
- Things just work — no "sorry I can't present" moments

## Constraints

- NixOS stays as the base platform
- No Distrobox
- Ayu Dark theme everywhere
- Long-lived terminal sessions are crucial

---

## 1. Platform: NixOS (nixos-unstable)

**Decision: Stay on NixOS.** The config is mature and well-architected. The problems
being experienced are upstream Linux issues (BlueZ race conditions, Bose firmware
limitations) and packaging issues (Teams/Zoom FHS paths), not NixOS problems.

**Addition: nix-flatpak** for declarative Flatpak management. Teams and Zoom run via
Flatpak to sidestep FHS path issues while keeping the config declarative.

```nix
# In system config
services.flatpak.enable = true;
# nix-flatpak for declarative management
# Flatpak apps: Teams, Zoom
```

No Distrobox. No distro switch.

## 2. Desktop Environment: KDE Plasma 6 Wayland

**Decision: Replace Hyprland with KDE Plasma 6 Wayland.**

### Why KDE over Hyprland

| Problem | Hyprland | KDE Plasma 6 |
|---|---|---|
| Monitor hotplugging | Regressions between versions, monitoradded/removed events unreliable | Best of any Linux DE, active fixes in Plasma 6.3-6.6 |
| Display profiles | Kanshi (external tool, known issues) | Built-in, automatic, remembers window positions |
| Mixed DPI scaling | Integer only, XWayland workarounds | Best fractional scaling, per-monitor, legacy app toggle |
| Window position restoration | Lost on disconnect (no auto-restore) | Session management preserves positions per-display-config |
| Screen sharing | xdg-desktop-portal-hyprland (works but less tested) | xdg-desktop-portal-kde (most tested portal impl) |
| Bluetooth/audio GUI | CLI only (bluetoothctl, wpctl) | System Settings GUI for quick profile switching |
| NixOS packaging | nixpkgs version lags, flake recommended | Stable in nixpkgs |

### What gets removed

- Hyprland config (`modules/home/hyprland/`)
- Kanshi (`modules/home/kanshi.nix`)
- Waybar (`modules/home/hyprland/waybar.nix`)
- Dunst (`modules/home/hyprland/dunst.nix`)
- Hyprlock (`modules/home/hyprland/hyprlock.nix`)
- Fuzzel (replaced by KRunner, or keep as alternative)
- swaybg wallpaper

### What gets added

- `services.desktopManager.plasma6.enable = true`
- SDDM or keep greetd (SDDM is KDE's native DM, better integrated)
- Polonium for tiling window management
- KDE Ayu Dark color scheme (see section 3)
- KDE keybindings mapped to current muscle memory where possible

### What stays unchanged

- Terminal workflow (Ghostty + tmux + Neovim) — DE-agnostic
- All system modules (audio, graphics, networking, power, etc.)
- Gaming config (Steam, Gamescope, Gamemode)

### KDE keybinding mapping

Current Hyprland bindings to recreate in KDE:

| Function | Current (Hyprland) | KDE equivalent |
|---|---|---|
| Terminal | Super+Return | Super+Return (custom shortcut) |
| App launcher | Super+d | KRunner (Alt+Space or remap to Super+d) |
| Lock screen | Super+Shift+l | Super+Shift+l (custom shortcut to loginctl lock-session) |
| TUI tools | Super+n/o/a/g/e/x | Custom shortcuts launching `ghostty -e <command>` |
| Window close | Super+q | Alt+F4 or remap |
| Fullscreen | Super+f | Meta+F (KDE default) |
| Floating | Super+Shift+f | Polonium toggle |
| Volume/brightness | Media keys | Media keys (works out of box) |
| Screenshot | Super+Print | Spectacle (KDE's screenshot tool) |
| Clipboard | Super+v | Klipper (KDE's clipboard manager) |

## 3. Theming: Ayu Dark Everywhere

**Decision: Unified Ayu Dark across the entire system.**

### Stylix (already configured)

Stylix continues to handle:
- GTK apps
- Terminal (Ghostty)
- Neovim (base16)
- Fish shell
- bat, lazygit, btop, fzf, yazi, k9s
- Firefox

### KDE Plasma theming

- Generate KDE color scheme from Ayu Dark base16 palette
- Stylix can target Qt/KDE via `qt.style` settings
- Alternatively, use a community Ayu Dark KDE global theme
- Ensure: window decorations, panels, system tray, notifications, System Settings
  all use Ayu Dark colors
- Font: Monaspace Neon (monospace), consistent with current Stylix config

### Consistency checklist

- [ ] KDE Plasma shell (panels, task switcher, notifications)
- [ ] KDE window decorations
- [ ] KRunner
- [ ] Spectacle (screenshots)
- [ ] Dolphin (if used)
- [ ] GTK apps via Stylix
- [ ] Qt apps via KDE theme
- [ ] Flatpak apps (Teams, Zoom) — may need `--filesystem=xdg-config` for theme access
- [ ] Terminal (Ghostty) — already themed
- [ ] Neovim — already themed
- [ ] tmux status bar

## 4. Terminal & Multiplexer: Ghostty + tmux

**Decision: Replace Zellij with tmux.**

### Why tmux

- Long-lived sessions — detach/reattach across terminal crashes, SSH, reboots
- tmux-resurrect + tmux-continuum for session persistence across reboots
- Ubiquitous — same muscle memory on any server
- Mature, stable, proven over decades

### Configuration via home-manager

```nix
programs.tmux = {
  enable = true;
  # Keybindings, plugins, theme
};
```

### Key config decisions

- Prefix: Ctrl+a (common alternative to default Ctrl+b)
- Vi mode for copy/navigation
- tmux-resurrect for session save/restore
- tmux-continuum for automatic save
- Ayu Dark status bar theme
- Mouse support enabled
- True color support (for Neovim inside tmux)

### tmux layout for coding

```
+-----------------------------------+
|           Neovim (70%)            |
|                                   |
+-----------------------------------+
|  Claude Code / OpenCode (30%)     |
+-----------------------------------+
```

Pane navigation with Ctrl+hjkl (vim-tmux-navigator for seamless Neovim/tmux movement).

## 5. Neovim: Pure Lua + lazy.nvim

**Decision: Ditch nvf. Pure Lua config with lazy.nvim, Nix handles deps only.**

### Why

- nvf wraps Lua in Nix strings — no Lua LSP, no syntax highlighting, slow iteration
- Pure Lua gives full editor support, copy-paste from anywhere, instant hot-reload
- lazy.nvim is the de facto standard plugin manager
- Nix provides LSP servers, formatters, treesitter grammars on PATH (replaces Mason)

### Directory structure (inside flake repo)

```
modules/home/nvim/
├── default.nix              # home-manager module: neovim + deps + symlink
└── config/
    ├── init.lua              # bootstraps lazy.nvim, loads modules
    ├── lazy-lock.json        # auto-managed by lazy.nvim
    ├── lua/
    │   ├── config/
    │   │   ├── options.lua   # vim.opt settings
    │   │   ├── keymaps.lua   # general keybindings
    │   │   └── autocmds.lua  # autocommands
    │   └── plugins/
    │       ├── lsp.lua       # LSP config (Neovim 0.11 native or lspconfig)
    │       ├── treesitter.lua
    │       ├── telescope.lua
    │       ├── completion.lua # blink-cmp
    │       ├── git.lua       # gitsigns, lazygit
    │       ├── editor.lua    # oil, harpoon, flash, which-key
    │       ├── formatting.lua # conform.nvim
    │       ├── ai.lua        # opencode.nvim, claudecode.nvim
    │       ├── markdown.lua
    │       └── ui.lua        # theme, statusline
    └── lsp/                  # Neovim 0.11 native LSP configs (optional)
        ├── lua_ls.lua
        ├── nil_ls.lua
        └── basedpyright.lua
```

### Nix module (default.nix)

```nix
{
  pkgs,
  config,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # LSP servers
      nil lua-language-server basedpyright
      typescript-language-server rust-analyzer gopls
      terraform-ls

      # Formatters
      nixfmt-rfc-style prettier stylua shfmt ruff

      # Tools needed by plugins
      ripgrep fd gcc
    ];
  };

  # Symlink config from flake repo (writable, instant iteration)
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/projects/system/modules/home/nvim/config";
}
```

### Plugins to migrate from nvf

All current nvf plugins, now as lazy.nvim specs:

- **Core**: telescope.nvim, blink-cmp, conform.nvim, treesitter + textobjects
- **Editor**: oil.nvim, harpoon2, flash.nvim, which-key.nvim, nvim-autopairs
- **Git**: gitsigns.nvim, lazygit.nvim
- **LSP**: nvim-lspconfig (or Neovim 0.11 native), trouble.nvim
- **AI**: opencode.nvim, claudecode.nvim (new)
- **Debug**: nvim-dap + nvim-dap-ui
- **UI**: base16-nvim (Stylix theme), todo-comments
- **Markdown**: render-markdown.nvim, markdown-preview.nvim, vim-table-mode
- **Motion**: flash.nvim (s: jump, S: treesitter, r: remote)

### Keybindings

Migrate existing keybindings 1:1 from nvf config. Leader = Space.
All current bindings are documented in `modules/home/nvf/keymaps.nix`.

## 6. AI-Assisted Coding Workflow

**Decision: OpenCode + Claude Code side by side, both integrated with Neovim.**

### OpenCode (anomalyco/opencode)

- Stays as flake input
- opencode.nvim plugin for Neovim integration
- Provider-flexible: can use Claude, OpenAI, local models
- TUI for interactive coding assistance

### Claude Code

- claudecode.nvim for MCP-based Neovim integration
- Claude sees buffers, diagnostics, file tree via WebSocket
- Best for multi-step agentic work and codebase-wide reasoning
- Already installed and running

### Workflow

- tmux main pane: Neovim (with both opencode.nvim and claudecode.nvim)
- tmux side/bottom pane: Claude Code CLI or OpenCode TUI
- Use whichever fits the task — OpenCode for quick questions/provider flexibility,
  Claude Code for deeper pair programming and agentic work
- Zed stays as VISUAL editor / fallback for visual diffs and quick edits

## 7. Bluetooth & Audio

**Decision: Optimize classic A2DP/HFP stack for Bose QC Ultra 2 HP.**

### Current hardware

- **Adapter**: Qualcomm BT 5.4 (LE Audio capable: cis-central, iso-broadcaster, etc.)
- **Headphones**: Bose QC Ultra 2 HP (BT 5.3, but no LE Audio in firmware)
- **Audio server**: PipeWire with WirePlumber

### Available profiles (confirmed)

- `a2dp-sink` (AAC) — highest priority, best quality for music
- `a2dp-sink-sbc_xq` (SBC-XQ)
- `a2dp-sink-sbc` (SBC)
- `headset-head-unit` (HSP/HFP, mSBC) — calls with mic, 16kHz wideband
- `headset-head-unit-cvsd` (HSP/HFP, CVSD) — calls with mic, 8kHz narrowband

### Tuning actions

1. **Disable multipoint** on Bose QC Ultra via Bose Music app. Multipoint causes
   BlueZ reconnection loops and profile confusion when the phone triggers audio
   events. This is the single most impactful change.

2. **Set native HFP backend explicitly**:
   ```nix
   "bluez5.hfphsp-backend" = "native";
   ```
   Ensures PipeWire handles HFP directly instead of trying oFono.

3. **Test mSBC vs CVSD**: mSBC (16kHz) is currently enabled and preferred. If
   buzzing persists after disabling multipoint, try falling back to CVSD:
   ```nix
   "bluez5.enable-msbc" = false;
   ```

4. **Keep autoswitch enabled**: WirePlumber's `bluetooth.autoswitch-to-headset-profile`
   handles A2DP→HFP switching when call apps open the mic. This is the Linux
   equivalent of Windows' unified endpoint behavior (though less seamless).

5. **Consider `ControllerMode = "bredr"`** if BLE features aren't needed — reduces
   connection complexity for the Bose headset. However, this would break BLE-only
   devices (Keychron M1 mouse, MX Master 3S if using BLE). May not be viable.

### Known limitations

- A2DP→HFP switch will have an audible gap (~0.5-2s). Windows handles this
  seamlessly via unified audio endpoints; Linux cannot yet.
- Bose QC Ultra has a documented BlueZ incompatibility (issue #1266, closed NOT_PLANNED)
  causing slow initial connections. Disabling multipoint may help.
- LE Audio (LC3 codec, no profile switching needed) is the long-term fix. Adapter
  is ready (BT 5.4), waiting for Bose firmware support.

### KDE advantage

KDE's Bluetooth System Settings provides a GUI for:
- Quick profile switching during meetings (faster than `wpctl` in a panic)
- Device management
- Audio device selection

This is a significant improvement over pure CLI Bluetooth management for call scenarios.

## 8. Teams & Zoom

**Decision: Flatpak via nix-flatpak (declarative).**

### Setup

```nix
# nix-flatpak declarative config
services.flatpak.enable = true;
# Install: com.github.nickvergessen.teams-for-linux
# Install: us.zoom.Zoom
```

### Why Flatpak

- Sidesteps all NixOS FHS path issues (hard-coded `/usr/share/`, `/usr/libexec/`)
- FHS-compatible sandbox provides portal discovery
- xdg-desktop-portal-kde handles screen sharing natively
- Updates independently of nixos-rebuild

### Alternative: Teams PWA

Teams via Chrome/Edge PWA at `teams.microsoft.com` is also viable and even simpler.
Screen sharing works via browser's native PipeWire portal integration. Consider
this if Flatpak Teams has issues.

### Zoom config

In `~/.config/zoomus.conf`:
```ini
enableWaylandShare=true
```

If screen sharing breaks (PipeWire 1.2 threading bug), fallback:
```bash
XDG_SESSION_TYPE="" zoom-us  # forces XWayland capture
```

## 9. Gaming

**Decision: Keep current setup, works on KDE.**

- Steam + Gamescope + Gamemode — continue as-is
- NVIDIA PRIME offload via `nvidia-offload` / `prime-run` — unchanged
- Gamescope works as nested compositor in KDE Wayland
- KDE's HDR support is more mature than Hyprland's
- VR (ALVR + Meta Quest) config stays if still used

## 10. Components Removed

| Component | Replacement |
|---|---|
| Hyprland | KDE Plasma 6 Wayland |
| Kanshi | KDE built-in display profiles |
| Waybar | KDE panel |
| Dunst | KDE notification system |
| Hyprlock | KDE lock screen |
| Fuzzel | KRunner (or keep as alternative) |
| swaybg | KDE wallpaper |
| Zellij | tmux |
| nvf | Pure Lua + lazy.nvim |
| wl-paste + cliphist | Klipper (KDE clipboard) |
| nm-applet | KDE network widget |
| blueman-applet | KDE Bluetooth widget |

## 11. Components Unchanged

- NixOS base (nixos-unstable)
- Ghostty terminal
- Fish shell + starship + zoxide + atuin
- Stylix (Ayu Dark base16)
- PipeWire + WirePlumber audio
- OpenCode (anomalyco/opencode)
- Claude Code
- Agenix (secrets)
- Tailscale
- ProtonVPN
- Docker/Kubernetes tooling
- All dev tools (Node, Rust, Go, Python, Terraform, etc.)
- Security hardening
- System maintenance (btrfs scrub, journal, nix GC)

---

## Migration Order

1. **Bluetooth tuning** — disable multipoint, add `bluez5.hfphsp-backend = "native"`. Test calls.
2. **Flatpak setup** — add nix-flatpak, install Teams and Zoom via Flatpak.
3. **tmux** — configure tmux via home-manager, migrate from Zellij.
4. **Neovim** — migrate from nvf to pure Lua + lazy.nvim. Extract Lua from Nix strings.
5. **KDE Plasma 6** — add KDE module, configure theming, keybindings, Polonium tiling.
6. **Remove Hyprland** — only after KDE is fully configured and tested.
7. **Polish** — Ayu Dark consistency audit, keybinding refinement, documentation.

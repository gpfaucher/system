# System Modernization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modernize the NixOS system configuration by switching to Zed as primary editor, fixing Bose headphone audio, expanding Stylix theming with plasma-manager for KDE, and removing dead code (beads).

**Architecture:** Five independent workstreams that can be committed separately: (1) Remove beads entirely from flake, overlays, and home modules. (2) Simplify audio.nix and remove bluetooth-monitor.nix, letting WirePlumber handle Bluetooth profile switching natively. (3) Create a declarative Zed editor module and update EDITOR variables. (4) Expand Stylix targets and add plasma-manager for safe KDE theming. (5) Clean up miscellaneous brittleness (JACK removal, dead comments, console color comment).

**Tech Stack:** NixOS 24.11 (unstable nixpkgs), Home Manager, Stylix, plasma-manager, PipeWire/WirePlumber, Zed editor

**Important:** This is a NixOS configuration repo — there are no unit tests. Verification is done via `nix flake check`, `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run`, and post-rebuild manual testing. Each task ends with a build verification step.

---

## Task 1: Remove Beads Completely

Beads is disabled (`enable = false`) due to an upstream vendoring mismatch. Remove all traces: the flake input, overlays, the home module file, the import, and the configuration block.

**Files:**
- Modify: `flake.nix` — remove `beads` input, overlay, and output parameter
- Delete: `modules/home/beads.nix`
- Modify: `modules/home/default.nix` — remove import and `programs.beads` block

**Step 1: Remove beads from flake.nix inputs**

In `flake.nix`, delete the beads input block (lines containing `beads = {` through the closing `};` and comment above it):

```nix
    # DELETE this entire block:
    # Beads - Git-backed issue tracker for AI agents
    # Provides persistent task memory across agent sessions
    # Task memory: .beads/issues/ (committed to git)
    # Cache: .beads/cache/ (local only, gitignored)
    beads = {
      url = "github:steveyegge/beads";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

**Step 2: Remove beads from flake.nix outputs function parameter**

In the `outputs` function signature, remove `beads,` from the destructured parameters:

```nix
    # Before:
    outputs = { self, nixpkgs, home-manager, nvf, stylix, ghostty, beads, agenix, ... }@inputs:

    # After:
    outputs = { self, nixpkgs, home-manager, nvf, stylix, ghostty, agenix, ... }@inputs:
```

**Step 3: Remove beads overlays from all three locations in flake.nix**

Remove the beads overlay from:
1. The top-level `pkgs` definition (`overlays = [...]` block)
2. The `laptop` nixosSystem `nixpkgs.overlays` block
3. The `nixbox` nixosSystem `nixpkgs.overlays` block

In each location, delete:
```nix
          (final: prev: {
            beads = beads.packages.${system}.default;
          })
```

After removal, if the `overlays` list is empty, remove the entire `overlays = [ ];` line. For the top-level `pkgs`, if overlays is empty the whole attribute can be dropped since `config.allowUnfree` is the only other thing — keep `config.allowUnfree` but remove `overlays`.

**Step 4: Remove beads module file and references**

Delete `modules/home/beads.nix`.

In `modules/home/default.nix`, remove:
```nix
    ./beads.nix
```
from the `imports` list.

Remove the `programs.beads` block:
```nix
  # Beads for persistent agent task memory
  programs.beads = {
    enable = false; # Disabled due to vendoring mismatch in upstream package
    enableDaemon = false;
  };
```

**Step 5: Verify build**

```bash
nix flake check 2>&1 | head -20
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

Expected: No errors referencing `beads`.

**Step 6: Commit**

```bash
git add -A
git commit -m "chore: remove beads entirely (disabled, upstream vendoring mismatch)"
```

---

## Task 2: Simplify Audio — Remove Bluetooth Monitor Script

The current audio setup fights WirePlumber's built-in Bluetooth policy. WirePlumber 0.5+ has a virtual source node that automatically switches between A2DP (music) and HFP (calls) when applications open/close the microphone. The custom udev rule and bluetooth-monitor.sh are unnecessary and harmful.

**Files:**
- Modify: `modules/system/audio.nix` — rewrite to use WirePlumber autoswitch
- Delete: `modules/system/bluetooth-monitor.nix`
- Modify: `hosts/laptop/default.nix` — remove bluetooth-monitor.nix import
- Modify: `modules/home/services.nix` — update EasyEffects comment

**Step 1: Rewrite audio.nix**

Replace the entire contents of `modules/system/audio.nix` with:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Disable PulseAudio (using PipeWire instead)
  services.pulseaudio.enable = false;

  # Enable rtkit for realtime scheduling (required for low-latency audio)
  security.rtkit.enable = true;

  # PipeWire audio server
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Audio quality settings
    extraConfig.pipewire = {
      "10-higher-quality" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [
            44100
            48000
            96000
          ];
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 512;
        };
      };
    };

    wireplumber = {
      enable = true;
      extraConfig = {
        # Bluetooth codec and role configuration
        "10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.roles" = [
              "a2dp_sink"
              "hfp_hf"
            ];
          };
        };

        # WirePlumber auto-switches to HFP when a call app opens the mic,
        # and back to A2DP when the call ends. No custom scripts needed.
        "11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = true;
          };
        };

        # Default to A2DP (high-quality music) on connection
        "12-bluetooth-defaults" = {
          "monitor.bluez.rules" = [
            {
              matches = [
                {
                  "device.name" = "~bluez_card.*";
                }
              ];
              actions = {
                update-props = {
                  "bluez5.auto-connect" = [
                    "a2dp_sink"
                    "hfp_hf"
                  ];
                };
              };
            }
          ];
        };
      };
    };
  };

  # Audio tools
  environment.systemPackages = with pkgs; [
    pipewire
    pulseaudio # pactl utilities
    easyeffects # System-wide EQ (output effects only with BT headsets)
    helvum # PipeWire patchbay for debugging
  ];

  # Bluetooth audio settings
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
      KernelExperimental = true;
    };
  };
}
```

Key changes from previous version:
- Removed `jack.enable = true` (irrelevant to Bluetooth audio)
- Removed `boseHeadsetProfile` script and `services.udev.extraRules` (hardcoded MAC, fights WirePlumber)
- Set `bluetooth.autoswitch-to-headset-profile = true` (was `false` — this was the root cause)
- Trimmed `bluez5.roles` to only needed roles (was listing all 6 including legacy HSP and audio gateway)
- Added `monitor.bluez.rules` for device-agnostic defaults (replaces MAC-specific udev rule)

**Step 2: Delete bluetooth-monitor.nix**

Delete `modules/system/bluetooth-monitor.nix`.

**Step 3: Remove bluetooth-monitor.nix import from laptop host**

In `hosts/laptop/default.nix`, remove this line from imports:

```nix
    ../../modules/system/bluetooth-monitor.nix
```

**Step 4: Update services.nix EasyEffects comment**

Replace the contents of `modules/home/services.nix` with:

```nix
{ ... }:

{
  # KDE Plasma handles services natively via System Settings:
  # - Display configuration (kscreen)
  # - Night Color (blue light filter)
  # - Power management and screen locking
  # - Window tiling (Plasma 6 native tiling or KWin scripts)

  # EasyEffects: installed system-wide in audio.nix
  # Safe for output effects (EQ, compression) with Bluetooth headsets.
  # Avoid input effects with BT — they confuse WirePlumber's autoswitch.
  # If BT mic routing breaks, add the BT loopback to EasyEffects' blocklist.
}
```

**Step 5: Verify build**

```bash
nix flake check 2>&1 | head -20
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

Expected: No errors. No references to `bluetooth-monitor` or `boseHeadsetProfile`.

**Step 6: Commit**

```bash
git add -A
git commit -m "fix(audio): simplify bluetooth — let WirePlumber handle profile switching

Remove bluetooth-monitor.sh (130-line brittle shell script parsing wpctl output).
Remove udev rule with hardcoded Bose MAC address.
Enable WirePlumber autoswitch (was disabled — root cause of all issues).
Remove unnecessary JACK, legacy HSP roles, and audio gateway roles.
WirePlumber 0.5+ handles A2DP<->HFP switching natively via virtual source node."
```

---

## Task 3: Add Declarative Zed Editor Module

Create a new `zed.nix` Home Manager module with fully declarative settings, vim mode, LSPs via `extraPackages`, and Stylix integration. Zed replaces Neovim as the primary editor (nvf.nix stays for terminal/server use).

**Files:**
- Create: `modules/home/zed.nix`
- Modify: `modules/home/default.nix` — add import, change EDITOR, remove `zed-editor` from packages
- Modify: `modules/home/theme.nix` — add `stylix.targets.zed.enable = true`

**Step 1: Create zed.nix**

Create `modules/home/zed.nix`:

```nix
{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    # Fully declarative — changes only via Nix, not Zed GUI
    mutableUserSettings = false;
    mutableUserKeymaps = false;

    # Extensions (installed at runtime by Zed, not Nix-managed)
    extensions = [
      "nix"
      "toml"
      "dockerfile"
      "docker-compose"
      "html"
      "git-firefly"
      "fish"
      "kdl"
    ];

    # System LSPs and formatters available to Zed via PATH
    extraPackages = with pkgs; [
      nixd
      nodePackages.typescript-language-server
      nodePackages.prettier
      ruff
      shellcheck
      shfmt
    ];

    userSettings = {
      # Vim mode
      vim_mode = true;

      # Theme (overridden by Stylix, but set as fallback)
      theme = {
        mode = "dark";
        dark = "One Dark";
        light = "One Light";
      };

      # UI
      hour_format = "hour24";
      ui_font_size = 16;
      buffer_font_size = 14;
      buffer_font_family = "Monaspace Neon";
      tab_size = 2;
      show_whitespaces = "boundary";
      relative_line_numbers = true;

      # Terminal
      terminal = {
        shell = {
          program = "fish";
        };
        font_size = 14;
        font_family = "JetBrainsMono Nerd Font";
        line_height = "comfortable";
        copy_on_select = true;
        working_directory = "current_project_directory";
      };

      # File behavior
      format_on_save = "on";
      autosave = "on_focus_change";
      ensure_final_newline_on_save = true;
      remove_trailing_whitespace_on_save = true;

      # Git
      git = {
        inline_blame.enabled = true;
      };

      # Inlay hints
      inlay_hints = {
        enabled = true;
      };

      # Language-specific settings
      languages = {
        Nix = {
          language_servers = [ "nixd" ];
          formatter = {
            external = {
              command = "nixfmt";
            };
          };
        };
        Python = {
          formatter = {
            external = {
              command = "ruff";
              arguments = [ "format" "-" ];
            };
          };
        };
      };

      # LSP binary paths (prefer system packages over Zed-downloaded)
      lsp = {
        nixd = {
          binary = {
            path_lookup = true;
          };
        };
      };

      # Vim mode settings
      vim = {
        use_system_clipboard = "always";
        use_smartcase_find = true;
      };

      # Collaboration (disabled for local-first workflow)
      features = {
        copilot = false;
      };
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
    };

    userKeymaps = [
      # Workspace-level keybindings
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-t" = "workspace::NewTerminal";
          "ctrl-shift-e" = "workspace::ToggleLeftDock";
        };
      }
      # Vim normal mode additions
      {
        context = "vim_mode == normal";
        bindings = {
          # Window navigation (match nvim C-hjkl)
          "ctrl-h" = "workspace::ActivatePaneInDirection::Left";
          "ctrl-j" = "workspace::ActivatePaneInDirection::Down";
          "ctrl-k" = "workspace::ActivatePaneInDirection::Up";
          "ctrl-l" = "workspace::ActivatePaneInDirection::Right";
          # Buffer navigation (match nvim S-hl)
          "shift-h" = "pane::ActivatePrevItem";
          "shift-l" = "pane::ActivateNextItem";
          # Leader-style (space) bindings
          "space f" = "file_finder::Toggle";
          "space g" = "workspace::NewSearch";
          "space b" = "tab_switcher::Toggle";
          "space e" = "workspace::ToggleLeftDock";
        };
      }
    ];
  };
}
```

**Step 2: Add zed.nix import and update default.nix**

In `modules/home/default.nix`:

Add to imports:
```nix
    ./zed.nix
```

Change EDITOR/VISUAL from nvim to zed:
```nix
    # Before:
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # After:
    sessionVariables = {
      EDITOR = "zeditor --wait";
      VISUAL = "zeditor --wait";
    };
```

Note: The `zed-editor` package provides the `zeditor` binary (not `zed`). The `--wait` flag makes it block until the file is closed, which is required for `$EDITOR` use (e.g., `git commit`).

Remove `zed-editor` from `home.packages` (now managed by `programs.zed-editor`):
```nix
    # DELETE this line from home.packages:
    zed-editor
```

**Step 3: Enable Stylix for Zed**

In `modules/home/theme.nix`, add to the `targets` block:

```nix
      zed.enable = true;
```

**Step 4: Verify build**

```bash
nix flake check 2>&1 | head -20
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

Expected: No errors.

**Step 5: Commit**

```bash
git add -A
git commit -m "feat(editor): add declarative Zed editor module as primary editor

Fully declarative config (mutableUserSettings = false).
Vim mode with matching nvim keybindings (C-hjkl, S-hl, space-leader).
System LSPs via extraPackages (nixd, typescript-language-server, etc.).
Stylix ayu-dark theme auto-applied.
Neovim (nvf.nix) retained for terminal/server use."
```

---

## Task 4: Expand Stylix Targets and Add plasma-manager

Expand Stylix to cover more installed applications. Add plasma-manager for safe declarative KDE Plasma 6 theming (Stylix KDE/Qt targets remain disabled due to ongoing issues).

**Files:**
- Modify: `flake.nix` — add `plasma-manager` input and sharedModule
- Modify: `modules/home/theme.nix` — expand Stylix targets, add plasma-manager config

**Step 1: Add plasma-manager input to flake.nix**

In `flake.nix` inputs, add after the `stylix` input:

```nix
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
```

Add `plasma-manager,` to the outputs function parameter (after `stylix,`).

**Step 2: Add plasma-manager to sharedModules**

In both the `laptop` and `nixbox` `home-manager` blocks within `flake.nix`, add to `sharedModules`:

```nix
              sharedModules = [
                inputs.nvf.homeManagerModules.default
                inputs.stylix.homeModules.stylix
                inputs.plasma-manager.homeManagerModules.plasma-manager  # ADD
              ];
```

**Step 3: Rewrite theme.nix**

Replace the entire contents of `modules/home/theme.nix` with:

```nix
{ pkgs, ... }:

{
  # Stylix theming configuration
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.monaspace;
        name = "Monaspace Neon";
      };
      sizes = {
        terminal = 14;
      };
    };

    opacity = {
      terminal = 0.9;
    };

    targets = {
      # Editors
      neovim.enable = true;
      zed.enable = true;

      # Shell and CLI
      fish.enable = true;
      btop.enable = true;
      fzf.enable = true;
      bat.enable = true;
      lazygit.enable = true;
      k9s.enable = true;
      yazi.enable = true;

      # Terminal
      ghostty.enable = true;

      # GTK apps
      gtk.enable = true;

      # Browser
      firefox.profileNames = [ "default" ];

      # KDE/Qt — disabled, managed by plasma-manager below
      # Issue #1092 is still open: KDE may not start with Stylix Qt target
      kde.enable = false;
      qt.enable = false;
    };
  };

  # Declarative KDE Plasma 6 configuration
  # Uses Breeze Dark to match ayu-dark aesthetic without the Stylix Qt/Kvantum issues
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
    };

    kwin = {
      titlebarButtons = {
        left = [ "on-all-desktops" ];
        right = [ "minimize" "maximize" "close" ];
      };
    };

    hotkeys.commands = { };

    shortcuts = {
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";
    };
  };

  home.packages = [ pkgs.nerd-fonts.symbols-only ];
}
```

Key changes:
- Added Stylix targets for: `zed`, `btop`, `fzf`, `bat`, `lazygit`, `k9s`, `yazi`, `ghostty`
- Added `programs.plasma` block for declarative KDE Plasma 6 theming via plasma-manager
- Breeze Dark look-and-feel matches ayu-dark without risking Kvantum/Qt breakage
- KDE shortcuts for virtual desktop switching

**Step 4: Verify build**

```bash
nix flake check 2>&1 | head -20
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

Expected: No errors. Stylix targets resolve. plasma-manager module loads.

Note: Some Stylix targets (like `btop`, `lazygit`, `k9s`, `yazi`) may require the corresponding `programs.<name>.enable = true` in Home Manager for the target to activate. If the build fails with "option does not exist" for any target, remove that target and handle it in a follow-up. The safe targets that work with just `home.packages` are: `fish`, `gtk`, `neovim`, `zed`, `ghostty`, `firefox`.

**Step 5: Commit**

```bash
git add -A
git commit -m "feat(theme): expand Stylix targets and add plasma-manager for KDE

Add Stylix targets for Zed, Ghostty, btop, fzf, bat, lazygit, k9s, yazi.
Add plasma-manager for declarative Plasma 6 config (Breeze Dark).
KDE/Qt Stylix targets remain disabled (upstream issue #1092).
plasma-manager handles look-and-feel, cursor, KWin buttons, shortcuts."
```

---

## Task 5: Miscellaneous Cleanup

Clean up remaining brittleness: remove `claude-code.nix` (empty file), remove duplicate packages from `home.packages` that are managed by programs modules, and add a comment about console colors.

**Files:**
- Modify: `modules/home/default.nix` — remove packages now managed by modules, remove empty claude-code.nix import if present
- Modify: `modules/system/bootloader.nix` — add comment about ayu-dark colors source

**Step 1: Clean up duplicate/unnecessary packages in default.nix**

In `modules/home/default.nix`, remove from `home.packages`:
- `neovim` — already provided by `programs.nvf`
- `git` — already provided by `programs.git`
- `delta` — already provided by `programs.delta`
- `vscode-fhs` — replaced by Zed as primary editor (remove if user confirms)
- `warp-terminal` — redundant with Ghostty (remove if user confirms)

Definitely safe to remove (managed by programs modules):
```nix
    # DELETE these from home.packages (managed by programs.* modules):
    neovim
    git
    delta
```

**Step 2: Add source comment to bootloader console colors**

In `modules/system/bootloader.nix`, add a comment above the `colors` block:

```nix
    # Ayu dark theme colors (from base16 ayu-dark scheme)
    # TODO: Consider generating from stylix base16 scheme instead of hardcoding
    # Format: black, red, green, yellow, blue, magenta, cyan, white (normal + bright)
    colors = [
```

**Step 3: Verify build**

```bash
nix flake check 2>&1 | head -20
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove duplicate packages managed by programs modules"
```

---

## Execution Order

Tasks 1-5 are independent and can be done in any order. Recommended order for safety:

1. **Task 1** (beads removal) — smallest, zero risk, clean diff
2. **Task 5** (cleanup) — small, reduces noise for later diffs
3. **Task 2** (audio) — medium risk, requires post-rebuild testing with actual headphones
4. **Task 3** (zed) — additive, no breakage risk
5. **Task 4** (stylix + plasma-manager) — largest change, new flake input

## Post-Rebuild Manual Testing

After `sudo nixos-rebuild switch`:

**Audio (Task 2):**
- Pair Bose QC Ultra headphones
- Play music — should be A2DP (high quality)
- Open a Teams/Zoom call — WirePlumber should auto-switch to HFP (mic active)
- End the call — should auto-switch back to A2DP
- Check with `wpctl status` that profiles switch correctly

**Zed (Task 3):**
- Run `zeditor` — should open with ayu-dark theme
- Verify vim mode works (motions, operators, visual mode)
- Open a `.nix` file — nixd LSP should attach
- Test `Ctrl-h/j/k/l` pane navigation
- Test `Space f` file finder, `Space g` search
- Test integrated terminal (`Ctrl-Shift-t`)

**Theme (Task 4):**
- Log out and back in — Plasma should use Breeze Dark
- Check that cursor theme is breeze_cursors
- Open a GTK app (Firefox) — should have ayu-dark styling
- Open Ghostty — should have ayu-dark colors
- Run `btop` — should have themed colors
- Run `lazygit` — should have themed colors

**Rollback plan:** If Plasma fails to start after Task 4, boot previous generation from systemd-boot menu, then set `programs.plasma.enable = false` and rebuild.

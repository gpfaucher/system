# NixOS Migration Design

Migration from Arch Linux to NixOS while preserving River WM, Gruvbox theming, and all current functionality.

## Overview

- **Structure:** Flake + Home Manager
- **Hardware:** AMD iGPU (Ryzen) + NVIDIA dGPU laptop
- **Bootloader:** rEFInd (dual-boot with Windows)
- **Theming:** Stylix with Gruvbox Dark Medium
- **Neovim:** nvf framework
- **AI Completion:** Tabby server with StarCoder-1B

## Repository Structure

```
/home/gabriel/system/
├── flake.nix                    # Entry point
├── flake.lock
├── hosts/
│   └── laptop/
│       ├── default.nix          # Host config
│       └── hardware.nix         # Generated hardware config
├── modules/
│   ├── system/                  # NixOS modules
│   │   ├── bootloader.nix       # rEFInd + Gruvbox + HiDPI console
│   │   ├── graphics.nix         # Hybrid AMD/NVIDIA PRIME
│   │   ├── networking.nix
│   │   ├── audio.nix            # PipeWire
│   │   └── services.nix         # CUPS, Bluetooth, Polkit
│   └── home/                    # Home Manager modules
│       ├── river.nix            # River WM
│       ├── nvf.nix              # Neovim
│       ├── shell.nix            # Fish + Starship + direnv
│       ├── terminal.nix         # Ghostty
│       ├── services.nix         # Tabby, Kanshi, etc.
│       └── theme.nix            # Stylix config
├── overlays/
├── assets/
│   └── wallpaper.png
└── docs/
    ├── plans/
    └── project-shells.md        # direnv + flake workflow
```

## Flake Inputs

```nix
{
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
  };
}
```

## System Configuration

### Bootloader & Console

```nix
# rEFInd with Gruvbox
boot.loader = {
  efi.canTouchEfiVariables = true;
  refind = {
    enable = true;
    extraConfig = ''
      # Gruvbox theme config
    '';
  };
};

# HiDPI console (2x scale for 4K)
console = {
  font = "ter-132n";
  packages = [ pkgs.terminus_font ];
  earlySetup = true;
};
```

### Hybrid Graphics (PRIME Offload)

```nix
hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = true;
  prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;  # Provides nvidia-offload command
    amdgpuBusId = "PCI:X:X:X";        # From lspci
    nvidiaBusId = "PCI:X:X:X";        # From lspci
  };
};
hardware.graphics.enable = true;
```

### System Services

- PipeWire (audio)
- NetworkManager
- Bluetooth (bluez)
- CUPS (printing)
- Polkit (auth dialogs)
- No display manager - TTY login, Fish starts River on tty1

### XDG Portals

```nix
xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  config.common = {
    default = [ "gtk" ];
    "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };
};
```

## Home Manager Configuration

### Stylix Theming

```nix
stylix = {
  enable = true;
  image = ./assets/wallpaper.png;
  base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  polarity = "dark";

  fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };
    sizes.terminal = 14;
  };

  opacity.terminal = 0.9;

  targets = {
    neovim.enable = false;  # nvf handles this
    fish.enable = true;
    gtk.enable = true;
    fuzzel.enable = true;
  };
};
```

Manually themed (not supported by Stylix):
- rEFInd bootloader
- River borders
- fnott notifications

### Neovim (nvf)

```nix
programs.nvf = {
  enable = true;
  settings.vim = {
    viAlias = true;
    theme = { name = "gruvbox"; style = "dark"; };

    languages = {
      lua.lsp.enable = true;
      ts.lsp.enable = true;
      rust.lsp.enable = true;
      go.lsp.enable = true;
      python.lsp = {
        enable = true;
        server = "basedpyright";
      };
      nix.enable = true;
    };

    autocomplete.blink-cmp.enable = true;
    telescope.enable = true;
    treesitter.enable = true;
    git.gitsigns.enable = true;
    statusline.lualine.enable = true;

    assistant.vim-tabby = {
      enable = true;
      serverUrl = "http://localhost:8080";
    };
  };
};
```

Custom plugins via `vim.extraPlugins`: Oil, Harpoon, venv-selector, todo-comments, which-key, lazygit.

### Shell (Fish + direnv)

```nix
programs.fish = {
  enable = true;
  interactiveShellInit = ''
    # Start River on tty1
    if test (tty) = "/dev/tty1"
      exec river
    end

    set fish_greeting
    set -g fish_key_bindings fish_vi_key_bindings
  '';

  shellAbbrs = {
    ga = "git add";
    gc = "git commit";
    gd = "git diff";
    gs = "git status";
    lg = "lazygit";
  };

  functions = {
    y = ''
      set tmp (mktemp -t "yazi-cwd.XXXXXX")
      yazi $argv --cwd-file="$tmp"
      if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
      end
      rm -f -- "$tmp"
    '';
  };
};

programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};

programs.starship.enable = true;
```

### User Services

**Tabby Server:**
```nix
systemd.user.services.tabby = {
  Unit.Description = "Tabby AI completion server";
  Service = {
    ExecStart = "${pkgs.tabby}/bin/tabby serve --model StarCoder-1B --device cuda";
    Restart = "always";
  };
  Install.WantedBy = [ "default.target" ];
};
```

**Kanshi (display profiles):**
```nix
services.kanshi = {
  enable = true;
  settings = [
    {
      profile.name = "laptop";
      profile.outputs = [{
        criteria = "eDP-1";
        mode = "3840x2400@60Hz";
        scale = 2.0;
      }];
    }
    {
      profile.name = "docked-dp";
      profile.outputs = [
        { criteria = "DP-2"; mode = "3440x1440@100Hz"; scale = 1.0; }
        { criteria = "eDP-1"; status = "disable"; }
      ];
    }
    # Additional profiles...
  ];
};
```

**Other services:** gammastep, fnott, wl-paste/cliphist, wpaperd

## Migration Steps

### Pre-Installation (from Arch)

1. Backup configs (already in git)
2. Note disk layout: `lsblk` and `blkid`
3. Identify Windows EFI partition
4. Get GPU bus IDs: `lspci | grep -E "(VGA|3D)"`

### NixOS Installation

1. Boot NixOS ISO
2. Partition: Keep Windows drive untouched, install NixOS on Arch drive
3. Mount partitions, mount Windows EFI at `/boot/efi`
4. Generate hardware config: `nixos-generate-config --root /mnt`
5. Clone system repo
6. Copy `hardware-configuration.nix` to `hosts/laptop/hardware.nix`
7. Update GPU bus IDs in `modules/system/graphics.nix`
8. Run `nixos-install --flake .#laptop`
9. Reboot

### Post-Install

1. Login at TTY1 → Fish starts River
2. Tabby downloads StarCoder-1B on first run (~2GB)
3. Test: `nvidia-offload glxinfo | grep vendor`

## Packages Summary

**System-level:**
- rEFInd, CUPS, PipeWire, NetworkManager, Bluetooth
- NVIDIA drivers, Mesa (AMD)

**User-level:**
- River, wideriver, kanshi, waylock, wlogout, fuzzel
- Ghostty, Fish, Starship
- Neovim (via nvf)
- Tabby
- grim, slurp, wf-recorder, wl-clipboard, cliphist
- fnott, gammastep, wpaperd
- Yazi, lazygit
- direnv, nix-direnv

## Files to Create

1. `flake.nix` - Main flake
2. `hosts/laptop/default.nix` - Host config
3. `modules/system/*.nix` - System modules
4. `modules/home/*.nix` - Home Manager modules
5. `docs/project-shells.md` - direnv workflow guide

{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ./river.nix
    ./nvf.nix
    ./shell.nix
    ./terminal.nix
    ./services.nix
    ./theme.nix
  ];

  # Home Manager configuration
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Enable River WM
  programs.river = {
    enable = true;
    terminal = "ghostty";
    borderColorFocused = "83a598";
    borderColorUnfocused = "504945";
    keyboardRepeatDelay = 250;
    keyboardRepeatRate = 30;
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Gabriel";
    userEmail = "gabriel@example.com";  # TODO: Update with actual email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Additional packages
  home.packages = with pkgs; [
    # Browsers
    firefox

    # Development tools
    gh
    git
    gnumake
    gcc

    # System utilities
    unzip
    wget
    curl
    htop
    tree

    # Fonts
    nerd-fonts.jetbrains-mono
  ];

  # XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Wallpaper configuration
  xdg.configFile."wpaperd/config.toml".text = ''
    [default]
    path = "${../../../assets/wallpaper.png}"
    duration = "30m"
    mode = "center"
  '';

  # Screenshot and screenrecord scripts
  home.file.".local/bin/screenshot-area" = {
    executable = true;
    text = ''
      #!/bin/sh
      grim -g "$(slurp)" - | wl-copy
    '';
  };

  home.file.".local/bin/screenshot-screen" = {
    executable = true;
    text = ''
      #!/bin/sh
      grim - | wl-copy
    '';
  };

  home.file.".local/bin/screenshot-save" = {
    executable = true;
    text = ''
      #!/bin/sh
      mkdir -p ~/Pictures/Screenshots
      grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png
    '';
  };

  home.file.".local/bin/screenrecord-area" = {
    executable = true;
    text = ''
      #!/bin/sh
      wf-recorder -g "$(slurp)" -f /tmp/recording.mp4 &
      echo $! > /tmp/screenrecord.pid
    '';
  };

  home.file.".local/bin/screenrecord-screen" = {
    executable = true;
    text = ''
      #!/bin/sh
      wf-recorder -f /tmp/recording.mp4 &
      echo $! > /tmp/screenrecord.pid
    '';
  };

  home.file.".local/bin/screenrecord-save" = {
    executable = true;
    text = ''
      #!/bin/sh
      if [ -f /tmp/screenrecord.pid ]; then
        kill $(cat /tmp/screenrecord.pid)
        rm /tmp/screenrecord.pid
        mkdir -p ~/Videos/Recordings
        mv /tmp/recording.mp4 ~/Videos/Recordings/$(date +%Y%m%d_%H%M%S).mp4
      fi
    '';
  };
}

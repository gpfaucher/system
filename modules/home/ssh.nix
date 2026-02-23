{
  config,
  pkgs,
  lib,
  ...
}:

{
  # SSH Agent systemd service
  # Automatically starts ssh-agent as a user service
  services.ssh-agent.enable = true;

  # SSH client configuration
  programs.ssh = {
    enable = true;

    # Disable default config - we set our own defaults via "*" matchBlock
    enableDefaultConfig = false;

    # Host-specific configurations
    matchBlocks = {
      # Default settings for all hosts
      "*" = {
        # Automatically add keys to the agent when used
        # Format: "yes" | "no" | "confirm" | "ask" | time (e.g., "1h", "30m")
        # Using time-based TTL: keys expire after 4 hours of inactivity
        addKeysToAgent = "4h";

        # Security: Only use identities explicitly configured
        identitiesOnly = true;

        # Keep connections alive
        serverAliveInterval = 60;
        serverAliveCountMax = 3;

        extraOptions = {
          # Multiplexing for faster subsequent connections
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h-%p";
          ControlPersist = "10m";
        };
      };

      # GitHub
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519" ];
        addKeysToAgent = "4h";
      };

      # GitLab
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519" ];
        addKeysToAgent = "4h";
      };

      # Wildcard for common dev patterns
      "*.github.com" = {
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519" ];
        addKeysToAgent = "4h";
      };
    };
  };

  # Ensure SSH socket directory exists
  home.activation.sshSocketDir = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.ssh/sockets
    $DRY_RUN_CMD chmod 700 $HOME/.ssh/sockets
  '';

  # WORKAROUND: Fix SSH config permissions
  # home-manager symlinks to Nix store which has wrong owner (nobody:nogroup or root)
  # SSH requires the config file to be owned by the user, not root/nix-daemon
  # This copies the file instead of symlinking, fixing "Bad owner or permissions" error
  # See: https://github.com/nix-community/home-manager/issues/322
  home.activation.fixSshConfigPermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -L "$HOME/.ssh/config" ]; then
      # Get the actual file the symlink points to
      configTarget=$(readlink -f "$HOME/.ssh/config")
      # Remove the symlink and copy the file with correct permissions
      $DRY_RUN_CMD rm "$HOME/.ssh/config"
      $DRY_RUN_CMD install -m 600 "$configTarget" "$HOME/.ssh/config"
    fi
  '';

  # SSH_ASKPASS integration for GUI passphrase prompts
  # Uses ssh-askpass-fullscreen for Wayland
  home.sessionVariables = {
    # Use pinentry for SSH passphrase prompts via ssh-askpass
    SSH_ASKPASS = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  # Install ssh-askpass for secure passphrase prompts
  home.packages = with pkgs; [
    ssh-askpass-fullscreen  # GUI askpass for Wayland
  ];
}

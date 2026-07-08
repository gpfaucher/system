{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;

    # Disable default config - we set our own defaults via "*" matchBlock
    enableDefaultConfig = false;

    settings = {
      "*" = {
        # Keys expire after 4h
        AddKeysToAgent = "4h";

        # Only use explicitly configured identities
        IdentitiesOnly = true;

        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h-%p";
        ControlPersist = "10m";
      };

      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = [ "~/.ssh/id_ed25519" ];
        AddKeysToAgent = "4h";
      };

      "gitlab.com" = {
        HostName = "gitlab.com";
        User = "git";
        IdentityFile = [ "~/.ssh/id_ed25519" ];
        AddKeysToAgent = "4h";
      };

      "*.github.com" = {
        User = "git";
        IdentityFile = [ "~/.ssh/id_ed25519" ];
        AddKeysToAgent = "4h";
      };

      "vps" = {
        HostName = "95.217.73.154";
        User = "gabriel";
        IdentityFile = [ "~/.ssh/id_ed25519" ];
        SetEnv = {
          TERM = "xterm-256color";
        };
      };
    };
  };

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

  # macOS uses keychain for SSH agent passphrase prompts
  # No need for ssh-askpass-fullscreen (Wayland-only)
}

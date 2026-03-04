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

    matchBlocks = {
      "*" = {
        # Keys expire after 4h
        addKeysToAgent = "4h";

        # Only use explicitly configured identities
        identitiesOnly = true;

        serverAliveInterval = 60;
        serverAliveCountMax = 3;

        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h-%p";
          ControlPersist = "10m";
        };
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519" ];
        addKeysToAgent = "4h";
      };

      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519" ];
        addKeysToAgent = "4h";
      };

      "*.github.com" = {
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519" ];
        addKeysToAgent = "4h";
      };

      "vps" = {
        hostname = "95.217.73.154";
        user = "gabriel";
        identityFile = [ "~/.ssh/id_ed25519" ];
        setEnv = { TERM = "xterm-256color"; };
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

  # ssh-askpass-fullscreen for Wayland passphrase prompts
  home.sessionVariables = {
    SSH_ASKPASS = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  home.packages = with pkgs; [
    ssh-askpass-fullscreen
  ];
}

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Impermanence configuration
  # NOTE: Full impermanence requires disk reconfiguration with Btrfs subvolumes
  # This module defines what to persist when impermanence is enabled

  # Currently DISABLED - set to true when ready to enable
  # environment.persistence."/persist" = lib.mkIf false {
  #   hideMounts = true;
  #   directories = [
  #     "/var/log"
  #     "/var/lib/bluetooth"
  #     "/var/lib/docker"
  #     "/var/lib/iwd" # iwd wireless network profiles
  #     "/var/lib/systemd"
  #   ];
  #   files = [
  #     "/etc/machine-id"
  #   ];
  #   users.gabriel = {
  #     directories = [
  #       ".ssh"
  #       ".aws"
  #       ".gnupg"
  #       ".local/share/fish"
  #       ".local/share/atuin"
  #       ".local/share/zoxide"
  #       ".config/github-copilot"
  #       "projects"
  #       "notes"
  #       "Documents"
  #       "Downloads"
  #       ".mozilla"
  #       ".tabby-client"
  #     ];
  #     files = [
  #       ".gitconfig"
  #     ];
  #   };
  # };

  # For now, just add a comment explaining the setup needed
  # To enable impermanence:
  # 1. Create Btrfs subvolumes: @persist, @nix, @home (or @home-persist)
  # 2. Mount /persist to @persist subvolume
  # 3. Uncomment the configuration above
  # 4. Reboot
}

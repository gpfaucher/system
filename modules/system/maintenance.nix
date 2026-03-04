{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=100M
    MaxFileSec=7day
  '';

  services.smartd = {
    enable = true;
    autodetect = true;
    # -W diff,info,crit: warn if temp changes 4C, info at 55C, critical at 70C
    # NVMe drives run 40-60C normally; 70C+ is concerning
    defaults.monitored = "-a -o on -S on -n standby,q -W 4,55,70";
    notifications = {
      wall.enable = true;
      x11.enable = false;
    };
  };

  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  # Trigger GC when free space drops below 1GB, free up to 5GB
  nix.settings = {
    min-free = 1073741824; # 1 GiB
    max-free = 5368709120; # 5 GiB
  };

  # ── Restic backup to Hetzner Storage Box (disabled until configured) ──
  # To enable:
  # 1. Create /etc/restic/password with your encryption password
  # 2. Create /etc/restic/hetzner-env with:
  #      RESTIC_REPOSITORY=sftp:uXXXXXX@uXXXXXX.your-storagebox.de:/backups
  # 3. Run: sudo restic -r sftp:... init
  # 4. Uncomment the services.restic.backups.hetzner block below
  # 5. Rebuild: sudo nixos-rebuild switch --flake .#laptop
  #
  # services.restic.backups.hetzner = {
  #   timerConfig = {
  #     OnCalendar = "03:00";
  #     Persistent = true;
  #     RandomizedDelaySec = "1h";
  #   };
  #   passwordFile = "/etc/restic/password";
  #   environmentFile = "/etc/restic/hetzner-env";
  #   paths = [
  #     "/home/gabriel"
  #     "/etc/nixos"
  #     "/var/lib"
  #   ];
  #   exclude = [
  #     "/home/gabriel/.cache"
  #     "/home/gabriel/.local/share/Steam"
  #     "/home/gabriel/.local/share/Trash"
  #     "/home/gabriel/.mozilla/firefox/*/cache2"
  #     "/home/gabriel/.config/google-chrome/Default/Service Worker/CacheStorage"
  #     "/home/gabriel/.config/google-chrome/Default/Cache"
  #     "/home/gabriel/Downloads"
  #     "/home/gabriel/.nix-defexpr"
  #     "/home/gabriel/.nix-profile"
  #     "/var/lib/docker"
  #     "/var/lib/systemd/coredump"
  #     "*.tmp"
  #     "*.swp"
  #     ".direnv"
  #     "node_modules"
  #     "__pycache__"
  #     ".venv"
  #     "target"
  #     "result"
  #   ];
  #   pruneOpts = [
  #     "--keep-daily 7"
  #     "--keep-weekly 4"
  #     "--keep-monthly 6"
  #     "--keep-yearly 2"
  #   ];
  #   extraBackupArgs = [
  #     "--verbose"
  #     "--exclude-caches"
  #     "--one-file-system"
  #   ];
  # };
}

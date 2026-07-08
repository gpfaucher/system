{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    restic
  ];

  systemd.tmpfiles.rules = [
    "d /etc/restic 0700 root root - -"
    "d /srv/backups 0750 root root - -"
    "d /srv/backups/databases 0750 root root - -"
  ];

  # Enable this after the first manual restic init/restore drill succeeds and
  # /etc/restic/password plus /etc/restic/hetzner-env exist, preferably from
  # agenix or sops-nix rather than hand-created files.
  #
  # services.restic.backups.hetzner = {
  #   initialize = true;
  #   passwordFile = "/etc/restic/password";
  #   environmentFile = "/etc/restic/hetzner-env";
  #   paths = [
  #     "/etc"
  #     "/srv"
  #     "/var/lib/rancher/k3s/server/db"
  #     "/var/lib/rancher/k3s/server/manifests"
  #   ];
  #   exclude = [
  #     "/var/lib/containerd"
  #     "/var/lib/rancher/k3s/agent/containerd"
  #     "/var/lib/systemd/coredump"
  #     "node_modules"
  #     ".direnv"
  #     ".venv"
  #     "target"
  #     "result"
  #     "*.tmp"
  #     "*.swp"
  #   ];
  #   timerConfig = {
  #     OnCalendar = "03:00";
  #     Persistent = true;
  #     RandomizedDelaySec = "1h";
  #   };
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

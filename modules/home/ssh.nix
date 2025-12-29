{ config, lib, pkgs, ... }:

let
  sshConfig = pkgs.writeText "ssh-config" ''
    Host paddock-staging
      HostName 3.65.122.203
      User ec2-user
      IdentityFile ~/.ssh/paddock-ec2

    Host paddock-staging-tunnel
      HostName 3.65.122.203
      User ec2-user
      IdentityFile ~/.ssh/paddock-ec2
      LocalForward 5432 staging-postgres.cpuuywqis1x2.eu-central-1.rds.amazonaws.com:5432
      ServerAliveInterval 60
      ServerAliveCountMax 3

    Host paddock-prod
      HostName 3.124.157.22
      User ec2-user
      IdentityFile ~/.ssh/paddock-ec2

    Host paddock-prod-tunnel
      HostName 3.124.157.22
      User ec2-user
      IdentityFile ~/.ssh/paddock-ec2
      LocalForward 5433 production-postgres.cbas6us2c8g8.eu-central-1.rds.amazonaws.com:5432
      LocalForward 6380 production-redis.0dod70.0001.euc1.cache.amazonaws.com:6379
      ServerAliveInterval 60
      ServerAliveCountMax 3
  '';
in {
  # Use activation script to install with correct permissions (600)
  # This avoids the symlink-to-nix-store permission issue
  home.activation.installSshConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD install -m 600 ${sshConfig} $HOME/.ssh/config
  '';
}

{ pkgs, ... }:

let
  sshBin = "${pkgs.openssh}/bin/ssh";

  mkTunnel = { name, localPort, remoteHost, bastionHost }: {
    Unit = {
      Description = "Paddock ${name} PostgreSQL tunnel (localhost:${toString localPort})";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = builtins.concatStringsSep " " [
        sshBin
        "-NTC"
        "-i %h/.ssh/paddock-ec2"
        "-L 0.0.0.0:${toString localPort}:${remoteHost}:5432"
        "-o ServerAliveInterval=60"
        "-o ServerAliveCountMax=3"
        "-o ExitOnForwardFailure=yes"
        "-o StrictHostKeyChecking=accept-new"
        "-o ControlMaster=no"
        "-o ControlPath=none"
        bastionHost
      ];
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
in
{
  # Paddock-app SSH tunnels to AWS RDS through bastion hosts.
  # Staging starts automatically; production is manual:
  #   systemctl --user start paddock-tunnel-production
  systemd.user.services = {
    paddock-tunnel-staging = mkTunnel {
      name = "staging";
      localPort = 5432;
      remoteHost = "staging-postgres.cpuuywqis1x2.eu-central-1.rds.amazonaws.com";
      bastionHost = "ec2-user@3.65.122.203";
    } // {
      Install.WantedBy = [ "default.target" ];
    };

    paddock-tunnel-production = mkTunnel {
      name = "production";
      localPort = 5433;
      remoteHost = "production-postgres.cbas6us2c8g8.eu-central-1.rds.amazonaws.com";
      bastionHost = "ec2-user@3.77.45.29";
    };
  };
}

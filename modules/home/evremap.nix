{ pkgs, ... }:
{
  home.packages = with pkgs; [
    evremap
  ];

  # Enable evremap service for advanced key remapping
  systemd.user.services.evremap = {
    Unit = {
      Description = "Evremap key remapping service";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.evremap}/bin/evremap remap ${./evremap.toml}";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
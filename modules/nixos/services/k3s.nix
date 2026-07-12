{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectl
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--tls-san=100.88.195.11"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    6443
  ];
}

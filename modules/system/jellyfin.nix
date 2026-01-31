{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================
  # Jellyfin Media Server with NVIDIA NVENC
  # ============================================
  # Hardware-accelerated transcoding using RTX GPU

  services.jellyfin = {
    enable = true;
    openFirewall = true; # Opens ports 8096 (HTTP) and 8920 (HTTPS)

    # Run as dedicated user
    user = "jellyfin";
    group = "jellyfin";
  };

  # Give Jellyfin access to GPU for hardware transcoding
  users.users.jellyfin = {
    extraGroups = [
      "video"  # Video device access
      "render" # GPU render node access
    ];
  };

  # Environment for NVIDIA hardware transcoding
  systemd.services.jellyfin = {
    environment = {
      # Make all NVIDIA GPUs visible to Jellyfin
      NVIDIA_VISIBLE_DEVICES = "all";
      NVIDIA_DRIVER_CAPABILITIES = "all";

      # Use NVIDIA for VA-API
      LIBVA_DRIVER_NAME = "nvidia";
    };

    # Ensure NVIDIA drivers are loaded before Jellyfin starts
    after = [ "nvidia-persistenced.service" ];
  };

  # Install Jellyfin packages with ffmpeg for transcoding
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg # Jellyfin's custom ffmpeg with hardware acceleration
  ];

  # NVIDIA persistence daemon for faster GPU initialization
  # Keeps GPU initialized, reducing first-transcode latency
  hardware.nvidia.nvidiaPersistenced = true;

  # Firewall ports (in case openFirewall doesn't cover all cases)
  networking.firewall.allowedTCPPorts = [
    8096  # Jellyfin HTTP
    8920  # Jellyfin HTTPS
    1900  # DLNA discovery (UDP, see below)
    7359  # Jellyfin client discovery
  ];

  networking.firewall.allowedUDPPorts = [
    1900  # DLNA/UPnP discovery
    7359  # Jellyfin client discovery
  ];
}

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # PRIME offload environment for NVIDIA GPU
  primeOffload = ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
  '';

  # Steam wrapper for VR (runs on NVIDIA GPU)
  steam-vr = pkgs.writeShellScriptBin "steam-vr" ''
    ${primeOffload}
    exec steam "$@"
  '';

  # SteamVR launch wrapper - use as launch options in Steam
  steamvr-launch = pkgs.writeShellScriptBin "steamvr-launch" ''
    ${primeOffload}
    exec "$@"
  '';

  # ALVR wrapper that ensures ADB path is set and uses NVENC
  alvr-wrapped = pkgs.writeShellScriptBin "alvr" ''
    # Copy ADB binary where ALVR expects it (symlinks may not work)
    mkdir -p "$HOME/.config/alvr/tools/platform-tools"
    if [ ! -f "$HOME/.config/alvr/tools/platform-tools/adb" ] || [ -L "$HOME/.config/alvr/tools/platform-tools/adb" ]; then
      rm -f "$HOME/.config/alvr/tools/platform-tools/adb"
      cp "${pkgs.android-tools}/bin/adb" "$HOME/.config/alvr/tools/platform-tools/adb"
      chmod +x "$HOME/.config/alvr/tools/platform-tools/adb"
    fi

    # Start ADB server and setup port forwarding
    "${pkgs.android-tools}/bin/adb" start-server 2>/dev/null || true
    "${pkgs.android-tools}/bin/adb" forward tcp:9943 tcp:9943 2>/dev/null || true
    "${pkgs.android-tools}/bin/adb" forward tcp:9944 tcp:9944 2>/dev/null || true

    export ALVR_ADB_PATH="${pkgs.android-tools}/bin/adb"
    export PATH="${pkgs.android-tools}/bin:$PATH"
    # Disable VAAPI so ALVR uses NVENC for encoding
    export LIBVA_DRIVER_NAME=disabled
    ${primeOffload}
    exec ${pkgs.alvr}/bin/alvr_dashboard "$@"
  '';
in
{
  # Add user to adbusers group
  users.users.gabriel.extraGroups = [ "adbusers" ];

  # Udev rules for Meta Quest devices
  services.udev.extraRules = ''
    # Meta Quest 3S / Quest 3 / Quest 2 / Quest Pro
    SUBSYSTEM=="usb", ATTR{idVendor}=="2833", MODE="0666", GROUP="adbusers"
    # Additional Meta/Oculus vendor IDs
    SUBSYSTEM=="usb", ATTR{idVendor}=="2d40", MODE="0666", GROUP="adbusers"
  '';

  # ALVR and VR tools
  environment.systemPackages = [
    alvr-wrapped
    steam-vr
    steamvr-launch
    pkgs.android-tools
    pkgs.scrcpy
  ];

  # Force ALVR to use system ADB instead of bundled version
  environment.sessionVariables = {
    ALVR_ADB_PATH = "${pkgs.android-tools}/bin/adb";
  };

  # Open firewall ports for ALVR
  networking.firewall = {
    allowedTCPPorts = [ 9943 9944 ];
    allowedUDPPorts = [ 9943 9944 ];
  };

  # Ensure fuse is available (ALVR may need it)
  boot.kernelModules = [ "fuse" ];
}

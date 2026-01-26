{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Disable PulseAudio (using PipeWire instead)
  services.pulseaudio.enable = false;

  # Enable rtkit for realtime scheduling (required for low-latency audio)
  security.rtkit.enable = true;

  # PipeWire audio server
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; # Enable JACK support for better Bluetooth audio

    wireplumber = {
      enable = true;
      extraConfig = {
        # Bluetooth codec configuration
        "10-bluez" = {
          "monitor.bluez.properties" = {
            # Enable better codecs
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            # Include BOTH A2DP and headset roles
            "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
            # Default to A2DP profile
            "bluez5.default.profile" = "a2dp-sink";
          };
        };
        # Auto-switch to headset profile when app needs microphone
        "11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = true;
          };
        };
      };
    };
  };

  # Bluetooth audio codec support
  # Provides high-quality codecs: AAC, aptX, aptX-HD, LDAC
  environment.systemPackages = with pkgs; [
    pipewire
  ];

  # Bluetooth settings for better audio compatibility
  hardware.bluetooth.settings = {
    General = {
      # Enable all Bluetooth profiles including A2DP (high-quality audio)
      Enable = "Source,Sink,Media,Socket";
      # Enable experimental features for mSBC codec support (better call quality)
      Experimental = true;
      # Keep connections alive during profile switches
      KernelExperimental = true;
    };
  };
}

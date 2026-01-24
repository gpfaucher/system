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
      # Custom WirePlumber configuration for Bluetooth multipoint handling
      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/main.lua.d/51-bluetooth-policy.lua" ''
          -- Bluetooth Multipoint Call Handling Policy
          -- Optimizes HSP/HFP profile switching for VoIP calls

          -- Configure Bluetooth policy
          bluetooth_policy = {
            ["policy.bluetooth"] = {
              -- Enable automatic profile switching
              ["auto-switch-profile"] = true,
              
              -- Prioritize HSP/HFP for calls (headset mode with microphone)
              -- This triggers automatically when apps like Teams request microphone access
              ["use-persistent-storage"] = true,
              
              -- Only allow one device to use HSP/HFP at a time
              -- This prevents multipoint conflicts during calls
              ["hfp-no-multi-hf"] = true,
              
              -- Set proper sample rate for headset mode (16kHz is standard for HSP/HFP)
              ["bluez5.hfp-headset-sample-rate"] = 16000,
              
              -- Enable mSBC codec for better voice quality
              ["bluez5.msbc-support"] = true,
              
              -- Reconnection handling
              ["bluez5.reconnect-delay"] = 2000,  -- 2 second delay before reconnecting
            },
          }

          -- Load the configuration
          table.insert(alsa_monitor.rules, bluetooth_policy)
        '')
      ];
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
      # Disable battery reporting if it causes disconnection issues
      Experimental = false;
    };
  };
}

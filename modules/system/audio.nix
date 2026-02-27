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

    # Audio quality settings
    extraConfig.pipewire = {
      "10-higher-quality" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [
            44100
            48000
            96000
          ];
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 512;
        };
      };
    };

    wireplumber = {
      enable = true;
      extraConfig = {
        # Bluetooth codec and role configuration
        "10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "hfp_hf"
              "hfp_ag"
            ];
          };
        };

        # WirePlumber auto-switches to HFP when a call app opens the mic,
        # and back to A2DP when the call ends. No custom scripts needed.
        "11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = true;
          };
        };

        # Cap camera resolution to 720p to prevent lag in video calls
        "10-camera-limit" = {
          "monitor.libcamera.rules" = [
            {
              matches = [ { "node.name" = "~libcamera_input.*"; } ];
              actions.update-props = {
                "node.param.PortConfig" = {
                  format = "MJPG";
                  width = 1280;
                  height = 720;
                  framerate = 30;
                };
              };
            }
          ];
          "monitor.v4l2.rules" = [
            {
              matches = [ { "node.name" = "~v4l2_input.*"; } ];
              actions.update-props = {
                "node.param.PortConfig" = {
                  format = "MJPG";
                  width = 1280;
                  height = 720;
                  framerate = 30;
                };
              };
            }
          ];
        };

        # Default to A2DP (high-quality music) on connection
        "12-bluetooth-defaults" = {
          "monitor.bluez.rules" = [
            {
              matches = [
                {
                  "device.name" = "~bluez_card.*";
                }
              ];
              actions = {
                update-props = {
                  "bluez5.auto-connect" = [
                    "a2dp_sink"
                    "hfp_hf"
                  ];
                };
              };
            }
          ];
        };

        # Boost built-in mic gain (internal mics are often too quiet)
        "20-mic-gain" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_input.*";
                }
              ];
              actions.update-props = {
                "channelVolumes" = [ 1.5 1.5 ];
                "channelMap" = [ "FL" "FR" ];
                "softVolumes" = true;
              };
            }
          ];
        };

        # Ensure USB webcam audio nodes are not suspended
        # (v4l2 camera rules can sometimes interfere with the audio side)
        "21-webcam-audio" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_input.usb-*";
                }
              ];
              actions.update-props = {
                "session.suspend-timeout-seconds" = 0;
                "channelVolumes" = [ 2.0 2.0 ];
                "channelMap" = [ "FL" "FR" ];
                "softVolumes" = true;
              };
            }
          ];
        };
      };
    };
  };

  # Audio tools
  environment.systemPackages = with pkgs; [
    pipewire
    pulseaudio # pactl utilities
    easyeffects # System-wide EQ (output effects only with BT headsets)
    helvum # PipeWire patchbay for debugging
  ];

  # Bluetooth audio settings
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
      KernelExperimental = true;
    };
  };
}

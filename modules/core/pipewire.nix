_ : 
{
  hardware.pulseaudio.enable = false;

  # https://wiki.nixos.org/wiki/PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # lowLatency.enable = true;
  };
}

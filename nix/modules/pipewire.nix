{ ... }:

{
  # PipeWire replaces PulseAudio + ALSA userspace + JACK
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Real-time audio scheduling priority
  security.rtkit.enable = true;
}

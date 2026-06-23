{ lib, pkgs, config, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "theseus";

  # Don't wait for network on boot (desktop, no need)
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Trust Tailscale interface — no need to open individual ports
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # NVIDIA graphics (desktop, no power management)
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # SSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;    # key-based auth only
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Ollama: local LLM server with NVIDIA GPU acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # NVIDIA GPU acceleration

    # Uncomment to make Ollama accessible on the network
    # host = "0.0.0.0";
    # openFirewall = true;

    # Pre-load some models (runs as a systemd oneshot after ollama starts)
    # loadModels = [
    #   "llama3.2"        # ~2GB, good general purpose
    #   "deepseek-r1:7b"  # ~4.7GB, reasoning model
    # ];
  };

}

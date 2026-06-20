{ lib, pkgs, config, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "theseus";

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

}

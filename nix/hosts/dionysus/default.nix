{ lib, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "dionysus";

  # Intel graphics
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
  ];

}

{ lib, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "dionysus";

  # Don't wait for network on boot (laptop, moves between networks)
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Intel graphics
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
  ];

  programs.steam = {
    enable = true;
  };

}

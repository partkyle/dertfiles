{ lib, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
    ../../modules/steam.nix
  ];

  networking.hostName = "minotaur";

  # Don't wait for network on boot (laptop, moves between networks)
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

}

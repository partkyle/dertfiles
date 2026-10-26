{ lib, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
    ../../modules/steam.nix
  ];

  networking.hostName = "dionysus";

  # Don't wait for network on boot (laptop, moves between networks)
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Intel graphics
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
  ];

  # logind ignores lid events for 30s (HoldoffTimeoutSec) after boot and after
  # every resume so it can see hotplugged docks/displays before deciding that
  # "docked" means "ignore the lid". This laptop has no dock, so closing the lid
  # right after resuming silently did nothing: no suspend, no swayidle
  # before-sleep lock. React immediately instead.
  services.logind.settings.Login.HoldoffTimeoutSec = "0s";

}

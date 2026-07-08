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

  # dwl with eDP-1 @ 1.25 scale + cursor-scale patch for HiDPI cursor
  environment.systemPackages = with pkgs; [
    ((dwl.override { configH = ../../packages/dwl/config-dionysus.h; }).overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ../../packages/dwl/cursor-scale.patch ];
    }))
    wlr-randr
  ];

}

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
    extest.enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        STEAM_FORCE_WAYLAND = "1";
        SDL_VIDEODRIVER = "wayland";
        GDK_BACKEND = "wayland,x11";
        QT_QPA_PLATFORM = "wayland;xcb";
      };
    };
    extraPackages = with pkgs; [ gamescope ];
  };

  programs.gamescope.enable = true;

}

{
  lib,
  pkgs,
  config,
  ...
}:
{

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

  # dwl with minimal config: only DP-2 rotated 270° (portrait), nothing else changed
  environment.systemPackages = with pkgs; [
    calibre
    ((dwl.override { configH = ../../packages/dwl/config-theseus.h; }).overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ../../packages/dwl/cursor-scale.patch ];
    }))
    wlr-randr
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; # key-based auth only
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
      AllowAgentForwarding = true;
    };
  };

  programs.steam = {
    enable = true;
  };

}

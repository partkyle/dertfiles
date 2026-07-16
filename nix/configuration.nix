{ lib, pkgs, ... }: {

  imports = [
    ./greetd.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Binary caches
    extra-substituters = [
      "https://pi.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.network.enable = true;
  networking.useNetworkd = true;
  services.resolved.enable = true;
  networking.wireless.iwd.enable = true;

  virtualisation.docker.enable = true;

  programs.fish.enable = true;

  # DWL is provided as a user package via home-manager (host-specific config)
  # No system-level compositor program needed unlike Hyprland

  users.users.partkyle = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbDY+neU1up+zsrz75ZsJGbgdupbYJdcCsLZJ/p+W26 partkyle@theseus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBL1TBBccA0/KpzcekAUr/peNgc1QTNN4W9UK8ofQR4G partkyle@dionysus"
    ];
  };

  environment.systemPackages = with pkgs; [
    # basic system utils for dwl
    libinput
    wayland
    wayland-protocols
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

  services.tailscale = {
    enable = true;
  };

  # Enable the unfree 1Password packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
      "1password-gui"
      "1password"
    ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "partkyle" ];
  };

  # Configure custom allowed browsers for 1Password
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        brave
        vivaldi-bin
      '';
      mode = "0755";
    };
  };

  # Enable the dconf system service (required for Home Manager to change dconf settings)
  programs.dconf.enable = true;

  # XDG portals for wlroots-based compositors (dwl)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gtk" ];
  };

  # PAM config for quickshell lock screen
  security.pam.services.quickshell = {
    text = ''
      auth sufficient pam_unix.so likeauth try_first_pass nullok
      auth required pam_deny.so
    '';
  };

  system.stateVersion = "26.05";
}

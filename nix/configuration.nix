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
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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

  # dwl is the compositor; built per-host in hosts/<host>/default.nix

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
    (writeShellScriptBin "start-dwl" ''
      set -e

      cleanup() {
        kill "$DWL_PID" "$WAYBAR_PID" "$MAKO_PID" "$HYPRIDLE_PID" 2>/dev/null || true
      }
      trap cleanup EXIT

      # Start dwl compositor
      dwl &
      DWL_PID=$!

      # Give dwl a moment to set up the wlroots session
      sleep 0.3

      # Start companion services
      waybar &
      WAYBAR_PID=$!
      mako &
      MAKO_PID=$!
      hypridle &
      HYPRIDLE_PID=$!

      # Wait for dwl to exit
      wait $DWL_PID
    '')
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

  # Alternatively, you could also just allow all unfree packages
  # nixpkgs.config.allowUnfree = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "partkyle" ];
  };

  # Configure custom allowed browsers for 1Password
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        brave
        vivaldi-bin
      '';
      mode = "0755"; # Crucial file permissions required by 1Password
    };
  };

  # Enable the dconf system service (required for Home Manager to change dconf settings)
  programs.dconf.enable = true;

  # Ensure the portals are loaded at the system level
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  system.stateVersion = "26.05";
}

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

  programs.hyprland.enable = true;

  users.users.partkyle = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    # empty
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
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  fonts.packages = with pkgs; [
    comic-neue
    maple-mono.NF
  ];

  system.stateVersion = "26.05";
}

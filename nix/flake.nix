{
  description = "partkyle nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pi-nix = {
      url = "github:lukasl-dev/pi.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      pi-nix,
      ...
    }:
    let
      sharedModules = [
        ./modules/claude.nix
        ./modules/fish.nix
        ./modules/hyprland.nix
        ./modules/pipewire.nix
        ./modules/quickshell.nix
        ./modules/reaper.nix
        ./modules/syncthing.nix
        ./modules/walker.nix

        {
          nixpkgs.overlays = [ pi-nix.overlays.default ];
        }

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.partkyle = import ./home.nix;
        }
      ];

      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/${hostName}/default.nix
          ]
          ++ sharedModules
          ++ [
            {
              # Host-specific hyprland monitor config
              programs.hyprland.hostLuaFile = ../hypr/.config/hypr/hosts/${hostName}.lua;
            }
          ];
        };
    in
    {
      nixosConfigurations.dionysus = mkHost "dionysus";
      nixosConfigurations.theseus = mkHost "theseus";
    };
}

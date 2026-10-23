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
    direnv-src = {
      url = "github:direnv/direnv/v2.38.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      pi-nix,
      direnv-src,
      ...
    }:
    let
      sharedModules = [
        ./modules/bun.nix
        ./modules/claude.nix
        ./modules/fish.nix
        ./modules/ghostty.nix
        ./modules/hyprland.nix
        ./modules/keyd.nix
        ./modules/kitty.nix
        ./modules/mango.nix
        ./modules/pipewire.nix
        ./modules/quickshell.nix
        ./modules/reaper.nix
        ./modules/syncthing.nix
        ./modules/tmux.nix
        ./modules/vital.nix
        ./modules/vst-plugins.nix

        {
          nixpkgs.overlays = [
            pi-nix.overlays.default

            # `require_allowed` in ./.envrc needs direnv >= 2.38, which
            # nixos-unstable does not carry yet (2.37.1) even though nixpkgs
            # master does. Take the package from the direnv repo's own flake
            # in the meantime; `inputs.nixpkgs.follows` keeps it building
            # against our nixpkgs. Drop this once the channel is on >= 2.38.
            (final: prev: {
              direnv = direnv-src.packages.${prev.stdenv.hostPlatform.system}.default;
            })
          ];
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
          ++ sharedModules;
        };
    in
    {
      nixosConfigurations.dionysus = mkHost "dionysus";
      nixosConfigurations.theseus = mkHost "theseus";

      # Entered by direnv from the repo-root .envrc (`use flake ./nix`). The
      # tools mirror what AGENTS.md says to verify with: `luac -p` for the
      # Hyprland lua config, `mango -c … -p` for the mango config, plus
      # shellcheck for bin/dert, scripts/ and nix/{hypr,mango}/scripts/.
      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          packages = with pkgs; [
            shellcheck
            lua5_4
            mangowc
            nixfmt
            statix
            nil
            nodejs # test/notification-logic.test.js
          ];
        };
    };
}

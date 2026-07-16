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

	outputs = { nixpkgs, home-manager, pi-nix, ...}: let
		dwlConfigForHost = hostName:
			builtins.readFile ../dwl/.config/dwl/config-base.h +
			builtins.readFile ../dwl/.config/dwl/hosts/${hostName}.h;

		sharedModules = [
			./modules/fish.nix
			./modules/syncthing.nix

			home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.partkyle = import ./home.nix;
			}
		];

		mkHost = hostName: nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./hosts/${hostName}/default.nix
			] ++ sharedModules ++ [{
				# Overlay pi-nix and host-specific dwl config
				nixpkgs.overlays = [
					pi-nix.overlays.default
					(final: prev: {
						dwl = prev.dwl.override {
							configH = final.writeText "config.h"
								(dwlConfigForHost hostName);
						};
						# Wrapper that integrates dwl with systemd user session
						dwl-session = final.writeShellScriptBin "dwl-session" ''
							systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
							dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
							systemctl --user start graphical-session.target
							exec ${final.dwl}/bin/dwl
						'';
					})
				];
			}];
		};
	in {
		nixosConfigurations.dionysus = mkHost "dionysus";
		nixosConfigurations.theseus = mkHost "theseus";
	};
}

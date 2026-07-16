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
		sharedModules = [
			./modules/fish.nix
			./modules/syncthing.nix

			{
				nixpkgs.overlays = [ pi-nix.overlays.default ];
			}

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
			] ++ sharedModules;
  };
	in {
		nixosConfigurations.dionysus = mkHost "dionysus";
		nixosConfigurations.theseus = mkHost "theseus";
	};
}

{
	description = "partkyle nixos config";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, home-manager, ...}: {
		nixosConfigurations.dionysus = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./hosts/dionysus/default.nix

				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;

					home-manager.users.partkyle = import ./home.nix;
				}
			];
		};
	};
}

HOST := $(shell hostname)

.PHONY: rebuild update-pi changelog

rebuild:
	cd nix && sudo nixos-rebuild switch --flake .#$(HOST)

update-pi:
	cd nix && nix flake update pi-nix && sudo nixos-rebuild switch --flake .#$(HOST)

changelog:
	@bash scripts/changelog.sh

{ lib, ... }:

{
  # oh-my-pi (OMP), a pi fork, installed per-user through home-manager.
  #
  # `programs.omp` comes from OMP's own flake (`omp.homeManagerModules.default`,
  # imported via `home-manager.sharedModules` in flake.nix); its default
  # package is `omp.packages.<system>.default`, which the `omp.overlays.default`
  # overlay also exposes as `pkgs.omp`. Adding/removing OMP is therefore just
  # this file's entry in `sharedModules`.
  #
  # No `settings` are declared: OMP rewrites ~/.omp/agent/config.yml itself
  # (/settings, onboarding), and declaring settings would overwrite those
  # runtime changes on every switch. Add them here when they should be owned
  # by the repo instead.
  home-manager.users.partkyle.programs.omp = {
    enable = true;
    settings = null;
  };
}

{ ... }:
{
  nixos.sharedModules = [ ./nixos.nix ];
  home.sharedModules = [ ./home.nix ];
}

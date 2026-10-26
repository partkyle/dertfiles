{ ... }:
{
  nixos.hosts.dionysus.modules = [
    ./hardware-configuration.nix
    ./nixos.nix
  ];
}

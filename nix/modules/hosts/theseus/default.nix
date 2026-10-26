{ ... }:
{
  nixos.hosts.theseus.modules = [
    ./hardware-configuration.nix
    ./nixos.nix
  ];
}

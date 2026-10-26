{
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.nixos = {
    sharedModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [ ];
      description = "NixOS modules applied to every host.";
    };

    hosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          system = mkOption {
            type = types.str;
            default = "x86_64-linux";
          };
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [ ];
          };
        };
      });
      default = { };
    };
  };

  options.home = {
    sharedModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [ ];
      description = "Home Manager modules applied to every user on every host.";
    };

    users = mkOption {
      type = types.attrsOf (types.submodule {
        options.modules = mkOption {
          type = types.listOf types.deferredModule;
          default = [ ];
        };
      });
      default = { };
    };
  };

  config.flake.nixosConfigurations = lib.mapAttrs (
    _hostName: host:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (host) system;
      modules =
        [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = lib.mapAttrs (_: user: {
              imports = config.home.sharedModules ++ user.modules;
            }) config.home.users;
          }
        ]
        ++ config.nixos.sharedModules
        ++ host.modules;
    }
  ) config.nixos.hosts;
}

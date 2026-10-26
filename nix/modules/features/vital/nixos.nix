{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.programs.vital = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install Vital synth.";
    };
  };

  config = lib.mkIf config.programs.vital.enable {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vital" ];

    home-manager.users.partkyle = {
      home.packages = [ pkgs.vital ];
    };
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.bun;
in
{
  options.programs.bun = {
    enable = (lib.mkEnableOption "the Bun JavaScript runtime") // {
      default = true;
    };

    package = lib.mkPackageOption pkgs "bun" { };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages installed alongside Bun.";
    };
  };

  # Enabled by default so both hosts get bun without extra host config; set
  # `programs.bun.enable = false` to opt out.
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
  };
}

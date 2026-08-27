# modules/vst-plugins.nix
{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.programs.vstPlugins = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Aggregate all Nix-installed VST3 plugins into ~/.vst3 for REAPER.";
    };
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ pkgs.vital ];
      description = "Plugin packages to symlink into the VST3 farm.";
    };
  };
  config = lib.mkIf config.programs.vstPlugins.enable {
    home-manager.users.partkyle = {
      home.file.".vst3".source = "${
        pkgs.symlinkJoin {
          name = "vst3-plugins";
          paths = config.programs.vstPlugins.packages;
        }
      }/lib/vst3";
    };
  };
}

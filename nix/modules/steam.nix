{ lib, pkgs, config, ... }:
let
  waylandLibs = l: with l; [ wayland libxkbcommon libdrm libGL ];
  baseEnv = {
    STEAM_FORCE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
in
{
  options.programs.steam.waylandExtraEnv = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = "Extra environment variables merged into the Steam Wayland override.";
  };

  config = {
    programs.steam = {
      enable = true;
      extest.enable = true;
      extraPackages = with pkgs; [ gamescope ];
      package = pkgs.steam.override {
        extraLibraries = waylandLibs;
        extraEnv = baseEnv // config.programs.steam.waylandExtraEnv;
      };
    };

    programs.gamescope.enable = true;
  };
}

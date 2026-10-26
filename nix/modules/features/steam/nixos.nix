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

    # Gamescope: 4K/240Hz/HDR Overwatch via `gamescope -W 3840 -H 2160 -r 240 -f --hdr-enabled -- %command%`
    # launch options (set in Steam per-game). capSysNice gives gamescope real-time
    # priority via a setuid wrapper to prevent stutter at high refresh rates.
    programs.gamescope = {
      enable = true;
      enableWsi = true;
      capSysNice = true;
    };
  };
}

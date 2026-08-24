{ lib, pkgs, config, ... }:

{
  options.programs.hyprland.hostLuaFile = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    default = null;
    description = "Host-specific Hyprland Lua config file (e.g., monitor setup).";
  };

  config = {
    # ── NixOS-level ──────────────────────────────────────────────────

    programs.hyprland.enable = true;

    nix.settings = {
      extra-substituters = [ "https://hyprland.cachix.org" ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

    # ── Home Manager-level ───────────────────────────────────────────

    home-manager.users.partkyle = {
      home.packages = with pkgs; [
        hypridle
        hyprlock
        libxkbcommon # xkbcli for keybind keycode resolution
        lua          # keybinds.sh Lua config scanner
        mako         # notification daemon (makoctl)
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        configType = "lua";

        extraLuaFiles = {
          "partkyle" = {
            content = ../../hypr/.config/hypr/partkyle.lua;
            autoLoad = true;
          };
        }
        // lib.optionalAttrs (config.programs.hyprland.hostLuaFile != null) {
          "host" = {
            content = config.programs.hyprland.hostLuaFile;
            autoLoad = true;
          };
        };
      };

      systemd.user.services.mako = {
        Unit = {
          Description = "Mako notification daemon";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.mako}/bin/mako";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "hyprland-session.target" ];
        };
      };

      systemd.user.services.hypridle = {
        Unit = {
          Description = "Hyprland idle daemon";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.hypridle}/bin/hypridle";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "hyprland-session.target" ];
        };
      };

      xdg.configFile = {
        "mako".source = ../../mako/.config/mako;
        "hypr/hypridle.conf".source = ../../hypr/.config/hypr/hypridle.conf;
        "hypr/hyprlock.conf".source = ../../hyprlock/.config/hypr/hyprlock.conf;
        "hypr/mocha.conf".source = ../../hyprmocha/.config/hypr/mocha.conf;
        "hypr/scripts/keybinds.sh" = {
          source = ../../hypr/.config/hypr/scripts/keybinds.sh;
          executable = true;
        };
      };
    };
  };
}

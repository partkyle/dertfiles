{
  lib,
  pkgs,
  config,
  ...
}:

let
  defaultHostLuaFile = ../../hypr/.config/hypr/hosts/${config.networking.hostName}.lua;
in
{
  options.programs.hyprland.hostLuaFile = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    default = if builtins.pathExists defaultHostLuaFile then defaultHostLuaFile else null;
    description = "Host-specific Hyprland Lua config file (e.g., monitor setup). Defaults to hypr/hosts/<hostname>.lua when present.";
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
      # Hyprland's native cursor format (uses the cursor set in home.nix).
      home.pointerCursor.hyprcursor.enable = true;

      home.packages = with pkgs; [
        hypridle
        hyprlock
        libxkbcommon # xkbcli for keybind keycode resolution
        lua # keybinds.sh Lua config scanner
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

      systemd.user.services.hypridle = {
        Unit = {
          Description = "Hyprland idle daemon";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
          # Restart when hypridle.conf changes (sd-switch only sees unit files).
          X-Restart-Triggers = [
            "${config.home-manager.users.partkyle.xdg.configFile."hypr/hypridle.conf".source}"
          ];
          X-SwitchMethod = "restart";
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
        "hypr/hypridle.conf".source = ../../hypr/.config/hypr/hypridle.conf;
        "hypr/hyprlock.conf".source = ../../hyprlock/.config/hypr/hyprlock.conf;
        "hypr/mocha.conf".source = ../../hyprmocha/.config/hypr/mocha.conf;
        "hypr/scripts/keybinds.sh" = {
          source = ../../hypr/.config/hypr/scripts/keybinds.sh;
          executable = true;
        };
        "hypr/scripts/idle-inhibit.sh" = {
          source = ../../hypr/.config/hypr/scripts/idle-inhibit.sh;
          executable = true;
        };
      };
    };
  };
}

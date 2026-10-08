{
  lib,
  pkgs,
  config,
  ...
}:

let
  # Hyprland config lives under nix/ because it is Linux/Nix-only and never
  # stowed (macOS doesn't run Hyprland).
  hostLuaFile = ../hypr/hosts/${config.networking.hostName}.lua;
  hasHostLuaFile = builtins.pathExists hostLuaFile;

  # Link the Lua files straight at the working tree instead of a store copy so
  # Hyprland's own config watcher reloads on save (the stow behaviour). This
  # is intentionally impure: the repo must live at ~/.dertfiles.
  dotfilesDir = "${config.home-manager.users.partkyle.home.homeDirectory}/.dertfiles";
  live =
    subpath:
    config.home-manager.users.partkyle.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nix/hypr/${subpath}";
in
{
  config = {
    # ── NixOS-level ──────────────────────────────────────────────────

    programs.hyprland = {
      enable = true;
      # UWSM wraps the compositor in a proper systemd user session: it starts
      # graphical-session.target, imports the environment into systemd/D-Bus,
      # and sets XDG_*. This replaces Hyprland's own systemd integration, the
      # custom hyprland-session.target, and the hooks that used to live in
      # hyprland.lua. Session services bind to graphical-session.target.
      withUWSM = true;
    };

    programs.uwsm.waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };

    nix.settings = {
      extra-substituters = [ "https://hyprland.cachix.org" ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    # ── Home Manager-level ───────────────────────────────────────────

    home-manager.users.partkyle = {
      # Hyprland's native cursor format (uses the cursor set in home.nix).
      home.pointerCursor.hyprcursor.enable = true;

      home.packages = with pkgs; [
        grim # screen capture backing hypr/scripts/screenshot.sh
        hypridle
        hyprlock
        libxkbcommon # xkbcli for keybind resolution in keybinds.sh
        lua # keybinds.sh Lua config scanner
        satty # screenshot annotation editor
        slurp # region selection for screenshot.sh
      ];

      # We own hyprland.lua (live-linked below). Keep configType = "lua" so
      # Home Manager still writes hypr/.luarc.json for the Lua language server.
      # systemd.enable = false because UWSM owns the session.
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        systemd.enable = false;
      };

      systemd.user.services.hypridle = {
        Unit = {
          Description = "Hyprland idle daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
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
          WantedBy = [ "graphical-session.target" ];
        };
      };

      xdg.configFile = {
        # Live links: Hyprland watches these and reloads on save, no rebuild.
        "hypr/hyprland.lua".source = live "hyprland.lua";

        # Store copies: content is captured in the generation and applied on
        # rebuild (hypridle restarts via X-Restart-Triggers above).
        "hypr/hypridle.conf".source = ../hypr/hypridle.conf;
        "hypr/hyprlock.conf".source = ../hypr/hyprlock.conf;
        "hypr/mocha.conf".source = ../hypr/mocha.conf;
        "hypr/scripts/keybinds.sh" = {
          source = ../hypr/scripts/keybinds.sh;
          executable = true;
        };
        "hypr/scripts/idle-inhibit.sh" = {
          source = ../hypr/scripts/idle-inhibit.sh;
          executable = true;
        };
        "hypr/scripts/screenshot.sh" = {
          source = ../hypr/scripts/screenshot.sh;
          executable = true;
        };
      }
      // lib.optionalAttrs hasHostLuaFile {
        "hypr/host.lua".source = live "hosts/${config.networking.hostName}.lua";
      };
    };
  };
}

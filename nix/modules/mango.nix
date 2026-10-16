{
  lib,
  pkgs,
  config,
  ...
}:

let
  # Per-host monitor rules, live-linked like the Hyprland host file. Absent on
  # hosts without one; config.conf pulls it in with source-optional.
  hostConf = ../mango/hosts/${config.networking.hostName}.conf;
  hasHostConf = builtins.pathExists hostConf;

  # Link the config straight at the working tree instead of a store copy so
  # the repo is the single source of truth (no rebuild to pick up an edit).
  # Mango 0.17.2 does not watch the file, so reload with Super+r after a
  # change. This is intentionally impure: the repo must live at ~/.dertfiles.
  dotfilesDir = "${config.home-manager.users.partkyle.home.homeDirectory}/.dertfiles";
  live =
    subpath:
    config.home-manager.users.partkyle.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nix/mango/${subpath}";
in
{
  config = {
    # ── NixOS-level ──────────────────────────────────────────────────

    programs.mango.enable = true;

    # Mango starts `mango-session.target` itself (after importing the session
    # environment into systemd/D-Bus); that target BindsTo
    # graphical-session.target, so user services (quickshell, hypridle,
    # keyd-application-mapper) come up with the session. Register the
    # package's user units so the target resolves.
    systemd.packages = [ config.programs.mango.package ];

    # xdg-autostart/dbus plumbing for window-manager-only sessions.
    services.graphical-desktop.enable = true;

    # XWayland is required: REAPER and Steam/Proton games are X11 clients.
    # (Hyprland already turns this on; set it here so mango does not depend on
    # the Hyprland module staying installed.)
    programs.xwayland.enable = true;

    # ── Home Manager-level ───────────────────────────────────────────

    home-manager.users.partkyle = {
      home.packages = with pkgs; [
        swaybg # draws the session background via background.sh
        wlopm # DPMS for hypridle's display-sleep listener
      ];

      # Random background, picked once per session start. Bound to
      # mango-session.target rather than graphical-session.target so it does
      # not also run under Hyprland. Restart the unit to roll a new image.
      systemd.user.services.mango-background = {
        Unit = {
          Description = "Mango background (swaybg)";
          PartOf = [ "mango-session.target" ];
          After = [ "mango-session.target" ];
        };
        Service = {
          ExecStart = "${config.home-manager.users.partkyle.home.homeDirectory}/.config/mango/scripts/background.sh";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "mango-session.target" ];
        };
      };

      xdg.configFile = {
        # Live link: no rebuild needed to edit; reload with Super+r.
        "mango/config.conf".source = live "config.conf";

        # Store copies: shared with the Hyprland module.
        "mango/scripts/screenshot.sh" = {
          source = ../hypr/scripts/screenshot.sh;
          executable = true;
        };
        "mango/scripts/wm-dir.sh" = {
          source = ../mango/scripts/wm-dir.sh;
          executable = true;
        };
        "mango/scripts/background.sh" = {
          source = ../mango/scripts/background.sh;
          executable = true;
        };
      }
      // lib.optionalAttrs hasHostConf {
        "mango/host.conf".source = live "hosts/${config.networking.hostName}.conf";
      };
    };
  };
}

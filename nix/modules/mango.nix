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
  # mango's config watcher reloads on save (the stow behaviour). This is
  # intentionally impure: the repo must live at ~/.dertfiles.
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
        wlopm # DPMS for hypridle's display-sleep listener
      ];

      xdg.configFile = {
        # Live link: mango watches this and reloads on save.
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
      }
      // lib.optionalAttrs hasHostConf {
        "mango/host.conf".source = live "hosts/${config.networking.hostName}.conf";
      };
    };
  };
}

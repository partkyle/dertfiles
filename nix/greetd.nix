{
  config,
  pkgs,
  ...
}:

let
  # Canonical session list assembled from services.displayManager.sessionPackages
  # (Hyprland, Hyprland (UWSM), Mango). NixOS also exposes the same sessions
  # through the system profile, and tuigreet scans $XDG_DATA_DIRS whenever
  # --sessions is absent, so without pinning both the greeter would list every
  # session twice.
  sessionShare = "${config.services.displayManager.sessionData.desktops}/share";
  sessionsDir = "${sessionShare}/wayland-sessions";

  # tuigreet preselects the alphabetically first session, and "Hyprland" sorts
  # before "Mango", so the picker alone can never default to mango. `--cmd` is
  # tuigreet's documented default-session command: a manual F3 selection
  # overrides it and, with --remember-session, is remembered. Because --cmd
  # bypasses the desktop file, repeat the XDG variables that file would set
  # (its DesktopNames=mango;wlroots, with ';' turned into ':').
  defaultSession = "mango";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # `env` scopes XDG_DATA_DIRS to the greeter only; the user session is
        # launched by greetd through PAM, so it keeps the normal data dirs.
        command = "${pkgs.coreutils}/bin/env XDG_DATA_DIRS=${sessionShare} ${pkgs.tuigreet}/bin/tuigreet --time --sessions ${sessionsDir} --cmd ${defaultSession} --env XDG_SESSION_DESKTOP=mango --env XDG_SESSION_TYPE=wayland --env XDG_CURRENT_DESKTOP=mango:wlroots --remember --remember-session --theme 'text=green;input=cyan;action=yellow'";
      };
    };
  };
}

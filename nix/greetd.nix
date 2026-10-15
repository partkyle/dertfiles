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
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # `env` scopes XDG_DATA_DIRS to the greeter only; the user session is
        # launched by greetd through PAM, so it keeps the normal data dirs.
        command = "${pkgs.coreutils}/bin/env XDG_DATA_DIRS=${sessionShare} ${pkgs.tuigreet}/bin/tuigreet --time --sessions ${sessionsDir} --remember --remember-session --theme 'text=green;input=cyan;action=yellow'";
      };
    };
  };
}

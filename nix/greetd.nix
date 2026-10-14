{ pkgs, ... }:

let
  # Let tuigreet list the sessions installed under /run/current-system/sw
  # (Hyprland and mango, each with a plain and a UWSM variant). Pick Hyprland's
  # "(UWSM)" entry, or the plain "mango" entry: mango starts its own session
  # target, while plain Hyprland would skip it.
  sessionsDir = "/run/current-system/sw/share/wayland-sessions";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --sessions ${sessionsDir} --remember --remember-session --theme 'text=green;input=cyan;action=yellow'";
      };
    };
  };
}

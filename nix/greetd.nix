{ lib, pkgs, ... }:

let
  # UWSM wraps the compositor in the systemd graphical session. greetd/tuigreet
  # are just the launcher for now; swapping them out later only changes this
  # command, not the UWSM setup.
  hyprlandSession = "/run/current-system/sw/bin/uwsm start -F -- /run/current-system/sw/bin/Hyprland";
in
{
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = hyprlandSession;
        user = "partkyle";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${hyprlandSession}' --remember --theme 'text=green;input=cyan;action=yellow'";
      };
    };
  };
}

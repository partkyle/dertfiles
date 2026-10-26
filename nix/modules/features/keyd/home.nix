{
  lib,
  pkgs,
  ...
}:

let
  # keyd-application-mapper normalizes the focused window class before matching:
  # it lowercases it and replaces every run of non-alphanumeric characters with a
  # single "-". Section headers are matched verbatim with fnmatch, so they must
  # already be normalized (com.mitchellh.ghostty -> com-mitchellh-ghostty).
  terminalSection = ''
    control.a = C-a
    control.e = C-e
    meta.c = C-S-c
    meta.v = C-S-v
  '';

  terminalClasses = [
    "foot"
    "org-codeberg-dnkl-foot"
    "alacritty"
    "kitty"
    "com-mitchellh-ghostty"
    "wezterm"
  ];

  appConf = lib.concatMapStringsSep "\n" (class: ''
    [${class}]
    ${terminalSection}
  '') terminalClasses;
in
{
  # Provides keyd-application-mapper.
  home.packages = [ pkgs.keyd ];

  xdg.configFile."keyd/app.conf".text = appConf;

  # The application mapper watches the focused toplevel through
  # zwlr_foreign_toplevel_manager_v1 (implemented by both Hyprland and
  # mango) and swaps in app-specific bindings. A session service keeps it
  # running for either compositor.
  systemd.user.services.keyd-application-mapper = {
    Unit = {
      Description = "keyd application-aware remapping";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.keyd}/bin/keyd-application-mapper";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

{
  config,
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
  config = {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings = {
          # Ctrl+A/Ctrl+E are Home/End everywhere. The Shift variants
          # (select-to-line-start/end) fall out of keyd's modifier stacking.
          control = {
            a = "home";
            e = "end";
          };
          # Super chords drive the focused app's own clipboard/select-all.
          meta = {
            a = "C-a";
            x = "C-x";
            c = "C-c";
            v = "C-v";
            # Kept from the old Hyprland send_shortcut_once() workaround.
            t = "C-t";
            w = "C-w";
          };
          # Super+Shift+C must still reach Hyprland (center window). The
          # composite layer re-emits the full chord instead of the meta
          # layer's plain C-c.
          "meta+shift" = {
            c = "M-S-c";
          };
        };
      };
    };

    # keyd-application-mapper talks to /run/keyd.socket (root:keyd, mode 0660),
    # so the group has to exist and the user has to be a member.
    users.groups.keyd = { };
    users.users.partkyle.extraGroups = [ "keyd" ];

    # keyd's chgid() calls setgid("keyd") on startup, but the NixOS unit drops
    # CAP_SETGID (CapabilityBoundingSet is only CAP_SYS_NICE/CAP_IPC_LOCK), so
    # that call fails with EPERM as soon as the group exists. Pre-setting the
    # primary group makes setgid() a no-op; the socket stays root:keyd 0660.
    systemd.services.keyd.serviceConfig.Group = "keyd";

    home-manager.users.partkyle = {
      # Provides keyd-application-mapper, started from hyprland.lua.
      home.packages = [ pkgs.keyd ];

      xdg.configFile."keyd/app.conf".text = appConf;
    };
  };
}

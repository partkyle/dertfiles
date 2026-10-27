{ ... }:

{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        # CapsLock is the user's Control. The compositor's `ctrl:nocaps` xkb
        # option is applied after keyd, so keyd only ever sees CAPSLOCK and
        # the control layer — and its Home/End mappings — would never
        # activate for CapsLock chords. Binding it to the same layer emits
        # Control and activates those mappings, exactly like the real key.
        main = {
          capslock = "layer(control)";
        };
        # Ctrl+A/Ctrl+E are Home/End by default; only the classes listed in
        # app.conf keep their native chords. The Shift variants
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
}

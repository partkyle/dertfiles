{
  lib,
  ...
}:

{
  # Enabled on every host by default; a host can opt out with
  # `home-manager.users.partkyle.programs.kitty.enable = false;`.
  # The font mirrors the foot config in home.nix (Maple Mono NF at size 12,
  # with the same cv05/cv38 character variants).
  home-manager.users.partkyle.programs.kitty = {
    enable = lib.mkDefault true;

    font = {
      name = "Maple Mono NF";
      size = 12;
    };

    settings = {
      font_features = "Maple Mono NF +cv05 +cv38";

      tab_bar_style = "powerline";

      cursor_blink_interval = -1;
      cursor_trail = 1;
      custom_shaders = "cursor-trail-motion-blur";
    };
  };
}

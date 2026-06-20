{ lib, pkgs, ... }: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland --remember --theme 'text=green;input=cyan;action=yellow'";
      };
    };
  };
}

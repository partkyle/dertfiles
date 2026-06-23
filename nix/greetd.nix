{ lib, pkgs, ... }: {
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "start-hyprland";
        user = "partkyle";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland --remember --theme 'text=green;input=cyan;action=yellow'";
      };
    };
  };
}

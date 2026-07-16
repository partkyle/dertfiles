{ lib, pkgs, ... }: {
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "start-dwl";
        user = "partkyle";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-dwl --remember --theme 'text=green;input=cyan;action=yellow'";
      };
    };
  };
}

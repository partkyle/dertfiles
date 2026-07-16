{ lib, pkgs, ... }: let
  dwlSessionExe = lib.getExe pkgs.dwl-session;
in {
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = dwlSessionExe;
        user = "partkyle";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${dwlSessionExe} --remember --theme 'text=green;input=cyan;action=yellow'";
      };
    };
  };
}

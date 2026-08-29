{
  lib,
  pkgs,
  config,
  ...
}:
let
  reaperPkg = pkgs.reaper.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      rm -rf $out/share/applications
    '';
  });
in
{
  options.programs.reaper = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install REAPER and create a pw-jack desktop entry.";
    };
  };
  config = lib.mkIf config.programs.reaper.enable {
    home-manager.users.partkyle = {
      home.packages = [
        reaperPkg
        pkgs.pipewire.jack
      ];
      xdg.desktopEntries.reaper = {
        name = "REAPER (jack)";
        exec = "${pkgs.pipewire.jack}/bin/pw-jack ${reaperPkg}/bin/reaper";
        icon = "cockos-reaper";
        categories = [
          "Audio"
          "AudioVideo"
          "Sequencer"
        ];
        terminal = false;
        startupNotify = true;
      };
    };
  };
}

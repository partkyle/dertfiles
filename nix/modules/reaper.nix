{ lib, pkgs, config, ... }:

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
      home.packages = [ pkgs.reaper pkgs.pipewire.jack ];

      xdg.desktopEntries.reaper = {
        name = "REAPER (jack)";
        exec = "${pkgs.pipewire.jack}/bin/pw-jack ${pkgs.reaper}/bin/reaper";
        icon = "cockos-reaper";
        categories = [ "Audio" "AudioVideo" "Sequencer" ];
        terminal = false;
        startupNotify = true;
      };
    };
  };
}

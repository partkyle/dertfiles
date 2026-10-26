{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.programs.desktopIdle = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install and start the compositor-agnostic idle, lock, and display-sleep stack.";
    };
  };

  config = lib.mkIf config.programs.desktopIdle.enable {
    home-manager.users.partkyle = {
      home.packages = with pkgs; [
        swayidle
        swaylock-effects
        wlopm
      ];

      systemd.user.services.swayidle = {
        Unit = {
          Description = "Wayland idle daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          # Restart when swayidle.conf changes (sd-switch only sees unit files).
          X-Restart-Triggers = [
            "${config.home-manager.users.partkyle.xdg.configFile."idle/swayidle.conf".source}"
          ];
          X-SwitchMethod = "restart";
        };
        Service = {
          ExecStartPre = "${config.home-manager.users.partkyle.home.homeDirectory}/.config/idle/scripts/idle-action.sh cancel";
          ExecStart = "${pkgs.swayidle}/bin/swayidle -w -C ${config.home-manager.users.partkyle.home.homeDirectory}/.config/idle/swayidle.conf";
          ExecStopPost = "${config.home-manager.users.partkyle.home.homeDirectory}/.config/idle/scripts/idle-action.sh cancel";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      xdg.configFile = {
        "swaylock/config".source = ../idle/swaylock.conf;
        "idle/swayidle.conf".source = ../idle/swayidle.conf;
        "idle/scripts/idle-action.sh" = {
          source = ../idle/scripts/idle-action.sh;
          executable = true;
        };
        "idle/scripts/idle-inhibit.sh" = {
          source = ../idle/scripts/idle-inhibit.sh;
          executable = true;
        };
        "idle/scripts/dpms.sh" = {
          source = ../idle/scripts/dpms.sh;
          executable = true;
        };
      };
    };
  };
}

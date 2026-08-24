{ lib, pkgs, config, ... }:

{
  options.programs.walker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install walker and run its systemd user service.";
    };

    wantedBy = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "hyprland-session.target" ];
      description = "Systemd user targets that pull in the walker service. Also drives PartOf/After.";
    };
  };

  config = lib.mkIf config.programs.walker.enable {
    home-manager.users.partkyle = {
      home.packages = [ pkgs.walker pkgs.elephant ];

      xdg.configFile."walker".source = ../../walker/.config/walker;

      systemd.user.services.elephant = {
        Unit = {
          Description = "Elephant data provider (backend for walker)";
          PartOf = config.programs.walker.wantedBy;
          After = config.programs.walker.wantedBy;
        };
        Service = {
          ExecStart = "${pkgs.elephant}/bin/elephant";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = config.programs.walker.wantedBy;
        };
      };

      systemd.user.services.walker = {
        Unit = {
          Description = "Walker app launcher (service mode)";
          PartOf = config.programs.walker.wantedBy;
          After = config.programs.walker.wantedBy ++ [ "elephant.service" ];
          Requires = [ "elephant.service" ];
        };
        Service = {
          ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = config.programs.walker.wantedBy;
        };
      };
    };
  };
}

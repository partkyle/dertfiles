{ lib, pkgs, config, ... }:

{
  options.programs.quickshell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install quickshell and run its systemd user service.";
    };

    wantedBy = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "hyprland-session.target" ];
      description = "Systemd user targets that pull in the quickshell service. Also drives PartOf/After.";
    };
  };

  config = lib.mkIf config.programs.quickshell.enable {
    # Battery widget reads UPower over D-Bus.
    services.upower.enable = true;

    home-manager.users.partkyle = {
      home.packages = [ pkgs.quickshell ];

      systemd.user.services.quickshell = {
        Unit = {
          Description = "Quickshell desktop shell (bar)";
          PartOf = config.programs.quickshell.wantedBy;
          After = config.programs.quickshell.wantedBy;
        };
        Service = {
          ExecStart = "${pkgs.quickshell}/bin/quickshell --no-duplicate";
          Restart = "on-failure";
          RestartSec = 3;
          # Neutralize the user's Qt theme overrides (kvantum/qt5ct) so the
          # shell renders predictably.
          Environment = [
            "QT_STYLE_OVERRIDE="
            "QT_QPA_PLATFORMTHEME="
          ];
        };
        Install = {
          WantedBy = config.programs.quickshell.wantedBy;
        };
      };

      xdg.configFile."quickshell".source = ../../quickshell;
    };
  };
}

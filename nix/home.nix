{ config, pkgs, ... }: {

  home.username = "partkyle";
  home.homeDirectory = "/home/partkyle";

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    btop
    clang
    erlang
    fd
    foot
    fzf
    git
    gnumake
    go
    mako
    neovim
    nodejs
    python3
    ripgrep
    rofi
    signal-desktop
    tree-sitter
    unzip
    vivaldi
    waybar
    wget
    wiremix
    wl-clipboard
    zoxide

    # theme stuff
    gnome-themes-extra
    adwaita-qt
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct"; 
    QT_STYLE_OVERRIDE = "kvantum";
    SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
  };

  # Force global dark preference via dconf
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Declare user GTK settings
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark"; 
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    configType = "lua";

    extraLuaFiles = {
      "partkyle" = {
        content = ../hypr/.config/hypr/partkyle.lua;
        autoLoad = true;
      };
      "clipboard" = {
        content = ../hypr/.config/hypr/clipboard.lua;
        autoLoad = true;
      };
    };
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };

  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar status bar";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };

  home.file.".zshrc".source = ../zsh/.zshrc;

  home.file.".gitconfig".source = ../git/.gitconfig;
  home.file.".gitignore_global".source = ../git/.gitignore_global;

  xdg.configFile = {
    "nvim".source = ../nvim/.config/nvim;
    "waybar".source = ../waybar/.config/waybar;
    "rofi".source = ../rofi/.config/rofi;
    "mako".source = ../mako/.config/mako;
  };

  programs.pi-coding-agent = {
    enable = true;
    
    # Extra tools Pi can use in your terminal (e.g., bun, python)
    extraPackages = [ pkgs.bun pkgs.python3 ];
    
    # Define models, keybindings, or agent context
    settings = {
      defaultProvider = "opencode-go";
      defaultModel = "deepseek-v4-flash";
    };
  };

  home.file.".ssh/config".text = ''
    IdentityAgent ~/.1password/agent.sock
  '';

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Maple Mono NF:size=11:fontfeatures=\\\"cv05\\\"";
      };
    };
  };

  home.stateVersion = "26.05";
}

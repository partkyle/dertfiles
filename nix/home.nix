{
  config,
  pkgs,
  lib,
  ...
}:

let
  webApps = import ./webapps.nix { inherit pkgs lib; };
  bibataRainbow = pkgs.callPackage ./packages/bibata-rainbow { };
in
{

  home.username = "partkyle";
  home.homeDirectory = "/home/partkyle";

  home.packages = with pkgs; [
    btop
    clang
    corefonts
    erlang
    fd
    fzf
    git
    gnumake
    go
    hypridle
    lazydocker
    lazygit
    mako
    neovim
    nodejs
    obsidian
    python3
    ripgrep
    rofi

    # nix tooling
    nil
    nixd
    nixfmt-rfc-style
    statix

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

    # rainbow cursor theme
    bibataRainbow.bibata-rainbow-original
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
  };

  # Only set 1Password agent socket when no forwarded agent is present
  # This preserves SSH agent forwarding (ssh -A)
  programs.bash.initExtra = lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
    if [ -z "$SSH_AUTH_SOCK" ] || [ "$SSH_AUTH_SOCK" = "" ]; then
      export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
    fi
  '';

  # shellInit runs for ALL fish shells (interactive and non-interactive)
  programs.fish.shellInit = lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
    if test -z "$SSH_AUTH_SOCK"
      set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
    end
  '';

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

  # Cursor theme configuration
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Rainbow-Original";
    package = bibataRainbow.bibata-rainbow-original;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
    x11.enable = true;
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

  systemd.user.services.hypridle = {
    Unit = {
      Description = "Hyprland idle daemon";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hypridle}/bin/hypridle";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };

  home.file.".gitconfig".source = ../git/.gitconfig;
  home.file.".gitignore_global".source = ../git/.gitignore_global;

  xdg.configFile = {
    "fastfetch".source = ../fastfetch/.config/fastfetch;
    "nvim".source = ../nvim/.config/nvim;
    "waybar".source = ../waybar/.config/waybar;
    "rofi".source = ../rofi/.config/rofi;
    "mako".source = ../mako/.config/mako;
    "hypr/hypridle.conf".source = ../hypr/.config/hypr/hypridle.conf;
  };

  programs.pi-coding-agent = {
    enable = true;

    # Extra tools Pi can use in your terminal (e.g., bun, python)
    extraPackages = [
      pkgs.bun
      pkgs.python3
    ];

    # Define models, keybindings, or agent context
    settings = {
      defaultProvider = "opencode-go";
      defaultModel = "deepseek-v4-flash";
    };
  };

  # SSH_AUTH_SOCK is set conditionally above; no IdentityAgent needed
  home.file.".ssh/config".text = "";

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "Maple Mono NF:size=11:fontfeatures=cv05:fontfeatures=cv38";
        pad = "2x2";
      };
      colors-dark = {
        alpha = "0.95";
      };
    };
  };

  programs.yazi.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  xdg.desktopEntries = webApps;

  home.stateVersion = "26.05";
}

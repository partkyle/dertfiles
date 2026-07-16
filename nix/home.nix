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
    comic-neue
    corefonts
    maple-mono.NF
    fd
    fzf
    git
    gnumake
    go
    lazydocker
    lazygit
    neovim
    nodejs
    obsidian
    python3
    ripgrep
    rofi
    swayidle       # idle daemon for dwl (replaces hypridle)
    swaylock       # fallback lock (quickshell lock is primary)

    # nix tooling
    nil
    nixd
    nixfmt
    statix

    signal-desktop
    tree-sitter
    unzip
    vivaldi
    brave
    wget
    wiremix
    wl-clipboard
    zoxide

    # quickshell for bar, notifications, lock
    quickshell

    # theme stuff
    gnome-themes-extra
    adwaita-qt
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum

    # rainbow cursor theme
    bibataRainbow.bibata-rainbow-original
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
  };

  # SSH agent socket is set in home.sessionVariables; no per-shell init needed

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

  # Cursor theme configuration (no hyprcursor for dwl)
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Rainbow-Original";
    package = bibataRainbow.bibata-rainbow-original;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ═══════════════════════════════════════════
  # QUICKSHELL BAR (replaces waybar)
  # ═══════════════════════════════════════════
  systemd.user.services.quickshell-bar = {
    Unit = {
      Description = "Quickshell status bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
      ExecStart = "${pkgs.quickshell}/bin/quickshell -c %h/.config/quickshell/bar.qml";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ═══════════════════════════════════════════
  # QUICKSHELL NOTIFICATIONS (replaces mako)
  # ═══════════════════════════════════════════
  systemd.user.services.quickshell-notifications = {
    Unit = {
      Description = "Quickshell notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
      ExecStart = "${pkgs.quickshell}/bin/quickshell -c %h/.config/quickshell/notifications.qml";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ═══════════════════════════════════════════
  # SWAYIDLE (replaces hypridle)
  # ═══════════════════════════════════════════
  systemd.user.services.swayidle = {
    Unit = {
      Description = "Swayidle idle daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w " +
        "timeout 120 '${pkgs.quickshell}/bin/quickshell -c %h/.config/quickshell/lock.qml' " +
        "timeout 300 '${pkgs.swaylock}/bin/swaylock -f' " +
        "before-sleep '${pkgs.quickshell}/bin/quickshell -c %h/.config/quickshell/lock.qml'";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.ssh-agent = {
    Unit = {
      Description = "SSH key agent";
    };
    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.socket";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file.".gitconfig".source = ../git/.gitconfig;
  home.file.".gitignore_global".source = ../git/.gitignore_global;

  xdg.configFile = {
    "fastfetch".source = ../fastfetch/.config/fastfetch;
    "nvim".source = ../nvim/.config/nvim;
    "rofi".source = ../rofi/.config/rofi;
    "quickshell".source = ../quickshell/.config/quickshell;
    "backgrounds".source = ../backgrounds/.config/backgrounds;
  };

  programs.pi-coding-agent = {
    enable = true;

    extraPackages = [
      pkgs.bun
      pkgs.python3
    ];

    settings = {
      defaultProvider = "opencode-go";
      defaultModel = "deepseek-v4-flash";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Maple Mono NF:size=12:fontfeatures=cv05:fontfeatures=cv38";
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

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

    # theme stuff
    gnome-themes-extra
    adwaita-qt
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum

    # rainbow cursor theme
    bibataRainbow.bibata-rainbow-original

    godot_4
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
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

  xdg.configFile = lib.mkMerge [
    {
      "fastfetch".source = ../fastfetch/.config/fastfetch;
      "nvim".source = ../nvim/.config/nvim;
      "backgrounds".source = ../backgrounds/.config/backgrounds;
      "rofi".source = ../rofi/.config/rofi;
    }
    webApps.wrapperFiles
  ];

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
      defaultModel = "qwen3.7-max";
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
        pad = "17x7";
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

  xdg.desktopEntries = webApps.desktopEntries;

  home.stateVersion = "26.05";
}

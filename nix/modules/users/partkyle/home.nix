{
  config,
  pkgs,
  lib,
  ...
}:

let
  webApps = import ../../../webapps.nix { inherit pkgs lib; };
  bibataRainbow = pkgs.callPackage ../../../packages/bibata-rainbow { };
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
    delve
    go
    gofumpt
    golangci-lint
    gopls
    gotools
    lazydocker
    lazygit
    libnotify # notify-send for testing/scripting notifications
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
    blender
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

  # Put ~/.local/bin (where dert is live-linked) and ~/.bun/bin (where
  # `bun add -g` puts its binaries) on PATH. Use Home Manager's sessionPath, not
  # NixOS's environment.localBinInPath: that only patches /etc/set-environment,
  # which the graphical session never sources, so fish never sees it without a
  # re-login. (xdg.localBinInPath would do this, but xdg.enable is off, so it is
  # a no-op.)
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
  ];

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

  home.file.".gitconfig".source = ../../../../git/.gitconfig;
  home.file.".gitignore_global".source = ../../../../git/.gitignore_global;

  # dert is live-linked from the working tree so the CLI tracks edits without a
  # rebuild — it is the tool you run to rebuild. Leave `executable` unset: the
  # source is an out-of-store symlink, and an explicit executable bit makes the
  # sandboxed home-files build fall back to `cp`, which cannot follow it.
  home.file.".local/bin/dert".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dertfiles/bin/dert";

  xdg.configFile = lib.mkMerge [
    {
      "fastfetch".source = ../../../../fastfetch/.config/fastfetch;
      "nvim".source = ../../../../nvim/.config/nvim;
      "backgrounds".source = ../../../../backgrounds/.config/backgrounds;
      "rofi".source = ../../../../rofi/.config/rofi;
    }
    webApps.wrapperFiles
  ];

  # direnv is a general shell tool here; the .dertfiles repo ships no .envrc,
  # so the system flake is never used as its environment. Its devShell is
  # entered explicitly with `nix develop ./nix`. Fish integration is on by
  # default (programs.fish.enable is set true).
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
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

  # The Godot package's desktop entry runs the editor with no display-driver
  # flag, so Godot picks its X11 backend and lands on XWayland. That blurs
  # under fractional monitor scaling and leaves resize artifacts, because the
  # compositor rescales a 1x buffer instead of Godot rendering at the native
  # fractional scale. Shadow the packaged entry with the same filename (which
  # is versioned upstream) — xdg.desktopEntries installs with hiPrio, so the
  # collision resolves in our favour — and force the Wayland backend.
  xdg.desktopEntries = webApps.desktopEntries // {
    "org.godotengine.Godot${lib.versions.majorMinor pkgs.godot_4.version}" = {
      name = "Godot Engine";
      genericName = "Game engine";
      comment = "Multi-platform 2D and 3D game engine with a feature-rich editor";
      exec = "${pkgs.godot_4}/bin/godot --display-driver wayland %f";
      icon = "godot";
      terminal = false;
      categories = [ "Development" "IDE" ];
      mimeType = [ "application/x-godot-project" ];
      settings = {
        StartupWMClass = "Godot";
        Keywords = "game development;development;IDE;game engine;";
      };
    };
  };

  home.stateVersion = "26.05";
}

{ lib, ... }:

{
  # tmux is configured through home-manager, which writes
  # ~/.config/tmux/tmux.conf.
  #
  # Keep the NixOS-level module off: this file is in `sharedModules`, i.e. it is
  # a NixOS module, so a plain `programs.tmux.enable` would arm the *NixOS*
  # option. That one only writes /etc/tmux.conf, whose default
  # `default-terminal "screen"` is the 8-colour terminfo entry — panes then get
  # TERM=screen, so every ncurses program (fish, eza, git, nvim, anything pi
  # shells out to) loses 256 colours and italics — and it leaves no place for
  # the user config below.
  programs.tmux.enable = lib.mkDefault false;

  home-manager.users.partkyle.programs.tmux = {
    enable = true;

    # home-manager's own default is "screen" (8 colours) as well.
    terminal = "tmux-256color";

    # pi asks for extended keys so Shift+Enter / Ctrl+Enter stay distinct from
    # Enter inside tmux; CSI-u is the reliable forwarding format (tmux >= 3.5).
    extraConfig = ''
      set -ga terminal-features ",xterm-ghostty:RGB"
      set -g extended-keys on
      set -g extended-keys-format csi-u
    '';

    historyLimit = 56000;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
  };
}

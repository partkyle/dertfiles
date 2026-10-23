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

    extraConfig = ''
      # `extkeys` says ghostty can report modified keys that have no legacy
      # encoding; it is what lets a program inside a pane (pi, nvim) use them.
      # tmux itself does not request them for its own prefix table.
      set -ga terminal-features ",xterm-ghostty:RGB:extkeys"
      set -g extended-keys on
      set -g extended-keys-format csi-u

      # windows
      bind-key 'C-c' new-window
      bind-key 'C-n' next-window
      bind-key 'C-p' previous-window
      bind-key 'C-l' last-window
      bind-key 'C-w' choose-tree -Zw
      bind-key 'C-f' command-prompt "find-window -N '%%'"
      bind-key 'C-d' detach-client
      bind-key 'C-t' clock-mode

      # windows 0-9
      bind-key 'C-0' select-window -t :=0
      bind-key 'C-1' select-window -t :=1
      bind-key 'C-2' select-window -t :=2
      bind-key 'C-3' select-window -t :=3
      bind-key 'C-4' select-window -t :=4
      bind-key 'C-5' select-window -t :=5
      bind-key 'C-6' select-window -t :=6
      bind-key 'C-7' select-window -t :=7
      bind-key 'C-8' select-window -t :=8
      bind-key 'C-9' select-window -t :=9

      # panes
      bind-key 'C-v' split-window -h
      bind-key 'C-s' split-window
      bind-key 'C-x' confirm-before kill-pane
      bind-key 'C-z' resize-pane -Z
      bind-key 'C-q' display-panes

      # prompts
      # Ctrl+/ is the 0x1f byte, which tmux names `C-_`.
      bind-key 'C-_' list-keys -N
    '';

    historyLimit = 56000;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
  };
}

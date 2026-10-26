{ lib, ... }:

{
  # tmux is configured through home-manager, which writes
  # ~/.config/tmux/tmux.conf.
  #
  # Keep the NixOS-level module off: this file is in `nixos.sharedModules`, i.e.
  # it is a NixOS module, so a plain `programs.tmux.enable` would arm the *NixOS*
  # option. That one only writes /etc/tmux.conf, whose default
  # `default-terminal "screen"` is the 8-colour terminfo entry — panes then get
  # TERM=screen, so every ncurses program (fish, eza, git, nvim, anything pi
  # shells out to) loses 256 colours and italics — and it leaves no place for
  # the user config in ./home.nix.
  programs.tmux.enable = lib.mkDefault false;
}

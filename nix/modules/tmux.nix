{ lib, ... }:

{
  # Enabled on every host by default; a host can opt out with
  # `programs.tmux.enable = false;`.
  programs.tmux.enable = lib.mkDefault true;
}

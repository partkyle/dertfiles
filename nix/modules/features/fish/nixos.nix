{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    fastfetch
    fishPlugins.fzf-fish
    fishPlugins.pure
    fzf
  ];
}

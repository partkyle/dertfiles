{
  pkgs,
  ...
}:

{
  home-manager.users.partkyle = {
    home.packages = [ pkgs.ghostty ];

    # Repo-owned, stow-style config tree (ghostty/.config/ghostty), linked like
    # the nvim/fastfetch/rofi dirs. This is a store copy, so edits to the config
    # or shaders need a rebuild before they take effect.
    xdg.configFile."ghostty".source = ../../ghostty/.config/ghostty;
  };
}

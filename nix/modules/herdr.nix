{
  pkgs,
  ...
}:

{
  home-manager.users.partkyle = { config, ... }: {
    home.packages = [ pkgs.herdr ];

    # Live-linked rather than copied into the store: Herdr rewrites config.toml
    # itself (finishing onboarding, in-app settings, channel changes), and a
    # read-only store symlink would make those writes fail. The trade-off is
    # that those writes land in the working tree; review them like any other
    # dotfile edit, then `herdr server reload-config`.
    xdg.configFile."herdr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.dertfiles/nix/herdr/config.toml";
  };
}

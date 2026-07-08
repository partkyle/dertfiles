{ config, pkgs, ... }: {
  # Note: Enabling linger so Syncthing starts on boot even without
  # a desktop session requires a one-time manual command:
  #   loginctl enable-linger partkyle
  # This creates /var/lib/systemd/linger/partkyle, telling systemd-logind
  # to keep the user manager alive regardless of login state.
  # (services.logind.lingerUsers is not available on nixpkgs 26.05.)

  home-manager.users.partkyle = {
    services.syncthing = {
      enable = true;
      overrideFolders = false;
      overrideDevices = false;

      # Tailscale-only: no global discovery, no relay servers
      settings.options = {
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        localAnnounceEnabled = false;
      };
    };
  };
}

# Changelog

## 2026-07-07

- **syncthing**: Added `modules/syncthing.nix` — dedicated NixOS module for
  Syncthing with Tailscale-only transport (global discovery, relays, and LAN
  discovery all disabled). Registered in `flake.nix` sharedModules. Removed
  inline `services.syncthing` block from `home.nix`.
  - Manual step still needed: `loginctl enable-linger partkyle` on each host
    (nixpkgs 26.05 doesn't expose `services.logind.lingerUsers`).
  - Removed invalid `dataDir`/`configDir` options (not available in this
    home-manager version). Syncthing uses `~/.local/state/syncthing` by
    default.
  - Post-rebuild: pair devices and add folders via Syncthing web UI
    (localhost:8384) using Tailscale IPs for peering.

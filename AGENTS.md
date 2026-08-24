# Agent Instructions

## Project Structure

This is a Nix flake-based dotfiles repository managing NixOS configs and user applications.

### NixOS Configuration (`nix/`)

- `flake.nix` — Entry point with nixpkgs, home-manager, pi-nix inputs
- `configuration.nix` — Shared system-wide NixOS config (imports greetd.nix)
- `home.nix` — Home Manager config for user packages and services
- `hosts/<hostname>/default.nix` — Host-specific NixOS configs (dionysus=laptop/Intel, theseus=desktop/NVIDIA)
- `modules/*.nix` — Shared NixOS modules (steam.nix, fish.nix, syncthing.nix, git-server.nix)
- `greetd.nix` — Display manager/login config
- `webapps.nix` — Desktop entries for web apps

### Hyprland (`hypr/`)

- `hyprland.lua` — Main Hyprland config (Lua-based, not hyprland.conf)
- `partkyle.lua` — User-specific keybinds, window rules, animations
- `clipboard.lua` — Clipboard manager integration
- `hosts/<hostname>.lua` — Per-host monitor configs (loaded via flake.nix)
- `hyprlock.conf`, `hypridle.conf` — Lock and idle configs

### Other Configs

- `quickshell/` — Quickshell desktop shell (replaces waybar); `shell.qml` entry point, `Commons/` theme singletons, `Ui/` base components, `widgets/` bar modules, `scripts/` helper scripts. Deployed via `nix/modules/quickshell.nix`
- `foot/` — Terminal config
- `nvim/` — Neovim config (LazyVim-based)
- `git/` — Git config and global ignore
- `fish/` — Fish shell config (managed via nix/modules/fish.nix)

## Conventions

### Module Pattern

Shared NixOS modules live in `nix/modules/`. When creating or extending modules:

- Set base config in `config = { ... }`
- Expose extension points via `options.<namespace>.<name> = lib.mkOption { ... }`
- Hosts import modules and declare their specific overrides via options (not `lib.mkForce`)
- Example: `modules/steam.nix` exposes `programs.steam.waylandExtraEnv` for host-specific env vars

### Host-Specific Configs

- Common settings go in `configuration.nix` or shared modules
- Host-specific settings go in `hosts/<hostname>/default.nix`
- Host-specific Hyprland monitor configs go in `hypr/hosts/<hostname>.lua` (loaded via flake.nix)

### Changelog

**Required**: Document substantive changes in `CHANGELOG.md`:
- Headers are newest-first (reverse chronological)
- Within a date, bullets sorted alphabetically by **tag**
- Single header per date (merge duplicates)
- No blank lines between bullets; one blank line between sections
- Format: `- **tag**: description`
- Omit formatting-only or mechanical changes

## Common Tasks

### Adding a new NixOS module

1. Create `nix/modules/<name>.nix`
2. Add to `flake.nix` `sharedModules` list
3. Use `options` for host-extensible configuration
4. Update CHANGELOG.md

### Extending a shared module from a host

```nix
# In hosts/<hostname>/default.nix
imports = [ ../../modules/<name>.nix ];

# Declare host-specific values
programs.<name>.<option> = { ... };
```

### Hyprland changes

- Main config: `hypr/hyprland.lua` or `hypr/partkyle.lua`
- Monitor setup: `hypr/hosts/<hostname>.lua`
- Keybinds/window rules: `hypr/partkyle.lua`
- Test with `hyprctl reload` before committing

### Rebuilding NixOS

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### Testing home-manager changes

```bash
home-manager switch --flake .#partkyle@<hostname>
```

## Hardware Profiles

- **dionysus** — Laptop, Intel graphics, moves between networks
- **theseus** — Desktop, NVIDIA graphics, Tailscale server, SSH enabled

## Key Patterns

- Steam on Wayland: See `modules/steam.nix` for the `waylandExtraEnv` extension pattern
- Syncthing: Tailscale-only transport, managed via `modules/syncthing.nix`
- Fish: Modular config with reload function in `modules/fish.nix`

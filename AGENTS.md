# Agent Instructions

## Project Structure

This is a Nix flake-based dotfiles repository managing NixOS configs and user applications.

### NixOS Configuration (`nix/`)

- `flake.nix` — Entry point with nixpkgs, home-manager, pi-nix inputs
- `configuration.nix` — Shared system-wide NixOS config (imports greetd.nix)
- `home.nix` — Home Manager config for user packages and services
- `hosts/<hostname>/default.nix` — Host-specific NixOS configs (dionysus=laptop/Intel, theseus=desktop/NVIDIA)
- `modules/*.nix` — Shared NixOS modules (hyprland.nix, steam.nix, fish.nix, syncthing.nix, git-server.nix)
- `hypr/` — Hyprland Lua/config assets (Linux/Nix-only; see below)
- `greetd.nix` — Display manager/login config
- `webapps.nix` — Desktop entries for web apps

### Hyprland (`nix/hypr/`)

Linux/Nix-only Hyprland config, deployed by `nix/modules/hyprland.nix`:

- `hyprland.lua` — Main config: `package.path`, host require, settings, keybinds, window rules (live-linked; Hyprland reloads on save)
- `hosts/<hostname>.lua` — Per-host monitor config, required as `host` (live-linked)
- `hypridle.conf` — Idle daemon config (store copy; restarts on rebuild)
- `hyprlock.conf`, `mocha.conf` — Lock screen and its color theme
- `scripts/` — `keybinds.sh` (keybind overlay) and `idle-inhibit.sh` (idle inhibit state)

Home Manager no longer generates `hyprland.lua`; the repo owns the entrypoint. The graphical session is managed by **UWSM** (`programs.hyprland.withUWSM`), which starts `graphical-session.target`, imports the environment into systemd/D-Bus, and wraps the compositor. Session services (quickshell, hypridle) bind to `graphical-session.target`; greetd/tuigreet just launch `uwsm start`.

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
- Host-specific Hyprland monitor configs go in `nix/hypr/hosts/<hostname>.lua` (loaded automatically by `nix/modules/hyprland.nix`)

### Changelog

**Required**: Document substantive changes in `CHANGELOG.md`. Omit formatting-only or mechanical changes.

**Format:**

```
## YYYY-MM-DD

- **<concern>**: short readable, yet complete description
- **<concern>**: another point in the same commit
```

**Rules:**

- **Append-on-top.** The working section is always the first `##` heading below `# Changelog`. Never touch, move, or re-sort anything below it.
- **One section = one git commit.** While working, iterate on the top section — add, remove, reword bullets freely. The section is finalized when the commit lands.
- **Same day, new commit:** increment the suffix — `## YYYY-MM-DD.1`, `## YYYY-MM-DD.2`. No suffix on the first entry of a day.
- **Never modify a committed section** unless specifically asked to do so.
- **Prefer one fact per bullet.** Split into separate bullets when it helps readability.

## Working guardrails

- **Only run git write commands when explicitly asked.** Read-only git (`status`, `diff`, `log`, `show`) is fine; do not `add`, `mv`, `rm`, `commit`, `checkout`, `reset`, `push`, `worktree`, etc. unless the user asks.
- **Never run a flake build.** Do not run `nix build`, `nixos-rebuild build`, or anything that builds the flake/system. Verify changes with cheap, non-building probes instead.
- **Probing and tests are fine:** `nix eval`, `nix flake check --no-build`, dry-runs, `hyprctl`, `luac -p`, `systemctl status`, `git`, etc.
- **Clean up `result` symlinks.** Builds and some tooling leave `result`/`result-*` symlinks lying around. Remove any before finishing (`rm -f result result-*`, in the repo root and `nix/`).

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

- Main config (keybinds, window rules, animations): `nix/hypr/hyprland.lua`
- Monitor setup: `nix/hypr/hosts/<hostname>.lua`
- Idle/lock: `nix/hypr/hypridle.conf`, `nix/hypr/hyprlock.conf`
- `hyprland.lua` and the host file are live-linked into `~/.config/hypr`, so edits reload via Hyprland's watcher — no rebuild needed.
- Everything else is a store copy; rebuild with `sudo nixos-rebuild switch` to apply it.
- Session: UWSM owns `graphical-session.target` (`programs.hyprland.withUWSM = true`); services bind to it. There is no custom session target or Hyprland config hook.

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

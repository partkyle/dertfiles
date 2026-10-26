# Agent Instructions

## Project Structure

This is a Nix flake-based dotfiles repository managing NixOS configs and user applications.

### NixOS Configuration (`nix/`)

- `flake.nix` — Entry point with nixpkgs, home-manager, pi-nix inputs
- `configuration.nix` — Shared system-wide NixOS config (imports greetd.nix)
- `home.nix` — Home Manager config for user packages and services
- `hosts/<hostname>/default.nix` — Host-specific NixOS configs (dionysus=laptop/Intel, theseus=desktop/NVIDIA)
- `modules/*.nix` — Shared NixOS modules (hyprland.nix, mango.nix, desktop-idle.nix, steam.nix, fish.nix, syncthing.nix, git-server.nix)
- `hypr/` — Hyprland Lua/config assets (Linux/Nix-only; see below)
- `mango/` — Mango (mangowc) config assets (Linux/Nix-only; see below)
- `idle/` — Compositor-agnostic idle, lock and display-sleep assets (Linux/Nix-only; see below)
- `greetd.nix` — Display manager/login config (tuigreet session picker)
- `webapps.nix` — Desktop entries for web apps

### Hyprland (`nix/hypr/`)

Linux/Nix-only Hyprland config, deployed by `nix/modules/hyprland.nix`:

- `hyprland.lua` — Main config: `package.path`, host require, settings, keybinds, window rules (live-linked; Hyprland reloads on save)
- `hosts/<hostname>.lua` — Per-host monitor config, required as `host` (live-linked)
- `scripts/` — `keybinds.sh` (keybind overlay) and `screenshot.sh` (grim/slurp/satty screenshots)

Home Manager no longer generates `hyprland.lua`; the repo owns the entrypoint. The graphical session is managed by **UWSM** (`programs.hyprland.withUWSM`), which starts `graphical-session.target`, imports the environment into systemd/D-Bus, and wraps the compositor. Session services (quickshell, swayidle, keyd-application-mapper) bind to `graphical-session.target`; greetd/tuigreet just launch `uwsm start`.

### Idle / lock (`nix/idle/`)

Linux/Nix-only, deployed by `nix/modules/desktop-idle.nix` and shared by every
compositor session (Hyprland and mango). The module installs `swayidle`,
`swaylock-effects` and `wlopm`, runs the `swayidle` user service on
`graphical-session.target`, and is on by default
(`programs.desktopIdle.enable = true`):

- `swayidle.conf` — Idle daemon config: lock after 120 s, display sleep after 300 s, lock before suspend (store copy; the unit restarts on rebuild)
- `swaylock.conf` — Lock screen (swaylock-effects config, deployed as `~/.config/swaylock/config`)
- `scripts/idle-action.sh` — swayidle's timeout/resume/before-sleep actions; defers lock and display sleep while the keep-awake stamp is active and fires them when it expires
- `scripts/idle-inhibit.sh` — Keep-awake stamp shared by the bar's lock icon and `dert idle`; `check` gates idle actions
- `scripts/dpms.sh` — Blank/wake outputs: `hyprctl` under Hyprland, `wlopm` on other wlroots compositors

### Mango (`nix/mango/`)

Linux/Nix-only mango (mangowc) config, deployed by `nix/modules/mango.nix`. It
coexists with Hyprland; the session picker chooses between them and defaults to
mango.

- `config.conf` — Main config: appearance, keybinds, tags, input, window/layer rules (live-linked; reload with Super+r — mango 0.17.2 does not watch the file)
- `hosts/<hostname>.conf` — Per-host monitor rules, live-linked as `host.conf` and pulled in with `source-optional`
- `scripts/` — `screenshot.sh` (shared with Hyprland) and `background.sh`

**Option names target the nixpkgs package (0.17.2).** The upstream docs describe
a newer release with different spellings (`tagrule` vs `tag_rule`, `shadowscolor`,
no `var=`, `source-optional` with a hyphen). Validate any change with
`mango -c nix/mango/config.conf -p` before committing.

Mango has native systemd integration: it imports the session environment into
systemd/D-Bus and starts `mango-session.target`, which `BindsTo`
`graphical-session.target`. No UWSM wrapper is needed; `nix/modules/mango.nix`
registers the package's user units via `systemd.packages`.

### Other Configs

- `quickshell/` — Quickshell desktop shell (replaces waybar); `shell.qml` entry point, `Commons/` theme singletons, `Ui/` base components, `widgets/` bar modules, `scripts/` helper scripts. Deployed via `nix/modules/quickshell.nix`
- `foot/` — Terminal config
- `nvim/` — Neovim config (LazyVim-based)
- `git/` — Git config and global ignore
- `fish/` — Fish shell config (managed via nix/modules/fish.nix)
- `bin/dert` — Self-documenting control CLI, live-linked into `~/.local/bin` by `nix/home.nix`

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
- Host-specific mango monitor rules go in `nix/mango/hosts/<hostname>.conf` (sourced by `nix/mango/config.conf` via `source-optional`)

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

### Adding a dert command

1. Add a `cmd_<group>_<name>()` function to `bin/dert`
2. Register it in `CMD_DESC` (and `CMD_USAGE` if it takes arguments) — dispatch and help both read the registry, so an unregistered handler is unreachable and an unhandled entry errors
3. Add the group to `GROUP_ORDER` if it is new

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
- Idle/lock: `nix/idle/swayidle.conf`, `nix/idle/swaylock.conf` (deployed by `nix/modules/desktop-idle.nix`, shared with mango)
- `swaylock.conf` is a store copy deployed as `~/.config/swaylock/config`; its colours follow Catppuccin's official swaylock Mocha port (`catppuccin/swaylock`), with geometry/clock options layered on top
- swaylock has no password field or dots, so typing feedback is the `key-hl-color`/`bs-hl-color` arcs and those must contrast with `ring-color`
- `hyprland.lua` and the host file are live-linked into `~/.config/hypr`, so edits reload via Hyprland's watcher — no rebuild needed.
- Everything else is a store copy; rebuild with `sudo nixos-rebuild switch` to apply it.
- Session: UWSM owns `graphical-session.target` (`programs.hyprland.withUWSM = true`); services bind to it. There is no custom session target or Hyprland config hook.

### Mango changes

- Main config (keybinds, tags, appearance, window rules): `nix/mango/config.conf`
- Monitor rules: `nix/mango/hosts/<hostname>.conf`
- Both are live-linked into `~/.config/mango`, so no rebuild is needed. Mango 0.17.2 does not watch the file: reload with `Super+r` (or `mmsg dispatch reload_config`) for edits to apply.
- Validate without starting it: `mango -c nix/mango/config.conf -p` (or point it at a concatenation of `config.conf` + the host file to check the monitor rules too).
- Layout switching is `dert mango layout <dwindle|tile|monocle|scroller>`; the bar's Layout widget reads the active tag's layout from `mmsg watch all-tags`, so it stays correct for any switch (keybind, CLI, startup).
- The background is `swaybg` via the `mango-background` user service (`nix/mango/scripts/background.sh`), bound to `mango-session.target` so it only runs under mango; it picks a random image from `~/.config/backgrounds` and `systemctl --user restart mango-background` rolls a new one.
- Mango owns its session target (see above), so use the plain `mango` entry in tuigreet (the default); Hyprland still uses its `(UWSM)` entry.

### Keybinds

A key can be rewritten before Hyprland ever sees it, so trace the whole path
when adding or moving a bind:

1. **keyd** (`nix/modules/keyd.nix`) remaps at the evdev layer — requires a
   rebuild. The `meta` layer takes `Super+A/X/C/V/T/W` for the focused app's own
   clipboard/select-all (`Super+C` becomes `Ctrl+C`), so those letters are no
   longer available as raw compositor chords. `meta+shift` re-asserts specific
   shifted chords that keyd would otherwise swallow (currently only `c`, so
   `Super+Shift+C` still reaches the compositor for center-window).
2. **keyd-application-mapper** (a systemd user service bound to
   `graphical-session.target`) swaps in `~/.config/keyd/app.conf` per focused
   app (terminals keep native `Ctrl+A`/`Ctrl+E` and get `Ctrl+Shift+C/V`). It
   watches `zwlr_foreign_toplevel_manager_v1`, which both Hyprland and mango
   implement, so one service covers both sessions.
3. **Hyprland** (`nix/hypr/hyprland.lua`) and **mango** (`nix/mango/config.conf`)
   receive whatever survives the above; `hyprctl binds` / `mango -c … -p` are the
   source of truth for the final result.

Reusing a keyd-remapped key in a new chord needs a matching `meta+shift` entry
so the full chord still reaches the compositor; unremapped keys pass through
untouched. Confirm with `hyprctl binds` and `hypr/scripts/keybinds.sh --print`.

### Rebuilding NixOS

```bash
dert nix rebuild
```

Use `dert nix update <input>` to bump a flake input (e.g. `pi-nix`, `nixpkgs`)
before rebuilding.

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
- Fish: Modular config with `fish_greeting` cleared in `modules/fish.nix`
- CLI: `bin/dert` dispatches from registries (`GROUP_ORDER`, `CMD_DESC`, `CMD_USAGE`); help is generated from them, so a command only exists once it has all three
- Mango: the nixpkgs package is 0.17.2, but upstream docs track a newer release with different option spellings — check `mango -c … -p`, not the website, when in doubt
- Keybinds: keyd rewrites keys at the evdev layer before the compositor sees them, so a chord can silently disappear — see `### Keybinds`

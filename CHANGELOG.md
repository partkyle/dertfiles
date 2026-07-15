# Changelog

## 2026-07-15

- **hyprland**: Consolidated clipboard keybinds into partkyle.lua (`send_shortcut_once` helper, SUPER+C/V/A/X/T/W, CTRL+A/E line navigation); removed `clipboard.lua` extraLuaFile from nix config and deleted stub file
- **hyprland**: Rebound `SUPER+R` from run launcher → `hl.dsp.window.swap()` (rotate/swap windows); run is already on `SUPER+SPACE`
- **hyprland**: Added vim-style directional keys — `SUPER+h/j/k/l` for focus, `SUPER+SHIFT+h/j/k/l` for moving windows
- **hyprlock**: Added hyprlock to nix packages, xdg config files (hyprlock.conf, mocha.conf, backgrounds), and updated hypridle to trigger lock at 120s then display sleep at 300s

## 2026-07-14

- **erlang**: don't install erlang by default
- **nixos**: nix flake update

## 2026-07-10

- **brave**: Added Brave browser to home packages and 1Password custom allowed browsers.
- **git**: Changed `push.default` from `matching` to `simple` — only the current branch is pushed by default.
- **hyprland**: Added Super+B hotkey to open default browser via `xdg-open about:blank`.
- **waybar/webapps**: Switched browser from Vivaldi to Brave in waybar calendar launcher and webapps.nix desktop entries.

## 2026-07-09

- **editor**: Set `EDITOR` and `VISUAL` to `nvim` in `home.sessionVariables`
  (home.nix) and as explicit exports in `.zshrc`.
- **foot**: Bumped font size from 11 to 12 in `home.nix` for better readability.
- **foot**: Removed `server.enable = true` from `home.nix` so foot runs as a
  standalone terminal rather than as a server daemon.
- **foot/waybar/hyprland**: Replaced all `footclient` invocations with `foot`
  (Waybar `on-click` handlers and Hyprland `terminal` variable). This removes
  the footclient/server split — `foot` is always used directly.
- **hyprland**: Made animations snappier — increased speeds across all
  animation leaves (windows, fade, layers, workspaces, zoom), tightened the
  spring curve (stiffness 71→120, dampening 16→20), and replaced the mild
  `almostLinear` bezier with a sharper `snappy` curve.
- **hyprland**: Fixed Waybar flicker when closing the last window on a
  workspace — switched `windowsOut` from `popin 87%` (scaling) to `fade`.
- **hyprland/dionysus**: Removed `scale = "1.25"` from monitor config — let monitor use its native scale.
- **nixfmt**: Replaced deprecated `nixfmt-rfc-style` with `nixfmt` in
  `home.nix` (nixfmt-rfc-style is now an alias for pkgs.nixfmt).
- **nvim**: Enabled `exrc` + `secure` for project-local `.nvim.lua` configs.
- **nvim**: Created `~/.dertfiles/.nvim.lua` to show hidden files in snacks.nvim picker only in this repo.

## 2026-07-08

- **fonts**: add `comic-neue` to system fonts in configuration.nix
- **foot**: add `pipe-command-output` (Control+Shift+L) experiment, then
  reverted — foot's pipe mechanism doesn't support in-terminal paging
  (stdout is piped away). Documented dual systemd services in ISSUES.md.
- **nvim**: add nix LSP/formatter support
- **nvim**: fix LazyVim import ordering warning
- **nvim**: skip Mason for nil_ls (installed via Nix), add statix

## 2026-07-07

- **obsidian**: Added to home packages via `nix/home.nix`.
- **ssh**: Fixed `home.nix` to properly configure SSH agent forwarding via
  Tailscale. Added `sshHosts` block for remote hosts to `hosts/theseus/default.nix`.
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

## 2026-07-01

- **calibre**: Added to `theseus` host config.
- **steam**: Enabled on `theseus` (desktop) via `programs.steam` in host config.

## 2026-06-26

- **bibata-rainbow**: Updated hash in the custom derivation to match upstream.
- **foot**: Refined foot client/server split in Waybar config (`hyprctl` to
  switch clients rather than raw socket calls). Fixed Hyprland partkyle.lua
  keybinds accordingly.

## 2026-06-25

- **aliases**: Added `cd...` alias to fish module.
- **autoformat**: Disabled global autoformat for Python in Neovim — opted in
  per-project instead.
- **bibata-rainbow**: Added a new package derivation at
  `packages/bibata-rainbow/default.nix` for a custom rainbow Bibata cursor
  theme. Registered in `flake.nix` and installed in `home.nix`.
- **floating/hotkeys**: Added `browser` keybind and tuned floating window rules
  in Hyprland partkyle.lua and clipboard.lua.
- **ollama**: Removed direct Ollama service from `theseus` host config
  (handled by Tailscale/remote now).
- **zshrc**: Switched from zsh to bash for that one local snippet.

## 2026-06-24

- **flake**: Updated `flake.lock` (nixpkgs pin refresh).
- **fontfeatures**: Fixed `home.nix` font config to allow both `features`
  lists for Iosevka (the old single-list syntax was wrong).

## 2026-06-23

- **cache**: Updated `configuration.nix` to use cached (pre-built) nix store
  paths for faster rebuilds.
- **cachix**: Added Cachix config for `nix-community` and `hyprland` caches.
- **foot**: Fixed font path typo (`font` with src- prefix).
- **graphics**: Removed redundant `hardware.opengl` enable (defaulted by
  the Hyprland module).
- **hyprland**: Added workspace move hotkeys. Changed quit binding. Added
  master-dwindle layout toggle and centered master layout. Changed to
  `start-hyprland` session command in greetd. Added `initialSession` config
  to greetd for auto-login.
- **network**: Fixed network interface conflict in `configuration.nix`
  (tailscale0 vs wlan0 ordering). Switched to `systemd-networkd` for network
  management on both hosts, dropping NetworkManager. Added `TODO.md`.
- **pi-coding-agent**: Moved to a flake input and accepted its Cachix hash.
  Updated `configuration.nix` to pull it from the flake.
- **TODO**: Cleaned up `TODO.md` (removed completed items).
- **waybar**: Refined config — default to output devices, removed tooltips,
  open calendar in separate app, removed span sizing, updated wifi icons,
  switched icon style, set font with px units, added more modules.

## 2026-06-22

- **alpha**: Added foot terminal alpha transparency setting in `home.nix`.
  Reduced from initial attempt.
- **display scale**: Moved scale settings from global `partkyle.lua` to
  per-host `hosts/dionysus.lua`. Set theseus to 240 DPI. Tuned font size in
  `home.nix`.
- **hypridle**: Added `hypridle.conf` with lock-on-suspend and before-suspend
  lock rules.
- **theseus**: Added `services.tailscale`, `services.ollama`, `services.sshd`,
  `services.hypridle` to host config for server-like operation.

## 2026-06-20

- **greetd**: Switched to `tuigreet` as the greeter. Tweaked session command.
- **packages**: Added `lazygit` to home packages. Added then removed `raylib`.

## 2026-06-19

- **clipboard**: Added clipboard manager remapping in Hyprland config.
- **fastfetch**: Added fastfetch config and integrated into fish prompt.
- **fish**: Modularized fish config into `modules/fish.nix` with reload
  function. Added `fish` to the flake's `nixosConfigurations`.
- **hosts**: Split configs — moved host-specific settings from
  `configuration.nix` into `hosts/dionysus/default.nix` and
  `hosts/theseus/default.nix`. Added `theseus` hardware config. Created
  per-host hyprland configs under `hypr/.config/hypr/hosts/`.
- **input**: Added tap-to-click and clickfinger support in Hyprland config.
- **mako**: Added `mako/config` for notification daemon styling.
- **rofi**: Added Catppuccin-mocha theme for rofi.
- **webapps**: Added `nix/webapps.nix` module with `waterfox` for web app
  support.

## 2026-06-18

- **nix flake**: Created foundational NixOS config:
  - `flake.nix` — flake entrypoint with nixpkgs, home-manager, hyprland inputs
  - `configuration.nix` — system-wide NixOS config
  - `home.nix` — home-manager config (packages, services, programs)
  - `greetd.nix` — greetd display manager config
  - `hosts/dionysus/` — first host definition
  - Moved Hyprland config from `hyprland/.config/hypr/hyprland.conf` to
    `hypr/.config/hypr/hyprland.lua` (Lua-based config). Added
    `clipboard.lua` module.
  - Converted existing dotfiles into Nix-managed configs (waybar, foot, kitty,
    etc.)
  - Added `.zshrc` and started `bash -> zsh` migration
  - Added `git/.gitconfig` and `git/.gitignore_global` managed via home-manager
  - Added ripgrep, fd, core fonts to home packages
  - Removed `nvim/lazyvim.json` from nix store (handled differently now)
  - Cleaned up old hyprland config remnants
- **timezone**: Set timezone to `America/Los_Angeles` in configuration.nix.
- **vscode**: Added VS Code to home packages.
- **yazi**: Added file manager to home packages.

## 2026-06-17

- **neovim**: Major revamp — trimmed `plugins/example.lua`, rewrote
  `plugins/partkyle.lua` with fewer plugins, updated lazy-lock.json and
  lazyvim.json.

## 2026-06-04

- **hyprland**: Migrated from `hyprland.conf` (syntax-based) to
  `hypr/partkyle.lua` (Lua API-based config). Added `hypr/clipboard.lua`.
  Moved `hypridle.conf` into the new structure. Added monitor setup via Lua.

## 2025-01-29 — 2025-01-31 (Initial setup)

- **Initial commit**: Bootstrapped the nix-based dotfiles repo with Neovim
  config (LazyVim-based), i3 config, Hyprland config (window rules,
  keybinds, monitor setup), Kitty terminal (with transparency, copy-on-select,
  font config), Waybar (status bar with modules, styling), Wofi (launcher
  style), Picom (compositor), Hyprlock (lock screen), Hypridle (idle daemon),
  Hyprpaper (wallpaper), and background images.
- **Tweaks**: Disabled nvim mouse, removed smear cursor, updated fonts/colors
  in Hyprland and Waybar, added window swapping keybind, set fullscreen
  preferences, disabled natural scrolling, added Ctrl+Alt+T terminal
  shortcut, configured cursors.

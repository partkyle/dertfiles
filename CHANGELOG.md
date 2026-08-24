# Changelog

## 2026-08-24

- **reaper**: added `nix/modules/reaper.nix` — installs Reaper with `pw-jack` desktop entry ("REAPER (jack)") for low-latency PipeWire JACK audio
- **reaper**: uses `pkgs.pipewire.jack` (which provides the `pw-jack` wrapper)
- **pipewire**: extracted `nix/modules/pipewire.nix` from `configuration.nix` — PipeWire (ALSA + Pulse + JACK backends) and rtkit
- **agents**: rewrote changelog conventions in AGENTS.md — one section per commit, append-on-top, date-only headers, bold concern tags in bullets

## 2026-08-24 — hyprland

- sped up layer animations for snappier launcher open/close (`layersIn` 12, `layersOut` 10, `fadeLayersIn` 12, `fadeLayersOut` 10)

## 2026-08-24 — quickshell

- added app launcher overlay (`Launcher.qml`) replacing rofi: fuzzy search over desktop entries with keyboard navigation and themed icons, Catppuccin Mocha card; summoned via `qs ipc call launcher toggle` bound to SUPER+SPACE
- bar widget fixes: FA-range Nerd Font icons, PipeWire volume tracking, networkd+iwd network status, lua workspace dispatch
- `nix/modules/quickshell.nix`: added `programs.quickshell.enable` and `wantedBy` options (steam.nix pattern); enabled UPower for the battery widget
- removed rofi and waybar packages and config deployment from `home.nix`

## 2026-08-23 — claude

- add `nix/modules/claude.nix`

## 2026-08-23 — quickshell

- replaced waybar with a standalone quickshell desktop shell modeled on omarchy quatro's architecture; deployed via new `nix/modules/quickshell.nix` systemd user service; same Catppuccin Mocha look and widget set as the old waybar config

## 2026-08-21 — changelog

- add `scripts/changelog.sh` helper that invokes pi to generate changelog entries with a braille progress spinner

## 2026-08-21 — Makefile

- add `make update-pi`, `make rebuild`, and `make changelog` targets at repo root

## 2026-08-21 — pi

- update pi-nix flake input to latest (0.83.0)

## 2026-08-06 — foot

- update foot padding to 17x7. going to try a little more space

## 2026-08-06 — waybar

- Switched clock module from 24-hour (`%H:%M`) to 12-hour time with AM/PM (`%I:%M %p`)

## 2026-07-30 — agents

- Created `AGENTS.md` documenting project structure, module patterns, host profiles, and common tasks for agent context

## 2026-07-30 — hyprland

- Enabled HDR on MSI MPG321UX OLED (DP-1, theseus) via `cm = "hdr"` and `bitdepth = 10` in `hypr/hosts/theseus.lua`
- Added `SUPER+SHIFT+C` hotkey to copy the active window's class to the clipboard via `hyprctl activewindow | grep | wl-copy`
- Added windowrule to float the Steam Settings dialog (class `steam`, title `Steam Settings`)

## 2026-07-30 — ssh

- Added `partkyle@phoneus` ED25519 public key (Android/Termux) to `configuration.nix` for git server access on theseus

## 2026-07-30 — steam

- Extracted shared Steam module (`nix/modules/steam.nix`) with Wayland libraries (`wayland`, `libxkbcommon`, `libdrm`, `libGL`) for native Wayland rendering; both hosts import the shared module (theseus declares NVIDIA-specific env vars via `programs.steam.waylandExtraEnv` option)
- Enabled gamescope WSI layer (`enableWsi`) and `cap_sys_nice` capability (`capSysNice`, setuid wrapper) for real-time compositor priority — prevents stuttering at 240Hz. Pair with Overwatch launch options `gamescope -W 3840 -H 2160 -r 240 -f --hdr-enabled -- %command%` in Steam

## 2026-07-29 — steam

- enabled `extest` for Wayland Steam Input support; added Wayland env vars (`STEAM_FORCE_WAYLAND`, `SDL_VIDEODRIVER`, `GDK_BACKEND`, `QT_QPA_PLATFORM`); added `GBM_BACKEND=nvidia-drm` on theseus; enabled gamescope on both hosts

## 2026-07-28 — fish

- Wrap `rebuild` in a `bash -c` subshell with `exec` so `$argv` is forwarded cleanly via `"$@"`

## 2026-07-27 — brightnessctl

- add to system packages for screen brightness control

## 2026-07-27 — godot

- add the godot binary

## 2026-07-16 — fish

- Added `interactiveShellInit` to set universal variables `fish_max_history_file_size=0` and `fish_max_history_age=0` for infinite shell history

## 2026-07-16 — ssh

- Suppressed `enableDefaultConfig` deprecation warning by explicitly setting `enableDefaultConfig = false` and inlining the default settings under `programs.ssh.settings."*"`

## 2026-07-16 — steam

- enabled steam on dionysus

## 2026-07-15 — hyprland

- Consolidated clipboard keybinds into partkyle.lua (`send_shortcut_once` helper, SUPER+C/V/A/X/T/W, CTRL+A/E line navigation); removed `clipboard.lua` extraLuaFile from nix config and deleted stub file
- Rebound `SUPER+R` from run launcher → `hl.dsp.window.swap()` (rotate/swap windows); run is already on `SUPER+SPACE`
- Added vim-style directional keys — `SUPER+h/j/k/l` for focus, `SUPER+SHIFT+h/j/k/l` for moving windows

## 2026-07-15 — hyprlock

- Added hyprlock to nix packages, xdg config files (hyprlock.conf, mocha.conf, backgrounds), and updated hypridle to trigger lock at 120s then display sleep at 300s

## 2026-07-15 — ssh

- Replaced 1Password SSH agent with standard ssh-agent systemd user service; added per-machine ED25519 keys, declarative `programs.ssh` config with matchBlocks and authorizedKeys; disabled agent forwarding

## 2026-07-14 — erlang

- don't install erlang by default

## 2026-07-14 — nixos

- nix flake update

## 2026-07-10 — brave

- Added Brave browser to home packages and 1Password custom allowed browsers.

## 2026-07-10 — git

- Changed `push.default` from `matching` to `simple` — only the current branch is pushed by default.

## 2026-07-10 — hyprland

- Added Super+B hotkey to open default browser via `xdg-open about:blank`.

## 2026-07-10 — waybar/webapps

- Switched browser from Vivaldi to Brave in waybar calendar launcher and webapps.nix desktop entries.

## 2026-07-09 — editor

- Set `EDITOR` and `VISUAL` to `nvim` in `home.sessionVariables`
  (home.nix) and as explicit exports in `.zshrc`.

## 2026-07-09 — foot

- Bumped font size from 11 to 12 in `home.nix` for better readability.
- Removed `server.enable = true` from `home.nix` so foot runs as a
  standalone terminal rather than as a server daemon.

## 2026-07-09 — foot/waybar/hyprland

- Replaced all `footclient` invocations with `foot`
  (Waybar `on-click` handlers and Hyprland `terminal` variable). This removes
  the footclient/server split — `foot` is always used directly.

## 2026-07-09 — hyprland

- Made animations snappier — increased speeds across all
  animation leaves (windows, fade, layers, workspaces, zoom), tightened the
  spring curve (stiffness 71→120, dampening 16→20), and replaced the mild
  `almostLinear` bezier with a sharper `snappy` curve.
- Fixed Waybar flicker when closing the last window on a
  workspace — switched `windowsOut` from `popin 87%` (scaling) to `fade`.

## 2026-07-09 — hyprland/dionysus

- Removed `scale = "1.25"` from monitor config — let monitor use its native scale.

## 2026-07-09 — nixfmt

- Replaced deprecated `nixfmt-rfc-style` with `nixfmt` in
  `home.nix` (nixfmt-rfc-style is now an alias for pkgs.nixfmt).

## 2026-07-09 — nvim

- Enabled `exrc` + `secure` for project-local `.nvim.lua` configs.
- Created `~/.dertfiles/.nvim.lua` to show hidden files in snacks.nvim picker only in this repo.

## 2026-07-08 — fonts

- add `comic-neue` to system fonts in configuration.nix

## 2026-07-08 — foot

- add `pipe-command-output` (Control+Shift+L) experiment, then
  reverted — foot's pipe mechanism doesn't support in-terminal paging
  (stdout is piped away). Documented dual systemd services in ISSUES.md.

## 2026-07-08 — nvim

- add nix LSP/formatter support
- fix LazyVim import ordering warning
- skip Mason for nil_ls (installed via Nix), add statix

## 2026-07-07 — obsidian

- Added to home packages via `nix/home.nix`.

## 2026-07-07 — ssh

- Fixed `home.nix` to properly configure SSH agent forwarding via
  Tailscale. Added `sshHosts` block for remote hosts to `hosts/theseus/default.nix`.

## 2026-07-07 — syncthing

- Added `modules/syncthing.nix` — dedicated NixOS module for
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

## 2026-07-01 — calibre

- Added to `theseus` host config.

## 2026-07-01 — steam

- Enabled on `theseus` (desktop) via `programs.steam` in host config.

## 2026-06-26 — bibata-rainbow

- Updated hash in the custom derivation to match upstream.

## 2026-06-26 — foot

- Refined foot client/server split in Waybar config (`hyprctl` to
  switch clients rather than raw socket calls). Fixed Hyprland partkyle.lua
  keybinds accordingly.

## 2026-06-25 — aliases

- Added `cd...` alias to fish module.

## 2026-06-25 — autoformat

- Disabled global autoformat for Python in Neovim — opted in
  per-project instead.

## 2026-06-25 — bibata-rainbow

- Added a new package derivation at
  `packages/bibata-rainbow/default.nix` for a custom rainbow Bibata cursor
  theme. Registered in `flake.nix` and installed in `home.nix`.

## 2026-06-25 — floating/hotkeys

- Added `browser` keybind and tuned floating window rules
  in Hyprland partkyle.lua and clipboard.lua.

## 2026-06-25 — ollama

- Removed direct Ollama service from `theseus` host config
  (handled by Tailscale/remote now).

## 2026-06-25 — zshrc

- Switched from zsh to bash for that one local snippet.

## 2026-06-24 — flake

- Updated `flake.lock` (nixpkgs pin refresh).

## 2026-06-24 — fontfeatures

- Fixed `home.nix` font config to allow both `features`
  lists for Iosevka (the old single-list syntax was wrong).

## 2026-06-23 — cache

- Updated `configuration.nix` to use cached (pre-built) nix store
  paths for faster rebuilds.

## 2026-06-23 — cachix

- Added Cachix config for `nix-community` and `hyprland` caches.

## 2026-06-23 — foot

- Fixed font path typo (`font` with src- prefix).

## 2026-06-23 — graphics

- Removed redundant `hardware.opengl` enable (defaulted by
  the Hyprland module).

## 2026-06-23 — hyprland

- Added workspace move hotkeys. Changed quit binding. Added
  master-dwindle layout toggle and centered master layout. Changed to
  `start-hyprland` session command in greetd. Added `initialSession` config
  to greetd for auto-login.

## 2026-06-23 — network

- Fixed network interface conflict in `configuration.nix`
  (tailscale0 vs wlan0 ordering). Switched to `systemd-networkd` for network
  management on both hosts, dropping NetworkManager. Added `TODO.md`.

## 2026-06-23 — pi-coding-agent

- Moved to a flake input and accepted its Cachix hash.
  Updated `configuration.nix` to pull it from the flake.

## 2026-06-23 — TODO

- Cleaned up `TODO.md` (removed completed items).

## 2026-06-23 — waybar

- Refined config — default to output devices, removed tooltips,
  open calendar in separate app, removed span sizing, updated wifi icons,
  switched icon style, set font with px units, added more modules.

## 2026-06-22 — alpha

- Added foot terminal alpha transparency setting in `home.nix`.
  Reduced from initial attempt.

## 2026-06-22 — display scale

- Moved scale settings from global `partkyle.lua` to
  per-host `hosts/dionysus.lua`. Set theseus to 240 DPI. Tuned font size in
  `home.nix`.

## 2026-06-22 — hypridle

- Added `hypridle.conf` with lock-on-suspend and before-suspend
  lock rules.

## 2026-06-22 — theseus

- Added `services.tailscale`, `services.ollama`, `services.sshd`,
  `services.hypridle` to host config for server-like operation.

## 2026-06-20 — greetd

- Switched to `tuigreet` as the greeter. Tweaked session command.

## 2026-06-20 — packages

- Added `lazygit` to home packages. Added then removed `raylib`.

## 2026-06-19 — clipboard

- Added clipboard manager remapping in Hyprland config.

## 2026-06-19 — fastfetch

- Added fastfetch config and integrated into fish prompt.

## 2026-06-19 — fish

- Modularized fish config into `modules/fish.nix` with reload
  function. Added `fish` to the flake's `nixosConfigurations`.

## 2026-06-19 — hosts

- Split configs — moved host-specific settings from
  `configuration.nix` into `hosts/dionysus/default.nix` and
  `hosts/theseus/default.nix`. Added `theseus` hardware config. Created
  per-host hyprland configs under `hypr/.config/hypr/hosts/`.

## 2026-06-19 — input

- Added tap-to-click and clickfinger support in Hyprland config.

## 2026-06-19 — mako

- Added `mako/config` for notification daemon styling.

## 2026-06-19 — rofi

- Added Catppuccin-mocha theme for rofi.

## 2026-06-19 — webapps

- Added `nix/webapps.nix` module with `waterfox` for web app
  support.

## 2026-06-18 — nix flake

- Created foundational NixOS config:
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

## 2026-06-18 — timezone

- Set timezone to `America/Los_Angeles` in configuration.nix.

## 2026-06-18 — vscode

- Added VS Code to home packages.

## 2026-06-18 — yazi

- Added file manager to home packages.

## 2026-06-17 — neovim

- Major revamp — trimmed `plugins/example.lua`, rewrote
  `plugins/partkyle.lua` with fewer plugins, updated lazy-lock.json and
  lazyvim.json.

## 2026-06-04 — hyprland

- Migrated from `hyprland.conf` (syntax-based) to
  `hypr/partkyle.lua` (Lua API-based config). Added `hypr/clipboard.lua`.
  Moved `hypridle.conf` into the new structure. Added monitor setup via Lua.

## 2025-01-29 — 2025-01-31 — Initial setup

- Bootstrapped the nix-based dotfiles repo with Neovim
  config (LazyVim-based), i3 config, Hyprland config (window rules,
  keybinds, monitor setup), Kitty terminal (with transparency, copy-on-select,
  font config), Waybar (status bar with modules, styling), Wofi (launcher
  style), Picom (compositor), Hyprlock (lock screen), Hypridle (idle daemon),
  Hyprpaper (wallpaper), and background images.
- Disabled nvim mouse, removed smear cursor, updated fonts/colors
  in Hyprland and Waybar, added window swapping keybind, set fullscreen
  preferences, disabled natural scrolling, added Ctrl+Alt+T terminal
  shortcut, configured cursors.

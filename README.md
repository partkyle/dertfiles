# ~/.dertfiles

Partkyle's NixOS dotfiles and system configuration.

## Structure

```
├── nix/                    # NixOS flake configuration
│   ├── flake.nix           # Flake entrypoint (nixpkgs, home-manager, pi-nix)
│   ├── configuration.nix   # System-wide NixOS config
│   ├── home.nix            # Home-manager config (packages, services, programs)
│   ├── flake.lock          # Pinned inputs (nixpkgs, home-manager, pi-nix, …)
│   ├── modules/            # NixOS/home-manager modules
│   ├── hypr/               # Hyprland Lua config, scripts, hypridle/hyprlock
│   ├── hosts/              # Per-host configs (dionysus, theseus)
│   └── packages/           # Custom package derivations
├── bin/dert                # Control CLI, live-linked into ~/.local/bin
├── nvim/                   # Neovim config (LazyVim-based)
├── foot/                   # Foot terminal config
├── rofi/                   # Rofi launcher config
├── quickshell/             # Desktop shell (bar + notifications)
├── backgrounds/            # Wallpapers / background images
└── fastfetch/              # Fastfetch config
```

## Hosts

| Host      | Role        |
|-----------|-------------|
| `dionysus` | Laptop      |
| `theseus`  | Desktop     |

## Adding a new machine

1. Generate a unique SSH key:
   ```bash
   ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -C "partkyle@$(hostname)"
   ```
2. Append the public key to `programs.ssh.authorizedKeys` in `nix/home.nix`.
3. Rebuild: `sudo nixos-rebuild switch --flake .#<hostname>`
4. Load the key: `ssh-add ~/.ssh/id_ed25519`
5. Add the public key to GitHub: `gh ssh-key add ~/.ssh/id_ed25519.pub`

## `dert`

`dert` is the self-documenting control CLI for this repo. `bin/dert` is
live-linked into `~/.local/bin`, so edits take effect immediately.

```bash
dert                      # list groups
dert nix                  # list the nix group's commands
dert nix rebuild          # nixos-rebuild switch for the current host
dert nix update           # update every flake input
dert nix update pi-nix    # update only the named input
dert nix build            # build the toplevel without switching
dert nix rollback         # switch to the previous generation
dert nix generations      # list system generations
dert nix gc               # delete old generations and collect garbage
dert idle status          # show the keep-awake lock state
dert idle on 2h           # keep the screen on for two hours
dert idle off             # release the keep-awake lock
dert idle default 45m     # set the default duration
```

`dert <group> <command> --help` (or `dert help <group> <command>`) prints a
command's usage.

### Keep-awake lock

The bar's lock icon and `dert idle` drive the same hypridle inhibit, so either
can release what the other engaged. Durations accept seconds or a suffix:
`90`, `45m`, `2h`, `1h30m`. The default used when no duration is given (the
bar's left click, or a bare `dert idle on`) is stored in
`~/.config/dert/idle-inhibit` and changed with `dert idle default <duration>`.

### Upgrade one input

```bash
dert nix update pi-nix
dert nix rebuild
```

Check the new agent version with `pi --version`.

### Upgrade everything

```bash
dert nix update
dert nix rebuild
```

### Dry-run (build without switching)

```bash
dert nix build
# inspect the result/ symlink
```

### Rollback

```bash
dert nix rollback
# or reboot and pick a previous generation from systemd-boot
```

### Safety notes

- Each rebuild adds a boot entry — you can always pick a previous generation
  from systemd-boot if something goes wrong.
- `dert nix build` builds without switching, for a dry run.
- On NixOS unstable, packages are tested against each other; isolated breakage
  of a single package is uncommon.

## Tests

```bash
node test/notification-logic.test.js   # notification persistence logic
bash test/idle-inhibit.test.sh         # keep-awake lock duration parsing
```

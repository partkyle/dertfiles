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
│   ├── hosts/              # Per-host configs (dionysus, theseus)
│   └── packages/           # Custom package derivations
├── nvim/                   # Neovim config (LazyVim-based)
├── hypr/                   # Hyprland Lua config (+ clipboards, hosts)
├── waybar/                 # Waybar config
├── foot/                   # Foot terminal config
├── wofi/                   # Wofi launcher config
├── rofi/                   # Rofi launcher config
├── kitty/                  # Kitty terminal config
├── mako/                   # Notification daemon config
├── background/             # Wallpapers / background images
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

## Common commands

### Upgrade pi (the coding agent) only

Update just the `pi-nix` flake input without touching nixpkgs, home-manager,
or any other dependency:

```bash
cd ~/.dertfiles/nix
nix flake lock --update-input pi-nix
sudo nixos-rebuild switch --flake .#<hostname>
```

Check the new version:

```bash
pi --version
```

### Update a single package (e.g., Vivaldi)

Updating just the `nixpkgs` input bumps all packages, but if you only care about
one (like Vivaldi), this is the simplest way — no flake restructuring needed:

```bash
cd ~/.dertfiles/nix
nix flake lock --update-input nixpkgs
sudo nixos-rebuild switch --flake .#<hostname>
```

To quickly test a newer version without rebuilding your config at all:

```bash
nix run nixpkgs#vivaldi
```

### Upgrade everything

```bash
cd ~/.dertfiles/nix
nix flake update
sudo nixos-rebuild switch --flake .#
```

### Dry-run (build without switching)

```bash
cd ~/.dertfiles/nix
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
# Inspect versions under the result/ symlink
```

Then apply with:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### Rollback

If a rebuild breaks something:

```bash
# Revert to the previous generation immediately
sudo nixos-rebuild switch --rollback

# Or reboot and pick the old generation from the boot menu
```

### Quick rebuild (no input update)

```bash
cd ~/.dertfiles/nix
sudo nixos-rebuild switch --flake .#
```

### Switch to a specific host

```bash
sudo nixos-rebuild switch --flake .#dionysus   # laptop
sudo nixos-rebuild switch --flake .#theseus    # desktop
```

### Safety notes

- Each rebuild adds a boot entry — you can always pick a previous generation from
  GRUB/systemd-boot if something goes wrong.
- Use `nix build` (dry-run) first to preview what changed before switching.
- On NixOS unstable, packages are tested against each other; isolated breakage
  of a single package is uncommon.

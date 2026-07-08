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

### Upgrade everything

```bash
cd ~/.dertfiles/nix
nix flake update
sudo nixos-rebuild switch --flake .#
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

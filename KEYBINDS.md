# Keybinding Reference Feature

## What was added

`SUPER+SHIFT+?` (slash) opens a searchable list of all Hyprland keybindings in walker. Start typing to filter by key combination or description.

## How it works

Unlike a hardcoded cheatsheet, this dynamically extracts keybindings from your Lua config:

1. **Lua Scanner** — A mock `hl` table loads `~/.config/hypr/hyprland.lua` and captures all `hl.bind()` calls with their descriptions
2. **hyprctl binds** — Gets runtime bindings from Hyprland
3. **Combines both** — Matches Lua descriptions with runtime bindings
4. **Formats with alignment** — Uses awk to create aligned columns
5. **Displays in walker** — Shows in dmenu mode with your Catppuccin theme

## Implementation details

### Added to `partkyle.lua`

Every `hl.bind()` call now includes a `description` field:

```lua
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal), { description = "Open terminal" })
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close window" })
-- ... etc
```

### New script: `hypr/.config/hypr/scripts/keybinds.sh`

Based on [omarchy's approach](https://github.com/omarchy/omarchy/blob/quattro/bin/omarchy-menu-keybindings):
- Lua scanner extracts binds with descriptions
- Combines with `hyprctl binds` output
- Resolves XKB keycodes to symbols (e.g., `code:24` → `Q`)
- Formats with aligned columns using awk
- Displays in walker dmenu mode

### Dependencies added to `home.nix`

- `lua` — For the config scanner
- `libxkbcommon` — For `xkbcli` keycode resolution

## Usage

```bash
# Show in walker (interactive)
~/.config/hypr/scripts/keybinds.sh

# Print to stdout (for debugging)
~/.config/hypr/scripts/keybinds.sh --print
```

## Deployment

After pulling these changes:

```bash
# Rebuild home-manager to deploy:
# - Updated partkyle.lua with descriptions
# - New keybinds.sh script
# - lua and libxkbcommon packages
home-manager switch --flake .#partkyle@theseus

# Reload Hyprland to pick up new keybind
hyprctl reload
```

Then press `SUPER+SHIFT+?` to see your keybindings!

## Maintaining

When adding new keybinds to `partkyle.lua`, include a description:

```lua
hl.bind("SUPER + NEW_KEY", hl.dsp.exec_cmd("some-command"), { description = "What it does" })
```

The script will automatically pick it up — no need to update a separate cheatsheet!

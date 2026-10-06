-- Hyprland main config (Lua). Live-linked into ~/.config/hypr by
-- nix/modules/hyprland.nix, so saving this file reloads Hyprland.

-- Let require() find sibling modules in this directory.
local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
package.path = config_home .. "/hypr/?.lua;" .. config_home .. "/hypr/?/init.lua;" .. package.path

-- Per-machine monitor config. Nix links host.lua at hosts/<hostname>.lua;
-- absent on machines without one, so a failed require is not fatal.
pcall(require, "host")

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "foot"
local browser = "brave"
local fileManager = terminal .. " -e yazi"
local menu = "rofi -show drun -show-icons"


hl.config({
  misc = {
    middle_click_paste = true,
  }
})

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 2,

		border_size = 2,

		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = { colors = { "rgba(45475aee)", "rgba(313244ee)" }, angle = 45 },
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 4,
		rounding_power = 0,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Animations. `speed` is the animation DURATION in units of 100ms (2 = 200ms),
-- so lower is faster. Springs ignore `speed` entirely (stiffness/dampening drive them).
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 350, dampening = 30 })

-- Baseline: any leaf NOT overridden below inherits this (layers, all fades,
-- workspaces, zoomFactor). This must exist — Hyprland's fallback for a config
-- that omits animations is a bare 800ms, not the tuned example defaults.
hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "quick" })

-- Deltas from the baseline
hl.animation({ leaf = "border", enabled = false })
hl.animation({ leaf = "windows", enabled = true, speed = 2, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "linear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "quick", style = "fade" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		orientation = "center",
		new_on_top = false,
		new_status = "master",
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})

----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "ctrl:nocaps",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = false,
			tap_to_click = true,
			clickfinger_behavior = true,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

-- [[ Clipboard helper — synthetic key state workaround              ]]
-- https://github.com/hyprwm/Hyprland/discussions/14099
local function send_shortcut_once(mods, key)
	return function()
		hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down", window = "activewindow" }))

		hl.timer(function()
			hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up", window = "activewindow" }))
		end, { timeout = 50, type = "oneshot" })
	end
end

-- Terminals treat Ctrl+C as SIGINT, so copy/paste there needs Ctrl+Shift+C/V.
-- Match on the window class rather than a tag: this config has no tag rules.
local terminal_class = "^(foot|org%.codeberg%.dnkl%.foot|Alacritty|kitty|com%.mitchellh%.ghostty|wezterm)$"

local function active_window_is_terminal()
	local window = hl.get_active_window()
	return window ~= nil and (window.class or ""):match(terminal_class) ~= nil
end

-- Inject the app's native shortcut, choosing the terminal variant when needed.
local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
	return function()
		if active_window_is_terminal() then
			send_shortcut_once(terminal_mods, terminal_key)()
		else
			send_shortcut_once(default_mods, default_key)()
		end
	end
end

-- center floating window
hl.bind("SUPER + SHIFT + C", hl.dsp.window.center(), { description = "Center window" })

-- Copy active window class to clipboard
-- hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprctl activewindow | wl-copy"), { description = "Copy window class" })

-- Copy/Paste: drive the focused app's own copy/paste (Ctrl+C/V), switching
-- to Ctrl+Shift+C/V inside terminals where Ctrl+C is SIGINT.
hl.bind("SUPER + C", universal_clipboard_shortcut("CTRL", "C", "CTRL SHIFT", "C"), { description = "Copy" })
hl.bind("SUPER + V", universal_clipboard_shortcut("CTRL", "V", "CTRL SHIFT", "V"), { description = "Paste" })
-- Select all / Cut
hl.bind("SUPER + A", send_shortcut_once("CTRL", "A"), { description = "Select all" })
hl.bind("SUPER + X", send_shortcut_once("CTRL", "X"), { description = "Cut" })
-- Browser convenience
hl.bind("SUPER + T", send_shortcut_once("CTRL", "T"), { description = "New browser tab" })
hl.bind("SUPER + W", send_shortcut_once("CTRL", "W"), { description = "Close browser tab" })
-- Line navigation in text fields
hl.bind("CTRL + A", send_shortcut_once("", "HOME"), { description = "Jump to line start" })
hl.bind("CTRL + SHIFT + A", send_shortcut_once("SHIFT", "HOME"), { description = "Select to line start" })
hl.bind("CTRL + E", send_shortcut_once("", "END"), { description = "Jump to line end" })
hl.bind("CTRL + SHIFT + E", send_shortcut_once("SHIFT", "END"), { description = "Select to line end" })

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal), { description = "Open terminal" })
local closeWindowBind = hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close window" })
-- closeWindowBind:set_enabled(false)
hl.bind(
	"SUPER + SHIFT + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
	{ description = "Power menu" }
)
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager), { description = "Open file manager" })
hl.bind("SUPER + G", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle float" })
hl.bind("SUPER + semicolon", hl.dsp.layout("togglesplit"), { description = "Toggle split direction" })  -- dwindle toggle split
hl.bind("SUPER + R", hl.dsp.window.swap({ next = true }), { description = "Swap with next window" })  -- rotate / swap with next window
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(menu), { description = "Open launcher" })
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser), { description = "Open browser" })
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("hyprlock"), { description = "Lock screen" })
hl.bind("SUPER + P", hl.dsp.window.pseudo(), { description = "Toggle pseudo-tile" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle", mode = 1 }), { description = "Toggle fullscreen (fake)" })
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Toggle fullscreen (real)" })

-- Direct layout switches
hl.bind("SUPER + M", hl.dsp.exec_cmd([[hyprctl eval 'hl.config({ general = { layout = "monocle" } })']]), { description = "Switch to monocle" })
hl.bind("SUPER + comma", hl.dsp.exec_cmd([[hyprctl eval 'hl.config({ general = { layout = "dwindle" } })']]), { description = "Switch to dwindle" })
hl.bind("SUPER + period", hl.dsp.exec_cmd([[hyprctl eval 'hl.config({ general = { layout = "master" } })']]), { description = "Switch to master" })
hl.bind("SUPER + slash", hl.dsp.exec_cmd([[hyprctl eval 'hl.config({ general = { layout = "scrolling" } })']]), { description = "Switch to scrolling" })

-- Show keybinding reference in rofi
hl.bind("SUPER + SHIFT + slash", hl.dsp.exec_cmd("~/.config/hypr/scripts/keybinds.sh"), { description = "Show keybindings" })

hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }), { description = "Focus left (vim)" })      -- vim-style
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }), { description = "Focus right (vim)" })     -- vim-style
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }), { description = "Focus up (vim)" })        -- vim-style
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }), { description = "Focus down (vim)" })      -- vim-style
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }), { description = "Move window left" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }), { description = "Move window right" })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }), { description = "Move window up" })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }), { description = "Move window down" })
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "left" }), { description = "Move window left (vim)" })   -- vim-style
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "right" }), { description = "Move window right (vim)" })  -- vim-style
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "up" }), { description = "Move window up (vim)" })     -- vim-style
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "down" }), { description = "Move window down (vim)" })   -- vim-style

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }), { description = "Focus workspace " .. i })
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Move to workspace " .. i })
end

-- Example special workspace (scratchpad)
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle special workspace" })
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move to special workspace" })

-- Scroll through existing workspaces with mainMod + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace", mouse = true })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace", mouse = true })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { description = "Drag window", mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { description = "Resize window", mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ description = "Volume up", locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ description = "Volume down", locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ description = "Toggle mute", locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ description = "Toggle mic mute", locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { description = "Brightness up", locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { description = "Brightness down", locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { description = "Next track", locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play/Pause", locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play/Pause", locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { description = "Previous track", locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Float the Steam Settings dialog; the main Steam window is unaffected
	name = "float-steam-settings",
	match = {
		class = "^steam$",
		title = "^Steam Settings$",
	},
	float = true,
})

hl.window_rule({
	-- Float Godot game windows, but not the editor.
	-- The editor maps with initialTitle "Godot"; a game maps with the game
	-- title, while still sharing the editor's window class.
	name = "float-godot-games",
	match = {
		class = "^(Godot)$",
		initial_title = "negative:^Godot$",
	},
	float = true,
})

hl.window_rule({
	-- Float Godot games launched as their own process (class is the project
	-- name). These map with initialTitle "Godot" and a class that is not the
	-- editor's "Godot".
	name = "float-godot-game-processes",
	match = {
		class = "negative:^(Godot)$",
		initial_title = "^(Godot)$",
	},
	float = true,
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Rofi: instant open, no fade-in
hl.layer_rule({
	name = "rofi-no-anim",
	match = { namespace = "^rofi$" },
	no_anim = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- reaper window rules -- center floating windows
hl.window_rule({
    name  = "center-reaper-popups",
    match = {
        class = "^(REAPER)$",
        float = true,
        title = "negative:^REAPER v.*$",
    },
    center = true,
})

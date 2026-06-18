-- Work around Hyprland send_shortcut sometimes leaving synthetic key state stuck/repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099
local function send_shortcut_once(mods, key)
	return function()
		hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down", window = "activewindow" }))

		hl.timer(function()
			hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up", window = "activewindow" }))
		end, { timeout = 50, type = "oneshot" })
	end
end

-- Copy: capture PRIMARY selection (highlighted text) into CLIPBOARD via wl-clipboard
-- Works universally in Wayland, unlike sending keystrokes to the active window
hl.bind("SUPER + C", hl.dsp.exec_cmd("wl-paste --primary | wl-copy"))

-- Paste: Shift+Insert works in foot, most terminals, and many GUI apps
hl.bind("SUPER + V", send_shortcut_once("SHIFT", "Insert"))

-- Select all / Cut: these keystroke senders work fine in most apps
hl.bind("SUPER + A", send_shortcut_once("CTRL", "A"))
hl.bind("SUPER + X", send_shortcut_once("CTRL", "X"))

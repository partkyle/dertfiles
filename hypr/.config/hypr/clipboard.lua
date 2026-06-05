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

hl.bind("SUPER + C", send_shortcut_once("CTRL", "Insert"))
hl.bind("SUPER + V", send_shortcut_once("SHIFT", "Insert"))
hl.bind("SUPER + A", send_shortcut_once("CTRL", "A"))
hl.bind("SUPER + X", send_shortcut_once("CTRL", "X"))

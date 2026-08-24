#!/usr/bin/env bash
# keybinds.sh — Display Hyprland keybindings dynamically from Lua config
# Based on omarchy's approach: scan Lua source for descriptions, combine with hyprctl binds
# Usage: keybinds.sh [--print|-p]

set -euo pipefail

# ── Lua source scanner ──────────────────────────────────────────────────
# Parses the Lua config files and extracts bind descriptions by running
# them through a mock `hl` table that captures bind() calls.
# Output format: modmask\tdescription\tkey\tdispatcher\targ
build_lua_bind_cache() {
	command -v lua >/dev/null 2>&1 || return 0

	lua <<'LUA'
local modifiers = { SHIFT = 1, CTRL = 4, CONTROL = 4, ALT = 8, SUPER = 64 }

local function split_keys(keys)
	local modmask = 0
	local key = ""
	for part in string.gmatch(tostring(keys or ""), "[^+]+") do
		local value = part:gsub("^%s+", ""):gsub("%s+$", "")
		local modifier = modifiers[string.upper(value)]
		if modifier then
			modmask = modmask + modifier
		else
			key = value
		end
	end
	return modmask, key
end

local function lua_literal(value)
	local value_type = type(value)
	if value_type == "string" then
		return string.format("%q", value)
	elseif value_type == "number" or value_type == "boolean" then
		return tostring(value)
	elseif value_type == "table" then
		local parts = {}
		local keys = {}
		local array_length = #value
		for index = 1, array_length do
			parts[#parts + 1] = lua_literal(value[index])
		end
		for key in pairs(value) do
			if not (type(key) == "number" and key >= 1 and key <= array_length and math.floor(key) == key) then
				keys[#keys + 1] = key
			end
		end
		table.sort(keys, function(left, right) return tostring(left) < tostring(right) end)
		for _, key in ipairs(keys) do
			local key_prefix
			if type(key) == "string" and key:match("^[%a_][%w_]*$") then
				key_prefix = key .. " = "
			else
				key_prefix = "[" .. lua_literal(key) .. "] = "
			end
			parts[#parts + 1] = key_prefix .. lua_literal(value[key])
		end
		return "{ " .. table.concat(parts, ", ") .. " }"
	elseif value_type == "nil" then
		return "nil"
	else
		return "nil"
	end
end

local function call_expression(path, ...)
	local args = {}
	for index = 1, select("#", ...) do
		args[index] = lua_literal(select(index, ...))
	end
	return path .. "(" .. table.concat(args, ", ") .. ")"
end

local function dispatcher(kind, arg, expr)
	return { __omarchy_dispatcher = true, kind = kind or "", arg = arg or "", expr = expr or "" }
end

local function dsp_proxy(path)
	return setmetatable({ path = path }, {
		__index = function(self, key)
			return dsp_proxy(self.path .. "." .. tostring(key))
		end,
		__call = function(self, ...)
			local first_arg = ...
			local expr = call_expression(self.path, ...)
			if self.path == "hl.dsp.exec_cmd" and type(first_arg) == "string" then
				return dispatcher("exec", first_arg, expr)
			end
			return dispatcher("lua", expr, expr)
		end,
	})
end

local noop
noop = setmetatable({}, {
	__index = function() return noop end,
	__call = function() return noop end,
})

hl = setmetatable({
	dsp = dsp_proxy("hl.dsp"),
	bind = function(keys, bind_dispatcher, opts)
		opts = opts or {}
		if opts.description and opts.description ~= "" then
			local modmask, key = split_keys(keys)
			local kind = ""
			local arg = ""
			if type(bind_dispatcher) == "table" and bind_dispatcher.__omarchy_dispatcher then
				kind = bind_dispatcher.kind or ""
				arg = bind_dispatcher.arg or bind_dispatcher.expr or ""
			elseif type(bind_dispatcher) == "string" and bind_dispatcher ~= "" then
				kind = "exec"
				arg = bind_dispatcher
			end
			print(table.concat({ tostring(modmask), opts.description, key, kind, arg }, "\t"))
		end
		return noop
	end,
	config = function() return noop end,
	curve = function() return noop end,
	animation = function() return noop end,
	gesture = function() return noop end,
	device = function() return noop end,
	workspace_rule = function() return noop end,
	window_rule = function() return noop end,
	layer_rule = function() return noop end,
	timer = function() return noop end,
	get_config = function() return nil end,
	exec_cmd = function() return noop end,
}, {
	__index = function() return noop end,
})

-- Load the main config which requires partkyle.lua
local config_dir = os.getenv("HOME") .. "/.config/hypr"
local main_config = config_dir .. "/hyprland.lua"
local file = io.open(main_config, "r")
if file then
	file:close()
	local ok, err = pcall(dofile, main_config)
	if not ok and os.getenv("DEBUG") == "1" then
		io.stderr:write("[DEBUG] lua bind scan failed: " .. tostring(err) .. "\n")
	end
end
LUA
}

# ── Modifier mask → text ────────────────────────────────────────────────
modmask_to_text() {
	case "$1" in
		0)  printf '' ;;
		1)  printf 'SHIFT' ;;
		4)  printf 'CTRL' ;;
		5)  printf 'SHIFT CTRL' ;;
		8)  printf 'ALT' ;;
		9)  printf 'SHIFT ALT' ;;
		12) printf 'CTRL ALT' ;;
		13) printf 'SHIFT CTRL ALT' ;;
		64) printf 'SUPER' ;;
		65) printf 'SUPER SHIFT' ;;
		68) printf 'SUPER CTRL' ;;
		69) printf 'SUPER SHIFT CTRL' ;;
		72) printf 'SUPER ALT' ;;
		73) printf 'SUPER SHIFT ALT' ;;
		76) printf 'SUPER CTRL ALT' ;;
		77) printf 'SUPER SHIFT CTRL ALT' ;;
		*)  printf '%s' "$1" ;;
	esac
}

# ── Resolve XKB keycodes to symbols ─────────────────────────────────────
parse_keycodes() {
	awk '
	BEGIN {
		split("10=1 11=2 12=3 13=4 14=5 15=6 16=7 17=8 18=9 19=0 20=MINUS 21=EQUAL 59=COMMA 60=PERIOD 61=SLASH", fallbacks, " ")
		for (i in fallbacks) {
			separator = index(fallbacks[i], "=")
			keycode_symbol[substr(fallbacks[i], 1, separator - 1)] = substr(fallbacks[i], separator + 1)
		}
		keymap_cmd = "xkbcli compile-keymap </dev/null 2>/dev/null"
		section = ""
		while ((keymap_cmd | getline line) > 0) {
			if (line ~ /xkb_keycodes/) { section = "codes"; continue }
			if (line ~ /xkb_symbols/)  { section = "syms";  continue }
			if (section == "codes" && match(line, /<([A-Za-z0-9_]+)>\s*=\s*([0-9]+)\s*;/, m)) code_by_name[m[1]] = m[2]
			if (section == "syms" && match(line, /key\s*<([A-Za-z0-9_]+)>\s*\{\s*\[\s*([^, \]]+)/, m)) sym_by_name[m[1]] = m[2]
		}
		close(keymap_cmd)
		for (name in code_by_name) {
			code = code_by_name[name]
			symbol = sym_by_name[name]
			if (code != "" && symbol != "" && symbol != "NoSymbol") keycode_symbol[code] = toupper(symbol)
		}
		for (code in keycode_symbol) {
			if (keycode_symbol[code] == "GRAVE") keycode_symbol[code] = "~"
		}
		mouse_symbol["272"] = "LMB"
		mouse_symbol["273"] = "RMB"
		mouse_symbol["274"] = "MMB"
	}
	{
		if (match($0, /code:([0-9]+)/, match_parts)) {
			code = match_parts[1]
			symbol = keycode_symbol[code]
			if (symbol == "") symbol = "code:" code
			sub("code:" code, symbol)
		} else if (match($0, /mouse:([0-9]+)/, match_parts)) {
			code = match_parts[1]
			symbol = mouse_symbol[code]
			if (symbol == "") symbol = "mouse:" code
			sub("mouse:" code, symbol)
		}
		print
	}
	'
}

# ── Fetch bindings from hyprctl + Lua cache ─────────────────────────────
# Combines hyprctl binds output with Lua source descriptions
dynamic_bindings() {
	# Build Lua bind cache into a temp file to avoid subshell issues
	local lua_cache
	lua_cache=$(mktemp)
	trap "rm -f $lua_cache" EXIT

	build_lua_bind_cache > "$lua_cache" 2>/dev/null || true

	local modmask key keycode description dispatcher arg modifiers cache_key

	hyprctl binds | awk '
		function emit() {
			if (!seen) return
			seen = 0
			printf "%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\n", f["modmask"], f["key"], f["keycode"], f["description"], f["dispatcher"], f["arg"]
		}
		/^bind/ { emit(); seen = 1; delete f; next }
		seen && match($0, /^\t[a-z]+: /) { f[substr($0, 2, RLENGTH - 3)] = substr($0, RLENGTH + 1) }
		END { emit() }
	' |
	while IFS=$'\x1f' read -r modmask key keycode description dispatcher arg; do
		# Lua binds carry full display key ("SUPER + code:20"); strip modifiers
		key="${key##* + }"

		if [[ -z $key && $keycode != "0" ]]; then
			key="code:$keycode"
		fi

		# Look up description from Lua cache if not set
		if [[ -z $description && -n $key ]]; then
			local lua_line
			lua_line=$(grep "^${modmask}	.*	${key}	" "$lua_cache" | head -1) || true
			if [[ -n $lua_line ]]; then
				description=$(echo "$lua_line" | cut -f2)
				dispatcher=$(echo "$lua_line" | cut -f4)
				arg=$(echo "$lua_line" | cut -f5)
			fi
		fi

		# Skip binds with no description (undocumented internal binds)
		[[ -z $description && $dispatcher == "__lua" ]] && continue

		# Friendly key names
		case "$key" in
			comma) key="COMMA" ;;
			period) key="PERIOD" ;;
			minus) key="MINUS" ;;
			equal) key="EQUAL" ;;
			grave) key="~" ;;
			semicolon) key="SEMICOLON" ;;
			slash) key="SLASH" ;;
		esac

		# Media key shortening
		case "$key" in
			XF86AudioRaiseVolume) key="VOL UP" ;;
			XF86AudioLowerVolume) key="VOL DOWN" ;;
			XF86AudioMute) key="MUTE" ;;
			XF86AudioMicMute) key="MIC MUTE" ;;
			XF86AudioPlay|XF86AudioPause) key="PLAY/PAUSE" ;;
			XF86AudioNext) key="NEXT" ;;
			XF86AudioPrev) key="PREV" ;;
			XF86MonBrightnessUp) key="BRIGHT UP" ;;
			XF86MonBrightnessDown) key="BRIGHT DOWN" ;;
		esac

		modifiers=$(modmask_to_text "$modmask")

		# Clean up arg: remove path prefixes
		arg="${arg##*/bin/}"

		printf '%s,%s,%s,%s,%s\n' "$modifiers" "$key" "$description" "$dispatcher" "$arg"
	done
}

# ── Format with aligned columns ─────────────────────────────────────────
format_bindings() {
	awk -F, '
	BEGIN {
		column = 30
	}
	{
		# Build key combo
		key_combo = $1 " + " $2
		gsub(/^[ \t]*\+?[ \t]*/, "", key_combo)
		gsub(/[ \t]+$/, "", key_combo)
		gsub(/[ \t]+/, " ", key_combo)

		# Action is the description
		action = $3

		# Reconstruct command from remaining fields for display
		cmd = ""
		for (i = 5; i <= NF; i++) {
			cmd = cmd $i (i < NF ? "," : "")
		}

		# Clean up command for display
		gsub(/^"hl\.dsp\.exec_cmd\(/, "", cmd)
		gsub(/\)"?$/, "", cmd)
		gsub(/^hyprctl dispatch exec /, "", cmd)

		# Shorten well-known commands
		if (cmd == "foot") cmd = ""
		else if (cmd == "brave") cmd = ""
		else if (cmd == "walker") cmd = ""
		else if (cmd == "hyprlock") cmd = ""
		else if (cmd ~ /^foot -e yazi$/) cmd = ""

		# If we have a description, just show it; otherwise show the command
		if (action == "") {
			action = cmd
			gsub(/^[ \t]+|[ \t]+$/, "", action)
		}

		printf "%-*s → %s\n", column, key_combo, action
	}
	'
}

# ── Main ────────────────────────────────────────────────────────────────
output_keybindings() {
	dynamic_bindings | parse_keycodes | format_bindings
}

if [[ ${1:-} == "--print" || ${1:-} == "-p" ]]; then
	output_keybindings
else
	output_keybindings | walker --dmenu --placeholder "Search keybindings…" --height 600
fi

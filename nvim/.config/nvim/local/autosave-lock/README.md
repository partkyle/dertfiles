# autosave-lock

Autosave-by-default with an escape hatch: lock a buffer when you want to save
it yourself.

VSCode-style autosave for Neovim in a terminal. Instead of opting *in* to
autosave, it is on by default and a per-buffer lock opts *out*:

- **Saves** a modified normal buffer when you leave it (`BufLeave`), when the
  terminal loses focus (`FocusLost`), and before quitting/suspending
  (`QuitPre`, `VimSuspend`).
- **Does not save** a locked buffer, even on `BufLeave` or `FocusLost`, so it
  stays modified and `:q` still complains until you `:w`.

Writes use `:update`, so clean buffers are never rewritten.

## Layout

This is a self-contained local plugin:

```
autosave-lock/
└── lua/autosave-lock/init.lua
```

It is loaded by lazy.nvim from `local/autosave-lock` in the Neovim config:

```lua
{
  dir = vim.fn.stdpath("config") .. "/local/autosave-lock",
  name = "autosave-lock",
  opts = { keymap = "<leader>zl" },
}
```

## Options

| Option           | Type                   | Default                                       | Meaning                                   |
| ---------------- | ---------------------- | --------------------------------------------- | ----------------------------------------- |
| `enabled`        | boolean                | `true`                                        | global autosave on/off                    |
| `events`         | string[]               | `BufLeave`, `FocusLost`, `QuitPre`, `VimSuspend` | events that trigger a save             |
| `skip_filetypes` | string[]               | `{}`                                          | never autosave these filetypes            |
| `skip_unnamed`   | boolean                | `true`                                        | don't write buffers with no name           |
| `persist`        | boolean                | `false`                                       | remember locks across sessions             |
| `persist_path`   | string                 | `stdpath("state")/autosave-lock.json`         | where locks are stored                     |
| `condition`      | `fun(buf): boolean`    | `nil`                                         | extra predicate; `false` vetoes a save     |
| `on_save`        | `fun(buf)`             | `nil`                                         | called after a successful autosave         |
| `notify`         | boolean                | `true`                                        | notify on lock/enable changes              |
| `keymap`         | string \| nil          | `nil`                                         | key for the lock toggle                    |
| `lock_icon`      | string                 | `` (U+F023)                                  | statusline glyph when locked               |

## API

```lua
local as = require("autosave-lock")

as.lock(buf?)      -- lock (defaults to the current buffer)
as.unlock(buf?)
as.toggle(buf?)
as.locked(buf?)    -- boolean
as.statusline(buf?) -- lock_icon or ""
as.enable()
as.disable()
```

## Commands

| Command           | Does                                             |
| ----------------- | ------------------------------------------------ |
| `:AutosaveLock`   | toggle the lock for the current buffer            |
| `:AutosaveEnable` | turn autosave on globally                         |
| `:AutosaveDisable`| turn autosave off globally (manual save everywhere)|
| `:AutosaveStatus` | report the current state                          |

## Statusline

Expose the lock state through lualine (or any statusline that accepts a
function):

```lua
{
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, 1, function()
      return require("autosave-lock").statusline()
    end)
  end,
}
```

## Notes

- `FocusLost` needs a terminal that reports focus events (foot, kitty, alacritty,
  wezterm, and most modern terminals do). Under tmux, enable
  `set -g focus-events on`.
- With LazyVim's opt-in autoformat, autosaving on `BufLeave` means leaving a
  formattable buffer also formats it. That mirrors VSCode's format-on-save;
  adjust `events` if you'd rather only write on explicit focus loss.

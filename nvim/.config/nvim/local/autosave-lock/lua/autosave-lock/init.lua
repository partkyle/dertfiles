--- autosave-lock
---
--- Autosave-by-default, with a per-buffer lock that forces manual saving.
---
--- A modified normal buffer is written when you leave it (`BufLeave`), when the
--- terminal loses focus (`FocusLost`), and just before quitting/suspending
--- (`QuitPre`, `VimSuspend`) — unless the buffer is locked.
---
--- Usage:
---   require("autosave-lock").setup({ ... })
---
--- Options:
---   enabled         boolean              autosave globally on/off (default true)
---   events          string[]             autocmd events that trigger a save
---   skip_filetypes  string[]             filetypes never autosaved
---   skip_unnamed    boolean              don't write buffers with no name
---   persist         boolean              remember locks across sessions
---   persist_path    string               where locks are stored
---   condition       fun(buf): boolean    extra veto for a save
---   on_save         fun(buf)             called after a successful autosave
---   notify          boolean              notify on lock/enable changes
---   keymap          string|nil           key for the lock toggle (off by default)
---   lock_icon       string               statusline glyph when locked
---
--- Lua API:
---   require("autosave-lock").lock(buf?)
---   require("autosave-lock").unlock(buf?)
---   require("autosave-lock").toggle(buf?)
---   require("autosave-lock").locked(buf?)          -> boolean
---   require("autosave-lock").statusline(buf?)      -> string
---   require("autosave-lock").enable() / disable()
---
--- Commands:
---   :AutosaveLock     toggle the lock for the current buffer
---   :AutosaveEnable   turn autosave on globally
---   :AutosaveDisable  turn autosave off globally (manual save everywhere)
---   :AutosaveStatus   report the current state

local M = {}

local defaults = {
  enabled = true,
  events = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
  skip_filetypes = {},
  skip_unnamed = true,
  persist = false,
  persist_path = vim.fn.stdpath("state") .. "/autosave-lock.json",
  condition = nil,
  on_save = nil,
  notify = true,
  keymap = nil,
  lock_icon = vim.fn.nr2char(0xf023),
}

M.config = vim.deepcopy(defaults)

local group = vim.api.nvim_create_augroup("AutosaveLock", { clear = true })
local locks = {}

-- Helpers --------------------------------------------------------------------

local function resolve(buf)
  if buf == nil or buf == 0 then
    return vim.api.nvim_get_current_buf()
  end
  return buf
end

local function buf_path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return nil
  end
  return vim.fn.fnamemodify(name, ":p")
end

-- Persistence ----------------------------------------------------------------

local function load_locks()
  locks = {}
  if not M.config.persist then
    return
  end
  local f = io.open(M.config.persist_path, "r")
  if not f then
    return
  end
  local data = f:read("*a")
  f:close()
  local ok, decoded = pcall(vim.json.decode, data)
  if ok and type(decoded) == "table" then
    locks = decoded
  end
end

local function save_locks()
  if not M.config.persist then
    return
  end
  vim.fn.mkdir(vim.fn.fnamemodify(M.config.persist_path, ":h"), "p")
  local f = io.open(M.config.persist_path, "w")
  if not f then
    return
  end
  f:write(vim.json.encode(locks))
  f:close()
end

-- Lock state -----------------------------------------------------------------

local function notify(msg)
  if M.config.notify then
    vim.notify(msg, vim.log.levels.INFO)
  end
end

---@param buf? integer
---@return boolean
function M.locked(buf)
  buf = resolve(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local state = vim.b[buf].autosave_lock
  if state ~= nil then
    return state == true
  end
  local path = buf_path(buf)
  return path ~= nil and locks[path] == true
end

local function set_lock(buf, state)
  buf = resolve(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.b[buf].autosave_lock = state
  local path = buf_path(buf)
  if path then
    if state then
      locks[path] = true
    else
      locks[path] = nil
    end
    save_locks()
  end
  notify(state and "Autosave locked (manual save)" or "Autosave enabled")
  vim.cmd("redrawstatus")
end

function M.lock(buf)
  set_lock(buf, true)
end

function M.unlock(buf)
  set_lock(buf, false)
end

function M.toggle(buf)
  buf = resolve(buf)
  set_lock(buf, not M.locked(buf))
end

function M.enable()
  M.config.enabled = true
  notify("Autosave enabled")
end

function M.disable()
  M.config.enabled = false
  notify("Autosave disabled (manual save everywhere)")
end

---@return boolean
function M.toggle_enabled()
  M.config.enabled = not M.config.enabled
  return M.config.enabled
end

---@param buf? integer
---@return string
function M.statusline(buf)
  return M.locked(buf) and M.config.lock_icon or ""
end

-- Saving ---------------------------------------------------------------------

---@param buf? integer
---@return boolean
function M.should_save(buf)
  buf = resolve(buf)
  if not M.config.enabled then
    return false
  end
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return false
  end
  local bo = vim.bo[buf]
  if bo.buftype ~= "" or not bo.modifiable or not bo.modified then
    return false
  end
  if M.config.skip_unnamed and vim.api.nvim_buf_get_name(buf) == "" then
    return false
  end
  if vim.tbl_contains(M.config.skip_filetypes, bo.filetype) then
    return false
  end
  if M.locked(buf) then
    return false
  end
  if M.config.condition and not M.config.condition(buf) then
    return false
  end
  return true
end

---@param buf? integer
---@return boolean saved
function M.save(buf)
  buf = resolve(buf)
  if not M.should_save(buf) then
    return false
  end
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! update")
  end)
  if M.config.on_save then
    M.config.on_save(buf)
  end
  return true
end

-- Setup ----------------------------------------------------------------------

local function define_commands()
  vim.api.nvim_create_user_command("AutosaveLock", function()
    M.toggle()
  end, { desc = "Toggle autosave lock for the current buffer" })
  vim.api.nvim_create_user_command("AutosaveEnable", function()
    M.enable()
  end, { desc = "Enable autosave" })
  vim.api.nvim_create_user_command("AutosaveDisable", function()
    M.disable()
  end, { desc = "Disable autosave (manual save everywhere)" })
  vim.api.nvim_create_user_command("AutosaveStatus", function()
    local name = vim.api.nvim_buf_get_name(0)
    notify(
      ("autosave=%s  lock=%s  %s"):format(
        M.config.enabled and "on" or "off",
        M.locked() and "on" or "off",
        name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
      )
    )
  end, { desc = "Show autosave status" })
end

---@param opts? table
function M.setup(opts)
  M.config = vim.tbl_extend("force", vim.deepcopy(defaults), opts or {})
  load_locks()

  vim.api.nvim_clear_autocmds({ group = group })
  vim.api.nvim_create_autocmd(M.config.events, {
    group = group,
    callback = function(args)
      M.save(args.buf)
    end,
  })

  define_commands()

  if M.config.keymap then
    vim.keymap.set("n", M.config.keymap, function()
      M.toggle()
    end, { desc = "Toggle autosave lock" })
  end

  return M
end

return M

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.scrolloff = 10

-- Allow project-local .nvim.lua / .nvimrc for per-repo overrides
-- with safe mode to restrict potentially dangerous commands
vim.opt.exrc = true
vim.opt.secure = true

vim.o.guicursor = "n-v-c:block,i:blinkon0"

-- Disable autoformat globally; opt-in per filetype
vim.g.autoformat = false

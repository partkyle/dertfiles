-- Show hidden files by default in the file picker (snacks.nvim) inside this repo.
local snacks = require("snacks")
snacks.config.picker = snacks.config.picker or {}
snacks.config.picker.sources = snacks.config.picker.sources or {}
snacks.config.picker.sources.files = snacks.config.picker.sources.files or {}
snacks.config.picker.sources.files.hidden = true

return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      scroll = { enabled = false },
      scratch = {},
    },
    keys = {
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
    },
  },
  -- nil_ls and gopls are installed via Nix, skip Mason
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          mason = false,
        },
        gopls = {
          mason = false,
        },
      },
    },
  },
  -- Go tooling (gopls, goimports, gofumpt, golangci-lint, delve) comes from
  -- Nix. Keep Mason from trying to reinstall it and let nvim-dap-go pick up
  -- `dlv` from PATH.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local from_nix = { "delve", "gofumpt", "goimports", "golangci-lint" }
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return not vim.tbl_contains(from_nix, tool)
      end, opts.ensure_installed or {})
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      automatic_installation = false,
    },
  },
  -- update position of command thingy
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.presets = opts.presets or {}
      opts.presets.command_palette = {
        views = {
          cmdline_popup = {
            position = { row = "30%", col = "50%" },
            anchor = "NW",
            size = { min_width = 60, width = "auto", height = "auto" },
          },
        },
      }
    end,
  },
  -- Local plugin: autosave by default, with a per-buffer manual-save lock
  {
    dir = vim.fn.stdpath("config") .. "/local/autosave-lock",
    name = "autosave-lock",
    main = "autosave-lock",
    opts = {
      keymap = "<leader>zl",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, 1, {
        function()
          return require("autosave-lock").statusline()
        end,
        cond = function()
          return require("autosave-lock").locked()
        end,
      })
    end,
  },
}

local M = {
  "goolord/alpha-nvim",
  event = "VimEnter",
}

M.opts = {
  dash_model = {
    [[     ██╗██╗   ██╗███████╗████████╗    ██████╗  ██████╗     ██╗████████╗██╗ ]],
    [[     ██║██║   ██║██╔════╝╚══██╔══╝    ██╔══██╗██╔═══██╗    ██║╚══██╔══╝██║ ]],
    [[     ██║██║   ██║███████╗   ██║       ██║  ██║██║   ██║    ██║   ██║   ██║ ]],
    [[██   ██║██║   ██║╚════██║   ██║       ██║  ██║██║   ██║    ██║   ██║   ╚═╝ ]],
    [[╚█████╔╝╚██████╔╝███████║   ██║       ██████╔╝╚██████╔╝    ██║   ██║   ██╗ ]],
    [[ ╚════╝  ╚═════╝ ╚══════╝   ╚═╝       ╚═════╝  ╚═════╝     ╚═╝   ╚═╝   ╚═╝ ]],
  },
}

function M.config(_, opts)
  local alpha = require("alpha")
  local startify = require("alpha.themes.startify")

  -- Tombol disesuaikan dengan keymap yang benar-benar dipakai sekarang.
  -- (dulu ada tombol "Find project" yang error karena project.nvim tak terpasang)
  startify.section.top_buttons.val = {}

  -- disable MRU
  startify.section.mru.val = { { type = "padding", val = 4 } }
  -- disable MRU cwd
  startify.section.mru_cwd.val = { { type = "padding", val = 0 } }
  -- disable nvim_web_devicons
  startify.nvim_web_devicons.enabled = false
  startify.section.bottom_buttons.val = {}

  startify.section.header.val = pcode.dashboard or opts.dash_model

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    desc = "Add Alpha dashboard footer",
    once = true,
    callback = function()
      local stats = require("lazy").stats()
      local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
      startify.section.footer.val = {
        {
          type = "text",
          val = {
            "───────────────────────────────────────────────",
            "⚡ " .. stats.loaded .. "/" .. stats.count .. " plugin dimuat dalam " .. ms .. "ms",
            "󰃭  " .. os.date("%A, %d %B %Y"),
          },
          opts = { hl = "Comment" },
        },
      }
      pcall(vim.cmd.AlphaRedraw)
    end,
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = { "AlphaReady" },
    callback = function()
      vim.cmd([[
      set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3
    ]])
    end,
  })
  -- ignore filetypes in MRU
  local default_mru_ignore = {}
  startify.mru_opts.ignore = function(path, ext)
    return (string.find(path, "COMMIT_EDITMSG")) or (vim.tbl_contains(default_mru_ignore, ext))
  end
  alpha.setup(startify.config)
end

return M

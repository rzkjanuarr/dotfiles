-- Garis vertikal indentasi (indent guides) ala VS Code / Flutter.
-- Full semua level, selalu tampil, scope aktif rainbow.
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local hooks = require("ibl.hooks")
    local rainbow = {
      "RainbowDelimiterRed",
      "RainbowDelimiterYellow",
      "RainbowDelimiterBlue",
      "RainbowDelimiterOrange",
      "RainbowDelimiterGreen",
      "RainbowDelimiterViolet",
      "RainbowDelimiterCyan",
    }
    -- daftarin ulang tiap ganti colorscheme biar warna gak ilang
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      -- fallback kalau highlight rainbow belum ada (rainbow-delimiters ga ke-load)
      local defs = {
        RainbowDelimiterRed = "#E06C75",
        RainbowDelimiterYellow = "#E5C07B",
        RainbowDelimiterBlue = "#61AFEF",
        RainbowDelimiterOrange = "#D19A66",
        RainbowDelimiterGreen = "#98C379",
        RainbowDelimiterViolet = "#C678DD",
        RainbowDelimiterCyan = "#56B6C2",
      }
      for name, fg in pairs(defs) do
        if vim.fn.hlexists(name) == 0 then
          vim.api.nvim_set_hl(0, name, { fg = fg })
        end
      end
    end)

    require("ibl").setup({
      indent = {
        char = "│", -- garis tiap level indentasi (semua baris, selalu tampil)
        tab_char = "│",
        highlight = rainbow, -- tiap level warna beda ala VS Code/Flutter
      },
      whitespace = {
        highlight = rainbow,
        remove_blankline_trail = false,
      },
      scope = {
        enabled = true,      -- scope kursor akurat (treesitter)
        highlight = rainbow, -- scope aktif ikut rainbow, lebih menonjol
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "NvimTree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
          "terminal",
        },
      },
    })

    -- sinkron warna scope aktif ke kurung rainbow-delimiters
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
  end,
}


-- Garis vertikal indentasi (indent guides) ala VS Code.
-- Nyambungin blok/scope widget Flutter dari induk ke anak.
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  lazy = true,
  event = "BufReadPre",
  opts = {
    indent = {
      char = "│", -- garis tiap level indentasi
      tab_char = "│",
    },
    scope = {
      enabled = true, -- highlight blok/scope tempat kursor (garis lebih terang)
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
  },
}

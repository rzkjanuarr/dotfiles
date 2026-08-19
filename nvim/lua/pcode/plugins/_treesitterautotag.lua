return {
  "windwp/nvim-ts-autotag",
  lazy = true,
  event = { "BufRead", "InsertEnter" },
  opts = {
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
    per_filetype = {
      javascriptreact = {
        enable_close = true,
        enable_rename = true,
      },
      typescriptreact = {
        enable_close = true,
        enable_rename = true,
      },
    },
  },
}

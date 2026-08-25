return {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  opts = {
    bind = true,
    handler_opts = {
      border = "rounded",
    },
    hint_prefix = "󰍩 ",
    -- Popup parameter JANGAN muncul sendiri saat ngetik widget Flutter
    -- (Container(, Column(, dst) — dulu bikin harus Esc terus.
    floating_window = false, -- jangan tampil otomatis
    hint_enable = false, -- matikan hint virtual-text di samping kode
    toggle_key = "<C-k>", -- tekan Ctrl+k di insert mode untuk memunculkannya
    toggle_key_flip_floatwin_setting = true,
    select_signature_key = "<C-n>", -- ganti antar-overload bila ada
  },
  -- or use config
  -- config = function(_, opts) require'lsp_signature'.setup({you options}) end
}

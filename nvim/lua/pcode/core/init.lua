_G.pcode = _G.pcode or {}
require("pcode.user.default")
require("pcode.config.lazy_lib")
require("pcode.user.colorscheme")
require("pcode.core.neovide")

vim.keymap.set({ "n", "v", "x" }, "<leader>og", function()
  require("gemini").start_chat_session()
end, { noremap = true, silent = true, desc = "Open Gemini terminal chat" })

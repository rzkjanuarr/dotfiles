local M = {}

---@type snacks.terminal.Opts
local snacks_terminal_opts = {
  win = {
    position = "right", -- sidekick kanan
    width = 0.3, -- 30% lebar layar
    enter = true, -- Gemini biasanya butuh input langsung
  },
}

function M.ask_gemini()
  M.start_chat_session()
end

function M.start_chat_session()
  require("snacks.terminal").toggle("gemini", snacks_terminal_opts)
end

return M

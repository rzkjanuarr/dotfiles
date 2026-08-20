local status_ok, dapui = pcall(require, "dapui")
if not status_ok then
	return
end

local status_ok_dap, dap = pcall(require, "dap")
if not status_ok_dap then
	return
end

-- Ikon breakpoint di-define di extras/dap.lua (config), sebelum file ini di-require.

dapui.setup({
	expand_lines = true,
	icons = { expanded = "", collapsed = "", current_frame = "" },
	mappings = {
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.33 },
				{ id = "breakpoints", size = 0.17 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 0.33,
			position = "right",
		},
		{
			elements = {
				{ id = "repl", size = 0.45 },
				{ id = "console", size = 0.55 },
			},
			size = 0.27,
			position = "bottom",
		},
	},
	floating = {
		max_height = 0.9,
		max_width = 0.5, -- Floats will be relative to the window
		border = "rounded",
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
})

-- ── Toggle breakpoint ala VS Code (global, 1 tombol) ─────────────
-- <F9> = toggle breakpoint. Standar VS Code, tanpa timeout leader.
vim.keymap.set("n", "<F9>", function()
	require("dap").toggle_breakpoint()
end, { desc = "DAP: Toggle Breakpoint" })
-- <F5> = start/continue debug (standar VS Code).
vim.keymap.set("n", "<F5>", function()
	require("dap").continue()
end, { desc = "DAP: Start/Continue" })

-- ── Diagnostik: :CheckBP → cek apakah breakpoint kepasang di baris kursor ──
vim.api.nvim_create_user_command("CheckBP", function()
	local d = require("dap")
	d.toggle_breakpoint()
	local bps = require("dap.breakpoints").get()
	local n = 0
	for _, list in pairs(bps) do
		n = n + #list
	end
	vim.notify("Total breakpoint sekarang: " .. n .. " (harus > 0 setelah toggle)", vim.log.levels.INFO)
end, { desc = "Toggle breakpoint di baris kursor + laporkan jumlah" })

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

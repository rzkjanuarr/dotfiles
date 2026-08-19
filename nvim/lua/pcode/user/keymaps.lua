-- definiskanfunction name
-- local keymap = vim.api.nvim_set_keymap
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local function ensure_valid_cwd()
  local cwd = vim.uv.cwd()
  if cwd and vim.uv.fs_stat(cwd) then
    return true
  end

  local home = vim.uv.os_homedir() or vim.fn.expand("~")
  if home and home ~= "" then
    vim.cmd("cd " .. vim.fn.fnameescape(home))
    return true
  end
  return false
end

-- Remap space leader keys
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- MODES
-- mormal mode = "n"
-- insert mode = "i"
-- visual mode = "v"
-- visual block mode = "x"
-- term mode = "t"
-- command mode = "c"

for _, mode in ipairs({ "i", "v", "n", "x" }) do
  -- duplicate line
  keymap(mode, "<S-Down>", "<cmd>t.<cr>", opts)
  keymap(mode, "<S-Up>", "<cmd>t -1<cr>", opts)
  keymap(mode, "<S-M-Down>", "<cmd>t.<cr>", opts)
  keymap(mode, "<S-M-Up>", "<cmd>t -1<cr>", opts)
  -- save file
  keymap(mode, "<C-s>", "<cmd>silent! w<cr>", opts)
end

-- duplicate line visual block
keymap("x", "<S-Down>", ":'<,'>t'><cr>", opts)
keymap("x", "<S-M-Down>", ":'<,'>t'><cr>", opts)
keymap("x", "<S-Up>", ":'<,'>t-1<cr>", opts)
keymap("x", "<S-M-Up>", ":'<,'>t-1<cr>", opts)

-- move text up and down
keymap("x", "<A-Down>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-Up>", ":move '<-2<CR>gv-gv", opts)
keymap("n", "<M-Down>", "<cmd>m+<cr>", opts)
keymap("i", "<M-Down>", "<cmd>m+<cr>", opts)
keymap("n", "<M-Up>", "<cmd>m-2<cr>", opts)
keymap("i", "<M-Up>", "<cmd>m-2<cr>", opts)

-- create comment CTRL + / visual block mode
keymap("x", "<C-_>", function()
  vim.api.nvim_feedkeys("gb", "v", true)
end, opts)
-- create comment CTRL + / visual mode
keymap("v", "<C-/>", "gb", opts)
-- create comment CTRL + / normal mode
keymap("i", "<C-_>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
  -- Toggle comment baris
  vim.api.nvim_feedkeys("gcc", "v", true)

  -- Tunggu sejenak agar komentar terbentuk
  vim.schedule(function()
    local row = vim.fn.line(".") - 1 -- index dimulai dari 0
    local col = #vim.fn.getline(".") -- panjang baris = akhir kalimat

    -- Geser 2 spasi dari akhir dan masuk insert mode
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
    vim.api.nvim_feedkeys("i", "v", true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right><leader>", true, false, true), "n", true)
  end)
end, opts)
-- create comment CTRL + / normal mode
keymap("n", "<C-_>", function()
  -- Toggle comment baris
  vim.api.nvim_feedkeys("gcc", "v", true)

  -- Tunggu sejenak agar komentar terbentuk
  vim.schedule(function()
    local row = vim.fn.line(".") - 1 -- index dimulai dari 0
    local col = #vim.fn.getline(".") -- panjang baris = akhir kalimat

    -- Geser 2 spasi dari akhir dan masuk insert mode
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
    vim.api.nvim_feedkeys("i", "v", true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right><leader>", true, false, true), "n", true)
  end)
end, opts)

-- close windows
keymap("n", "q", function()
  if #vim.api.nvim_list_wins() > 1 then
    vim.cmd("q")
  end
end, opts)

-- find file global (sesuai dashboard)
keymap("n", "F", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "R", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "S", function()
  local grugfar = require("grug-far")
  local is_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "grug-far" then
      is_open = true
      vim.api.nvim_win_close(win, true)
      break
    end
  end

  if not is_open then
    grugfar.open({
      windowCreationCommand = "tabnew",
      staticTitle = " Global Search and Replace ",
    })
  end
end, opts)

-- search & replace di file yang sedang dibuka saja
keymap("n", "<leader>sr", function()
  require("grug-far").open({
    prefills = {
      paths = vim.fn.expand("%"),
    },
    staticTitle = " Search and Replace (Current File) ",
  })
end, opts)

if pcode.use_nvimtree then
  keymap("n", "E", function()
    ensure_valid_cwd()
    vim.cmd("NvimTreeFindFileToggle")
  end, opts)
else
  keymap("n", "E", function()
    ensure_valid_cwd()
    vim.cmd("Neotree toggle")
  end, opts)
end

-- window navigation
keymap("n", "<c-h>", "<C-w>h", opts)
keymap("n", "<c-j>", "<C-w>j", opts)
keymap("n", "<c-k>", "<C-w>k", opts)
keymap("n", "<c-l>", "<C-w>l", opts)
keymap({ "n", "v" }, "<c-a>", "ggVG", opts)
keymap("i", "<c-a>", "<esc>ggVG", opts)
keymap({ "n", "v" }, "<m-a>", "ggVG", opts)
keymap("i", "<m-a>", "<esc>ggVG", opts)
keymap({ "n", "v" }, "<D-a>", "ggVG", opts)
keymap("i", "<D-a>", "<esc>ggVG", opts)
keymap({ "v", "x" }, "<c-c>", '"+y', opts)
keymap("n", "<c-c>", '"+yy', opts)
keymap({ "n", "v", "x" }, "<c-v>", '"+P', opts)
keymap("i", "<c-v>", "<esc>pa<Left>", opts)
keymap("n", "<c-z>", "<cmd>undo<CR>", opts)
keymap("x", "<c-z>", "<esc><cmd>undo<CR>", opts)
keymap("v", "<c-z>", "<esc><cmd>undo<CR>", opts)
keymap("i", "<c-z>", "<esc><cmd>undo<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-Left>", "<Esc>:bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<S-Right>", "<Esc>:bprevious<CR>", opts)

-- Reordering Bufferline
keymap("n", "<S-PageUp>", "<cmd>BufferLineMovePrev<cr>", opts)
keymap("n", "<S-PageDown>", "<cmd>BufferLineMoveNext<cr>", opts)

-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- ALT + l to open terminal and run live-server
keymap("n", "<A-l>", "<cmd>terminal live-server<cr>", opts)

-- close current buffer (like VSCode's Ctrl+W)
-- Note: This overrides Neovim's default window command prefix <C-w>
keymap("n", "<C-w>", "<cmd>lua require('auto-bufferline.configs.utils').bufremove()<cr>", opts)

-- panggil google gemini
keymap("n", "<leader>ga", "<cmd>lua require('gemini').start_chat_session()<cr>", opts)

vim.api.nvim_create_user_command("TSIsInstalled", function()
  local parsers = require("nvim-treesitter.info").installed_parsers()
  table.sort(parsers)
  local choices = {}
  local lookup = {}

  for _, parser in ipairs(parsers) do
    local label = "[✓] " .. parser
    table.insert(choices, label)
    lookup[label] = parser
  end

  vim.ui.select(choices, {
    prompt = "Uninstall Treesitter",
  }, function(choice)
    if choice then
      local parser_name = lookup[choice]
      if parser_name then
        vim.cmd("TSUninstall " .. parser_name)
      end
    end
  end)
end, {})

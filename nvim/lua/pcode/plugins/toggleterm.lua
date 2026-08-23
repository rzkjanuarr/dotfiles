return {
  "akinsho/toggleterm.nvim",
  lazy = true,
  cmd = {
    "ToggleTerm",
    "TermExec",
    "ToggleTermToggleAll",
    "ToggleTermSendCurrentLine",
    "ToggleTermSendVisualLines",
    "ToggleTermSendVisualSelection",
  },
  branch = "main",
  enabled = true,
  opts = {
    size = 20,
    open_mapping = [[<c-\\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    local horizontal = Terminal:new({
      direction = "horizontal",
      size = 15,
      hidden = true,
    })

    local vertical = Terminal:new({
      direction = "vertical",
      size = 80,
      hidden = true,
    })

    -- ── Terminal float multi-tab ──────────────────────────────────────────
    -- Simpan beberapa terminal float; Ctrl+h / Ctrl+l buat pindah antar-tab,
    -- Ctrl+t buat nambah tab baru. Default langsung 2 tab.
    local floats = {}
    local aktif = 1

    -- keymap khusus buffer terminal float: pindah/tambah tab.
    -- buffer-local → nggak ganggu Ctrl+h/l pindah window di luar terminal.
    local function pasang_keymap_tab(bufnr)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      local o = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set({ "n", "t" }, "<C-l>", function()
        _G._FLOAT_NEXT()
      end, o)
      vim.keymap.set({ "n", "t" }, "<C-h>", function()
        _G._FLOAT_PREV()
      end, o)
      vim.keymap.set({ "n", "t" }, "<C-t>", function()
        _G._FLOAT_NEW()
      end, o)
    end

    local function buat_float()
      local t = Terminal:new({
        direction = "float",
        hidden = true,
        -- on_create: pasti dipanggil saat buffer terminal dibuat
        on_create = function(term)
          pasang_keymap_tab(term.bufnr)
        end,
        -- on_open: dipasang ulang tiap dibuka, jaga-jaga ketimpa autocmd TermOpen
        on_open = function(term)
          pasang_keymap_tab(term.bufnr)
        end,
      })
      table.insert(floats, t)
      return t
    end

    -- mulai dengan 2 tab
    buat_float()
    buat_float()

    local function tampilkan(idx)
      for i, t in ipairs(floats) do
        if i ~= idx and t:is_open() then
          t:close()
        end
      end
      aktif = idx
      floats[idx]:open()
      vim.notify("Terminal " .. idx .. "/" .. #floats, vim.log.levels.INFO)
    end

    function _G._FLOAT_NEXT()
      tampilkan(aktif % #floats + 1)
    end

    function _G._FLOAT_PREV()
      tampilkan((aktif - 2) % #floats + 1)
    end

    function _G._FLOAT_NEW()
      buat_float()
      tampilkan(#floats)
    end

    function _G._HORIZONTAL_TOGGLE()
      horizontal:toggle()
    end

    function _G._VERTICAL_TOGGLE()
      vertical:toggle()
    end

    function _G._FLOAT_TOGGLE()
      if floats[aktif]:is_open() then
        for _, t in ipairs(floats) do
          if t:is_open() then
            t:close()
          end
        end
      else
        floats[aktif]:open()
      end
    end

    function _G.set_terminal_keymaps()
      local optsn = { noremap = true }
      vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\\><C-n>]], optsn)
      vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\\><C-n>]], optsn)
      -- Di terminal FLOAT, Ctrl+h/l dipakai pindah antar-tab terminal (di-set
      -- lewat on_open). Jadi pindah-window hanya untuk terminal non-float.
      local is_float = false
      for _, t in ipairs(floats) do
        if t.bufnr == vim.api.nvim_get_current_buf() then
          is_float = true
          break
        end
      end
      if not is_float then
        vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\\><C-n><C-W>h]], optsn)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\\><C-n><C-W>l]], optsn)
      end
      vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\\><C-n><C-W>j]], optsn)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\\><C-n><C-W>k]], optsn)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
  keys = {
    { "<leader>t", "", desc = " Terminal", mode = "n" },

    {
      "<leader>th",
      "<cmd>lua _HORIZONTAL_TOGGLE()<CR>",
      desc = "Horizontal",
      mode = "n",
    },

    {
      "<leader>tv",
      "<cmd>lua _VERTICAL_TOGGLE()<CR>",
      desc = "Vertical",
      mode = "n",
    },

    {
      "<leader>tf",
      "<cmd>lua _FLOAT_TOGGLE()<CR>",
      desc = "Float",
      mode = "n",
    },

    {
      "<leader>tx",
      "<cmd>ToggleTermToggleAll!<CR>",
      desc = "Close All",
      mode = "n",
    },
  },
}

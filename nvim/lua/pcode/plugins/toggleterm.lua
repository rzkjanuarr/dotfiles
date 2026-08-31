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

    local vertical = Terminal:new({
      direction = "vertical",
      size = 80,
      hidden = true,
    })

    -- ── Grup terminal multi-tab ───────────────────────────────────────────
    -- Bikin sekumpulan terminal dengan direction tertentu yang bisa dipindah
    -- antar-tab: Ctrl+l next, Ctrl+h prev, Ctrl+t tab baru. Default 2 tab.
    -- Dipakai buat float (leader tf) dan horizontal (leader th).
    local function buat_grup_tab(direction, extra)
      local grup = {}
      local aktif = 1
      local api = {}

      -- keymap khusus buffer terminal: pindah/tambah tab. buffer-local →
      -- nggak ganggu Ctrl+h/l pindah window di luar terminal.
      local function pasang_keymap_tab(bufnr)
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        local o = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set({ "n", "t" }, "<C-l>", function()
          api.next()
        end, o)
        vim.keymap.set({ "n", "t" }, "<C-h>", function()
          api.prev()
        end, o)
        vim.keymap.set({ "n", "t" }, "<C-t>", function()
          api.new()
        end, o)
      end

      local function buat()
        local spec = vim.tbl_extend("force", {
          direction = direction,
          hidden = true,
          -- on_create: pasti dipanggil saat buffer terminal dibuat
          on_create = function(term)
            pasang_keymap_tab(term.bufnr)
          end,
          -- on_open: dipasang ulang tiap dibuka, jaga ketimpa autocmd TermOpen
          on_open = function(term)
            pasang_keymap_tab(term.bufnr)
          end,
        }, extra or {})
        local t = Terminal:new(spec)
        table.insert(grup, t)
        return t
      end

      local function tampilkan(idx)
        for i, t in ipairs(grup) do
          if i ~= idx and t:is_open() then
            t:close()
          end
        end
        aktif = idx
        grup[idx]:open()
        vim.notify("Terminal " .. idx .. "/" .. #grup, vim.log.levels.INFO)
      end

      function api.next()
        tampilkan(aktif % #grup + 1)
      end

      function api.prev()
        tampilkan((aktif - 2) % #grup + 1)
      end

      function api.new()
        buat()
        tampilkan(#grup)
      end

      function api.toggle()
        if grup[aktif]:is_open() then
          for _, t in ipairs(grup) do
            if t:is_open() then
              t:close()
            end
          end
        else
          grup[aktif]:open()
        end
      end

      function api.is_member(bufnr)
        for _, t in ipairs(grup) do
          if t.bufnr == bufnr then
            return true
          end
        end
        return false
      end

      -- mulai dengan 2 tab
      buat()
      buat()

      return api
    end

    local grup_float = buat_grup_tab("float", {})
    local grup_horizontal = buat_grup_tab("horizontal", { size = 15 })

    function _G._FLOAT_TOGGLE()
      grup_float.toggle()
    end

    function _G._HORIZONTAL_TOGGLE()
      grup_horizontal.toggle()
    end

    function _G._VERTICAL_TOGGLE()
      vertical:toggle()
    end

    function _G.set_terminal_keymaps()
      local optsn = { noremap = true }
      vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\\><C-n>]], optsn)
      vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\\><C-n>]], optsn)
      -- Di terminal float/horizontal, Ctrl+h/l dipakai pindah antar-tab
      -- terminal (di-set lewat on_open). Jadi pindah-window hanya untuk
      -- terminal yang bukan anggota grup tab.
      local buf = vim.api.nvim_get_current_buf()
      local grup_tab = grup_float.is_member(buf) or grup_horizontal.is_member(buf)
      if not grup_tab then
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

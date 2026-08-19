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

    local floating = Terminal:new({
      direction = "float",
      hidden = true,
    })

    function _G._HORIZONTAL_TOGGLE()
      horizontal:toggle()
    end

    function _G._VERTICAL_TOGGLE()
      vertical:toggle()
    end

    function _G._FLOAT_TOGGLE()
      floating:toggle()
    end

    function _G.set_terminal_keymaps()
      local optsn = { noremap = true }
      vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\\><C-n>]], optsn)
      vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\\><C-n>]], optsn)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\\><C-n><C-W>h]], optsn)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\\><C-n><C-W>j]], optsn)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\\><C-n><C-W>k]], optsn)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\\><C-n><C-W>l]], optsn)
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

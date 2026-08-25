return {
  { "nvim-lua/plenary.nvim", event = "VeryLazy" },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufRead", "VeryLazy" },
    version = false,
    build = ":TSUpdate",
    lazy = true,
    cmd = {
      "TSInstall",
      -- "TSInstallInfo",
      "TSInstallSync",
      "TSUpdate",
      "TSUpdateSync",
      "TSUninstall",
      "TSUninstallInfo",
      "TSInstallFromGrammar",
    },
    opts = function()
      return {
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = { "lua", "luadoc", "printf", "vim", "vimdoc" },
        incremental_selection = {
          enable = true,
        },
        autopairs = {
          enable = true,
        },
      }
    end,
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("nvim-treesitter").setup(opts)

      -- nvim-treesitter main branch: setup() TIDAK meng-enable highlight/indent
      -- otomatis. Harus di-start manual per-buffer via FileType autocmd.
      -- Ini juga syarat agar nvim-ts-autotag (auto-close <Tag>) berfungsi.
      local ensure = opts.ensure_installed or {}

      local function ts_start(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        local ft = vim.bo[buf].filetype
        if ft == "" then
          return
        end
        local lang = vim.treesitter.language.get_lang(ft) or ft
        -- pastikan parser terpasang, kalau belum install async lalu start
        if not pcall(vim.treesitter.get_parser, buf, lang) then
          local ok_installed = false
          for _, l in ipairs(ensure) do
            if l == lang then
              ok_installed = true
              break
            end
          end
          if ok_installed then
            pcall(function()
              require("nvim-treesitter").install(lang):await(function()
                if vim.api.nvim_buf_is_valid(buf) then
                  pcall(vim.treesitter.start, buf, lang)
                end
              end)
            end)
          end
          return
        end
        pcall(vim.treesitter.start, buf, lang)
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("pcode_ts_start", { clear = true }),
        callback = function(ev)
          ts_start(ev.buf)
        end,
      })

      -- start juga untuk buffer yang sudah terbuka (FileType sudah lewat)
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          ts_start(buf)
        end
      end

      vim.api.nvim_create_user_command("TSInstallInfo", function()
        vim.cmd("Telescope treesitter_info")
      end, {})
    end,
  },
}

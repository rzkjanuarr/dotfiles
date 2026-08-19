return {
  -- animations
  {
    "echasnovski/mini.animate",
    event = "BufRead",
    opts = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs({ "Up", "Down" }) do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require("mini.animate")
      return {
        resize = {
          timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
        },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 120, unit = "total" }),
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          }),
        },
        cursor = {
          timing = animate.gen_timing.linear({ duration = 90, unit = "total" }),
        },
        open = {
          enable = true,
          timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
          winconfig = animate.gen_winconfig.static({}),
        },
        close = {
          enable = true,
          timing = animate.gen_timing.linear({ duration = 90, unit = "total" }),
          winconfig = animate.gen_winconfig.static({}),
        },
      }
    end,
    config = function(_, opts)
      require("mini.animate").setup(opts)
    end,
  },
}

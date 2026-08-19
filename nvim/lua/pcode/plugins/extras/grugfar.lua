return {
  "MagicDuck/grug-far.nvim",
  config = function()
    require("grug-far").setup({
      headerMaxWidth = 80,
      -- Jangan gunakan "float" di sini karena itu bukan command nvim
    })
  end,
}

-- activate config spesific languages
pcode.lang = {
  angular = false,
  sql = false,
  golang = false,
  javascript = true,
  markdown = true,
  php = false,
  python = false,
  rust = true,
  tailwind = true,
  pascal = true,
  flutter_hyper = true,
}
-- activate config extras
pcode.extras = {
  autosave = false,
  bigfiles = true,
  snacks = true,
  opencode = false,
  liveserver = false,
  minianimate = false,
  neoscroll = false,
  nvimufo = true,
  refactoring = false,
  treesittercontex = false,
  colorizer = true,
  dap = true,
  deviconcolor = false,
  illuminate = true,
  indentscupe = false,
  indentblankline = true,
  navic = true,
  nvimmenu = false,
  rainbowdelimiters = true,
  scrollview = false,
  smartsplit = true,
  verticalcolumn = false,
  visualmulti = true,
  yanky = true,
  zenmode = false,
  lspsignatur = false,
  telescopetreesiterinfo = false,
  fidget = false,
  tinydignostic = false,
  dressing = true,
  telescopediff = false,
  cheatsheet = false,
  showkeys = true,
  mcp = false,
  avante = false,
  grugfar = true,
  dbee = true,
  nvimspectre = false,
  muslim = false,
  commander = true,
  claudecode = true,
  retrospect = true,
  neogit = true,
}
-- activate config themes
pcode.themes = {
  -- note: open remark only one
  -- **:: Eva Theme ::** --
  evatheme = "Eva-Dark",
  -- evatheme = "Eva-Dark-Italic",
  -- evatheme = "Eva-Dark-Bold",
  -- evatheme = "Eva-Light",
  --
  -- **:: Dracula Theme ::** --
  -- dracula = "dracula",
  -- dracula = "dracula-soft",
  --
  -- **:: Onedarkpro Theme ::** --
  -- onedarkpro = "onedark",
  -- onedarkpro = "onedark_vivid",
  -- onedarkpro = "onedark_dark",
  --
  -- **:: Jetbrains Theme ::** --
  -- jetbrains = "darcula-dark",
  --
  -- **:: Sublimetext Theme ::** --
  -- sublimetext = "juliana",
  --
  -- **:: Tokyonight Theme ::** --
  -- tokyonight = "tokyonight-night",
  -- tokyonight = "tokyonight-storm",
  -- tokyonight = "tokyonight-day",
  -- tokyonight = "tokyonight-moon",
  --
  -- **:: Catppuccin Theme ::** --
  -- catppuccin = "catppuccin",
  -- catppuccin = "catppuccin-latte",
  -- catppuccin = "catppuccin-frappe",
  -- catppuccin = "catppuccin-macchiato",
  -- catppuccin = "catppuccin-macchiato",
  --
  -- **:: Gruvbox Theme ::** --
  -- gruvbox = "gruvbox",

  -- **:: Github Theme ::** --
  -- github = "github_dark_dimmed",
}
-- activate config transparent_bg
pcode.transparent = true
pcode.localcode = true
pcode.snippets_path = vim.fn.stdpath("config") .. "/mysnippets"
pcode.use_nvimtree = false -- pakai neo-tree (sidebar bertumpuk: FILES + GIT STATUS ala VSCode)
pcode.nvimtree_float = false

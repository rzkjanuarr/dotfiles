-- ════════════════════════════════════════════════════════════════════════════
-- Snippet Saver — simpan blok visual jadi snippet VS Code
-- Alur:
--   1. Blok teks di visual mode
--   2. Tekan keymap (<leader>ss) / :SnippetSave
--   3. Popup (dressing) tanya NAMA (= language, mis. "flutter"/"dart"/"go")
--   4. Popup tanya PREFIX (trigger completion, mis. "myscaffold")
--   5. Tersimpan ke ~/dotfiles/nvim/mysnippets/<nama>/snippets.json
--      + auto-daftar ke mysnippets/package.json (language = <nama>)
--      + reload LuaSnip -> langsung kepakai di completion
-- ════════════════════════════════════════════════════════════════════════════
local M = {}

local function snippets_root()
  -- pakai pcode.snippets_path bila ada, fallback stdpath config/mysnippets
  local ok = pcall(function() return _G.pcode and _G.pcode.snippets_path end)
  if ok and _G.pcode and _G.pcode.snippets_path then
    return _G.pcode.snippets_path
  end
  return vim.fn.stdpath("config") .. "/mysnippets"
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Snippet Saver" })
end

-- Ambil teks blok visual terakhir (mode charwise/linewise), kembalikan array baris.
local function get_visual_lines()
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  local srow, scol = s[2], s[3]
  local erow, ecol = e[2], e[3]
  if srow == 0 or erow == 0 then return nil end
  if srow > erow or (srow == erow and scol > ecol) then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end
  local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
  if #lines == 0 then return nil end
  -- charwise: potong kolom awal/akhir; linewise ('V') ambil utuh
  local vmode = vim.fn.visualmode()
  if vmode == "v" then
    if #lines == 1 then
      lines[1] = string.sub(lines[1], scol, ecol)
    else
      lines[1] = string.sub(lines[1], scol)
      lines[#lines] = string.sub(lines[#lines], 1, ecol)
    end
  end
  return lines
end

-- Baca JSON file -> table (kosong bila belum ada / invalid).
local function read_json(path)
  if vim.fn.filereadable(path) == 0 then return {} end
  local content = table.concat(vim.fn.readfile(path), "\n")
  if vim.trim(content) == "" then return {} end
  local ok, decoded = pcall(vim.json.decode, content, { luanil = { object = true, array = true } })
  if not ok or type(decoded) ~= "table" then
    notify("File JSON rusak, dibuat ulang: " .. path, vim.log.levels.WARN)
    return {}
  end
  return decoded
end

-- Tulis table -> JSON (indent 2 spasi, biar rapi & diff-friendly).
local function write_json(path, tbl)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local encoded
  local ok = pcall(function()
    encoded = vim.fn.json_encode(tbl)
  end)
  if not ok or not encoded then
    return false, "gagal encode JSON"
  end
  -- json_encode tanpa indent; rapikan via jq bila ada, else simpan apa adanya
  if vim.fn.executable("jq") == 1 then
    local pretty = vim.fn.system({ "jq", "." }, encoded)
    if vim.v.shell_error == 0 and vim.trim(pretty) ~= "" then
      encoded = pretty
    end
  end
  vim.fn.writefile(vim.split(encoded, "\n", { plain = true }), path)
  return true
end

-- Daftarkan language -> ./<name>/snippets.json ke package.json bila belum ada.
local function ensure_registered(name)
  local root = snippets_root()
  local pkg_path = root .. "/package.json"
  local pkg = read_json(pkg_path)
  pkg.contributes = pkg.contributes or {}
  pkg.contributes.snippets = pkg.contributes.snippets or {}
  local rel = "./" .. name .. "/snippets.json"
  for _, e in ipairs(pkg.contributes.snippets) do
    if e.language == name and e.path == rel then
      return -- sudah terdaftar
    end
  end
  table.insert(pkg.contributes.snippets, { language = name, path = rel })
  write_json(pkg_path, pkg)
end

-- Reload LuaSnip agar snippet baru langsung tersedia di session ini.
local function reload_luasnip()
  local root = snippets_root()
  local ok, from_vscode = pcall(require, "luasnip.loaders.from_vscode")
  if not ok then return end
  pcall(from_vscode.load, { paths = root })
  pcall(from_vscode.lazy_load, { paths = root })
end


-- Simpan snippet: name=language/file, prefix=trigger, body=array baris.
local function do_save(name, prefix, body)
  name = vim.trim(name):lower()
  prefix = vim.trim(prefix)
  local root = snippets_root()
  local file = root .. "/" .. name .. "/snippets.json"
  local snippets = read_json(file)

  -- key = prefix (unik). Bila sudah ada, tambah suffix numerik.
  local key = prefix
  if snippets[key] then
    local i = 2
    while snippets[key .. "_" .. i] do i = i + 1 end
    key = key .. "_" .. i
  end
  snippets[key] = {
    prefix = prefix,
    body = body,
    description = "Saved from visual selection",
  }

  local ok, err = write_json(file, snippets)
  if not ok then
    notify("Gagal menulis: " .. (err or "?"), vim.log.levels.ERROR)
    return
  end
  ensure_registered(name)
  reload_luasnip()
  notify(string.format("Snippet '%s' (prefix: %s) tersimpan ->\n%s", key, prefix, file))
end

-- Alur interaktif dari blok visual.
function M.save_visual()
  local body = get_visual_lines()
  if not body then
    notify("Tidak ada blok visual. Blok teks dulu (v/V), lalu jalankan.", vim.log.levels.WARN)
    return
  end

  -- default nama = filetype buffer (mis. dart), biar cepat
  local default_name = vim.bo.filetype ~= "" and vim.bo.filetype or "flutter"

  vim.ui.input({ prompt = "Simpan snippet ke (nama/language): ", default = default_name }, function(name)
    if not name or vim.trim(name) == "" then
      notify("Dibatalkan (nama kosong).", vim.log.levels.WARN)
      return
    end
    vim.ui.input({ prompt = "Prefix (trigger completion): " }, function(prefix)
      if not prefix or vim.trim(prefix) == "" then
        notify("Dibatalkan (prefix kosong).", vim.log.levels.WARN)
        return
      end
      do_save(name, prefix, body)
    end)
  end)
end

-- test helpers (headless)
M._do_save = do_save
M._read_json = read_json
M._write_json = write_json
M._ensure_registered = ensure_registered

function M.setup()
  vim.api.nvim_create_user_command("SnippetSave", function()
    M.save_visual()
  end, { range = true, desc = "Snippet Saver: simpan blok visual jadi snippet" })

  -- keymap visual mode
  vim.keymap.set("x", "<leader>ss", function()
    -- keluar dari visual dulu supaya mark '< '> terisi
    vim.cmd('noautocmd normal! \27')
    M.save_visual()
  end, { silent = true, desc = "Snippet Saver: simpan seleksi" })
end

return M


-- Flutter Hyper Generators (port ke Neovim)
-- Reimplementasi 3 status-bar generator dari VS Code extension
-- "denyocr.flutter-hyper-extension":
--
--   :FlutterCore    -> generateCore    (scan lib/, tulis lib/core.dart export semua .dart valid)
--   :FlutterModule  -> customModule    (baca .vscode/templates/<name>, scaffold file + placeholder)
--   :FlutterUdf     -> userDefinedSnippet (scan lib/ blok //#TEMPLATE prefix .. //#END -> snippet json)
--
-- Semua stateless (tidak butuh plugin lazy), dipasang lewat autocmd FileType dart.
-- Diaktifkan bareng pcode.lang.flutter = true.

local M = {}

-- ── util: root project (dir berisi pubspec.yaml, cari ke atas dari cwd) ──────
local function project_root()
  local found = vim.fs.find("pubspec.yaml", {
    path = vim.fn.getcwd(),
    upward = true,
  })
  if found and found[1] then
    return vim.fs.dirname(found[1])
  end
  return vim.fn.getcwd()
end

-- ── util: nama package dart dari pubspec.yaml (baris `name: xxx`) ────────────
local function package_name(root)
  local pubspec = root .. "/pubspec.yaml"
  local f = io.open(pubspec, "r")
  if not f then
    return nil
  end
  for line in f:lines() do
    local name = line:match("^name:%s*([%w_]+)")
    if name then
      f:close()
      return name
    end
  end
  f:close()
  return nil
end

-- ── util: baca file jadi string ─────────────────────────────────────────────
local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

-- ── util: tulis string ke file (buat dir bila perlu) ────────────────────────
local function write_file(path, content)
  local dir = vim.fs.dirname(path)
  vim.fn.mkdir(dir, "p")
  local f = io.open(path, "w")
  if not f then
    return false
  end
  f:write(content)
  f:close()
  return true
end

-- ── util: kumpulkan semua file secara rekursif dari sebuah direktori ─────────
local function read_files_recursive(dir)
  local result = {}
  local function walk(d)
    local handle = vim.loop.fs_scandir(d)
    if not handle then
      return
    end
    while true do
      local name, typ = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      local full = d .. "/" .. name
      if typ == "directory" then
        walk(full)
      else
        table.insert(result, full)
      end
    end
  end
  walk(dir)
  return result
end

-- ── util: case converters (port dari string extensions extension) ───────────
-- Input umumnya snake_case (moduleName wajib lowercase), mis. "product_category".
local function split_words(s)
  -- pecah berdasar _, -, spasi, dan batas camelCase
  s = s:gsub("([a-z0-9])([A-Z])", "%1_%2")
  local words = {}
  for w in s:gmatch("[%a%d]+") do
    table.insert(words, w:lower())
  end
  return words
end

local function to_key_name(s) -- product_category
  return table.concat(split_words(s), "_")
end

local function to_class_name(s) -- ProductCategory
  local out = {}
  for _, w in ipairs(split_words(s)) do
    table.insert(out, w:sub(1, 1):upper() .. w:sub(2))
  end
  return table.concat(out, "")
end

local function to_word_case(s) -- Product Category
  local out = {}
  for _, w in ipairs(split_words(s)) do
    table.insert(out, w:sub(1, 1):upper() .. w:sub(2))
  end
  return table.concat(out, " ")
end

local function to_camel_case(s) -- productCategory
  local cls = to_class_name(s)
  return cls:sub(1, 1):lower() .. cls:sub(2)
end

-- ════════════════════════════════════════════════════════════════════════════
-- 1. CORE  (:FlutterCore)
-- Port dari core_generator.js -> generateForDirectory().
-- Scan lib/, kumpulkan .dart valid, tulis lib/core.dart berisi export tiap file.
-- ════════════════════════════════════════════════════════════════════════════

-- Filter file dart valid (port getValidDartFiles): skip generated & part-of & core.
local function valid_dart_files(lib_dir)
  local files = read_files_recursive(lib_dir)
  local out = {}
  for _, path in ipairs(files) do
    if not path:match("%.dart$") then
      goto continue
    end
    local fname = vim.fs.basename(path)
    if path:find("/lib/core%.dart$") then goto continue end
    if path:find("/lib/core_package%.dart$") then goto continue end
    if path:find("/lib/main%.dart$") then goto continue end
    if path:find("/lib/generated_plugin_registrant%.dart$") then goto continue end
    -- file yang bukan sl_ : skip generated
    if not fname:match("^sl_") then
      if path:match("%.freezed%.dart$") then goto continue end
      if path:match("%.g%.dart$") then goto continue end
      if path:match("%.gr%.dart$") then goto continue end
    end
    local content = read_file(path) or ""
    -- skip file yang "part of" (bukan library sendiri)
    local is_part = false
    for line in content:gmatch("[^\n]+") do
      if line:match("^part of ") then
        is_part = true
        break
      end
    end
    if is_part then goto continue end
    if content:find("class Datum", 1, true) then goto continue end
    if content:find("//@excluded_from_core.dart", 1, true) then goto continue end
    table.insert(out, path)
    ::continue::
  end
  table.sort(out)
  return out
end

-- Bangun lib/core.dart dari scan folder lib/.
-- Return: jumlah file di-export, atau nil bila gagal (root/lib/pubspec bermasalah).
-- Dipisah dari M.generate_core agar bisa dipanggil ulang oleh build_module
-- (meniru CoreGenerator.generate() yang dipanggil extension setelah bikin module).
local function build_core(root)
  root = root or project_root()
  local lib = root .. "/lib"
  if vim.fn.isdirectory(lib) == 0 then
    return nil, "folder lib/ tidak ditemukan"
  end
  local pkg = package_name(root)
  if not pkg then
    return nil, "gagal baca name dari pubspec.yaml"
  end
  local files = valid_dart_files(lib)
  local export_list = {
    "/*",
    "We believe, the class name must be unique. ",
    "If there is a conflicting class name in this file,",
    "it means you have to rename it to something more unique.",
    string.format("fileCount: %d", #files),
    "*/",
  }
  for _, f in ipairs(files) do
    -- exportPath = path relatif terhadap lib (dengan leading slash)
    local export_path = f:gsub("^" .. vim.pesc(lib), "")
    table.insert(export_list, string.format("export 'package:%s%s';", pkg, export_path))
  end
  local target = lib .. "/core.dart"
  if write_file(target, table.concat(export_list, "\n") .. "\n") then
    -- reload buffer core.dart bila sedang terbuka
    vim.cmd("checktime")
    return #files
  end
  return nil, "gagal menulis core.dart"
end

-- diekspos untuk test/otomasi
M._build_core = build_core

function M.generate_core()
  local root = project_root()
  local count, err = build_core(root)
  if count then
    vim.notify(string.format("FlutterCore: %d file di-export ke lib/core.dart", count), vim.log.levels.INFO)
  else
    vim.notify("FlutterCore: " .. (err or "gagal"), vim.log.levels.ERROR)
  end
end

-- ════════════════════════════════════════════════════════════════════════════
-- 2. CREATE MODULE  (:FlutterModule)
-- Port dari mvc_module_generator.js -> customModule() + call().
-- Baca template teks di <root>/.vscode/templates/<name>, parse blok
-- `@@@ filepath` .. `---`, ganti placeholder, tulis file.
-- ════════════════════════════════════════════════════════════════════════════

-- Ganti placeholder standar Flutter Hyper pada isi template.
local function apply_placeholders(text, module_name, pkg)
  text = text:gsub("hyper_example", to_key_name(module_name))
  text = text:gsub("HyperExample", to_class_name(module_name))
  text = text:gsub("Hyper Example", to_word_case(module_name))
  text = text:gsub("hyperExample", to_camel_case(module_name))
  if pkg then
    text = text:gsub("hyper_ui", pkg)
    text = text:gsub("hyper_supabase", pkg)
  end
  return text
end

-- Daftar template yang tersedia = nama file (tanpa ekstensi) di .vscode/templates
local function list_templates(root)
  local dir = root .. "/.vscode/templates"
  local names = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then
    return names
  end
  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    -- extension pakai file tanpa titik (bukan .json / .txt)
    if typ == "file" and not name:find(".", 1, true) then
      table.insert(names, name)
    end
  end
  table.sort(names)
  return names
end

-- Proses satu template terpilih dengan module_name yang sudah diinput.
local function build_module(root, template_name, module_name, pkg)
  local template_path = root .. "/.vscode/templates/" .. template_name
  local content = read_file(template_path)
  if not content then
    vim.notify("FlutterModule: template tidak terbaca: " .. template_path, vim.log.levels.ERROR)
    return
  end
  -- normalisasi CRLF -> LF (template asli extension pakai \r\n)
  content = content:gsub("\r\n", "\n"):gsub("\r", "")

  local override = content:find("%%override") ~= nil

  -- moduleName bisa "path/name"
  local module_path, mod_name
  if module_name:find("/") then
    local parts = vim.split(module_name, "/")
    mod_name = parts[#parts]
    table.remove(parts, #parts)
    module_path = table.concat(parts, "/")
  else
    mod_name = module_name
  end

  if mod_name ~= mod_name:lower() then
    vim.notify("FlutterModule: nama modul harus lowercase (mis: product_category)", vim.log.levels.WARN)
    return
  end

  -- Parse blok @@@ path .. isi .. ---
  local templates = {}
  local start = false
  local file_path, buf = "", ""
  for _, line in ipairs(vim.split(content, "\n")) do
    if line:sub(1, 3) == "@@@" then
      file_path = vim.trim(line:sub(4))
      if module_path then
        file_path = file_path:gsub("hyper_example", module_path .. "/hyper_example", 1)
      end
      file_path = file_path:gsub("hyper_example", mod_name)
      file_path = root .. "/" .. file_path
      buf = ""
      start = true
    elseif line:sub(1, 3) == "---" then
      table.insert(templates, { path = file_path, text = buf })
      start = false
      buf = ""
    elseif start then
      buf = buf .. line .. "\n"
    end
  end

  if #templates == 0 then
    vim.notify("FlutterModule: template kosong / format salah (butuh @@@ path .. ---)", vim.log.levels.WARN)
    return
  end

  local written = {}
  for _, t in ipairs(templates) do
    local final = apply_placeholders(t.text, mod_name, pkg)
    if not override and vim.fn.filereadable(t.path) == 1 then
      vim.notify("FlutterModule: file sudah ada: " .. t.path, vim.log.levels.ERROR)
      return
    end
    if write_file(t.path, final) then
      table.insert(written, t.path)
    end
  end

  -- Regenerate lib/core.dart supaya file module baru otomatis ter-export
  -- (meniru CoreGenerator.generate() di akhir MVCModuleGenerator.call()).
  local core_count, core_err = build_core(root)
  if core_count then
    vim.notify(
      string.format("FlutterModule: %d file dibuat untuk '%s' + core.dart di-update (%d export)", #written, mod_name, core_count),
      vim.log.levels.INFO
    )
  else
    vim.notify(
      string.format("FlutterModule: %d file dibuat untuk '%s' (core.dart GAGAL di-update: %s)", #written, mod_name, core_err or "?"),
      vim.log.levels.WARN
    )
  end

  if written[1] then
    vim.cmd("edit " .. vim.fn.fnameescape(written[1]))
  end
end

-- diekspos untuk keperluan test/otomasi (dipakai internal oleh generate_module).
M._build_module = build_module

function M.generate_module()
  local root = project_root()
  local names = list_templates(root)
  if #names == 0 then
    vim.notify(
      "FlutterModule: tidak ada template di .vscode/templates/ (buat file berisi blok @@@ path .. ---)",
      vim.log.levels.WARN
    )
    return
  end

  local function pick(template_name)
    vim.ui.input({ prompt = "Nama modul (lowercase, boleh path/name): " }, function(module_name)
      if not module_name or module_name == "" then
        return
      end
      build_module(root, template_name, module_name, package_name(root))
    end)
  end

  if #names == 1 then
    pick(names[1])
  else
    vim.ui.select(names, { prompt = "Pilih template" }, function(choice)
      if choice then
        pick(choice)
      end
    end)
  end
end


-- ════════════════════════════════════════════════════════════════════════════
-- 3. UDF - User Defined Snippet  (:FlutterUdf)
-- Port dari user_defined_snippet.js -> runSnippetGenerator().
-- Scan lib/, cari blok `//#TEMPLATE <prefix>` .. `//#END`, ganti xcursor1/2 -> $1/$2,
-- tulis snippet VS Code-format ke <root>/.vscode/flutter_udf.code-snippets, lalu
-- load ke LuaSnip (project sudah pakai loader from_vscode).
-- ════════════════════════════════════════════════════════════════════════════

function M.generate_udf()
  local root = project_root()
  local lib = root .. "/lib"
  if vim.fn.isdirectory(lib) == 0 then
    vim.notify("FlutterUdf: folder lib/ tidak ditemukan", vim.log.levels.ERROR)
    return
  end

  local files = read_files_recursive(lib)
  local snippets = {} -- prefix -> body(lines)
  local count = 0

  for _, file in ipairs(files) do
    local content = read_file(file)
    if content then
      local prefix = ""
      local body = {}
      local record = false
      for _, raw in ipairs(vim.split(content, "\n")) do
        local line = vim.trim(raw)
        if line:find("#TEMPLATE", 1, true) then
          -- format: //#TEMPLATE <prefix>
          prefix = line:match("#TEMPLATE%s+(%S+)") or ""
          body = {}
          record = true
        elseif line:find("#END", 1, true) then
          if prefix ~= "" then
            local snippet_body = table.concat(body, "\n")
            -- xcursor1 -> $1, xcursor2 -> $2
            for j = 1, 2 do
              snippet_body = snippet_body:gsub("xcursor" .. j, "$" .. j)
            end
            snippets[prefix] = {
              prefix = prefix,
              -- VS Code snippet body = array of lines
              body = vim.split(snippet_body, "\n"),
            }
            count = count + 1
          end
          prefix = ""
          record = false
        elseif record then
          table.insert(body, raw)
        end
      end
    end
  end

  if count == 0 then
    vim.notify(
      "FlutterUdf: tidak ada blok //#TEMPLATE <prefix> .. //#END di lib/",
      vim.log.levels.WARN
    )
    return
  end

  local out_path = root .. "/.vscode/flutter_udf.code-snippets"
  local ok, json = pcall(vim.json.encode, snippets)
  if not ok then
    vim.notify("FlutterUdf: gagal encode snippet json", vim.log.levels.ERROR)
    return
  end
  if not write_file(out_path, json) then
    vim.notify("FlutterUdf: gagal menulis " .. out_path, vim.log.levels.ERROR)
    return
  end

  -- Load ke LuaSnip agar langsung terpakai di session ini (dart).
  local ls_ok, from_vscode = pcall(require, "luasnip.loaders.from_vscode")
  if ls_ok then
    pcall(from_vscode.load_standalone, { path = out_path })
  end

  vim.notify(
    string.format("FlutterUdf: %d snippet -> .vscode/flutter_udf.code-snippets", count),
    vim.log.levels.INFO
  )
end

-- ── registrasi user commands (idempotent) ───────────────────────────────────
function M.setup()
  vim.api.nvim_create_user_command("FlutterCore", M.generate_core, {
    desc = "Flutter Hyper: generate lib/core.dart (export semua .dart)",
  })
  vim.api.nvim_create_user_command("FlutterModule", M.generate_module, {
    desc = "Flutter Hyper: scaffold module dari .vscode/templates",
  })
  vim.api.nvim_create_user_command("FlutterUdf", M.generate_udf, {
    desc = "Flutter Hyper: generate snippet dari blok //#TEMPLATE di lib/",
  })
end

return M


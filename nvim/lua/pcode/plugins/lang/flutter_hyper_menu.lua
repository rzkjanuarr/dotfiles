-- ════════════════════════════════════════════════════════════════════════════
-- Flutter Hyper — Menu terpusat (port fitur denyocr.flutter-hyper-extension)
-- Satu popup (vim.ui.select via dressing) berisi semua fitur:
--   Generator (Core/Module/UDF) · Wrap widget · Remove · Permission · Open file
-- Command: :FlutterHyper   |  keymap: <leader>fh
-- ════════════════════════════════════════════════════════════════════════════
local M = {}

local gen = require("pcode.plugins.lang.flutter_hyper_gen")

-- ── util root/pubspec ───────────────────────────────────────────────────────
local function project_root()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then dir = vim.fn.getcwd() end
  local found = vim.fs.find({ "pubspec.yaml" }, { upward = true, path = dir })[1]
  if found then return vim.fn.fnamemodify(found, ":h") end
  return vim.fn.getcwd()
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Flutter Hyper" })
end

-- ════════════════════════════════════════════════════════════════════════════
-- WRAP WIDGET  (port get_widget.js + create_snippet.js)
-- ════════════════════════════════════════════════════════════════════════════

-- Port getWidget(): start,end (0-based byte offset) + content. line_index 0-based.
local function get_widget(text, line_index)
  local lines = vim.split(text, "\n", { plain = true })
  if line_index < 0 or line_index >= #lines then return nil end

  local function line_start(idx)
    local s = 0
    for i = 1, idx do s = s + #lines[i] + 1 end
    return s
  end

  local line_start_index = line_start(line_index)
  local cur_line = lines[line_index + 1]
  local paren_rel = cur_line:find("%(")
  if not paren_rel then return nil end
  local open_tag_index = line_start_index + (paren_rel - 1) -- 0-based

  local value = 1
  local end_index = nil
  for i = open_tag_index + 1, #text - 1 do
    local ch = text:sub(i + 1, i + 1)
    if ch == "(" then value = value + 1 end
    if ch == ")" then value = value - 1 end
    if value == 0 then end_index = i; break end
  end
  if not end_index then return nil end

  local start_index = open_tag_index
  local space_before, colon_before = -1, -1
  for i = start_index - 1, line_start_index, -1 do
    local ch = text:sub(i + 1, i + 1)
    if ch == " " then space_before = i; break end
    if ch == ":" then colon_before = i; break end
  end
  if space_before ~= -1 then
    start_index = space_before + 1
  elseif colon_before ~= -1 then
    start_index = colon_before + 1
  else
    start_index = line_start_index
  end

  end_index = end_index + 1
  if end_index < start_index then return nil end
  local content = text:sub(start_index + 1, end_index)
  return start_index, end_index, content
end

-- offset byte (0-based) -> (row,col) 0-based untuk nvim_buf_set_text.
local function offset_to_pos(text, offset)
  local row, count = 0, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    local len = #line + 1
    if count + len > offset then
      return row, offset - count
    end
    count = count + len
    row = row + 1
  end
  return row, 0
end

-- Bungkus widget di kursor dengan template (mengandung @CONTENT).
local function wrap_with(template)
  local buf = 0
  if vim.bo[buf].filetype ~= "dart" then
    notify("Wrap: hanya untuk file .dart", vim.log.levels.WARN)
    return
  end
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local line_index = vim.api.nvim_win_get_cursor(0)[1] - 1

  local s, e, content = get_widget(text, line_index)
  if not s then
    notify("Wrap: widget `Name(...)` tak ditemukan di baris kursor", vim.log.levels.WARN)
    return
  end

  -- buang newline/indentasi pembuka dari long-bracket template (biar rapi)
  template = template:gsub("^%s*\n", "")
  local new_content = template:gsub("@CONTENT", (content:gsub("%%", "%%%%")))
  local sr, sc = offset_to_pos(text, s)
  local er, ec = offset_to_pos(text, e)
  local repl = vim.split(new_content, "\n", { plain = true })
  vim.api.nvim_buf_set_text(buf, sr, sc, er, ec, repl)
  pcall(vim.lsp.buf.format, { async = false, timeout_ms = 3000 })
end

M._get_widget = get_widget -- untuk test


-- Template wrap (port extension_list.js). @CONTENT = widget asal.
local WRAPS_ORDER = {
  "Container", "Center", "Padding", "Expanded",
  "Row", "Column", "Wrap",
  "InkWell",
  "SingleChildScrollView",
  "SingleChildScrollView (Horizontal)",
  "ListView.builder",
  "ListView.builder (Horizontal)",
  "Dismissible",
  "Obx (GetX)",
  "StreamBuilder (Document / Firestore)",
  "StreamBuilder (List / Firestore)",
  "StreamBuilder (List Horizontal / Firestore)",
  "Wrap ListView in StreamBuilder (List)",
}
local WRAPS = {
  -- ── single-line (atribut siap pakai, persis hyper) ──
  ["Container"] = "Container(\nchild:@CONTENT\n,)",
  ["Center"] = "Center(\nchild:@CONTENT\n,)",
  ["Padding"] = "Padding(\npadding: EdgeInsets.all(8.0),child:@CONTENT,)",
  ["Expanded"] = "Expanded(\nchild:@CONTENT\n,)",
  ["Row"] = "Row(crossAxisAlignment: CrossAxisAlignment.start,children: [@CONTENT],)",
  ["Column"] = "Column(crossAxisAlignment: CrossAxisAlignment.start,children: [@CONTENT],)",
  ["Wrap"] = "Wrap(runSpacing: 10, spacing: 10, children: [@CONTENT],)",
  ["InkWell"] = "InkWell(\nonTap: (){},\nchild:@CONTENT,)",
  ["SingleChildScrollView"] = "SingleChildScrollView(\ncontroller: ScrollController(),\nchild:@CONTENT\n,)",

  -- ── multiline (atribut lengkap, persis hyper) ──
  ["SingleChildScrollView (Horizontal)"] = [[
SingleChildScrollView(
    controller: ScrollController(),
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(10,(index) {
        return @CONTENT;
      }),
    ),
)]],
  ["ListView.builder"] = [[
ListView.builder(
    itemCount: 10,
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    clipBehavior: Clip.none,
    itemBuilder: (context, index) {
        var item = {};
        return @CONTENT;
    },
)]],
  ["ListView.builder (Horizontal)"] = [[
SizedBox(
    height: 80.0,
    child: ListView.builder(
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
            return @CONTENT;
        },
    ),
)]],
  ["Dismissible"] = [[
Dismissible(
    key: UniqueKey(),
    onDismissed: (detail) {

    },
    confirmDismiss: (direction) async {
      bool confirm = false;
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Are you sure you want to delete this item?'),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  confirm = true;
                  Navigator.pop(context);
                },
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );

      if (confirm) {
        return Future.value(true);
      }
      return Future.value(false);
    },
    child: @CONTENT,
  )]],
  ["Obx (GetX)"] = [[
Obx((){
    return @CONTENT;
})]],
  ["StreamBuilder (Document / Firestore)"] = [[
StreamBuilder<DocumentSnapshot<Object?>>(
    stream: FirebaseFirestore.instance
        .collection("products")
        .doc("10001")
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Text("Error");
      if (!snapshot.hasData) return const Text("No Data");
      Map<String,dynamic> item = (snapshot.data!.data() as Map<String,dynamic>);
      item["id"] = snapshot.data!.id;

      return @CONTENT;},)]],
  ["StreamBuilder (List / Firestore)"] = [[
StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("products")
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Text("Error");
      if(snapshot.data == null) return Container();
      if (snapshot.data!.docs.isEmpty) {
        return const Text("No Data");
      }

      final data = snapshot.data!;
      return ListView.builder(
        itemCount: data.docs.length,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          Map<String,dynamic> item = (data.docs[index].data() as Map<String,dynamic>);
          item["id"] = data.docs[index].id;

          return @CONTENT;},);},)]],
  ["StreamBuilder (List Horizontal / Firestore)"] = [[
StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("products")
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Text("Error");
      if(snapshot.data == null) return Container();
      if (snapshot.data!.docs.isEmpty) {
        return const Text("No Data");
      }

      final data = snapshot.data!;
      return SizedBox(
        height: 140.0,
        child: ListView.builder(
            itemCount: data.docs.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              Map<String,dynamic> item = (data.docs[index].data() as Map<String,dynamic>);
              item["id"] = data.docs[index].id;
              return @CONTENT;
            },
        ),
      );
    },)]],
  ["Wrap ListView in StreamBuilder (List)"] = [[
StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("products")
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Text("Error");
      if(snapshot.data == null) return Container();
      if (snapshot.data!.docs.isEmpty) {
        return const Text("No Data");
      }
      final data = snapshot.data!;
      return @CONTENT;},)]],
}

-- Wrap builder otomatis sesuai state management (port snippet_wrapper.js).
local function wrap_builder_auto()
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local template
  if text:find("flutter_bloc", 1, true) or text:find("Cubit", 1, true) then
    template = "BlocSelector<YourBloc, YourState, YourType>(\n  selector: (state) => state.yourState,\n  builder: (context, value) {\n    return @CONTENT;\n  },\n)"
  elseif text:find("Getx", 1, true) or text:find("GetX", 1, true) then
    template = "Obx(() {\n  return @CONTENT;\n})"
  else
    template = "ValueListenableBuilder(\n  valueListenable: state.counter,\n  builder: (context, __, _) {\n    return @CONTENT;\n  },\n)"
  end
  wrap_with(template)
end



-- ════════════════════════════════════════════════════════════════════════════
-- REMOVE / UNWRAP  (port remove_widget, remove_constants, comment_remover)
-- ════════════════════════════════════════════════════════════════════════════

-- Ambil isi `child:`/`children:` dari sebuah widget content (bracket-aware).
-- Port extractChildFromWidget (create_snippet.js).
local function extract_child(content)
  local key_pos
  local ci = content:find("child:", 1, true)
  local cs = content:find("children:", 1, true)
  if cs and (not ci or cs < ci) then
    key_pos = cs + #"children:"
  elseif ci then
    key_pos = ci + #"child:"
  else
    return nil
  end
  -- skip spasi
  while content:sub(key_pos, key_pos):match("%s") do key_pos = key_pos + 1 end
  -- children:[ ... ] → buang kurung siku bila list
  local is_list = content:sub(key_pos, key_pos) == "["
  local value_start = is_list and key_pos + 1 or key_pos
  local depth = 1
  for i = value_start, #content do
    local ch = content:sub(i, i)
    if ch == "(" or ch == "[" or ch == "{" then depth = depth + 1 end
    if ch == ")" or ch == "]" or ch == "}" then depth = depth - 1 end
    if depth == 1 and ch == "," then
      return vim.trim(content:sub(value_start, i - 1))
    end
    if depth == 0 then
      return vim.trim(content:sub(value_start, i - 1))
    end
  end
  return nil
end

-- Unwrap: ganti widget di kursor dengan child-nya (port advRemoveWidget).
local function remove_widget()
  local buf = 0
  if vim.bo[buf].filetype ~= "dart" then
    notify("Remove Widget: hanya untuk .dart", vim.log.levels.WARN); return
  end
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local line_index = vim.api.nvim_win_get_cursor(0)[1] - 1
  local s, e, content = get_widget(text, line_index)
  if not s then notify("Remove: widget tak ditemukan di baris kursor", vim.log.levels.WARN); return end
  local child = extract_child(content)
  if not child then notify("Remove: widget ini tak punya child untuk diangkat", vim.log.levels.WARN); return end
  local sr, sc = offset_to_pos(text, s)
  local er, ec = offset_to_pos(text, e)
  vim.api.nvim_buf_set_text(buf, sr, sc, er, ec, vim.split(child, "\n", { plain = true }))
  pcall(vim.lsp.buf.format, { async = false, timeout_ms = 3000 })
end

-- Hapus `const` (port remove_constants.js).
local function remove_constants()
  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, l in ipairs(lines) do
    for _ = 1, 3 do
      l = l:gsub(" const %[", " ["):gsub(" const%[", " ["):gsub("%(const ", "( "):gsub(" const ", " ")
    end
    lines[i] = l
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  notify("Removed `const`")
end

-- Hapus komentar (port comment_remover.js). Dart: // dan /* */ ; yaml: #
local function comment_remover()
  local buf = 0
  local ft = vim.bo[buf].filetype
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  if ft == "dart" then
    text = text:gsub("/%*.-%*/", "")
    text = text:gsub("([^:\\])//[^\n]*", "%1"):gsub("^//[^\n]*", "")
  elseif ft == "yaml" then
    text = text:gsub("#[^\n]*", "")
  else
    notify("Remove Comments: filetype tak didukung", vim.log.levels.WARN); return
  end
  local out = {}
  for _, l in ipairs(vim.split(text, "\n", { plain = true })) do
    if vim.trim(l) ~= "" then out[#out + 1] = l end
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
  notify("Removed comments")
end

-- ════════════════════════════════════════════════════════════════════════════
-- ANDROID PERMISSION  (port android_manifest_editor.js + fsx.addPermission)
-- Sisip <uses-permission android:name="android.permission.NAME" /> sebelum <application>.
-- ════════════════════════════════════════════════════════════════════════════

-- Daftar izin Android umum (bukan cuma satu).
local PERMISSIONS = {
  "INTERNET",
  "ACCESS_NETWORK_STATE",
  "ACCESS_WIFI_STATE",
  "CAMERA",
  "RECORD_AUDIO",
  "READ_EXTERNAL_STORAGE",
  "WRITE_EXTERNAL_STORAGE",
  "READ_MEDIA_IMAGES",
  "READ_MEDIA_VIDEO",
  "READ_MEDIA_AUDIO",
  "ACCESS_FINE_LOCATION",
  "ACCESS_COARSE_LOCATION",
  "ACCESS_BACKGROUND_LOCATION",
  "BLUETOOTH",
  "BLUETOOTH_SCAN",
  "BLUETOOTH_CONNECT",
  "READ_CONTACTS",
  "WRITE_CONTACTS",
  "CALL_PHONE",
  "READ_PHONE_STATE",
  "SEND_SMS",
  "RECEIVE_SMS",
  "READ_SMS",
  "VIBRATE",
  "WAKE_LOCK",
  "FOREGROUND_SERVICE",
  "POST_NOTIFICATIONS",
  "RECEIVE_BOOT_COMPLETED",
  "USE_BIOMETRIC",
  "USE_FINGERPRINT",
  "REQUEST_INSTALL_PACKAGES",
  "MANAGE_EXTERNAL_STORAGE",
}

-- Set default (port runDefaultAndroidManifestPermissions).
local PERMISSIONS_DEFAULT = {
  "INTERNET", "READ_EXTERNAL_STORAGE", "WRITE_EXTERNAL_STORAGE",
  "ACCESS_BACKGROUND_LOCATION", "ACCESS_FINE_LOCATION", "ACCESS_COARSE_LOCATION",
}

local function manifest_path(root)
  return root .. "/android/app/src/main/AndroidManifest.xml"
end

-- Sisip satu izin bila belum ada. Return true jika ditambahkan.
local function add_permission_to_content(content, name)
  if content:find('android:name="android.permission.' .. name, 1, true) then
    return content, false
  end
  local line = '    <uses-permission android:name="android.permission.' .. name .. '" />\n'
  local new = content:gsub("(%s*)<application", "\n" .. line .. "%1<application", 1)
  return new, true
end

local function add_permissions(names)
  local root = project_root()
  local path = manifest_path(root)
  if vim.fn.filereadable(path) == 0 then
    notify("AndroidManifest.xml tidak ditemukan:\n" .. path, vim.log.levels.ERROR)
    return
  end
  local content = table.concat(vim.fn.readfile(path), "\n")
  local added = {}
  for _, name in ipairs(names) do
    local new, ok = add_permission_to_content(content, name)
    content = new
    if ok then added[#added + 1] = name end
  end
  vim.fn.writefile(vim.split(content, "\n", { plain = true }), path)
  if #added == 0 then
    notify("Semua izin sudah ada, tak ada perubahan.")
  else
    notify("Ditambahkan " .. #added .. " izin:\n" .. table.concat(added, ", "))
  end
  -- reload buffer manifest bila terbuka
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(b) == path then
      vim.api.nvim_buf_call(b, function() vim.cmd("edit!") end)
    end
  end
end

local function permission_menu()
  local items = { "★ Add Default Set (Internet/Storage/Location)", "✎ Manual (ketik nama izin)" }
  for _, p in ipairs(PERMISSIONS) do items[#items + 1] = p end
  vim.ui.select(items, { prompt = "Android Permission" }, function(choice)
    if not choice then return end
    if choice:find("Default Set", 1, true) then
      add_permissions(PERMISSIONS_DEFAULT)
    elseif choice:find("Manual", 1, true) then
      vim.ui.input({ prompt = "Nama izin (mis. CAMERA): " }, function(input)
        if input and vim.trim(input) ~= "" then
          add_permissions({ vim.trim(input):upper() })
        end
      end)
    else
      add_permissions({ choice })
    end
  end)
end


-- ════════════════════════════════════════════════════════════════════════════
-- OPEN FILE  (port openPubspec/openMainDart/openAndroidManifest/openBuildGradle…)
-- ════════════════════════════════════════════════════════════════════════════

local function open_path(rel, root)
  root = root or project_root()
  local path = root .. "/" .. rel
  if vim.fn.filereadable(path) == 0 then
    notify("File tak ditemukan:\n" .. path, vim.log.levels.WARN)
    return
  end
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

local OPEN_TARGETS = {
  { "pubspec.yaml", "pubspec.yaml" },
  { "main.dart", "lib/main.dart" },
  { "core.dart", "lib/core.dart" },
  { "AndroidManifest.xml", "android/app/src/main/AndroidManifest.xml" },
  { "build.gradle (app)", "android/app/build.gradle" },
  { "build.gradle (app kts)", "android/app/build.gradle.kts" },
  { "build.gradle (android)", "android/build.gradle" },
  { "build.gradle (android kts)", "android/build.gradle.kts" },
  { "settings.gradle", "android/settings.gradle" },
  { "gradle.properties", "android/gradle.properties" },
  { "Info.plist (iOS)", "ios/Runner/Info.plist" },
  { "analysis_options.yaml", "analysis_options.yaml" },
  { ".gitignore", ".gitignore" },
  { "README.md", "README.md" },
}

local function open_menu()
  local root = project_root()
  local labels = {}
  for _, t in ipairs(OPEN_TARGETS) do labels[#labels + 1] = t[1] end
  vim.ui.select(labels, { prompt = "Open File" }, function(choice, idx)
    if not choice then return end
    open_path(OPEN_TARGETS[idx][2], root)
  end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- WRAP MENU (submenu semua wrap + builder auto + unwrap)
-- ════════════════════════════════════════════════════════════════════════════
local function wrap_menu()
  local items = { "Builder (auto: Bloc/GetX/ValueListenable)" }
  for _, name in ipairs(WRAPS_ORDER) do items[#items + 1] = name end
  items[#items + 1] = "Remove / Unwrap Widget"
  vim.ui.select(items, { prompt = "Wrap Widget" }, function(choice)
    if not choice then return end
    if choice:find("^Builder %(auto") then
      wrap_builder_auto()
    elseif choice == "Remove / Unwrap Widget" then
      remove_widget()
    elseif WRAPS[choice] then
      wrap_with(WRAPS[choice])
    end
  end)
end



-- ════════════════════════════════════════════════════════════════════════════
-- MAIN MENU  (:FlutterHyper / <leader>fh)
-- ════════════════════════════════════════════════════════════════════════════

-- item = { label, action }. Separator dilewati saat dipilih.
local function main_menu()
  local items = {
    { "── Generator ──", nil },
    { "  Generate Core (lib/core.dart)", function() gen.generate_core() end },
    { "  Generate Module (dari template)", function() gen.generate_module() end },
    { "  Generate UDF Snippet", function() gen.generate_udf() end },
    { "── Widget ──", nil },
    { "  Wrap Widget…", wrap_menu },
    { "  Remove / Unwrap Widget", remove_widget },
    { "── Refactor ──", nil },
    { "  Remove `const`", remove_constants },
    { "  Remove Comments", comment_remover },
    { "── Android ──", nil },
    { "  Add Permission…", permission_menu },
    { "── Open File ──", nil },
    { "  Open File…", open_menu },
  }

  local labels = {}
  for _, it in ipairs(items) do labels[#labels + 1] = it[1] end

  vim.ui.select(labels, {
    prompt = "Flutter Hyper",
    format_item = function(x) return x end,
  }, function(_, idx)
    if not idx then return end
    local action = items[idx][2]
    if action then
      -- defer agar popup pertama benar-benar tertutup sebelum submenu/edit
      vim.schedule(action)
    else
      -- separator dipilih -> buka lagi menu
      vim.schedule(main_menu)
    end
  end)
end

M.main_menu = main_menu
M.wrap_menu = wrap_menu
M.open_menu = open_menu
M.permission_menu = permission_menu

-- test helpers (headless)
M._wrap_with = wrap_with
M._remove_widget = remove_widget
M._extract_child = extract_child
M._add_permission_to_content = add_permission_to_content

function M.setup()
  vim.api.nvim_create_user_command("FlutterHyper", main_menu, {
    desc = "Flutter Hyper: menu terpusat semua fitur",
  })
  vim.api.nvim_create_user_command("FlutterPermission", permission_menu, {
    desc = "Flutter Hyper: tambah Android permission",
  })
  vim.api.nvim_create_user_command("FlutterWrap", wrap_menu, {
    desc = "Flutter Hyper: wrap widget",
  })
  vim.api.nvim_create_user_command("FlutterOpen", open_menu, {
    desc = "Flutter Hyper: buka file project",
  })
end

return M

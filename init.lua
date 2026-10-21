-- lazy.nvim の自動ブートストラップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグインの読み込み (lua/plugins.lua を読み込む)
require("lazy").setup("plugins")

vim.g.python3_host_prog = vim.env.HOME .. '\\.vim\\nvim\\Scripts\\python.exe'

vim.o.fileencodings = 'utf-8,cp932,utf-16le,euc-jp'

-- タブラインの設定
vim.o.showtabline = 1

-- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.o.ignorecase = true
-- 大文字が含まれる場合にのみ厳密に区別
vim.o.smartcase = true

-- Tab の表示設定
vim.wo.list = true
vim.wo.listchars = 'tab:>-'

-- diffオプションの設定
vim.opt.diffopt:append({
  "iwhite",             -- 空白文字（スペースやタブ）の違いを無視
  "algorithm:patience", -- より直感的に差分を抽出するアルゴリズムを使用
  "linematch:60",       -- 改行・空白位置がずれても類似行を賢くマッチング（Neovim v0.9+）
})

local keymap = vim.keymap.set
local option_noremap = { noremap = true, silent = true }

-- <ESC>x2 で検索ハイライトを無効化
keymap('n', '<ESC><ESC>', ':<C-u>nohlsearch<CR>', option_noremap)

-- Ctrl + q でターミナルを終了
keymap('t', '<C-q>', '<C-\\><C-n>:bw!<CR>', option_noremap)
-- ESCでターミナルモードからノーマルモードへ
keymap('t', '<ESC>', '<C-\\><C-n>', option_noremap)

-- ターミナルモード中に <C-r>+ でクリップボードから貼り付け
keymap('t', '<C-r>+', function()
  local clipboard = vim.fn.getreg('+')
  vim.api.nvim_chan_send(vim.b.terminal_job_id, clipboard)
end, option_noremap)
-- <C-r>* も
keymap('t', '<C-r>*', function()
  local clipboard = vim.fn.getreg('*')
  vim.api.nvim_chan_send(vim.b.terminal_job_id, clipboard)
end, option_noremap)

-- クリップボードの改行を指定文字で結合して返す共通関数
local function get_joined_clipboard()
  -- 連結に使う1文字をユーザーに入力させる
  local ok, char_code = pcall(vim.fn.getchar)
  if not ok or type(char_code) ~= "number" then
    return ""
  end

  -- 特殊キー（Escなど）が押された場合は中断
  local delimiter = vim.fn.nr2char(char_code)
  if delimiter == "\27" then -- \27 は Esc キー
    return ""
  end

  local text = vim.fn.getreg('+')
  -- 改行（\r\n や \n）を指定した区切り文字に置換
  return text:gsub('\r?\n', delimiter)
end

-- コマンドラインモード・インサートモードへの割り当て (expr = true)
keymap({ 'c', 'i' }, '<C-r>j', get_joined_clipboard, {
  expr = true,
  noremap = true,
  silent = false,
  desc = "Paste clipboard joined with typed character",
})

-- ターミナルモードへの割り当て (キー送信で挿入)
keymap('t', '<C-r>j', function()
  local joined = get_joined_clipboard()
  if joined ~= "" then
    -- ターミナルにテキストをそのまま送る
    vim.api.nvim_chan_send(vim.b.terminal_job_id, joined)
  end
end, { noremap = true, silent = false, desc = "Paste clipboard joined with typed character in terminal" })

-- ,cm で :messages の内容をクリップボードにコピーして通知
keymap("n", ",cm", function()
  local msgs = vim.fn.execute("messages")
  vim.fn.setreg("+", msgs)
  vim.notify("Copied :messages to clipboard!")
end, { desc = "Copy :messages to clipboard" })

-- 日付/時刻を展開
vim.cmd([[
" 基本形
noremap! <expr> <C-d>d strftime('%Y%m%d')
noremap! <expr> <C-d>t strftime('%H%M%S')
" セパレーター指定
noremap! <expr> <C-d>d- strftime('%Y-%m-%d')
noremap! <expr> <C-d>d. strftime('%Y.%m.%d')
noremap! <expr> <C-d>d/ strftime('%Y/%m/%d')
noremap! <expr> <C-d>t: strftime('%H:%M:%S')
" 会話
noremap! <expr> <C-d>dt: strftime('%b/%d %H:%M')
]])

-- 対象にしたい言語のリスト
local target_ft = { "c", "cpp", "cs", "javascript", "typescript", "java", "go", "rust" }

-- 設定したい共通クエリの中身
local query_content = [[
;;; extends

(unary_expression
  "!" @attribute.negation)

(unary_expression
  operator: "!" @attribute.negation)
]]

-- after/queries/ 以下の各フォルダへ自動配置する処理
local queries_base = vim.fn.stdpath("config") .. "/after/queries/"

for _, ft in ipairs(target_ft) do
  local dir = queries_base .. ft
  local filepath = dir .. "/highlights.scm"

  -- フォルダが存在しない場合は作成
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  -- ファイルが存在しない場合のみ作成（既存設定を壊さない）
  if vim.fn.filereadable(filepath) == 0 then
    local f = io.open(filepath, "w")
    if f then
      f:write(query_content)
      f:close()
    end
  end
end

vim.cmd([[
if has('win32') || has ('win64')
  " 関連付け実行
  nmap ,exe :!start cmd.exe /C start <cfile><CR>

  " カレントディレクトリをエクスプローラーで開く
  nmap ,ode :call OpenDirectoryExplorer("%:p:h")<CR>
  function! OpenDirectoryExplorer(dir)
    let save_ss = &shellslash
    set noshellslash
    silent execute('!start explorer.exe "' . a:dir . '"')
    let &shellslash = save_ss
  endfunction

  " 全角解除
  autocmd InsertLeave * :call DisableIME()
  function! DisableIME() abort
    call system('zenhan.exe 0')
  endfunction
else
  " Windows Subsystem for Linux で、ヤンクでクリップボードにコピー
  if system('uname -a | grep -i microsoft') != ''
    augroup myYank
      autocmd!
      autocmd TextYankPost * :call system('clip.exe', @")
    augroup END
  endif
endif
]])

-- 差分表示を解除してカレントバッファのみにする
vim.api.nvim_create_user_command("DiffOffOnly", "diffoff | only", { desc = "Turn off diff and keep current window" })
vim.keymap.set("n", ",doo", "<cmd>DiffOffOnly<CR>", { silent = true })

-- シングルクォートをダブルクォートに変換
vim.api.nvim_create_user_command("ToDoubleQuote", function()
  vim.cmd("s/'/\"/g")
  vim.cmd("nohlsearch")
end, { desc = "Convert single quotes to double quotes" })
vim.keymap.set("n", ",todq", "<cmd>ToDoubleQuote<CR>", { silent = true })

-- ダブルクォートをシングルクォートに変換
vim.api.nvim_create_user_command("ToSingleQuote", function()
  vim.cmd('s/"/\'/g')
  vim.cmd("nohlsearch")
end, { desc = "Convert double quotes to single quotes" })
vim.keymap.set("n", ",tosq", "<cmd>ToSingleQuote<CR>", { silent = true })

-- バックスラッシュをスラッシュに変換
vim.api.nvim_create_user_command("ToSlash", function()
  vim.cmd([[s/\\/\//g]])
  vim.cmd("nohlsearch")
end, { desc = "Convert backslashes to slashes" })
vim.keymap.set("n", ",tosl", "<cmd>ToSlash<CR>", { silent = true })

-- スラッシュをバックスラッシュに変換
vim.api.nvim_create_user_command("ToBackSlash", function()
  vim.cmd([[s/\//\\/g]])
  vim.cmd("nohlsearch")
end, { desc = "Convert slashes to backslashes" })
vim.keymap.set("n", ",tobs", "<cmd>ToBackSlash<CR>", { silent = true })

-- バイナリダンプ表示 (xxd)
vim.api.nvim_create_user_command("ToBin", "%!xxd", { desc = "Convert buffer to hex dump" })
vim.api.nvim_create_user_command("ToTxt", "%!xxd -r", { desc = "Restore buffer from hex dump" })

-- メールアドレス加工
vim.api.nvim_create_user_command("SplitMailAddress", function()
  vim.cmd([[s/; */\r/g]])
  vim.cmd("nohlsearch")
end, { desc = "Split mail address list by semicolon" })
vim.keymap.set("n", ",ms", "<cmd>SplitMailAddress<CR>", { silent = true })

vim.api.nvim_create_user_command("JoinMailAddress", function(opts)
  vim.cmd(string.format("%d,%ds/\\n/; /g", opts.line1, opts.line2))
  vim.cmd("nohlsearch")
end, { range = true, desc = "Join mail address list with semicolon" })
vim.keymap.set("v", ",mj", ":JoinMailAddress<CR>", { silent = true })

-- PowerShell を新しいタブで開く
vim.api.nvim_create_user_command("PowerShell", "-tabnew | term powershell", { desc = "Open PowerShell in new tab" })
vim.keymap.set("n", ",sh", "<cmd>PowerShell<CR>i", { silent = true })

-- Cmd (Shell) を新しいタブで開く
vim.api.nvim_create_user_command("Shell", "-tabnew | term", { desc = "Open CMD in new tab" })
vim.keymap.set("n", ",cmd", "<cmd>Shell<CR>i", { silent = true })

-- jq による JSON 整形
vim.api.nvim_create_user_command("Jq", function(opts)
  local arg = (opts.args ~= "") and opts.args or "."
  vim.cmd("%!jq " .. arg)
end, { nargs = "?", desc = "Format JSON using jq" })

-- xmllint による XML 整形
vim.api.nvim_create_user_command("XmlLint", function(opts)
  local arg = (opts.args ~= "") and opts.args or "--format --noblanks -"
  vim.cmd("%!xmllint " .. arg)
end, { nargs = "?", desc = "Format XML using xmllint" })
vim.api.nvim_create_user_command("Xl", function(opts)
  vim.cmd("XmlLint " .. opts.args)
end, { nargs = "?", desc = "Alias for XmlLint" })

-- 編集中のファイルのディレクトリに移動
vim.api.nvim_create_user_command("CdCurrent", "cd %:p:h", { desc = "Change directory to current file" })
vim.keymap.set("n", ",cd", "<cmd>CdCurrent<CR>", { silent = true })

-- プロジェクトのルート（.git などがある場所）に自動で cd する設定
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(ctx)
    -- oil.nvim のバッファのときは、ルート検索をスキップする
    if vim.bo[ctx.buf].filetype == "oil" or ctx.file:match("^oil://") then
      return
    end

    -- プロジェクトマーカーを探す
    local root = vim.fs.root(ctx.buf, { ".git", ".svn", ".vscode", "Cargo.toml", "package.json" })
    if root then
      vim.fn.chdir(root)
    end
  end,
})

-- GUIモード（nvim-qtなど）で起動している場合のみ実行
if vim.fn.has('gui_running') == 1 then
  vim.opt.guifont = "PlemolJP Console NF:h16"
end

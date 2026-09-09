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

local option_noremap = { noremap = true, silent = true }

-- local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

-- diffオプションの設定
vim.opt.diffopt:append({
  "iwhite",             -- 空白文字（スペースやタブ）の違いを無視
  "algorithm:patience", -- より直感的に差分を抽出するアルゴリズムを使用
  "linematch:60",       -- 改行・空白位置がずれても類似行を賢くマッチング（Neovim v0.9+）
})

-- インサートモードでカーソル移動
keymap('i', '<C-l>', '<Right>', option_noremap)
keymap('i', '<C-h>', '<Left>' , option_noremap)

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

-- 否定を表す"!"を強調
vim.cmd([[
autocmd ColorScheme * highlight Emphasis ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
autocmd Syntax * syntax match Emphasis /![^ =]/he=e-1
]])

-- <ESC>x2 で検索ハイライトを無効化
keymap('n', '<ESC><ESC>', ':<C-u>nohlsearch<CR>', option_noremap)

-- Ctrl + q でターミナルを終了
keymap('t', '<C-q>', '<C-\\><C-n>:bw!<CR>', option_noremap)
-- ESCでターミナルモードからノーマルモードへ
keymap('t', '<ESC>', '<C-\\><C-n>', option_noremap)

vim.cmd([[
if has('win32') || has ('win64')
	" 関連付け実行
	nmap ,exe :!start cmd.exe /C start <cfile><CR>

	" カレントディレクトリをエクスプローラーで開く
	nmap ,ode :call OpenDirectoryExplorer("%:p:h")<CR>
	function! OpenDirectoryExplorer(dir)
		let save_ss = &shellslash
		set noshellslash
		execute('!start explorer.exe "' . a:dir . '"')
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

-- 差分表示を解除してカレントのみにする
vim.cmd([[
nmap ,doo :DiffOffOnly<CR>
command! DiffOffOnly :diffoff | only
]])

vim.cmd([[
nmap ,todq :ToDoubleQuote<CR>
command! ToDoubleQuote :s/'/\"/g | nohlsearch

nmap ,tosq :ToSingleQuote<CR>
command! ToSingleQuote :s/\"/'/g | nohlsearch

nmap ,tosl :ToSlash<CR>
command! ToSlash :s/\\/\//g | nohlsearch

nmap ,tobs :ToBackSlash<CR>
command! ToBackSlash :s/\//\\/g | nohlsearch

command! ToBin :%!xxd
command! ToTxt :%!xxd -r

" メアド加工
nmap ,ms :SplitMailAddress<CR>
command! SplitMailAddress s/; */\r/g | nohlsearch

vmap ,mj :JoinMailAddress<CR>
command! -range JoinMailAddress <line1>,<line2>s/\n/; /g | nohlsearch
]])

-- Shell(PowerShell)をインサートモードで起動
vim.cmd([[
nmap ,sh :PowerShell<CR>i
command! PowerShell :-tabnew | term powershell
]])

-- Shell(cmd)をインサートモードで起動
vim.cmd([[
nmap ,cmd :Shell<CR>i
command! Shell :-tabnew | term
]])

-- JSON を整形
vim.cmd([[
command! -nargs=? Jq call _Jq(<f-args>)
function! _Jq(...)
	if 0 == a:0
		let l:arg = "."
	else
		let l:arg = a:1
	endif
	execute "%!jq " . l:arg
endfunction
]])

-- XML を整形
vim.cmd([[
command! -nargs=? Xl call _XmlLint(<f-args>)
function! _XmlLint(...)
	if 0 == a:0
		let l:arg = "--format --noblanks -"
	else
		let l:arg = a:1
	endif
	execute "%!xmllint " . l:arg
endfunction
]])

-- 編集中のファイルのディレクトリに移動する
vim.cmd('nmap ,cd :CdCurrent<CR>')
vim.cmd('command! -nargs=0 CdCurrent cd %:p:h')

-- テーマ
vim.cmd('colorscheme wombat')

-- GUIモード（nvim-qtなど）で起動している場合のみ実行
if vim.fn.has('gui_running') == 1 then
	vim.opt.guifont = "PlemolJP Console NF:h16"
end

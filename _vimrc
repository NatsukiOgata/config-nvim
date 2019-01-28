let $PATH="C:\\msys64\\usr\\bin;".$PATH
let g:python3_host_prog = 'C:\msys64\usr\bin\python3.exe'

if &compatible
	set nocompatible
endif

set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

let s:dein_dir = expand('~/.cache/dein')
if dein#load_state(s:dein_dir)
	call dein#begin(s:dein_dir)

	let g:rc_dir    = expand('~/.vim/rc')
	let s:toml      = g:rc_dir . '/dein.toml'
	let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

	call dein#load_toml(s:toml,      {'lazy': 0})
	call dein#load_toml(s:lazy_toml, {'lazy': 1})

	call dein#end()
	call dein#save_state()
endif

if dein#check_install()
	call dein#install()
endif

syntax enable
filetype plugin indent on

set encoding=utf-8

" タブラインの設定
set showtabline=1
 
" バックアップファイルの作成場所
set backupdir=$tmp
" スワップファイルの作成場所はバックアップと同じ
let &directory = &backupdir
 
let &undodir = &backupdir
 
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
 
" インサートモードでカーソル移動
noremap! <C-L> <Right>
noremap! <C-H> <Left>

" 日付/時刻を展開(基本形)
noremap! <expr> <C-d>d strftime('%Y%m%d')
noremap! <expr> <C-d>t strftime('%H%M%S')
" 日付/時刻を展開(セパレーター指定)
noremap! <expr> <C-d>d- strftime('%Y-%m-%d')
noremap! <expr> <C-d>d. strftime('%Y.%m.%d')
noremap! <expr> <C-d>d/ strftime('%Y/%m/%d')
noremap! <expr> <C-d>t: strftime('%H:%M:%S')

" 8進数で扱うのは止める
set nrformats-=octal

" Tab の表示設定
set listchars=tab:>-
set list
 
" Beep 無効
set visualbell
"set vb t_vb=

" 検索結果をハイライトする
set hlsearch

" 全角記号の幅
set ambiwidth=double

" 検索時などで除外する
set wildignore+=.git/**,.svn/**,vendor*/**

" スペルチェックを有効化
set spelllang=en,cjk
"set spell

if has('nvim')
	" 文字列置換をインタラクティブに表示
	set inccommand=split
endif

" 特に入力補完が用意されていない場合の各種キーワードの補完
autocmd FileType *
\   if &l:omnifunc == ''
\ |   setlocal omnifunc=syntaxcomplete#Complete
\ | endif

" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave  * if pumvisible() == 0|pclose|endif

" (C:\Program Files\Git\bin\)bash を起動する
"set shell=bash

"autocmd FileType h,cpp setlocal fileencoding=utf-8
"autocmd FileType h,cpp setlocal nobomb
autocmd FileType h,cpp setlocal noexpandtab
autocmd FileType h,cpp setlocal shiftwidth=4
autocmd FileType h,cpp setlocal tabstop=4

"" PSR-2
"autocmd FileType php setlocal expandtab
"autocmd FileType php setlocal shiftwidth=4
"autocmd FileType php setlocal softtabstop=4
"autocmd FileType php setlocal tabstop=4

" TOPCON Web コーディング規約
autocmd FileType php,javascript,css setlocal fileencoding=utf-8
autocmd FileType php,javascript,css setlocal nobomb
autocmd FileType php,javascript,css setlocal fileformat=unix
autocmd FileType php,javascript,css setlocal noexpandtab
autocmd FileType php,javascript,css setlocal shiftwidth=8
autocmd FileType php,javascript,css setlocal tabstop=8

" TOML
autocmd BufNewFile,BufRead *.toml setfiletype vim

" QML(Qt)
autocmd BufNewFile,BufRead *.qml setfiletype javascript

" <ESC>x2 で検索ハイライトを無効化
nnoremap <ESC><ESC> :nohlsearch<CR>

" Ctrl + q でターミナルを終了
tnoremap <C-q> <C-\><C-n>:bw!<CR>
" ESCでターミナルモードからノーマルモードへ
tnoremap <ESC> <C-\><C-n>

" Ctrl + space でオムニ補完
imap <C-Space> <C-x><C-o>

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

" 差分表示を解除してカレントのみにする
nmap ,doo :DiffOffOnly<CR>
command! DiffOffOnly :diffoff | only

nmap ,todq :ToDoubleQuote<CR>
command! ToDoubleQuote :s/'/\"/g | nohlsearch

nmap ,tosq :ToSingleQuote<CR>
command! ToSingleQuote :s/\"/'/g | nohlsearch

nmap ,tosl :ToSlash<CR>
command! ToSlash :s/\\/\//g | nohlsearch

nmap ,tobs :ToBackSlash<CR>
command! ToBackSlash :s/\//\\/g | nohlsearch

" JSON を整形
command! -nargs=? Jq call s:Jq(<f-args>)
function! s:Jq(...)
	if 0 == a:0
		let l:arg = "."
	else
		let l:arg = a:1
	endif
	execute "%!jq " . l:arg
endfunction

if !has('kaoriya')
	" 編集中のファイルのディレクトリに移動する
	command! CdCurrent :cd %:p:h
endif

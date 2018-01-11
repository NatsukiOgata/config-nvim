let g:python3_host_prog = 'C:\Users\z026369\neovim3\Scripts\python.exe'

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

filetype plugin indent on
 
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

" 8進数で扱うのは止める
set nrformats-=octal

" Tab の表示設定
set listchars=tab:>-
set list
 
" Beep 無効
set visualbell
"set vb t_vb=

" gtags
" cscope_maps.vim like
autocmd FileType h,c,cpp,php,js,css nnoremap <C-\>s :<C-u>Unite gtags/context -immediately<CR>
autocmd FileType h,c,cpp,php,js,css nnoremap <C-\>g :<C-u>Unite gtags/def -immediately<CR>
autocmd FileType h,c,cpp,php,js,css nnoremap <C-\>c :<C-u>Unite gtags/ref<CR>
autocmd FileType h,c,cpp,php,js,css nnoremap <C-\>e :<C-u>Unite gtags/grep<CR>

autocmd FileType h,cpp setlocal fileencoding=utf-8
autocmd FileType h,cpp setlocal nobomb
autocmd FileType h,cpp setlocal noexpandtab
autocmd FileType h,cpp setlocal shiftwidth=8
autocmd FileType h,cpp setlocal tabstop=8

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

" <ESC>x2 で検索ハイライトを無効化
nnoremap <ESC><ESC> :nohlsearch<CR>

nnoremap [unite]    :Unite
nnoremap [denite]   :Denite
nnoremap [vimfiler] :VimFiler
nnoremap [vimshell] :VimShell
nnoremap [tsvn]     <Nop>

nmap ,u [unite]
nmap ,d [denite]
nmap ,f [vimfiler]
nmap ,s [vimshell]
nmap ,t [tsvn]

" バッファ一覧
nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> [unite]f :<C-u>Unite file_rec<CR>
" ディレクトリ一覧
nnoremap <silent> [unite]s :<C-u>Unite directory<CR>
" bookmark
nnoremap <silent> [unite]j :<C-u>Unite bookmark<CR>
" 最近使用したファイル一覧(ファイル・ディレクトリ)
nnoremap <silent> [unite]m :<C-u>Unite file_mru directory_mru<CR>
" 最近使用したファイル一覧(ディレクトリ・ファイル)
nnoremap <silent> [unite]d :<C-u>Unite directory_mru file_mru<CR>

nnoremap <silent> ,fr :<C-u>Denite file_rec<CR>
nnoremap <silent> ,fm :<C-u>Denite file_mru directory_mru<CR>
nnoremap <silent> ,dr :<C-u>Denite directory_rec<CR>
nnoremap <silent> ,dm :<C-u>Denite directory_mru file_mru<CR>
nnoremap <silent> ,gr :<C-u>Denite -auto_preview grep<CR>
nnoremap <silent> ,gc :<C-u>DeniteCursorWord grep<CR>

" VimFiler(バッファディレクトリ)
nnoremap <silent> [vimfiler]d :<C-u>VimFilerBufferDir<CR>
" VimFiler(カレントディレクトリ)
nnoremap <silent> [vimfiler]c :<C-u>VimFilerCurrentDir<CR>

" カレントディレクトリをエクスプローラーで開く
nmap ,ode :call OpenDirectoryExplorer("%:p:h")<CR>
function! OpenDirectoryExplorer(dir)
	let save_ss = &shellslash
	set noshellslash
	execute('!start explorer.exe "' . a:dir . '"')
	let &shellslash = save_ss
endfunction

" 差分表示を解除してカレントのみにする
nmap ,doo :diffoff<CR>:only<CR>

" ヘッダファイルとソースファイルを切り替える
command! A call altr#forward()

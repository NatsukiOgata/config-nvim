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

" �^�u���C���̐ݒ�
set showtabline=1
 
" �o�b�N�A�b�v�t�@�C���̍쐬�ꏊ
set backupdir=$tmp
" �X���b�v�t�@�C���̍쐬�ꏊ�̓o�b�N�A�b�v�Ɠ���
let &directory = &backupdir
 
let &undodir = &backupdir
 
" ���������񂪏������̏ꍇ�͑啶������������ʂȂ���������
set ignorecase
 
" �C���T�[�g���[�h�ŃJ�[�\���ړ�
noremap! <C-L> <Right>
noremap! <C-H> <Left>

" ���t/������W�J(��{�`)
noremap! <expr> <C-d>d strftime('%Y%m%d')
noremap! <expr> <C-d>t strftime('%H%M%S')
" ���t/������W�J(�Z�p���[�^�[�w��)
noremap! <expr> <C-d>d- strftime('%Y-%m-%d')
noremap! <expr> <C-d>d. strftime('%Y.%m.%d')
noremap! <expr> <C-d>d/ strftime('%Y/%m/%d')
noremap! <expr> <C-d>t: strftime('%H:%M:%S')

" 8�i���ň����͎̂~�߂�
set nrformats-=octal

" Tab �̕\���ݒ�
set listchars=tab:>-
set list
 
" Beep ����
set visualbell
"set vb t_vb=

" �������ʂ��n�C���C�g����
set hlsearch

" �S�p�L���̕�
set ambiwidth=double

" �������Ȃǂŏ��O����
set wildignore+=.git/**,.svn/**,vendor*/**

" �X�y���`�F�b�N��L����
set spelllang=en,cjk
"set spell

if has('nvim')
	" ������u�����C���^���N�e�B�u�ɕ\��
	set inccommand=split
endif

" ���ɓ��͕⊮���p�ӂ���Ă��Ȃ��ꍇ�̊e��L�[���[�h�̕⊮
autocmd FileType *
\   if &l:omnifunc == ''
\ |   setlocal omnifunc=syntaxcomplete#Complete
\ | endif

" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave  * if pumvisible() == 0|pclose|endif

" (C:\Program Files\Git\bin\)bash ���N������
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

" TOPCON Web �R�[�f�B���O�K��
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

" <ESC>x2 �Ō����n�C���C�g�𖳌���
nnoremap <ESC><ESC> :nohlsearch<CR>

" Ctrl + q �Ń^�[�~�i�����I��
tnoremap <C-q> <C-\><C-n>:bw!<CR>
" ESC�Ń^�[�~�i�����[�h����m�[�}�����[�h��
tnoremap <ESC> <C-\><C-n>

" Ctrl + space �ŃI���j�⊮
imap <C-Space> <C-x><C-o>

" �֘A�t�����s
nmap ,exe :!start cmd.exe /C start <cfile><CR>

" �J�����g�f�B���N�g�����G�N�X�v���[���[�ŊJ��
nmap ,ode :call OpenDirectoryExplorer("%:p:h")<CR>
function! OpenDirectoryExplorer(dir)
	let save_ss = &shellslash
	set noshellslash
	execute('!start explorer.exe "' . a:dir . '"')
	let &shellslash = save_ss
endfunction

" �����\�����������ăJ�����g�݂̂ɂ���
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

" JSON �𐮌`
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
	" �ҏW���̃t�@�C���̃f�B���N�g���Ɉړ�����
	command! CdCurrent :cd %:p:h
endif

let loaded_matchparen = 1

let g:ack_autoclose = 1
let g:ackhighlight = 1
let g:ackpreview = 0
let g:ack_use_dispatch = 1
let g:ack_default_options = " -s -H --nocolor --nogroup --column --follow --type-set=LOG=.log --noLOG "

set clipboard=unnamed
set nocompatible
set ignorecase
set smartcase
set incsearch
set nohlsearch
set backspace=2
set autoindent
set viminfo='20,\"50
set history=50
set ruler
set tabstop=4
set noexpandtab
set showmatch
set wrap
set wildmenu
set nocindent
set restorescreen
set shiftwidth=4
set list listchars=tab:+-,extends:>,precedes:<,trail:-
set scrolljump=1
set showcmd
set sidescrolloff=3
set laststatus=2
set noautochdir
set ttimeoutlen=250

syntax enable
set background=dark
colorscheme luke
"colorscheme solarized
syntax sync minlines=1000

au BufNewFile,BufRead *.php,*.php3,*.inc  set ft=php
"au BufNewFile,BufRead *.txt set et ts=4 tw=80
au BufNewFile,BufRead *.txt set et ts=4
au BufNewFile,BufRead *.js,*.html,*.htm,*.less,*.scss,*.sass,*.rb,*.yml,*.haml,*.erb,*.ejs,*.rake,*.markdown,*.json set et syntax=javascript ts=2 sw=2 sts=2
au BufNewFile,BufRead *.jst.ejs.erb set ft=html
au BufNewFile,BufRead Gemfile,Rakefile,Capfile,capfile,*.pdf.prawn,*.rabl,*.ruby,*.god,*.cap set et ts=2 sw=2 sts=2 ft=ruby
au BufNewFile,BufRead *.scss set ft=sass
au BufNewFile,BufRead *.less set ft=css

au BufNewFile,BufRead *.scss,*.rb,*.yml,*.haml,*.erb set et ts=2 sw=2 sts=2
au BufNewFile,BufRead *.js set et ts=2 sw=2 sts=2
au BufNewFile,BufRead *.py* set et ts=4 sw=4 sts=4
au BufNewFile,BufRead *.c,*.h set noet nolist ts=4 sw=4 sts=4
au BufNewFile,BufRead Rakefile,Capfile,capfile set et ts=2 sw=2 sts=2 ft=ruby
au BufNewFile,BufRead *.scss set ft=sass
au BufNewFile,BufRead *.md set textwidth=72

au BufNewFile,BufRead *.sh,.bashrc,.*profile,.bash* set syntax=sh et ts=4 sw=4


inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-k> <Esc>lDa

" Block commenting with ',,' and uncommenting with ',.'
autocmd FileType c,cpp,java,scala,javascript let b:comment_leader = '// '
autocmd FileType sh,ruby,python,perl,conf,fstab let b:comment_leader = '# '
autocmd FileType vim let b:comment_leader = '" '
noremap <silent> ,, :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,. :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

" Vundle Setup
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
silent! call vundle#begin()
" --> Have Vundle manage itself
silent! Plugin 'gmarik/Vundle.vim'
" --> These are all for snippets
silent! Plugin 'MarcWeber/vim-addon-mw-utils'
silent! Plugin 'tomtom/tlib_vim'
silent! Plugin 'garbas/vim-snipmate'
silent! Plugin 'honza/vim-snippets'
" --> The CtrlP plugin
silent! Plugin 'kien/ctrlp.vim'
" --> For block comments
silent! Plugin 'tomtom/tcomment_vim'
" --> For Rails support
silent! Plugin 'tpope/vim-rails'
" --> For JavaScript support
silent! Plugin 'pangloss/vim-javascript'
" --> For jst/ejs support
silent! Plugin 'briancollins/vim-jst'
" --> For changing the cwd to the project root
silent! Plugin 'airblade/vim-rooter'
" --> For fuzzy finding
silent! Plugin 'mileszs/ack.vim'
" --> For asynchronously running commands
silent! Plugin 'tpope/vim-dispatch'
silent! call vundle#end()
" --> For proper markdown formatting of .md files
silent! Plugin 'godlygeek/tabular'
silent! Plugin 'plasticboy/vim-markdown'
silent! call vundle#end()
filetype plugin indent on

" CTRL-P Configuration
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_prompt_mappings = {
	\ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
	\ 'AcceptSelection("e")': ['<c-t>'],
	\ }
let g:ctrlp_status_func = {
	\ 'main': 'CtrlP_Statusline_1',
	\ 'prog': 'CtrlP_Statusline_2',
	\ }
fu! CtrlP_Statusline_1(...)
	return '%#CtrlPMode2# '.getcwd().' %*'
endf
fu! CtrlP_Statusline_2(...)
	return '%#CtrlPMode2# '.a:1.' %*'
endf

noremap <C-f> :tabnew<CR>:Ack

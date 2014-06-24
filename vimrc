let loaded_matchparen = 1

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
set nowrap
set wildmenu
set nocindent
set restorescreen
set shiftwidth=4
set list
set listchars=tab:+-,extends:>,precedes:<,trail:-
set scrolljump=1
set showcmd
set sidescrolloff=3
set laststatus=2
set noautochdir
set ttimeoutlen=250

syntax on
colorscheme luke
syntax sync minlines=1000

au BufNewFile,BufRead *.php,*.php3,*.inc  set ft=php
au BufNewFile,BufRead *.txt set et ts=4 tw=80
au BufNewFile,BufRead *.js,*.html,*.htm,*.less,*.scss,*.sass,*.rb,*.yml,*.haml,*.erb,*.ejs,*.rake,*.markdown set et ts=2 sw=2 sts=2
"au BufNewFile,BufRead *.ejs,*.erb set ft=html
au BufNewFile,BufRead *.ejs set ft=html
au BufNewFile,BufRead Gemfile,Rakefile,Capfile,capfile,*.pdf.prawn,*.rabl set et ts=2 sw=2 sts=2 ft=ruby
au BufNewFile,BufRead *.scss set ft=sass
au BufNewFile,BufRead *.less set ft=css

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
call vundle#begin()
" --> Have Vundle manage itself
Plugin 'gmarik/Vundle.vim'
" --> These are all for snippets
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
" --> The CtrlP plugin
Plugin 'kien/ctrlp.vim'
" --> For block comments
Plugin 'tomtom/tcomment_vim'
call vundle#end()
filetype plugin indent on

" CTRL-P Configuration
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_working_path_mode = 'ra'
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

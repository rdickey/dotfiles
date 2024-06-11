let loaded_matchparen = 1

let g:ack_autoclose = 1
let g:ackhighlight = 1
let g:ackpreview = 0
let g:ack_use_dispatch = 1
let g:ack_default_options = " -s -H --nocolor --nogroup --column --follow --type-set=LOG=.log --noLOG "

"" this clipboard thing copies everything to the clipboard for cc, yy, etc
"set clipboard=unnamed

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
set expandtab
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
"colorscheme luke
colorscheme solarized
syntax sync minlines=5000

au BufNewFile,BufRead *.php,*.php3,*.inc  set ft=php
"au BufNewFile,BufRead *.txt set et ts=4 tw=80
au BufNewFile,BufRead *.txt set et ts=4
au BufNewFile,BufRead *.js,*.html,*.htm,*.less,*.scss,*.sass,*.rb,*.haml,*.erb,*.ejs,*.rake,*.markdown,*.json set et syntax=javascript ts=2 sw=2 sts=2
au BufNewFile,BufRead *.jst.ejs.erb set ft=html
"au BufNewFile,BufRead Gemfile,Rakefile,Capfile,Cloudfile,capfile,*.pdf.prawn,*.rabl,*.ruby,*.god,*.cap set et ts=2 sw=2 sts=2 ft=ruby
au BufNewFile,BufRead *file,*.pdf.prawn,*.rabl,*.ruby,*.god,*.cap set et ts=2 sw=2 sts=2 ft=ruby
au BufNewFile,BufRead *.scss set ft=sass
au BufNewFile,BufRead *.less set ft=css

au BufNewFile,BufRead *.scss,*.rb,*.yml,*.haml,*.erb set et ts=2 sw=2 sts=2
au BufNewFile,BufRead *.js set et ts=2 sw=2 sts=2
au BufNewFile,BufRead *.py* set et ts=4 sw=4 sts=4
au BufNewFile,BufRead *.c,*.h set noet nolist ts=4 sw=4 sts=4
au BufNewFile,BufRead *.scss set ft=sass
au BufNewFile,BufRead *.md set textwidth=72

au BufNewFile,BufRead *.sh,*/.bash* set syntax=sh et ts=4 sw=4

let g:terraform_align=1
let g:terraform_fmt_on_save = 1


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
" --> For Rails support
Plugin 'tpope/vim-rails'
" --> For JavaScript support
Plugin 'pangloss/vim-javascript'
" --> For jst/ejs support
Plugin 'briancollins/vim-jst'
" --> For changing the cwd to the project root
Plugin 'airblade/vim-rooter'
" --> For fuzzy finding
Plugin 'mileszs/ack.vim'
" --> For asynchronously running commands
Plugin 'tpope/vim-dispatch'
Plugin 'godlygeek/tabular'
" --> For proper markdown formatting of .md files
Plugin 'plasticboy/vim-markdown'
Plugin 'pearofducks/ansible-vim'
Plugin 'fatih/vim-go'
Plugin 'hashivim/vim-terraform'
Plugin 'bash-support.vim'
Plugin 'ekalinin/Dockerfile.vim'
call vundle#end()
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

"let g:ansible_extra_syntaxes = "sh.vim ruby.vim"
let g:ansible_attribute_highlight = "ab"
let g:ansible_extra_keywords_highlight = 1

noremap <C-f> :tabnew<CR>:Ack

" Lifted from ecarey's ~/.vimrc
" Terraform magic!
command! -bar TerraformKeywordsPrettify %s/^"\(module\|resource\|data\|variable\)"/\1/e
command! -bar TerraformCommentsPrettify %s!^\s\+\zs//\ze!#!e
command! -bar TerraformNewlinesPrettify %s/.*=.*\zs\n\n\ze/\r/e
command! -bar TerraformAssignsPrettify %s/\s\+\zs"\([A-Za-z0-9_\-]\+\)"\ze.*=/\1/e
command! -bar TerraformFormat %!terraform fmt -
command! -bar TerraformMapValuePrettify %s/= {/{/e
command! -bar TerraformEmptyValueFix %s/= $/= ""/e
command! PrettyFormatTerraform TerraformEmptyValueFix | TerraformCommentsPrettify | TerraformKeywordsPrettify | TerraformAssignsPrettify | TerraformMapValuePrettify | TerraformNewlinesPrettify | TerraformFormat
command! TerraformPrettyFormat PrettyFormatTerraform

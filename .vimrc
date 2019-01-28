" the following are required to use vundle plugin manager
set nocompatible
filetype off
let g:python3_host_prog='/usr/bin/python'
let g:python_host_prog='/usr/bin/python2'
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin('~/.config/nvim/bundle')
"Plugin 'VundleVim/Vundle.vim'
call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'mbbill/undotree'
Plug 'airblade/vim-gitgutter'
Plug 'fatih/vim-go'
"Plug 'zchee/deoplete.nvim'  " Generic completions based on buffers
"Plug 'zchee/deoplete-go', { 'do': 'make' }
"Plug 'yosssi/vim-ace'
"Plug 'davidhalter/jedi-vim'  " Great completion for python class methods, etc
Plug 'davidhalter/jedi'  " Great completion for python class methods, etc

"call vundle#end()
call plug#end()

filetype plugin indent on
" end of vundle section

" vim-go opts
" automatically insert import paths on fmt
let g:go_fmt_command = "goimports"

" map leader to most prominent key
let mapleader = "\<Space>"

" we use a dark terminal background provide appropriate colours
set background=dark

" allow syntax highlighting
syntax on

" turn on:
"   1) Filetype detection
"   2) Use filetype plugins
"   3) Use filetype specific indenting
filetype plugin indent on

" enable JSX syntax in *.js files, too
let g:jsx_ext_required = 0

" enable deoplete completion
"let g:deoplete#enable_at_startup = 1

" YCM, close preview window after accept
au CompleteDone * pclose

" TODO rm ?
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0

" enable XML tag matching
"runtime macros/matchit.vim

" force no background color on loading colo schemes (for transparent term emus)
au ColorScheme * call NoBackground()
function! NoBackground()
    hi Normal ctermbg=none
    hi Comment ctermbg=none
    hi Folded ctermbg=none
    hi NonText ctermbg=none
    hi SpecialKey ctermbg=none
    hi VertSplit ctermbg=none
    hi SignColumn ctermbg=none
    hi Constant ctermbg=NONE
    hi Special ctermbg=NONE
    hi Identifier ctermbg=NONE
    hi Statement ctermbg=NONE
    hi PreProc ctermbg=NONE
    hi Type ctermbg=NONE
    hi Underlined ctermbg=NONE
    hi Todo ctermbg=NONE
    hi String ctermbg=NONE
    hi Function ctermbg=NONE
    hi Conditional ctermbg=NONE
    hi Repeat ctermbg=NONE
    hi Operator ctermbg=NONE
    hi Structure ctermbg=NONE
    hi CursorLine ctermfg=NONE
endfunction

" try really hard to allow 256 colos
set t_Co=256

" default colorscheme
colorscheme darcula

" show training whitespace as `-', and tabs as `>---'
set list lcs=trail:-,tab:>-
" default to not show
set list!

set hlsearch    " highlight search results
set shiftround  " shift to set columns rather than relative
set si          " use smartindent on new lines (see ':help smartindent')
set cinkeys-=0#
set indentkeys-=0#
set ai          " use autoindent (copy indent from prev line on new line)
set cursorline  " highlight current line (expensive)
set nu          " show line numbers by default

"hi,
"here is a basic .vimrc that you can choose to use if you like.  use all/part/none of it up to you.
" Ty

" ignore case during search
set ignorecase

" obey case if search pattern has uppercase
set smartcase

" shiftwidth is 4 @ sparq
set shiftwidth=4
set tabstop=4

" expandtab, expand tabs as spaces
set expandtab

" fileformats=unix
set ffs=unix

" normal mode key maps
function! NumberToggle()
  if(&relativenumber == 1)
    set relativenumber!
  else
    set relativenumber
  endif
endfunc
nnoremap <C-n> :call NumberToggle()<cr> " toggle nu/rnu

" toggle highlight on search
nnoremap <silent> <C-l> :set hls!<CR><C-l>

" refresh .vimrc
nnoremap <C-s> :source $MYVIMRC<CR>

" (insert) bind omnifunc to Ctrl+Space
inoremap <C-Space> <C-x><C-o>

" make debugging python scripts a little less painful
nnoremap <silent> <F5> :!python -u %<CR>

" alt+w to toggle line wrapping
nnoremap <M-w> :set wrap!<CR>

" insert mode key maps
" don't auto-indent `#' comments to beginning of line
inoremap # X#

" shortcut to toggle :NERDTree plugin
map <silent> <C-t> :NERDTreeToggle<CR>

" shortcut to activate FZF (<C-c> quits)
"map <C-f> :FZF<CR>

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line (see ":help statusline")
"   \       a space
"   %F      path from home
"   %f      path for file in buffer
"   %m      modified? [+], not-modifiable? [-]
"   %r      readonly? [RO]
"   %h      is vim help? [help]
"   %w      is preview? [Preview]
"   %l      line
"   %c      column
set statusline=\ %F%m%r%h\ %w\ pos:\(%l,%c)

" code folding
set foldmethod=manual
set foldlevelstart=99 " open all folds on file open

" track undo changes in dedicated folder
if has ("persistent_undo")
    set undofile
    set undodir=$HOME/.vim/undo  " where to save (REQ: `mkdir ~/.vim/undo`!)
endif

"""
""" source per language settings, macros
"""

" load filetype generic macros, settings
source ${HOME}/.vimrc.d/lang_configs/macros_all.vim

" load filetype specific macros, settings
" syntax `function!' silently replaces the function,
" which is useful when using `source ${HOME}/.vimrc'.
au BufNewFile,BufRead,FileType *.js* call Javascript_conf()
    function! Javascript_conf()
        source ${HOME}/.vimrc.d/lang_configs/macros_javascript.vim
    endfunction
au BufNewFile,BufRead,FileType *.jsx call ReactJSX_conf()
    function! ReactJSX_conf()
        source ${HOME}/.vimrc.d/lang_configs/macros_reactjsx.vim
    endfunction
autocmd BufNewFile,BufRead,FileType c[pp]* call Cpp_conf()
    function! Cpp_conf()
        source ${HOME}/.vimrc.d/lang_configs/macros_cpp.vim
    endfunction
autocmd BufNewFile,BufRead,FileType *.sh call Bash_conf()
    function! Bash_conf()
        source ${HOME}/.vimrc.d/lang_configs/macros_bash.vim
    endfunction
autocmd BufNewFile,BufRead,FileType *.go call Go_conf()
    function! Go_conf()
        set syn=go
        source ${HOME}/.vimrc.d/lang_configs/go/settings_go.vim
    endfunction

" syntax highlighting like HTML for EJS files
au BufNewFile,BufRead *.ejs set filetype=html

" iMacros syntax
"au Filetype iim setfiletype iMacros
"au BufNewFile,BufRead *.iim set syntax=iim filetype=iMacros

" set explicit tab character for .at files
"au BufNewFile,BufRead *.a[tm], set noic cin noexpandtab list filetype=autotest
"au Filetype autotest setlocal noexpandtab list
match ErrorMsg '\%>72v.\+'

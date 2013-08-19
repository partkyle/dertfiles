set nocompatible               " be iMproved
filetype off                   " required!

let mapleader=","

nnoremap <f7> :sp ~/.vimrc<cr>
nnoremap <f8> :BundleUpdate<cr>
nnoremap <f9> :source ~/.vimrc<cr>

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'
Bundle 'bling/vim-airline'
Bundle 'epmatsw/ag.vim'
Bundle 'nanotech/jellybeans.vim'
Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimproc.vim'
Bundle 'partkyle/Align'
Bundle 'tpope/vim-dispatch'
Bundle 'fugitive.vim'
Bundle 'repeat.vim'
Bundle 'surround.vim'
Bundle 'file-line'

filetype plugin indent on

set laststatus=2

set tabstop=2     " Set the default tabstop
set softtabstop=2
set shiftwidth=2  " Set the default shift width for indents
set expandtab     " Make tabs into spaces (set by tabstop)
set smarttab      " Smarter tab levels

set noshowmode " vim-airline handles this

set hlsearch            " highlight searches
set incsearch           " do incremental searching
set showmatch           " jump to matches when entering regexp
set ignorecase          " ignore case when searching
set smartcase           " no ignorecase if Uppercase char present

set visualbell t_vb=    " turn off error beep/flash
set novisualbell        " turn off visual bell

set backspace=indent,eol,start  " make that backspace key work the way it should

set splitright " switch to newly created split
set splitbelow

syntax on               " turn syntax highlighting on by default

color jellybeans

" ruby filetypes
au BufRead,BufNewFile {Gemfile,Rakefile,Capfile,*.rake,config.ru} set ft=ruby
au BufRead,BufNewFile {*.md,*.mkd,*.markdown}                     set ft=markdown

" keybindings

" Clear search
nmap <C-c> :nohlsearch<CR>

" Yank from the cursor to the end of the line, to be consistent with C and D
nnoremap Y y$

" I can find my own help
nmap <F1> <ESC>

" I never intentionally lookup keywords (with `man`)
nmap K <Esc>

" Search for selected text, forwards or backwards.
" http://vim.wikia.com/wiki/Search_for_visually_selected_text
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" Reselect visual block after indent
vnoremap < <gv
vnoremap > >gv

nnoremap <C-i> i

" better moving in insert mode
imap <C-j> <C-o>j
imap <C-k> <C-o>k
imap <C-h> <C-o>h
imap <C-l> <C-o>l

" mappings for command line
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" space mappings
nnoremap <Space> <C-w>w
nnoremap <S-Space> <C-w>W

nnoremap vv :vsplit<CR>

nnoremap ss :split<CR>

" sudo write
cnoreabbrev w!! %!sudo tee > /dev/null %

" open file helpers
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" fugitive
map <leader>gs :Gstatus<CR><C-w>J
map <leader>gd :Gdiff<CR>

" emacsisms (so sue me)
inoremap <C-A> <C-O>^
cnoremap <C-A> <Home>
inoremap <C-E> <End>
cnoremap <C-E> <End>
inoremap <C-F> <C-O>l
cnoremap <C-F> <C-O>l
inoremap <C-B> <C-O>h
cnoremap <C-B> <C-O>h

" yank
inoremap <C-y> <C-o>p

nnoremap <C-x><C-c> ZZ
inoremap <C-x><C-c> <ESC>ZZ
nnoremap <C-x><C-s> :w<CR>
inoremap <C-x><C-s> <ESC>:w<CR>gi

" I can't believe that :W does nothing
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Wq wq
cnoreabbrev WQ wq

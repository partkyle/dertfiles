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
Bundle 'partkyle/vim-easy-align'
Bundle 'tpope/vim-dispatch'
Bundle 'fugitive.vim'
Bundle 'repeat.vim'
Bundle 'surround.vim'
Bundle 'file-line'
Bundle 'YankRing.vim'
Bundle 'Valloric/YouCompleteMe'

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

" wildmenu

set wildmode=longest:full,full
set wildmenu
set wildignore+=*.png,*.jpg,*.gif
set wildignore+=*DS_Store*
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

" netrw
let g:netrw_list_hide='.*\.pyc$'
let g:netrw_liststyle=3

" mouse
set mouse=a
set ttymouse=xterm2

" ruby filetypes
au BufRead,BufNewFile {Gemfile,Rakefile,Capfile,*.rake,config.ru} set ft=ruby
au BufRead,BufNewFile {*.md,*.mkd,*.markdown}                     set ft=markdown

" git filetypes
if has('autocmd')
  if has('spell')
    au BufNewFile,BufRead COMMIT_EDITMSG setlocal spell
  endif
  au BufNewFile,BufRead COMMIT_EDITMSG call feedkeys('ggi', 't')
endif

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

" I hate that I have to to this. Damn you EasyAlign!
cnoreabbrev E Ex

" Make trailing whitespace annoyingly highlighted.
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

if exists('$TMUX')
  function! TmuxOrSplitSwitch(wincmd, tmuxdir)
    let previous_winnr = winnr()
    silent! execute "wincmd " . a:wincmd
    if previous_winnr == winnr()
      call system("tmux select-pane -" . a:tmuxdir)
      redraw!
    endif
  endfunction

  let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
  let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
  let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te

  nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('h', 'L')<cr>
  nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('j', 'D')<cr>
  nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('k', 'U')<cr>
  nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('l', 'R')<cr>
else
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l
endif

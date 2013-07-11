if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'altercation/vim-colors-solarized'

NeoBundle 'benmills/vimux'

NeoBundle 'bling/vim-airline'

NeoBundle 'chriskempson/vim-tomorrow-theme'

NeoBundle 'epmatsw/ag.vim'

NeoBundle 'Lokaltog/vim-distinguished'

NeoBundle 'h1mesuke/unite-outline'

NeoBundle 'mileszs/ack.vim'

NeoBundle 'nanotech/jellybeans.vim'

NeoBundle 'nsf/gocode'

NeoBundle 'partkyle/vim-colors'

NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc.vim'

NeoBundle 'vim-scripts/vim-multiple-cursors'

NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-vividchalk'

if version >= 730
  NeoBundle 'Valloric/YouCompleteMe'
endif

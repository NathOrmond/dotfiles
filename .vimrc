""" Enhanced vim Configuration """

""" Basic Settings """
set nocompatible                    " Don't try to be vi compatible
syntax on                           " Enable syntax highlighting
set encoding=utf-8                  " Set UTF-8 encoding
set background=dark                " Dark background colors
set visualbell                      " Visual bell instead of beeping
set mouse=a                         " Enable mouse in all modes
set clipboard=unnamed               " Use system clipboard
set history=1000                    " Store more command history
set undolevels=1000                " Store more undo levels
set autoread                        " Reload files changed outside vim

""" Plugin Management """
filetype off                        " Required for plugin initialization
" TODO: Load plugins here (pathogen or vundle)
filetype plugin indent on           " Enable file type detection and plugins

""" Visual Settings """
set number relativenumber           " Show hybrid line numbers
set ruler                          " Show file position
set cursorline                     " Highlight current line
set laststatus=2                  " Always show status bar
set showmode                       " Show current mode
set showcmd                        " Show command in bottom bar
set ttyfast                        " Faster redrawing
set t_Co=256                       " 256 color terminal support
set signcolumn=yes                " Always show sign column
set colorcolumn=80                " Show column boundary
set list                          " Show invisible characters
set listchars=tab:▸\ ,eol:¬,trail:·,extends:>,precedes:<  " Characters for visualizing whitespace

""" Indentation and Whitespace """
set autoindent                      " Auto-indent new lines
set smartindent                     " Smart auto-indenting
set tabstop=4                      " Width of tab character
set softtabstop=4                  " Backspace deletes pseudo-tabs
set shiftwidth=4                  " Width of auto-indentation
set expandtab                      " Use spaces instead of tabs
set wrap                           " Wrap lines
set textwidth=80                  " Text width before wrapping
set formatoptions=tcqrn1          " Text formatting options
set noshiftround                  " Don't round indent to shiftwidth

""" Search Settings """
set hlsearch                       " Highlight search results
set incsearch                      " Incremental search
set ignorecase                    " Case insensitive search
set smartcase                     " Case sensitive if uppercase present
set showmatch                     " Show matching brackets
set gdefault                      " Use 'g' flag by default with :s/foo/bar/

""" Navigation and Movement """
set scrolloff=8                   " Keep 8 lines below and above cursor
set sidescrolloff=15             " Keep 15 columns to the left and right of cursor
set backspace=indent,eol,start   " Make backspace behave normally
set matchpairs+=<:>              " Add angle brackets to match pairs

"nnoremap j gj                     " Move by visual line
"nnoremap k gk                     " Move by visual line

" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

""" File and Buffer Handling """
set hidden                         " Allow hidden buffers
set autowrite                     " Auto-save before certain commands
set noswapfile                    " Don't create swap files
set nobackup                      " Don't create backup files
set wildmenu                      " Enhanced command line completion
set wildmode=list:longest         " Complete files like a shell
set wildignore+=*.pyc,*.pyo,*/__pycache__/*  " Ignore compiled files
set wildignore+=*.swp,~*          " Ignore swap files

""" Key Mappings """
let mapleader = ","               " Set leader key to comma
" Clear search highlighting with leader + space
map <leader><space> :let @/=''<cr>
" Toggle whitespace visualization
map <leader>l :set list!<CR>
" Format paragraph
map <leader>q gqip
" Quick save
nmap <leader>w :w!<cr>
" Quick quit
nmap <leader>q :q<cr>
" Quick save and quit
nmap <leader>x :x<cr>
" Reload vimrc
map <leader>r :source ~/.vimrc<CR>

""" Code Folding """
set foldenable                    " Enable folding
set foldlevelstart=10            " Open most folds by default
set foldnestmax=10              " Maximum nested folds
set foldmethod=indent           " Fold based on indentation

""" Color Scheme """
let g:solarized_termcolors=256
let g:solarized_termtrans=1
" To use solarized:
" 1. Download from https://raw.github.com/altercation/vim-colors-solarized/master/colors/solarized.vim
" 2. Place in ~/.vim/colors/
" 3. Uncomment the next line:
" colorscheme solarized

""" Performance Settings """
set lazyredraw                    " Don't redraw while executing macros
set regexpengine=1               " Use old regexp engine
set synmaxcol=200                " Only highlight first 200 columns

""" Load Local Settings """
if filereadable("/etc/vim/vimrc.local")
    source /etc/vim/vimrc.local
endif

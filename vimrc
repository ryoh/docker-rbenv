let g:neocomplcache_enable_at_startup = 1
"--------------------------------------------------------------------------
" neobundle
set nocompatible               " Be iMproved
filetype off                   " Required!

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

"---- plugins start ---------------------------
NeoBundle 'Align'
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/unite-outline'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/vimfiler'
NeoBundle 'Shougo/vimproc.vim', {
  \ 'build' : {
    \ 'windows' : 'make -f make_mingw32.mak',
    \ 'cygwin'  : 'make -f make_cygwin.mak',
    \ 'mac'     : 'make -f make_mac.mak',
    \ 'unix'    : 'make -f make_unix.mak',
  \ },
\ }
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'vim-scripts/AnsiEsc.vim'
NeoBundle 'vim-scripts/md5.vim'
NeoBundle 'AndrewRadev/switch.vim'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'ervandew/supertab'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-bundler'
NeoBundle 'tpope/vim-cucumber'
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'slim-template/vim-slim'
NeoBundle 'skalnik/vim-vroom'
NeoBundle 'bbatsov/rubocop'
NeoBundleLazy 'alpaca-tc/alpaca_tags', {
      \ 'depends': ['Shougo/vimproc'],
      \ 'autoload': {
      \   'commands': [
      \     {'name': 'AlpacaTagsBundle', 'complete': 'customlist,alpaca_tags#complete_source' },
      \     {'name': 'AlpacaTagsUpdate', 'complete': 'customlist,alpaca_tags#complete_source' },
      \     'AlpacaTagsSet', 'AlpacaTagsCleanCache', 'AlpacaTagsEnable', 'AlpacaTagsDisable', 'AlpacaTagsKillProcess', 'AlpacaTagsProcessStatus',
      \   ],
      \ }}
NeoBundleLazy 'marcus/rsense', {
      \ 'autoload': {
      \   'filetypes': 'ruby',
      \ },
      \ }
NeoBundle 'Shougo/neocomplcache-rsense.vim', {
      \ 'depends': ['Shougo/neocomplcache.vim', 'marcus/rsense'],
      \ }
"---- plugins end ----------------------
call neobundle#end()

filetype plugin indent on     " Required!

" Installation check.
if neobundle#exists_not_installed_bundles()
  echomsg 'Not installed bundles : ' .
        \ string(neobundle#get_not_installed_bundle_names())
  echomsg 'Please execute ":NeoBundleInstall" command.'
  "finish
endif

let g:neocomplcache_force_overwrite_completefunc=1
"--------------------------------------
" Base setting
"--------------------------------------
syntax on

" colorscheme
set background=dark
colorscheme solarized
let g:solarized_termcolors=256

" system
set nobackup
set noswapfile
set nowritebackup
set wrap
set shiftround
set hidden
set history=10000
set mouse=a
set ttymouse=xterm2
set showcmd
set textwidth=0
set cursorline
set clipboard=unnamed,autoselect
set nrformats=

" editor visual
set number

" tabs and indent
set expandtab
set smartindent
set shiftwidth=4
set tabstop=4
set autoindent
set cindent
set smartindent

" fileencoding
set fenc=utf8
set fencs=utf8,sjis,euc-jp,iso-2022-jp,cp932

" brace match
set matchpairs& matchpairs+=<:>
set showmatch
set matchtime=3

" search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Can undo when stop vim
if has('persistent_undo')
  set undofile
  set undodir=./.vimundo,~/.vim/undo
endif

inoremap jj <Esc>
nmap <silent> <Esc><Esc> :nohlsearch<CR>

" change target window
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" change window size
nnoremap <S-Left> <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up> <C-w>-<CR>
nnoremap <S-Up> <C-w>+<CR>

" imap
imap { {}<Left>
imap [ []<Left>
imap ( ()<Left>


"----------------------------------------
" AlpacaTags
"----------------------------------------
augroup AlpacaTags
  autocmd!
  if exists(':Tags')
    autocmd BufWritePost Gemfile TagsBundle
    autocmd BufEnter * TagsSet
  endif
augroup END


"----------------------------------------
" neosnippet
"----------------------------------------
" Set to snippet save directory.

let s:default_snippet = neobundle#get_neobundle_dir() . '/neosnippet/autoload/neosnippet/snippets'
let s:my_snippet = '~/snippet'
let g:neosnippet#snippets_directory = s:my_snippet
let g:neosnippet#snippets_directory = s:default_snippet . ',' . s:my_snippet
imap <silent><C-F>          <Plug>(neosnippet_expand_or_jump)
inoremap <silent><C-U>      <ESC>:<C-U>Unite snippet<CR>
nnoremap <silent><Space>e   :<C-U>NeoSnippetEdit -split<CR>
smap <silent><C-F>          <Plug>(neosnippet_expand_or_jump)

 
" ------------------------------------
" switch.vim
" ------------------------------------

function! s:separate_defenition_to_each_filetypes(ft_dictionary) "{{{
  let result = {}

  for [filetypes, value] in items(a:ft_dictionary)
    for ft in split(filetypes, ",")
      if !has_key(result, ft)
        let result[ft] = []
      endif

      call extend(result[ft], copy(value))
    endfor
  endfor

  return result
endfunction"}}}

" switch defined {{
nnoremap ! :Switch<CR>
let s:switch_definition = {
      \ '*': [
      \   ['is', 'are']
      \ ],
      \ 'ruby,eruby,haml' : [
      \   ['if', 'unless'],
      \   ['while', 'until'],
      \   ['.blank?', '.present?'],
      \   ['include', 'extend'],
      \   ['class', 'module'],
      \   ['.inject', '.delete_if'],
      \   ['.map', '.map!'],
      \   ['attr_accessor', 'attr_reader', 'attr_writer'],
      \ ],
      \ 'Gemfile,Berksfile' : [
      \   ['=', '<', '<=', '>', '>=', '~>'],
      \ ],
      \ 'ruby.application_template' : [
      \   ['yes?', 'no?'],
      \   ['lib', 'initializer', 'file', 'vendor', 'rakefile'],
      \   ['controller', 'model', 'view', 'migration', 'scaffold'],
      \ ],
      \ 'erb,html,php' : [
      \   { '<!--\([a-zA-Z0-9 /]\+\)--></\(div\|ul\|li\|a\)>' : '</\2><!--\1-->' },
      \ ],
      \ 'rails' : [
      \   [100, ':continue', ':information'],
      \   [101, ':switching_protocols'],
      \   [102, ':processing'],
      \   [200, ':ok', ':success'],
      \   [201, ':created'],
      \   [202, ':accepted'],
      \   [203, ':non_authoritative_information'],
      \   [204, ':no_content'],
      \   [205, ':reset_content'],
      \   [206, ':partial_content'],
      \   [207, ':multi_status'],
      \   [208, ':already_reported'],
      \   [226, ':im_used'],
      \   [300, ':multiple_choices'],
      \   [301, ':moved_permanently'],
      \   [302, ':found'],
      \   [303, ':see_other'],
      \   [304, ':not_modified'],
      \   [305, ':use_proxy'],
      \   [306, ':reserved'],
      \   [307, ':temporary_redirect'],
      \   [308, ':permanent_redirect'],
      \   [400, ':bad_request'],
      \   [401, ':unauthorized'],
      \   [402, ':payment_required'],
      \   [403, ':forbidden'],
      \   [404, ':not_found'],
      \   [405, ':method_not_allowed'],
      \   [406, ':not_acceptable'],
      \   [407, ':proxy_authentication_required'],
      \   [408, ':request_timeout'],
      \   [409, ':conflict'],
      \   [410, ':gone'],
      \   [411, ':length_required'],
      \   [412, ':precondition_failed'],
      \   [413, ':request_entity_too_large'],
      \   [414, ':request_uri_too_long'],
      \   [415, ':unsupported_media_type'],
      \   [416, ':requested_range_not_satisfiable'],
      \   [417, ':expectation_failed'],
      \   [422, ':unprocessable_entity'],
      \   [423, ':precondition_required'],
      \   [424, ':too_many_requests'],
      \   [426, ':request_header_fields_too_large'],
      \   [500, ':internal_server_error'],
      \   [501, ':not_implemented'],
      \   [502, ':bad_gateway'],
      \   [503, ':service_unavailable'],
      \   [504, ':gateway_timeout'],
      \   [505, ':http_version_not_supported'],
      \   [506, ':variant_also_negotiates'],
      \   [507, ':insufficient_storage'],
      \   [508, ':loop_detected'],
      \   [510, ':not_extended'],
      \   [511, ':network_authentication_required'],
      \ ],
      \ 'rspec': [
      \   ['describe', 'context', 'specific', 'example'],
      \   ['before', 'after'],
      \   ['be_true', 'be_false'],
      \   ['get', 'post', 'put', 'delete'],
      \   ['==', 'eql', 'equal'],
      \   { '\.should_not': '\.should' },
      \   ['\.to_not', '\.to'],
      \   { '\([^. ]\+\)\.should\(_not\|\)': 'expect(\1)\.to\2' },
      \   { 'expect(\([^. ]\+\))\.to\(_not\|\)': '\1.should\2' },
      \ ],
      \ 'markdown' : [
      \   ['[ ]', '[x]']
      \ ]
      \ }
"}}
 
let s:switch_definition = s:separate_defenition_to_each_filetypes(s:switch_definition)
function! s:define_switch_mappings() "{{{
  if exists('b:switch_custom_definitions')
    unlet b:switch_custom_definitions
  endif

  let dictionary = []
  for filetype in split(&ft, '\.')
    if has_key(s:switch_definition, filetype)
      let dictionary = extend(dictionary, s:switch_definition[filetype])
    endif
  endfor

  if exists('b:rails_root')
    let dictionary = extend(dictionary, s:switch_definition['rails'])
  endif

  if has_key(s:switch_definition, '*')
    let dictionary = extend(dictionary, s:switch_definition['*'])
  endif
endfunction"}}}

augroup SwitchSetting
  autocmd!
  autocmd Filetype * if !empty(split(&ft, '\.')) | call <SID>define_switch_mappings() | endif
augroup END


"----------------------------------------
" Rubocop
"----------------------------------------
" Use to check Rubocop of Ruby
let g:syntastic_ruby_checkers = ['rubocop']

" Run check use even when file was opened.
let g:syntastic_check_on_open = 1

" Ruu automatic check in the case of Ruby
let g:syntastic_mode_map = {"mode": "passive",
      \ "active_filetypes": ["ruby"],
      \ "passive_filetypes": [] }


"----------------------------------------
" endwise.vim
"----------------------------------------
"let g:endwise_no_mappings = 1


"----------------------------------------
" fugitive
"----------------------------------------
autocmd QuickFixCmdPost *grep* cwindow
set statusline+=%{fugitive#statusline()}


"----------------------------------------
" vim-indent-guides
"----------------------------------------
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_auto_colors = 0
autocmd VimEnter,ColorScheme * :hi IndentGuidesOdd  guibg=#262626 ctermbg=gray
autocmd VimEnter,ColorScheme * :hi IndentGuidesEven guibg=#3c3c3c ctermbg=darkgray
let g:indent_guides_color_change_percent = 30
let g:indent_guides_guide_size = 1


"----------------------------------------
" Visible Zenkaku Space
"----------------------------------------
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermbg=lightblue guibg=darkgray
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme * call ZenkakuSpace()
    autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
  augroup END
  call ZenkakuSpace()
endif


"-----------------
" NERDTree
"-----------------
map <C-e> :NERDTreeToggle<CR>
let g:NERDTreeDirArrows = 0
let g:NERDTreeMouseMode = 0
autocmd VimEnter * if !argc() | NERDTree ./ | endif
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif


"-----------------
" quickrun
"-----------------
let g:quickrun_config={'*': {'split': ''}}
let g:quickrun_config._={ 'runner': 'vimproc',
      \ 'runner/vimproc/updatetime': 10,
      \ 'outputter/buffer/close_on_empty': 1,
      \ }


"-----------------
" lightline
"-----------------
set laststatus=2
set t_Co=256
let g:lightline = {
      \ 'colorscheme': 'solarized'
      \ }


"-----------------
" rsense
"-----------------
let g:neocomplcache#sources#rsense#home_directory = '~/.rsense'


NeoBundleCheck
"=======================================
" vim:ft=vim:fenc=utf-8:ff=unix:fdm=marker:ts=2:sw=2:tw=80:et:
"=======================================

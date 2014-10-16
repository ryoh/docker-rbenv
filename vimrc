let g:neocomplcache_enable_at_startup = 1
"--------------------------------------------------------------------------
" neobundle
set nocompatible               " Be iMproved
filetype off                   " Required!

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

"---- plugins start ---------------------------
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc.vim', {
  \ 'build' : {
    \ 'windows' : 'make -f make_mingw32.mak',
    \ 'cygwin'  : 'make -f make_cygwin.mak',
    \ 'mac'     : 'make -f make_mac.mak',
    \ 'unix'    : 'make -f make_unix.mak',
  \ },
\ }
NeoBundle 'VimClojure'
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'jpalardy/vim-slime'
NeoBundle 'scrooloose/syntastic'

NeoBundle 'alpaca-tc/alpaca_tags'
NeoBundle 'AndrewRadev/switch.vim'
NeoBundle 'bbatsov/rubocop'
NeoBundle 'tpope/vim-endwise'
"---- plugins end ----------------------

filetype plugin indent on     " Required!

" Installation check.
if neobundle#exists_not_installed_bundles()
  echomsg 'Not installed bundles : ' .
        \ string(neobundle#get_not_installed_bundle_names())
  echomsg 'Please execute ":NeoBundleInstall" command.'
  "finish
endif

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

  if !empty('dictionary')
    call alpaca#let_b:('switch_custom_definitions', dictionary)
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
let g:endwise_no_mappings = 1


"----------------------------------------
" settings
"----------------------------------------
syntax  on
set     ai ci si
set     sw=2 ts=2
set     expandtab
set     nobackup
set     noswapfile
set     nohlsearch

" General Options " {{{
set wildmenu " Enable command line completion menu
set wildoptions=tagfile " Use classic completion menu instead of floating window
set mouse=a " Enable mouse
set noshowmode " Don't show edit mode in command bar
" }}}

" Appearance " {{{
set cursorline " Highlight current line
set list " Show unprintable characters
set listchars=tab:».,trail:⌴,extends:❯,precedes:❮,nbsp:° " Unprintable characters
set number " Display line numbers
set pumheight=8 " Limit completion menu height
" }}}

" Folding " {{{
set foldmethod=indent " Fold based on indent
set nofoldenable " Do not fold by default
" }}}

" Formatting " {{{
set expandtab " Use spaces instead of tabs
set nowrap " Disable line wrapping
set shiftwidth=2 " Number of spaces used for indentation
set softtabstop=2 " Makes <BS> (backspace key) treat two spaces like a tab
set tabstop=2 " Number of spaces for each <Tab>
"}}}

" Searching " {{{
set ignorecase " Ignore case sensitivity
set smartcase " Enable case-smart searching (overrides ignorecase)
" }}}

" Terminal {{{
if has('nvim')
  autocmd TermOpen * setlocal signcolumn=no nonumber ft=
endif
"}}}

" Key mappings " {{{

" Space as leader
let mapleader = " "

" Yank visual selection to clipboard
vnoremap <Leader>y "+y
" Yank with motion to clipboard
nnoremap <Leader>y "+y
" Yank line to clipboard
nnoremap <Leader>Y "+Y

" Paste clipboard contents on visual selection
vnoremap <Leader>p "+p
" Paste clipboard contents after cursor
nnoremap <Leader>p "+p
" Paste clipboard contents before cursor
nnoremap <Leader>P "+P

" Save/exit quicker
nnoremap <silent> <Leader>q :qall<CR>
nnoremap <silent> <Leader>w :write<CR>
nnoremap <silent> <Leader>x :xit<CR>

" Expand %% to file path
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" Select last pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Navigate buffers more easily
nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprev<CR>

" Automatically jump to end of pasted text
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" Paste in visual mode doesn't yank
xnoremap p pgvy

" C-n/p also cycle through command history
cmap <C-p> <Up>
cmap <C-n> <Down>

" Quickly navigate locationlist items
nnoremap <silent> [l :lprevious<CR>
nnoremap <silent> ]l :lnext<CR>
nnoremap <silent> [L :lfirst<CR>
nnoremap <silent> ]L :llast<CR>

" Quickly navigate quickfix items
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [Q :cfirst<CR>
nnoremap <silent> ]Q :clast<CR>

" Cleverly close buffers (based on reddit.com/em9qvv)
nnoremap <expr><Leader>d (bufnr('%') == getbufinfo({'buflisted': 1})[-1].bufnr ? ':bp' : ':bn').'<bar>bd #<CR>'

" More natural split opening
nnoremap <silent> <C-w>s :rightbelow split<CR>
nnoremap <silent> <C-w>v :rightbelow vsplit<CR>
nnoremap <silent> <C-w>n :rightbelow vnew<CR>

" Resize splits with purpose
augroup SaveWindowSize
  autocmd!
  autocmd VimEnter,VimResized * let full_width = winwidth(0)
  autocmd VimEnter,VimResized * let full_height = winheight(0)
augroup END

nnoremap <silent> <C-w>+ :execute 'resize ' . (winheight(0) + (full_height / 4))<CR>
nnoremap <silent> <C-w>- :execute 'resize ' . (winheight(0) - (full_height / 4))<CR>
nnoremap <silent> <C-w>> :execute 'vertical resize ' . (winwidth(0) + (full_width / 4))<CR>
nnoremap <silent> <C-w>< :execute 'vertical resize ' . (winwidth(0) - (full_width / 4))<CR>

" Visual Star Search (http://vim.wikia.com/wiki/VimTip171)
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>

" Easily clear search matches
nnoremap <silent> <Leader><Leader> :noh<CR>
" }}}

" Automatic commands {{{

" Resize all splits when host window is resized
augroup AutoResizeSplits
  autocmd!
  autocmd VimResized * wincmd =
augroup END

" Auto save buffers when focus is lost, like modern editors
augroup AutoSave
  autocmd!
  autocmd BufLeave,FocusLost * if !empty(bufname('%')) && &modified | write | endif
augroup END

" Close vim when quickfix is the only open buffer
augroup QuickfixAutoClose
  autocmd!
  autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), '&buftype') == 'quickfix' | quit | endif
augroup END

" Remember cursor position
augroup RememberCursorPosition
  autocmd!
  autocmd BufWinEnter * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"zv" | endif
augroup END

"}}}

" Functions and Commands "{{{

command! -nargs=1 -range=% Align :execute "<line1>,<line2>!sed 's/" . <f-args> . "/@". <f-args> . "/g' | column -s@ -t"

command! -nargs=0 -range SortLine <line1>,<line2>call setline('.',join(sort(split(getline('.'),' ')),' '))

function! GetVisualSelection()
  " Why is this not a built-in Vim script function!?
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction

command! StripTrailingWhitespaces :call <SID>exec_and_restore_cursor_position('%s/\s\+$//e')

fun! s:CloseHiddenBuffers() "{{{
  let open_buffers = []

  for i in range(tabpagenr('$'))
    call extend(open_buffers, tabpagebuflist(i+1))
  endfor

  for num in range(1, bufnr('$')+1)
    if buflisted(num) && index(open_buffers, num) == -1
      exec 'bdelete '.num
    endif
  endfor
endf
command! CloseHiddenBuffers call s:CloseHiddenBuffers()
" }}}

fun! s:exec_and_restore_cursor_position(command) "{{{
  let l:current_view = winsaveview()
  execute 'keeppatterns '.a:command
  call histadd('cmd', a:command)
  call winrestview(l:current_view)
endf
" }}}

fun! s:SyntaxGroupsForWordUnderCursor() "{{{
  if !exists('*synstack')
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endf
nmap <silent> <leader>sg :call <SID>SyntaxGroupsForWordUnderCursor()<CR>
"}}}

" Instant grep + quickfix {{{
" Source: https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
if executable('rg')
  set grepprg=rg\ --vimgrep
endif

function! Grep(...)
  return system(join([&grepprg] + [expand(join(a:000, ' '))], ' '))
endfunction

command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

augroup quickfix
  autocmd!
  autocmd FileType qf setlocal nobuflisted
  autocmd QuickFixCmdPost cgetexpr nested cwindow
  autocmd QuickFixCmdPost lgetexpr nested lwindow
augroup END
"}}}
"}}}

" StatusLine {{{
hi StatusLineNormal  gui=bold guifg=#3a3a3a guibg=#d5c4a1
hi StatusLineInsert  gui=bold guifg=#87dfff guibg=#005f87
hi StatusLineVisual  gui=bold guifg=#3a3a3a guibg=#ff8700
hi StatusLineReplace gui=bold guifg=#ffafaf guibg=#870000
hi StatusLineCommand gui=bold guifg=#ffd7ff guibg=#5f005f

function! StatusLineRenderer()
  let mode_colors = {
        \ 'n':  'StatusLineNormal',
        \ 'i':  'StatusLineInsert',
        \ 'v':  'StatusLineVisual',
        \ 'V':  'StatusLineVisual',
        \ '': 'StatusLineVisual',
        \ 'c':  'StatusLineCommand',
        \ 'R':  'StatusLineReplace'
        \ }

  let hl = '%#' . get(mode_colors, mode(), 'StatusLineNC') . '#'

  return hl
        \ . '%<'
        \ . '%f'
        \ . ' %{LintStatus()}'
        \ . '%{&ft=="help"?"\ \ ":""}'
        \ . '%{&modified?"":""}'
        \ . '%{&readonly?"":""}'
        \ . '%='
        \ . "%-14.(%l,%c%V%)"
        \ .' %P'
endfunction

augroup StatusLine
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter,BufDelete *
        \ setlocal statusline& |
        \ setlocal statusline=%!StatusLineRenderer()
  autocmd VimLeave,WinLeave,BufWinLeave *
        \ setlocal statusline&
augroup END
"}}}

" Third-Party Plugins {{{

" Auto-install vim-plug
let VIMPLUG = stdpath('config') . '/autoload/plug.vim'
if !filereadable(expand(VIMPLUG))
  execute '!curl -fLo '.VIMPLUG.' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  execute '!python3 -m pip install --user --upgrade pynvim'
endif

" Auto-install missing plugins
autocmd VimEnter *
      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
      \|   PlugInstall --sync | q | source $MYVIMRC
      \| endif

let PLUGINS_DIR = stdpath('config') . '/plugins'
call plug#begin(PLUGINS_DIR)

" Appearance
Plug 'kyazdani42/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'
Plug 'sheerun/vim-polyglot'
Plug 'sjl/badwolf'
Plug 'yggdroot/indentLine', { 'on': [] }

" Completion, Linting, LSP, etc
Plug 'neoclide/coc.nvim', { 'on': ['CocAction', 'CocCommand', 'CocList'], 'branch': 'release' }
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-treesitter/nvim-treesitter-refactor'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'nvim-treesitter/playground'
Plug 'tmsvg/pear-tree'
Plug 'w0rp/ale', { 'on': [] }

" Navigation
Plug 'christoomey/vim-tmux-navigator', { 'on': ['TmuxNavigateLeft', 'TmuxNavigateRight', 'TmuxNavigateUp', 'TmuxNavigateDown'] }
Plug 'junegunn/fzf', { 'on': [ 'FZF', 'BLines', 'Buffers', 'Commands', 'GFiles', 'Helptags', 'History' ], 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'on': [ 'BLines', 'Buffers', 'Commands', 'GFiles', 'Helptags', 'History' ] }
Plug 'kyazdani42/nvim-tree.lua'
Plug 'tpope/vim-projectionist', { 'on': [] }

" Misc
Plug 'itchyny/vim-qfedit', { 'on': [] }
Plug 'mhinz/vim-signify', { 'on': [] }
Plug 'obxhdx/vim-action-mapper'
Plug 'tpope/vim-commentary', { 'on': '<Plug>Commentary' }
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-surround', { 'on': [] }

" Test Runners
Plug 'benmills/vimux', { 'on': [] }
Plug 'janko/vim-test', { 'on': [] }

" Temporary settings/plugins, etc
if filereadable(expand('~/.vimrc.local.vim'))
  source ~/.vimrc.local.vim
endif

call plug#end()

" Lazy Loading {{{
function! LoadPlugins()
  call plug#load(
        \ 'ale',
        \ 'coc.nvim',
        \ 'fzf',
        \ 'fzf.vim',
        \ 'indentLine',
        \ 'pear-tree',
        \ 'vim-projectionist',
        \ 'vim-qfedit',
        \ 'vim-signify',
        \ 'vim-surround',
        \ 'vim-test',
        \ 'vimux',
        \ )
  echom 'Plugins will be loaded on CursorHold... Plugins loaded!'
endfunction

augroup LoadPlugins
  autocmd!
  autocmd VimEnter * echo 'Plugins will be loaded on CursorHold...'
  autocmd CursorHold * call LoadPlugins() | autocmd! LoadPlugins
augroup END
" }}}

" ActionMapper {{{
function! FindAndReplace(text, type) " {{{
  let l:use_word_boundary = index(['v', '^V'], a:type) < 0
  let l:pattern = l:use_word_boundary ? '<'.a:text.'>' : a:text
  let l:new_text = input('Replace '.l:pattern.' with: ', a:text)

  if len(l:new_text)
    call <SID>exec_and_restore_cursor_position(',$s/\v'.l:pattern.'/'.l:new_text.'/gc')
  endif
endfunction

autocmd User MapActions call MapAction('FindAndReplace', '<Leader>r')
"}}}

function! DebugLog(text, ...) "{{{
  let javascript_template = "console.log('==> %s:', %s);"
  let supported_languages = {
        \   'java': 'System.out.println("==> %s: " + %s);',
        \   'javascript': javascript_template,
        \   'javascript.jsx': javascript_template,
        \   'javascriptreact': javascript_template,
        \   'python': "print('==> %s:', %s)",
        \   'ruby': 'puts ("==> %s: #{%s}")',
        \   'typescript': javascript_template,
        \   'typescript.jsx': javascript_template,
        \   'typescriptreact': javascript_template,
        \ }
  let log_expression = get(supported_languages, &ft, '')

  if empty(log_expression)
    echohl ErrorMsg | echo 'DebugLog: filetype "'.&ft.'" not suppported.' | echohl None
    return
  endif

  execute "normal o".printf(log_expression, a:text, a:text)
endfunction

autocmd User MapActions call MapAction('DebugLog', '<leader>l')
"}}}

function! GrepWithMotion(text, type) "{{{
  execute('Grep '.a:text)
endfunction

autocmd User MapActions call MapAction('GrepWithMotion', '<Leader>g')
"}}}
"}}}

" Ale {{{
let g:ale_echo_msg_format = '%linter%(%code%): %s [%severity%]'
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_linters_ignore = { 'javascript': ['tsserver'], 'javascript.jsx': ['tsserver'] }
let g:ale_set_quickfix = 1
let g:ale_sign_error = '●'
let g:ale_sign_warning = '●'
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = '➜  '

nmap ]d <Plug>(ale_next)
nmap [d <Plug>(ale_previous)

autocmd ColorScheme * hi ALEErrorSign guifg=red
      \| hi ALEInfoSign guifg=cyan
      \| hi ALEWarningSign guifg=orange
      \| hi ALEVirtualTextError guibg=NONE guifg=red
      \| hi ALEVirtualTextInfo guibg=NONE guifg=cyan
      \| hi ALEVirtualTextWarning guibg=NONE guifg=yellow
      \| hi ALEWarning guifg=grey

function! s:NumberToSuperscript(number) abort
  if a:number > 9
    return '⁹⁺'
  endif
  return {
    \ 0: '⁰',
    \ 1: '¹',
    \ 2: '²',
    \ 3: '³',
    \ 4: '⁴',
    \ 5: '⁵',
    \ 6: '⁶',
    \ 7: '⁷',
    \ 8: '⁸',
    \ 9: '⁹',
    \ }[a:number]
endfunction

function! LintStatus() abort
  if get(b:, 'lint_started', v:false) == v:false
    return ''
  endif

  let l:counts = ale#statusline#Count(bufnr('%'))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  if ale#engine#IsCheckingBuffer(bufnr('%'))
    return '  '
  elseif l:counts.total == 0
    return '  '
  elseif l:counts.total > 0
    return printf(' %s  %s ', s:NumberToSuperscript(all_non_errors), s:NumberToSuperscript(all_errors))
  else
    return ''
  endif
endfunction

augroup LintProgress
  autocmd!
  autocmd User ALELintPre  let b:lint_started = v:true
  autocmd User ALEFixPre   let b:lint_started = v:true
augroup END

" }}}

" barbar {{{
let bufferline = {}
let bufferline.maximum_padding = 1
let bufferline.animation = v:false

" Magic buffer-picking mode
nnoremap <silent> <C-s> :BufferPick<CR>
" Move to previous/next
autocmd VimEnter * nnoremap <silent> <C-p> :BufferPrevious<CR>
autocmd VimEnter * nnoremap <silent> <C-n> :BufferNext<CR>
" Close buffer
nnoremap <silent> <Leader>d :BufferClose<CR>

let g:icons = {
      \ 'bufferline_separator_active':   '|',
      \ 'bufferline_separator_inactive': '|',
      \ }

let s:base6       = '#73797e'
let s:base7       = '#9ca0a4'
let s:base8       = '#b1b1b1'
let s:black       = '#1c1f24'
let s:blue        = '#51afef'
let s:dark_gray   = '#262626'
let s:red         = '#ff6c6b'
let s:warm_white  = '#d5c4a1'
let s:yellow      = '#ecbe7b'

function! s:hi(group, fg, bg, attr)
  if a:fg != ""
    exec "hi " . a:group . " guifg=" . a:fg
  endif
  if a:bg != ""
    exec "hi " . a:group . " guibg=" . a:bg
  endif
  if a:attr != ""
    exec "hi " . a:group . " gui=" . a:attr
  endif
endfunction

function! TablineColors() abort
  "      Current: current buffer
  "      Visible: visible but not current buffer
  "     Inactive: invisible but not current buffer
  "         -Mod: when modified
  "        -Sign: the separator between buffers
  "      -Target: letter in buffer-picking mode
  " BufferShadow: shadow in buffer-picking mode

  call s:hi('TabLine',               s:base7,       'none',       'bold')
  call s:hi('TabLineSel',            s:blue,        'none',       'bold')
  call s:hi('TabLineFill',           'none',        s:dark_gray,  'bold')

  call s:hi('BufferCurrent',         s:warm_white,  'none',       'bold')
  call s:hi('BufferCurrentMod',      s:yellow,      'none',       'bold')
  call s:hi('BufferCurrentSign',     s:blue,        'none',       'bold')
  call s:hi('BufferCurrentTarget',   s:red,         'none',       'bold')

  call s:hi('BufferVisible',         s:base8,       s:dark_gray,  'none')
  call s:hi('BufferVisibleMod',      s:yellow,      s:dark_gray,  'bold')
  call s:hi('BufferVisibleSign',     s:base6,       s:dark_gray,  'bold')
  call s:hi('BufferVisibleTarget',   s:red,         s:dark_gray,  'bold')

  call s:hi('BufferInactive',        s:base7,       s:dark_gray,  'none')
  call s:hi('BufferInactiveMod',     s:yellow,      s:black,      'bold')
  call s:hi('BufferInactiveSign',    s:dark_gray,   s:dark_gray,  'bold')
  call s:hi('BufferInactiveTarget',  s:red,         s:dark_gray,  'bold')
endfunction

autocmd ColorScheme * call TablineColors()
" }}}

" BufTabline {{{
let g:buftabline_show = 1
let g:buftabline_indicators = 1
hi BufTabLineCurrent gui=bold guibg=#ff5f5f guifg=#080808
hi BufTabLineActive  gui=bold guibg=#3a3a3a guifg=#ff5f5f
hi BufTabLineHidden  gui=bold guibg=#3a3a3a guifg=#D5C4A1
hi BufTabLineFill    gui=bold guibg=#3a3a3a guifg=#D5C4A1
" }}}

" CoC {{{
let g:coc_node_path = expand("$LATEST_NODE_PATH")

" Echo method signatures
function! s:ShowCodeSignature()
  if exists('*CocActionAsync') && &ft =~ 'javascript'
    call CocActionAsync('showSignatureHelp')
  endif
endfunction

augroup ShowCodeSignature
  autocmd!
  autocmd User CocJumpPlaceholder call <SID>ShowCodeSignature()
  autocmd CursorHoldI * call <SID>ShowCodeSignature()
augroup END

" if hidden not set, TextEdit might fail.
set hidden

" always show signcolumns
set signcolumn=yes

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>ShowDocumentation()<CR>

function! s:ShowDocumentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Use <C-n> to trigger completion menu
inoremap <silent><expr> <C-n> coc#refresh()

" Go-to mappings
nmap <silent> <leader>cd <Plug>(coc-definition)
nmap <silent> <leader>ct <Plug>(coc-type-definition)
nmap <silent> <leader>ci <Plug>(coc-implementation)
nmap <silent> <leader>cf <Plug>(coc-references)
nmap <silent> <leader>cr <Plug>(coc-rename)

" UltiSnips compatibility
let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'

inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
"}}}

" Color Scheme {{{
function! SanitizeColors()
  hi CursorLine guibg=#444444
  hi LineNr guibg=NONE
  hi MatchParen guibg=NONE
  hi Normal guibg=NONE
  hi Pmenu guifg=#f8f6f2 guibg=#484A55
  hi PmenuSbar guibg=#2B2C31
  hi PmenuThumb guibg=grey
  hi SignColumn guibg=NONE
  hi StatusLineNC gui=bold guifg=gray guibg=#262626
  hi VertSplit guifg=#3a3a3a guibg=#3a3a3a
  hi Visual guibg=#626262
  hi! link ColorColumn CursorLine

  hi VertSplit guibg=#262626 guifg=#262626
  hi NormalNC guibg=#3a3a3a

  if g:colors_name == 'badwolf'
    hi DiffAdd guibg=#143800
    hi DiffDelete guibg=#380000
    hi Noise guifg=#949494
    hi NonText guibg=NONE
    hi QuickFixLine gui=NONE guibg=#32302f
    hi! link StatusLine StatusLineNormal
    hi! link jsxBraces Noise
    hi! link typescriptBraces Noise
    hi! link typescriptParens Noise
    hi! link typescriptImport Include
    hi! link typescriptExport Include
    hi! link typescriptVariable typescriptAliasKeyword
    hi! link typescriptBOM Normal
  endif
endf

autocmd ColorScheme * call SanitizeColors()

try
  if (has("termguicolors"))
    set termguicolors
  endif

  colorscheme badwolf
catch | endtry
" }}}

" Commentary {{{
map gc <Plug>Commentary
nmap gcc <Plug>CommentaryLine
autocmd FileType lisp setlocal commentstring=;;\ %s " fix lisp comment strings
" }}}

" File Explorer {{{
let g:lua_tree_ignore = ['.git']
let g:lua_tree_follow = 1
let g:lua_tree_indent_markers = 1
let g:lua_tree_show_icons = {
    \ 'git': 0,
    \ 'folders': 1,
    \ 'files': 1,
    \ }
let g:lua_tree_icons = {
    \ 'default': '',
    \ 'symlink': '',
    \ }
map <silent> <Leader>nf :LuaTreeFindFile<CR>
map <silent> <Leader>nt :LuaTreeToggle<CR>
nnoremap <silent> <C-n> :if &filetype != 'LuaTree' <Bar> execute 'BufferNext' <Bar> endif<CR>
nnoremap <silent> <C-p> :if &filetype != 'LuaTree' <Bar> execute 'BufferPrevious' <Bar> endif<CR>
"}}}

" FZF {{{
let g:fzf_layout = { 'window': { 'width': 0.7, 'height': 0.4 } }
let g:projectionist_ignore_term = 1 " workaround for slownes when fzf and projectionist are enabled

nnoremap <silent> <Leader>fb :Buffers<CR>
nnoremap <silent> <Leader>fc :Commands<CR>
nnoremap <silent> <Leader>ff :Files<CR>
nnoremap <silent> <Leader>fh :History:<CR>
nnoremap <silent> <Leader>fl :BLines<CR>
nnoremap <silent> <Leader>fr :History<CR>

" Visual selection mappings
vnoremap <silent> <Leader>ff :<C-u>execute 'FZF -q ' . GetVisualSelection()<CR>
vnoremap <silent> <Leader>fl :call fzf#vim#buffer_lines({'options': '-q ' . GetVisualSelection()})<CR>
"}}}

" IndentLine {{{
let g:indentLine_faster = 1
let g:indentLine_char = '┊'
let g:indentLine_fileTypeExclude = ['help', 'nerdtree']
" Enable after plugin is lazily loaded:
" This is required because (for some reason) ale makes indent lines disappear
" when it loads
autocmd! User indentLine IndentLinesEnable
" }}}


" pear-tree {{{
let g:pear_tree_pairs = {
      \ '"': {'closer': '"'},
      \ '{': {'closer': '}'},
      \ '''': {'closer': ''''},
      \ '(': {'closer': ')'},
      \ '[': {'closer': ']'},
      \ '<': {'closer': '>'}
      \ }

autocmd FileType typescriptreact
      \ let b:pear_tree_pairs = extend(deepcopy(g:pear_tree_pairs), {
      \ '<*>': {'closer': '</*>',
      \         'not_if': [],
      \         'not_like': '/$',
      \         'until': '[^a-zA-Z0-9-._]'
      \        }
      \ }, 'keep')
"}}}

" Polyglot {{{
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
"}}}

" Projectionist {{{
nnoremap <silent> <Leader>aa :A<CR>
nnoremap <silent> <Leader>as :AS<CR>
nnoremap <silent> <Leader>av :AV<CR>
"}}}

" Signify {{{
hi SignifySignAdd    guifg=#9BB76D guibg=NONE
hi SignifySignChange guifg=#00AFFF guibg=NONE
hi SignifySignDelete guifg=#FF5F5F guibg=NONE

let g:signify_sign_add               = '│'
let g:signify_sign_delete            = '│'
let g:signify_sign_delete_first_line = '│'
let g:signify_sign_change            = '│'
let g:signify_sign_changedelete = g:signify_sign_change
let g:signify_sign_show_count = 0
"}}}

" Tmux Navigator {{{
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<CR>
nnoremap <silent> <M-j> :TmuxNavigateDown<CR>
nnoremap <silent> <M-k> :TmuxNavigateUp<CR>
nnoremap <silent> <M-l> :TmuxNavigateRight<CR>
"}}}

" Tree-sitter {{{
autocmd VimEnter * luafile $HOME/.config/nvim/init.lua
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
"}}}

" VimTest {{{
let test#strategy = 'vimux'
nnoremap <Leader>tf :TestFile<CR>
nnoremap <Leader>tl :TestLast<CR>
nnoremap <Leader>tn :TestNearest<CR>
nnoremap <Leader>ts :TestSuite<CR>
nnoremap <Leader>tv :TestVisit<CR>
"}}}
"}}}

" vim: set foldmethod=marker foldenable :

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
hi StatusLineNormal  cterm=bold ctermfg=232 ctermbg=15  gui=bold guifg=#3a3a3a guibg=#d5c4a1
hi StatusLineInsert  cterm=bold ctermfg=117 ctermbg=24  gui=bold guifg=#87dfff guibg=#005f87
hi StatusLineVisual  cterm=bold ctermfg=52  ctermbg=208 gui=bold guifg=#3a3a3a guibg=#ff8700
hi StatusLineReplace cterm=bold ctermfg=217 ctermbg=88  gui=bold guifg=#ffafaf guibg=#870000
hi StatusLineCommand cterm=bold ctermfg=225 ctermbg=53  gui=bold guifg=#ffd7ff guibg=#5f005f

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

"}}}

" Third-Party Plugins {{{
let VIMPLUG_DIR='~/.dotfiles/config/config/nvim/autoload/plug.vim'
let PLUGINS_DIR='~/.vim/plugins'

if empty(glob(VIMPLUG_DIR)) || empty(glob(PLUGINS_DIR))
  execute '!curl -fLo '.VIMPLUG_DIR.' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  execute '!python3 -m pip install --user --upgrade pynvim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(PLUGINS_DIR)

" Appearance
Plug 'ap/vim-buftabline'
Plug 'ryanoasis/vim-devicons'
Plug 'sheerun/vim-polyglot'
Plug 'sjl/badwolf'
Plug 'yggdroot/indentLine', { 'on': [] }

" Code Completion
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', { 'on': ['CocAction', 'CocCommand', 'CocList'], 'branch': 'release' }

" Linting & Formatting
Plug 'tpope/vim-sleuth', { 'on': [] }
Plug 'w0rp/ale', { 'on': [] }

" Navigation
Plug 'christoomey/vim-tmux-navigator', { 'on': ['TmuxNavigateLeft', 'TmuxNavigateRight', 'TmuxNavigateUp', 'TmuxNavigateDown'] }
Plug 'junegunn/fzf', { 'on': [ 'FZF', 'BLines', 'Buffers', 'Commands', 'GFiles', 'Helptags', 'History' ], 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'on': [ 'BLines', 'Buffers', 'Commands', 'GFiles', 'Helptags', 'History' ] }
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-projectionist', { 'on': [] }

" Misc
Plug 'itchyny/vim-qfedit', { 'on': [] }
Plug 'mhinz/vim-signify', { 'on': [] }
Plug 'obxhdx/vim-action-mapper'
Plug 'obxhdx/vim-auto-highlight', { 'on': [] }
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
        \ 'auto-pairs',
        \ 'coc.nvim',
        \ 'fzf',
        \ 'fzf.vim',
        \ 'indentLine',
        \ 'vim-auto-highlight',
        \ 'vim-projectionist',
        \ 'vim-qfedit',
        \ 'vim-signify',
        \ 'vim-sleuth',
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
autocmd! User MapActions

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

autocmd ColorScheme * hi ALEErrorSign ctermfg=red guifg=red
      \| hi ALEInfoSign ctermfg=cyan guifg=cyan
      \| hi ALEWarningSign ctermfg=yellow guifg=orange
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

" AutoHighlightWord {{{
let g:auto_highlight#disabled_filetypes = ['nerdtree', 'qf']
set updatetime=500 " Make CursorHold trigger faster
" Tweak color after plugin is lazily loaded on demand:
autocmd! User vim-auto-highlight hi AutoHighlightWord ctermbg=238 guibg=darkslategray
" }}}

" Auto-Pairs {{{
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutFastWrap = ''
let g:AutoPairsShortcutJump = ''
let g:AutoPairsShortcutBackInsert = ''
"}}}

" BufTabline {{{
let g:buftabline_show = 1
let g:buftabline_indicators = 1
hi BufTabLineCurrent ctermbg=203 ctermfg=232 guibg=#ff5f5f guifg=#080808
hi BufTabLineActive ctermbg=236 ctermfg=203 guibg=#3a3a3a guifg=#ff5f5f
hi BufTabLineHidden ctermbg=236 guibg=#3a3a3a guifg=#D5C4A1
hi BufTabLineFill ctermbg=236 guibg=#3a3a3a guifg=#D5C4A1
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
  hi CursorLine ctermbg=238 term=NONE cterm=NONE guibg=#444444
  hi LineNr ctermbg=NONE guibg=NONE
  hi MatchParen guibg=NONE
  hi Normal guibg=NONE
  hi Pmenu ctermfg=15 ctermbg=236 guifg=#f8f6f2 guibg=#484A55
  hi PmenuSbar ctermbg=236 guibg=#2B2C31
  hi PmenuThumb ctermbg=236 guibg=grey
  hi SignColumn guibg=NONE
  hi StatusLineNC cterm=bold ctermfg=15 ctermbg=238 gui=bold guifg=#d5c4a1 guibg=#3a3a3a
  hi VertSplit ctermfg=237 ctermbg=237 guifg=#3a3a3a guibg=#3a3a3a
  hi Visual ctermbg=238 guibg=#626262
  hi! link ColorColumn CursorLine
  hi! link NormalNC ColorColumn

  if g:colors_name == 'badwolf'
    hi DiffAdd guibg=#143800
    hi DiffDelete guibg=#380000
    hi Noise guifg=#949494
    hi NonText guibg=NONE
    hi QuickFixLine gui=NONE guibg=#32302f
    hi parens guifg=#9e9e9e
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

" FZF {{{
let g:fzf_layout = { 'window': { 'width': 0.7, 'height': 0.4 } }
let g:projectionist_ignore_term = 1 " workaround for slownes when fzf and projectionist are enabled

nnoremap <silent> <Leader>fb :Buffers<CR>
nnoremap <silent> <Leader>fc :Commands<CR>
nnoremap <silent> <Leader>ff :GFiles<CR>
nnoremap <silent> <Leader>fh :History:<CR>
nnoremap <silent> <Leader>fl :BLines<CR>
nnoremap <silent> <Leader>fr :History<CR>

" Find file using visual selection
vnoremap <silent> <Leader>ff "py:execute ":FZF -q " . getreg("p")<CR>
"}}}

" IndentLine {{{
let g:indentLine_faster = 1
let g:indentLine_char = get(g:, 'indentLine_char', '┊')
let g:indentLine_bufTypeExclude = ['help']
" Enable after plugin is lazily loaded on demand:
autocmd! User indentLine IndentLinesEnable
" }}}

" NERDTree {{{
let g:NERDTreeDirArrowCollapsible = '◢'
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeMapActivateNode = '<CR>'
let g:NERDTreeMinimalUI = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeStatusline = 'NERDTree '
let g:NERDTreeWinSize = '35'
let g:loaded_netrwPlugin = 1
" Custom mappings
let NERDTreeMapCustomOpen = '<C-j>'

" DevIcons integration
let g:DevIconsDefaultFolderOpenSymbol = ''
let g:DevIconsEnableFoldersOpenClose = 1
let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '
let g:WebDevIconsNerdTreeBeforeGlyphPadding = ''
let g:WebDevIconsUnicodeDecorateFileNodesDefaultSymbol = ''

hi NERDTreeClosable guifg=cyan
hi NERDTreeDir gui=bold guifg=deeppink
hi NERDTreeFile guifg=lightgray
hi NERDTreeFlags guifg=palevioletred
hi! link NERDTreeDirSlash NERDTreeFlags
hi! link NERDTreeOpenable NERDTreeFlags

fun! s:NERDTreeFindWrapper()
  if empty(bufname('%')) || &ft == 'nerdtree'
    NERDTreeToggle
  else
    NERDTreeFind
    normal zz
  endif
endfunction

" Prevent buffer loads within nerdtree
nnoremap <silent> <C-n> :if &filetype != 'nerdtree' <Bar> :bnext <Bar> endif<CR>
nnoremap <silent> <C-p> :if &filetype != 'nerdtree' <Bar> :bprev <Bar> endif<CR>

map <silent> <Leader>nf :call <SID>NERDTreeFindWrapper()<CR>
map <silent> <Leader>nt :NERDTreeToggle<CR>
" }}}

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
hi SignifySignAdd ctermfg=green ctermbg=NONE guifg=#9BB76D guibg=NONE
hi SignifySignChange ctermfg=cyan ctermbg=NONE guifg=#00AFFF guibg=NONE
hi SignifySignDelete ctermfg=red ctermbg=NONE guifg=#FF5F5F guibg=NONE

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

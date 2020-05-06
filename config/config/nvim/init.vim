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
nnoremap <Leader>q :qall<CR>
nnoremap <Leader>w :write<CR>
nnoremap <Leader>x :xit<CR>

" Expand %% to file path
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" Find/replace
noremap <Leader>r :%s/\C\<<C-r>=expand("<cword>")<CR>\>/<C-r>=expand("<cword>")<CR>/gc<left><left><left>
noremap <Leader><Leader>r :%s/\C<C-r>=expand("<cword>")<CR>/<C-r>=expand("<cword>")<CR>/gc<left><left><left>

" Select last pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Navigate buffers more easily
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprev<CR>

" Automatically jump to end of pasted text
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" Pase in visual mode doesn't yank
xnoremap p pgvy

" C-n/p also cycle through command history
cmap <C-p> <Up>
cmap <C-n> <Down>

" Quickly navigate quickfix windows
nnoremap [L :lfirst<CR>
nnoremap [Q :cfirst<CR>
nnoremap [l :lprevious<CR>
nnoremap [q :cprevious<CR>
nnoremap ]L :llast<CR>
nnoremap ]Q :clast<CR>
nnoremap ]l :lnext<CR>
nnoremap ]q :cnext<CR>

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
" }}}

" Auto commands {{{
augroup AutoResizeSplits
  autocmd!
  " Resize all splits when host window is resized
  autocmd VimResized * wincmd =
augroup END

augroup AutoSave
  autocmd!
  " Auto save buffers when focus is lost, like modern editors
  autocmd BufLeave,FocusLost * if !empty(bufname('%')) && &modified | write | endif
augroup END

augroup QuickfixAutoClose
  autocmd!
  " Close vim when quickfix is the only open buffer
  autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), '&buftype') == 'quickfix' | quit | endif
augroup END
"}}}

" Functions and Commands "{{{

command! -nargs=1 -range=% Align :execute "<line1>,<line2>!sed 's/" . <f-args> . "/@". <f-args> . "/g' | column -s@ -t" "{{{
"}}}

command! -nargs=0 -range SortLine <line1>,<line2>call setline('.',join(sort(split(getline('.'),' ')),' ')) "{{{
"}}}

command! StripTrailingWhitespaces :call <SID>ExecPreservingCursorPos('%s/\s\+$//e') "{{{
"}}}

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

fun! s:ExecPreservingCursorPos(command) "{{{
  " Taken from http://goo.gl/DJ7xA

  " Save last search and cursor position
  let _s=@/
  let l = line('.')
  let c = col('.')

  " Do the business
  execute a:command
  call histadd('cmd', a:command)

  " Restore previous search history and cursor position
  let @/=_s
  call cursor(l, c)
endf
" }}}

fun! s:SyntaxGroupsForWordUnderCursor() "{{{
  if !exists('*synstack')
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endf
nmap <leader>sg :call <SID>SyntaxGroupsForWordUnderCursor()<CR>
"}}}

"}}}

" Sensitive/Temporary settings " {{{
if filereadable(expand('~/.vimrc.local.vim'))
  source ~/.vimrc.local.vim
endif
" }}}

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
Plug 'sheerun/vim-polyglot'
Plug 'sjl/badwolf'
Plug 'yggdroot/indentLine', { 'on': [] }

" Code Completion
Plug 'honza/vim-snippets', { 'on': [] }
Plug 'neoclide/coc.nvim', { 'on': ['CocAction', 'CocCommand', 'CocList'], 'branch': 'release' }

" Linting & Formatting
Plug 'tpope/vim-sleuth', { 'on': [] }
Plug 'w0rp/ale', { 'on': [] }

" Navigation
Plug 'christoomey/vim-tmux-navigator'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-projectionist', { 'on': [] }
Plug 'yggdroot/LeaderF', { 'on': ['Leaderf'], 'do': './install.sh' }

" Misc
Plug 'mhinz/vim-signify', { 'on': [] }
Plug 'obxhdx/vim-action-mapper'
Plug 'obxhdx/vim-auto-highlight', { 'on': [] }
Plug 'tpope/vim-commentary', { 'on': '<Plug>Commentary' }
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-surround', { 'on': [] }

call plug#end()

" Lazy Loading {{{
function! LoadPlugins()
  call plug#load('ale', 'coc.nvim', 'indentLine', 'vim-auto-highlight', 'vim-projectionist', 'vim-signify', 'vim-sleuth', 'vim-snippets', 'vim-surround')
  echom 'All plugins loaded.'
endfunction

augroup LoadPlugins
  autocmd!
  autocmd CursorHold * call LoadPlugins() | autocmd! LoadPlugins
augroup END
" }}}

" ActionMapper {{{
autocmd! User MapActions

function! s:FindAndReplace(text, use_word_boundary) " {{{
  let l:pattern = a:use_word_boundary ? '<'.a:text.'>' : a:text
  let l:new_text = input('Replace '.l:pattern.' with: ', a:text)

  if len(l:new_text)
    call <SID>ExecPreservingCursorPos(',$s/\v'.l:pattern.'/'.l:new_text.'/gc')
  endif
endfunction

function! FindAndReplaceWithWordBoundary(text, ...)
  let l:use_word_boundary = 1
  execute s:FindAndReplace(a:text, l:use_word_boundary)
endfunction

function! FindAndReplaceWithoutWordBoundary(text, ...)
  let l:use_word_boundary = 0
  execute s:FindAndReplace(a:text, l:use_word_boundary)
endfunction

autocmd User MapActions call MapAction('FindAndReplaceWithWordBoundary', '<leader>r')
autocmd User MapActions call MapAction('FindAndReplaceWithoutWordBoundary', '<leader><leader>r')
"}}}

function! DebugLog(text, ...) "{{{
  let l:supported_languages = ['javascript', 'javascript.jsx']
  if index(l:supported_languages, &ft) < 0
    return
  endif
  execute "normal o"
  execute "normal iconsole.log('==> ".substitute(a:text, "'", '"', 'g')."', ".a:text.");"
endfunction

autocmd User MapActions call MapAction('DebugLog', '<leader>l')
"}}}

function! GrepWithLeaderF(text, type) "{{{
  let l:base_cmd = 'Leaderf rg '.expand('$LEADERF_GREP_OPTS')
  let l:pattern = index(['v', ''], a:type) >= 0 ? a:text : '"\b'.a:text.'\b"'
  execute(l:base_cmd.' '.l:pattern)
endfunction

autocmd User MapActions call MapAction('GrepWithLeaderF', '<Leader>g')
"}}}
"}}}

" Ale {{{
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
  if get(g:, 'lint_status', 0) == 0
    return ''
  endif

  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  let b:linted = get(b:, 'linted', v:false)

  if g:lint_status == 1
    return '  '
  elseif b:linted && l:counts.total == 0
    return '  '
  elseif l:counts.total > 0
    let b:linted = v:true
    return printf(' %s  %s ', s:NumberToSuperscript(all_non_errors), s:NumberToSuperscript(all_errors))
  else
    return ''
  endif
endfunction

augroup LintProgress
  autocmd!
  autocmd BufReadPost *    let g:lint_status = 0  " Not started
  autocmd User ALELintPre  let g:lint_status = 1  " In progress
  autocmd User ALEFixPre   let g:lint_status = 1  " In progress
  autocmd User ALELintPost let g:lint_status = 2  " Finished
  autocmd User ALEFixPost  let g:lint_status = 2  " Finished
augroup END

set statusline=%<%f\ %{LintStatus()}%*%{&ft=='help'?'\ \ ':''}%{&modified?'':''}%{&readonly?'':''}%=%-14.(%l,%c%V%)\ %P
" }}}

" AutoHighlightWord {{{
let g:auto_highlight#disabled_filetypes = ['nerdtree', 'qf']
set updatetime=500 " Make CursorHold trigger faster
" Tweak color after plugin is lazily loaded on demand:
autocmd! User vim-auto-highlight hi AutoHighlightWord ctermbg=238 guibg=darkslategray
" }}}

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

" Remap keys for gotos
nmap <silent> <leader>cd <Plug>(coc-definition)
nmap <silent> <leader>ct <Plug>(coc-type-definition)
nmap <silent> <leader>ci <Plug>(coc-implementation)
nmap <silent> <leader>cf <Plug>(coc-references)
nmap <silent> <leader>co :<C-u>CocList outline<CR>

" Remap for rename current word
nmap <leader>crn <Plug>(coc-rename)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vmap <leader>ca <Plug>(coc-codeaction-selected)
nmap <leader>ca <Plug>(coc-codeaction-selected)

" Notify coc that <CR> has been pressed (for coc-pairs to auto-indent on Enter)
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"

" UltiSnips compatibility
let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'

autocmd CompleteDone * if pumvisible() == 0 | pclose | endif

autocmd VimEnter * inoremap <silent><expr> <TAB>
      \ pumvisible() ?  "<C-y>" :
      \ coc#expandableOrJumpable() ? coc#rpc#request('doKeymap', ['snippets-expand-jump', '']) :
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
  hi VertSplit ctermfg=237 ctermbg=237 guifg=#3a3a3a guibg=#3a3a3a
  hi Visual ctermbg=238 guibg=#626262
  hi! link ColorColumn CursorLine
  hi! link NormalNC ColorColumn

  if g:colors_name == 'badwolf'
    hi DiffAdd guibg=#143800
    hi DiffDelete guibg=#380000
    hi IncSearch guibg=lightgreen guifg=black gui=bold
    hi Noise guifg=#949494
    hi NonText guibg=NONE
    hi SignifySignAdd guifg=#B8BB26 guibg=#3A3A3A
    hi parens guifg=#9e9e9e
    hi! link Search IncSearch
  endif

  hi StatusLineNormal cterm=NONE ctermfg=232 ctermbg=15  gui=NONE guifg=#3a3a3a guibg=#d5c4a1
  hi StatusLineInsert cterm=NONE ctermfg=117 ctermbg=24  gui=NONE guifg=#87dfff guibg=#005f87
  hi StatusLineNC     cterm=NONE ctermfg=15  ctermbg=238 gui=NONE guifg=#d5c4a1 guibg=#3a3a3a

  hi! link StatusLine StatusLineNormal

  autocmd InsertEnter * hi clear StatusLine | hi! link StatusLine StatusLineInsert
  autocmd InsertLeave * hi clear StatusLine | hi! link StatusLine StatusLineNormal
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
" }}}

" IndentLine {{{
let g:indentLine_faster = 1
let g:indentLine_char = get(g:, 'indentLine_char', '┊')
let g:indentLine_bufTypeExclude = ['help']
" Enable after plugin is lazily loaded on demand:
autocmd! User indentLine IndentLinesEnable
" }}}

" LeaderF {{{
let g:Lf_CommandMap = { '<Left>': ['<C-b>'], '<Right>': ['<C-f>'], '<Home>': ['<C-a>'], '<End>': ['<C-e>'] }
let g:Lf_HideHelp = 1
let g:Lf_PreviewInPopup = 1
let g:Lf_PreviewResult = { 'Line': 1 }
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2" }
let g:Lf_WindowPosition = 'popup'
nnoremap <Leader>fb :Leaderf buffer<CR>
nnoremap <Leader>fc :Leaderf command<CR>
nnoremap <Leader>ff :Leaderf file<CR>
nnoremap <Leader>fh :Leaderf help<CR>
nnoremap <Leader>fl :Leaderf line<CR>
nnoremap <Leader>fr :Leaderf mru<CR>
command! -nargs=* Grep :execute 'Leaderf rg '.expand('$LEADERF_GREP_OPTS').' '.<q-args>
"}}}

" NERDTree {{{
let g:loaded_netrwPlugin = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeWinSize = '35'
let g:NERDTreeShowHidden = 1
let g:NERDTreeMapActivateNode = '<CR>'

hi NERDTreeClosable guifg=cyan

fun! s:NERDTreeFindWrapper()
  if empty(bufname('%')) || &ft == 'nerdtree'
    NERDTreeToggle
  else
    NERDTreeFind
    normal zz
  endif
endfunction

map <silent> <Leader>nf :call <SID>NERDTreeFindWrapper()<CR>
map <silent> <Leader>nt :NERDTreeToggle<CR>
" }}}

" Polyglot {{{
let g:vim_markdown_conceal = 0
"}}}

" Projectionist {{{
nnoremap <Leader>aa :A<CR>
nnoremap <Leader>as :AS<CR>
nnoremap <Leader>av :AV<CR>
"}}}

" Signify {{{
hi SignifySignAdd ctermfg=green ctermbg=NONE guifg=#B8BB26 guibg=NONE
hi SignifySignChange ctermfg=yellow ctermbg=NONE guifg=#FABD30 guibg=NONE
hi SignifySignDelete ctermfg=red ctermbg=NONE guifg=#FB4934 guibg=NONE

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

"}}}

" vim: set foldmethod=marker foldenable :

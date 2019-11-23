" General Options " {{{
set wildmenu " Enable command line completion menu
set wildoptions=tagfile " Use classic completion menu instead of floating window
set mouse=a " Enable mouse
set noshowmode " Don't show edit mode in command bar
" }}}

" Appearance " {{{
set cursorline " Highlight current line
set guicursor=a:hor25-blinkon10,i:ver25-blinkon10 " Switch cursor shape between vertical/underline bar (Insert/Normal)
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
autocmd TermOpen * setlocal signcolumn=no nonumber ft=
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

" Faster way to save/quit
nnoremap <Leader>w :write<CR>
nnoremap <Leader>x :xit<CR>
nnoremap <Leader>q :quit<CR>
nnoremap <Leader>d :bnext<bar>bdelete#<CR>

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
" }}}

" Automatic commands"{{{
autocmd VimResized * wincmd = " Resize all splits when host window is resized

augroup QuickfixAutoClose
  autocmd!
  autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype") == "quickfix" | q | endif
augroup END
"}}}

" Functions and Commands "{{{

" Align command (format text in columns) {{{
command! -nargs=1 -range=% Align :execute "<line1>,<line2>!sed 's/" . <f-args> . "/@". <f-args> . "/g' | column -s@ -t"
"}}}

" StripTrailingWhitespaces command {{{
command! StripTrailingWhitespaces :call <SID>ExecPreservingCursorPos('%s/\s\+$//e')
" }}}

fun! s:CloseBuffer() "{{{
  if bufname('%') =~ '^term://'
    silent! bdelete!
  else
    bnext | silent! bdelete#
  endif
endfunction
nnoremap <silent> <Leader>d :call <SID>CloseBuffer()<CR>
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

  " Restore previous search history and cursor position
  let @/=_s
  call cursor(l, c)
endf
" }}}

fun! s:GitAnnotate() "{{{
  " save cursor position
  let l:current_line = line('.')
  normal gg

  " create annotate buffer
  execute 'vnew | 0read !git annotate '.expand('%')." | awk '{print $1,$2,$3}' | sed -E 's/\\( ?//g'"
  " adjust buffer width to longest line
  execute 'vertical resize '.max(map(getline(1,'$'), 'len(v:val)'))
  " delete last line
  execute 'normal Gddgg'

  " configure annotate buffer
  setlocal bufhidden=hide buftype=nofile nobuflisted nonumber noswapfile nomodifiable statusline=git-annotate
  silent! file git-annotate
  nnoremap <buffer> <silent> <CR> :<C-U>exe <SID>GitBlameCommit((&splitbelow ? "botright" : "topleft")." new")<CR>

  " lock cursor and scroll
  windo setlocal cursorbind scrollbind
  windo execute 'normal '.l:current_line.'Gzz'
  wincmd h

  " unlock when annotate buffer closes
  autocmd BufHidden git-annotate windo set nocursorbind noscrollbind
endf
command! GitAnnotate :call s:GitAnnotate()

fun! s:GitBlameCommit(cmd) abort
  let l:hash = expand('<cword>')
  execute a:cmd
  execute 'read !git show '.l:hash
  execute 'setlocal statusline=Commit\ '.l:hash
  setlocal bufhidden=hide buftype=nofile nobuflisted nonumber noswapfile filetype=diff nomodifiable
endf
"}}}

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
if empty(glob('~/.vim/plugins'))
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.vim/plugins')

" Appearance
Plug 'ap/vim-buftabline'
Plug 'sheerun/vim-polyglot'
Plug 'yggdroot/indentLine'
Plug 'sjl/badwolf'

" Code Completion
Plug 'honza/vim-snippets', { 'on': [] }
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', { 'on': ['CocAction', 'CocCommand', 'CocList'], 'tag': '*', 'branch': 'release' }
Plug 'tpope/vim-endwise', { 'on': [] }

" Linting & Formatting
Plug 'tpope/vim-sleuth'
Plug 'w0rp/ale', { 'on': [] }

" Navigation
Plug 'pgdouyon/vim-evanesco'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'tpope/vim-projectionist'
Plug 'valloric/MatchTagAlways', { 'for': ['html', 'javascript.jsx', 'xml'] }

" Misc
Plug 'ludovicchabant/vim-gutentags'
Plug 'mhinz/vim-signify'
Plug 'obxhdx/vim-action-mapper'
Plug 'obxhdx/vim-auto-highlight'
Plug 'tpope/vim-commentary', { 'on': '<Plug>Commentary' }
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-surround'

" Tools
Plug 'junegunn/fzf.vim', { 'on': ['FzBuffers', 'FzCommands', 'FzFiles', 'FzHistory', 'FzLines', 'FzRg'] }
Plug 'metakirby5/codi.vim', { 'on': 'Codi' }

call plug#end()

" Lazy Loading {{{
function! s:LoadCompletionPlugins()
  call plug#load('ale', 'coc.nvim', 'vim-endwise', 'vim-snippets')
  echom 'Snippets + Completion plugins loaded!'
endfunction

augroup LoadCompletionPlugins
  autocmd!
  autocmd CursorHold * call <SID>LoadCompletionPlugins() | autocmd! LoadCompletionPlugins
augroup END
" }}}

" ActionMapper {{{
autocmd! User MapActions

function! FindAndReplaceWithWordBoundary(text)
  let l:use_word_boundary = 1
  execute s:FindAndReplace(a:text, l:use_word_boundary)
endfunction

function! FindAndReplaceWithoutWordBoundary(text)
  let l:use_word_boundary = 0
  execute s:FindAndReplace(a:text, l:use_word_boundary)
endfunction

function! s:FindAndReplace(text, use_word_boundary)
  let l:pattern = a:use_word_boundary ? '<'.a:text.'>' : a:text
  let l:new_text = input('Replace '.l:pattern.' with: ', a:text)

  if len(l:new_text)
    execute ',$s/\v'.l:pattern.'/'.l:new_text.'/gc'
  endif
endfunction

autocmd User MapActions call MapAction('FindAndReplaceWithWordBoundary', '<leader>r')
autocmd User MapActions call MapAction('FindAndReplaceWithoutWordBoundary', '<leader><leader>r')

function! DebugLog(text)
  let l:supported_languages = ['javascript', 'javascript.jsx']
  if index(l:supported_languages, &ft) < 0
    return
  endif
  execute "normal o"
  execute "normal iconsole.log('==> ".substitute(a:text, "'", '"', 'g')."', ".a:text.");"
endfunction

autocmd User MapActions call MapAction('DebugLog', '<leader>l')

"}}}

" Ale {{{
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 'normal'
let g:ale_sign_error = '●'
let g:ale_sign_warning = '●'
let g:ale_warn_about_trailing_whitespace = 1
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = '➜  '

" Use [g and ]g to navigate diagnostics
nmap <silent> [g <Plug>(ale_previous_wrap)
nmap <silent> ]g <Plug>(ale_next_wrap)

function! s:TweakAleColors()
  hi ALEErrorSign ctermfg=red guifg=red
  hi ALEInfoSign ctermfg=cyan guifg=cyan
  hi ALEWarningSign ctermfg=yellow guifg=orange
  hi ALEVirtualTextError guibg=NONE guifg=red
  hi ALEVirtualTextInfo guibg=NONE guifg=cyan
  hi ALEVirtualTextWarning guibg=NONE guifg=yellow
  hi ALEWarning guifg=grey
endfunction
autocmd ColorScheme * call s:TweakAleColors()
" }}}

" AutoHighlightWord {{{
autocmd FileType netrw,qf DisableAutoHighlightWord
set updatetime=500 " Make CursorHold trigger faster
" }}}

" BufTabline {{{
let g:buftabline_show = 1
let g:buftabline_indicators = 1
hi BufTabLineCurrent ctermbg=203 ctermfg=232 guibg=#ff5f5f guifg=#080808
hi BufTabLineActive ctermbg=236 ctermfg=203 guibg=#303030 guifg=#ff5f5f
hi BufTabLineHidden ctermbg=236 guibg=#303030 guifg=#D5C4A1
hi BufTabLineFill ctermbg=236 guibg=#303030 guifg=#D5C4A1
" }}}

" CoC {{{
let g:coc_node_path = expand("$LATEST_NODE_PATH")

" Prettier command (requires coc-prettier)
command! -nargs=0 Prettier :CocCommand prettier.formatFile

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
nmap <silent> <leader>ctd <Plug>(coc-type-definition)
nmap <silent> <leader>ci <Plug>(coc-implementation)
nmap <silent> <leader>cr <Plug>(coc-references)

" Remap for rename current word
nmap <leader>crn <Plug>(coc-rename)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vmap <leader>ca <Plug>(coc-codeaction-selected)
nmap <leader>ca <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>caa <Plug>(coc-codeaction)

" Fix autofix problem of current line
nmap <leader>cf <Plug>(coc-fix-current)

" Find symbol of current document
nnoremap <silent> <space>co :<C-u>CocList outline<cr>

" AutoHighlightWord compatibility
hi! link CocHighlightText AutoHighlightWord

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
  hi ColorColumn ctermbg=237 guibg=#3a3a3a
  hi CursorLine ctermbg=237 term=NONE cterm=NONE guibg=#3a3a3a
  hi LineNr ctermbg=NONE guibg=NONE
  hi MatchParen guibg=NONE
  hi Normal guibg=NONE
  hi Pmenu ctermfg=15 ctermbg=236 guifg=#f8f6f2 guibg=#484A55
  hi PmenuSbar ctermbg=236 guibg=#2B2C31
  hi PmenuThumb ctermbg=236 guibg=grey
  hi SignColumn guibg=NONE
  hi Visual ctermbg=238 guibg=#626262
  hi! link NormalNC ColorColumn
  hi! link VertSplit LineNr

  if g:colors_name == 'badwolf'
    hi Noise guifg=#949494
    hi NonText guibg=NONE
    hi SignifySignAdd guifg=#B8BB26 guibg=#3A3A3A
    hi parens guifg=#9e9e9e
    hi IncSearch guibg=magenta guifg=white gui=bold,reverse
    hi Search guibg=magenta guifg=white
  endif

  hi StatusLine cterm=NONE ctermfg=232 ctermbg=white gui=NONE guifg=#3a3a3a guibg=#d5c4a1
  hi StatusLineNC cterm=NONE ctermfg=15 ctermbg=238 gui=NONE guifg=white guibg=#45413b
  autocmd InsertEnter * hi StatusLine cterm=NONE ctermfg=117 ctermbg=24 gui=NONE guifg=#87dfff guibg=#005f87
  autocmd InsertLeave * hi StatusLine cterm=NONE ctermfg=232 ctermbg=white gui=NOne guifg=#3a3a3a guibg=#d5c4a1
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

" Deoplete {{{
let g:deoplete#enable_at_startup = 1
"}}}

" FZF {{{
set rtp+=/usr/local/opt/fzf
let g:fzf_command_prefix = 'Fz'
let g:fzf_files_options  = '--tiebreak=end' " Prioritize matches that are closer to the end of the string
nnoremap <Leader>fb :FzBuffers<CR>
nnoremap <Leader>fc :FzCommands<CR>
nnoremap <Leader>ff :FzFiles<CR>
nnoremap <Leader>fg :FzRg 
nnoremap <Leader>fh :FzHistory<CR>
nnoremap <Leader>fl :FzLines<CR>
" }}}

" GutenTags {{{
let g:gutentags_ctags_tagfile = '.tags'
let g:gutentags_file_list_command = 'git ls-files'
" }}}

" IndentLine {{{
let g:indentLine_faster = 1
let g:indentLine_char = get(g:, 'indentLine_char', '┊')
let g:indentLine_bufTypeExclude = ['help']
" }}}

" MatchTagAlways {{{
au VimEnter *
      \| let g:mta_filetypes['javascript'] = 1
      \| let g:mta_filetypes['javascript.jsx'] = 1
" }}}

" NERDTree {{{
let g:loaded_netrwPlugin = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeWinSize = '35'
let g:NERDTreeShowHidden = 1
let g:NERDTreeHighlightFolders = 1 " enables folder icon highlighting using exact match
let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name
let g:DevIconsEnableFoldersOpenClose = 1
let g:NERDTreeMapActivateNode = '<CR>'

autocmd FileType nerdtree setlocal signcolumn=no | DisableAutoHighlightWord
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif " close vim when nerdtree is the only open buffer

hi NERDTreeOpenable cterm=NONE ctermfg=darkgray gui=NONE guifg=darkgray
hi link NERDTreeDir NERDTreeOpenable
hi link NERDTreeDirSlash NERDTreeOpenable

fun! s:OpenNERDTree()
  if empty(bufname('%')) || &ft == 'nerdtree'
    NERDTreeToggle
  else
    NERDTreeFind
    normal zz
  endif
endfunction
map <silent> - :call <SID>OpenNERDTree()<CR>
" }}}

" Polyglot {{{
let g:vim_markdown_conceal = 0
"}}}

" Projectionist {{{
let g:projectionist_ignore_term = 1
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

"}}}

" vim: set foldmethod=marker foldenable :

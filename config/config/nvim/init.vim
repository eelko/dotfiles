" General Options " {{{
set wildmenu " Enable command line completion menu
set mouse=a " Enable mouse
" }}}

" Appearance " {{{
set cursorline " Highlight current line
set guicursor=a:hor25-blinkon10,i:ver25-blinkon10 " Switch cursor shape between vertical/underline bar (Insert/Normal)
set list " Show unprintable characters
set listchars=tab:».,trail:⌴,extends:❯,precedes:❮,nbsp:° " Unprintable characters
set number " Display line numbers
set pumheight=8 " Limit completion menu height
set statusline=%<\ %t\ %h%m%r%=%-14.(%l,%c%V%)\ %P\ 
set winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow " Dim inactive windows
hi! link InactiveWindow ColorColumn
" }}}

" Folding " {{{
set foldmethod=indent " Fold based on indent
set nofoldenable " Do not fold by default
" }}}

" Searching " {{{
set ignorecase " Ignore case sensitivity
set smartcase " Enable case-smart searching (overrides ignorecase)
" }}}

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
nnoremap <Leader>w :w<CR>
nnoremap <Leader>x :x<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>d :bd<CR>

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
" }}}

" Functions and Commands "{{{

" Align command (format text in columns) {{{
command! -nargs=1 -range=% Align :execute "<line1>,<line2>!sed 's/" . <f-args> . "/@". <f-args> . "/g' | column -s@ -t"
"}}}

" StripTrailingWhitespaces command {{{
command! StripTrailingWhitespaces :call <SID>ExecPreservingCursorPos('%s/\s\+$//e')
" }}}

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

autocmd BufEnter git-annotate DimInactiveOff
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

" Third-Party Plugins {{{
if empty(glob('~/.vim/plugins'))
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.vim/plugins')

" Appearance
Plug 'sheerun/vim-polyglot'
Plug 'yggdroot/indentLine'
Plug 'sjl/badwolf'

" Code Completion
Plug 'honza/vim-snippets', { 'on': [] }
Plug 'jiangmiao/auto-pairs'
Plug 'shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins', 'on': [] }
Plug 'sirver/ultisnips', { 'on': [] }
Plug 'tpope/vim-endwise'

" Linting & Formatting
Plug 'tpope/vim-sleuth'
Plug 'w0rp/ale', { 'on': [] }

" Navigation
Plug 'junegunn/vim-slash'
Plug 'valloric/MatchTagAlways'

" Misc
Plug 'ludovicchabant/vim-gutentags'
Plug 'mhinz/vim-signify'
Plug 'obxhdx/vim-action-mapper'
Plug 'obxhdx/vim-auto-highlight'
Plug 'tpope/vim-commentary', { 'on': '<Plug>Commentary' }
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-surround'

" Tools
Plug 'christoomey/vim-tmux-navigator'
Plug '~/.fzf', { 'on': ['FzBuffers', 'FzCommands', 'FzFiles', 'FzHistory', 'FzAg'] }
Plug 'junegunn/fzf.vim', { 'on': ['FzBuffers', 'FzCommands', 'FzFiles', 'FzHistory', 'FzAg'] }
Plug 'metakirby5/codi.vim', { 'on': 'Codi' }

call plug#end()

" On-demand Loading {{{
augroup LoadCompletionPlugins
  autocmd!
  autocmd InsertEnter * call plug#load('ale', 'deoplete.nvim', 'ultisnips', 'vim-snippets')
        \| echom 'Snippets + Completion plugins loaded!'
        \| autocmd! LoadCompletionPlugins
augroup END
" }}}

" ActionMapper {{{
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

function! GrepWithFZF(text)
  execute 'FzAg '.a:text
endfunction

autocmd! User MapActions
autocmd User MapActions call MapAction('GrepWithFZF', '<leader>g')
autocmd User MapActions call MapAction('FindAndReplaceWithWordBoundary', '<leader>r')
autocmd User MapActions call MapAction('FindAndReplaceWithoutWordBoundary', '<leader><leader>r')
"}}}

" Ale {{{
let g:ale_sign_error = '●'
let g:ale_sign_warning = '●'
let g:ale_lint_on_text_changed = 1
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1
let g:ale_lint_on_filetype_changed = 0

au ColorScheme * hi ALEErrorSign ctermfg=red guifg=red
au ColorScheme * hi ALEWarningSign ctermfg=yellow guifg=orange
" }}}

" AutoHighlightWord {{{
au ColorScheme * hi! AutoHighlightWord ctermbg=238 guibg=#444444
set updatetime=500 " Make CursorHold trigger faster
" }}}

" Color Scheme {{{
function! SanitizeColors()
  hi ColorColumn ctermbg=237 guibg=#3a3a3a
  hi CursorLine ctermbg=237 term=NONE cterm=NONE guibg=#3a3a3a
  hi LineNr ctermbg=NONE guibg=NONE
  hi Normal guibg=NONE
  hi Pmenu ctermbg=13 ctermfg=black guibg=#d7afff guifg=black
  hi SignColumn guibg=NONE

  if g:colors_name == 'badwolf'
    hi Noise guifg=#949494
    hi NonText guibg=NONE
    hi SignifySignAdd guifg=#B8BB26 guibg=#3A3A3A
    hi VertSplit guibg=NONE guifg=#585858
    hi parens guifg=#9e9e9e
  endif
endf

autocmd BufEnter,InsertEnter,InsertLeave * syn match parens /[][(){}]/
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
let g:fzf_command_prefix = 'Fz'
let g:fzf_files_options  = '--tiebreak=end' " Prioritize matches that are closer to the end of the string
nnoremap <Leader>b :FzBuffers<CR>
nnoremap <Leader>c :FzCommands<CR>
nnoremap <Leader>f :FzFiles<CR>
nnoremap <Leader>h :FzHistory<CR>
" }}}

" GutenTags {{{
let g:gutentags_ctags_tagfile = '.tags'
let g:gutentags_file_list_command = 'git ls-files'
" }}}

" IndentLine {{{
let g:indentLine_char = get(g:, 'indentLine_char', '┊')
" }}}

" Signify {{{
hi SignifySignAdd ctermfg=green ctermbg=NONE guifg=#B8BB26 guibg=NONE
hi SignifySignChange ctermfg=yellow ctermbg=NONE guifg=#FABD30 guibg=NONE
hi SignifySignDelete ctermfg=red ctermbg=NONE guifg=#FB4934 guibg=NONE

let g:signify_sign_add               = '│'
let g:signify_sign_delete            = '│'
let g:signify_sign_delete_first_line = '│'
let g:signify_sign_change            = '│'
let g:signify_sign_changedelete      = g:signify_sign_change
"}}}

" Slash {{{
nnoremap <silent> <plug>(slash-after) :execute 'match IncSearch /\c\%'.virtcol('.').'v\%'.line('.').'l'.@/.'/'<CR>
autocmd CursorMoved * call map(filter(getmatches(), 'v:val.group == "IncSearch"'), { k, v -> matchdelete(v.id) })
"}}}

" UltiSnips {{{
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
"}}}

"}}}

" vim: set foldmethod=marker foldenable :

" --- OPTIONS ---

" Misc
set clipboard+=unnamedplus                                 " Use system clipboard for all operations
set hidden                                                 " Allows buffers to be left unsaved (bp/bn)
set mouse=a                                                " Enable mouse
set noautoread                                             " Don't auto reload files from disk when they change outisde Vim
set noshowmode                                             " Don't show edit mode in command bar
set shell=/bin/bash
set wildmenu                                               " Enable command line completion menu
set wildoptions=tagfile                                    " Use classic completion menu instead of floating window
" Appearance
set cursorline                                             " Highlight current line
set list                                                   " Show unprintable characters
set listchars=tab:».,trail:⌴,extends:❯,precedes:❮,nbsp:°   " Unprintable characters
set number                                                 " Display line numbers
set pumheight=8                                            " Limit completion menu height
set signcolumn=yes                                         " ALways show the sign column
set termguicolors                                          " Enables RGB color in the terminal
set laststatus=3                                           " Enable global statusline
" Folding
set foldmethod=indent                                      " Fold based on indent
set nofoldenable                                           " Do not fold by default
" Formatting
set expandtab                                              " Use spaces instead of tabs
set nowrap                                                 " Disable line wrapping
set shiftwidth=2                                           " Number of spaces used for indentation
set softtabstop=2                                          " Makes <BS> (backspace key) treat two spaces like a tab
set tabstop=2                                              " Number of spaces for each <Tab>
" Searching
set ignorecase                                             " Ignore case sensitivity
set smartcase                                              " Enable case-smart searching (overrides ignorecase)

" --- DISABLE OBSOLETE NATIVE PLUGINS ---

for feature in [
      \ 'netrw',
      \ 'netrwPlugin',
      \ 'netrwSettings',
      \ 'netrwFileHandlers',
      \ 'gzip',
      \ 'zip',
      \ 'zipPlugin',
      \ 'tar',
      \ 'tarPlugin',
      \ 'getscript',
      \ 'getscriptPlugin',
      \ 'vimball',
      \ 'vimballPlugin',
      \ '2html_plugin',
      \ 'logipat',
      \ 'rrhelper',
      \ 'spellfile_plugin'
      \ ]
  execute 'let g:loaded_' . feature . ' = 1'
endfor

" --- AUTOMATIC COMMANDS ---

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

" Remember folds and cursor position on launch
augroup RememberView
  autocmd!
  autocmd BufWinLeave * if !empty(bufname('%')) | mkview | endif
  autocmd BufWinEnter * silent! loadview
augroup END

" Highlight yanked text (NeoVim 0.6.+ only)
augroup HighlightYank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
augroup END

" Better vimdiff
augroup VimDiff
  autocmd!
  autocmd VimEnter * if &diff | set laststatus=2 | silent! windo set signcolumn=no | endif
augroup END

" Restore cursor on leave
augroup RestoreCursor
  autocmd!
  autocmd VimLeave * set guicursor=a:hor20
augroup END

" --- KEY MAPPINGS ---

" Space as leader
let mapleader = " "

" Navigate wrapped lines
nnoremap j gj
nnoremap k gk

" Save/exit quicker
nnoremap <silent> <Leader>q :qall<CR>
nnoremap <silent> <Leader>Q :qall!<CR>
nnoremap <silent> <Leader>w :write<CR>
nnoremap <silent> <Leader>x :xit<CR>

" Expand %% to file path
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" Select last pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Navigate buffers more easily
nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprev<CR>

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

" Give S-Tab some purpose
inoremap <silent> <S-Tab> <C-h>

" Cleverly close buffers (based on reddit.com/em9qvv)
nnoremap <expr><Leader>d (bufnr('%') == getbufinfo({'buflisted': 1})[-1].bufnr ? ':bp' : ':bn').'<bar>bd #<CR>'
nnoremap <expr><Leader>D (bufnr('%') == getbufinfo({'buflisted': 1})[-1].bufnr ? ':bp' : ':bn').'<bar>bd! #<CR>'

" Easily clear search matches
nnoremap <silent> <Esc> :noh<CR>

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

" --- FUNCTIONS AND COMMANDS ---

command! -nargs=1 -range=% Align :execute "<line1>,<line2>!sed 's/" . <f-args> . "/@". <f-args> . "/g' | column -s@ -t"

command! StripTrailingWhitespaces :call SaveCursorPos('%s/\s\+$//e')

" Run substitution commands and restore previous cursor position
function! SaveCursorPos(command)
  let l:current_view = winsaveview()
  execute 'keeppatterns '.a:command
  call histadd('cmd', a:command)
  call winrestview(l:current_view)
endfunction

" Close all other hidden and saved buffers
function! s:CloseOtherBuffers()
  let open_buffers = []
  for i in range(tabpagenr('$'))
    call extend(open_buffers, tabpagebuflist(i+1))
  endfor
  for num in range(1, bufnr('$')+1)
    if buflisted(num) && index(open_buffers, num) == -1
      exec 'bdelete '.num
    endif
  endfor
endfunction
command! CloseOtherBuffers call s:CloseOtherBuffers()

" Show all syntax groups for word under cursor
function! ShowSyntaxGroup()
  if !exists('*synstack')
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

" Grep helper
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

" --- PLUGINS ---

lua pcall(require, 'impatient')
lua require('plugins')

" --- TEMPORARY CONFIGS ---

if filereadable(expand('~/.vimrc.local.vim'))
  source ~/.vimrc.local.vim
endif

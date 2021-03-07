" --- OPTIONS ---

" Misc
set hidden                                                 " Allows buffers to be left unsaved (bp/bn)
set mouse=a                                                " Enable mouse
set noautoread                                             " Don't auto reload files from disk when they change outisde Vim
set noshowmode                                             " Don't show edit mode in command bar
set wildmenu                                               " Enable command line completion menu
set wildoptions=tagfile                                    " Use classic completion menu instead of floating window
" Appearance
set cursorline                                             " Highlight current line
set list                                                   " Show unprintable characters
set listchars=tab:».,trail:⌴,extends:❯,precedes:❮,nbsp:°   " Unprintable characters
set number                                                 " Display line numbers
set pumheight=8                                            " Limit completion menu height
set termguicolors                                          " Enables RGB color in the terminal
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

" Remember cursor position
augroup RememberCursorPosition
  autocmd!
  autocmd BufWinEnter * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"zv" | endif
augroup END

" --- KEY MAPPINGS ---

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

" Easily clear search matches
nnoremap <silent> <Leader><Leader> :noh<CR>

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
function! s:ShowSyntaxGroup()
  if !exists('*synstack')
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
nmap <silent> <leader>sg :call <SID>ShowSyntaxGroup()<CR>

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

" --- STATUSLINE ---

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
        \ . ' %{exists("*DiagnosticsStatus()") ? DiagnosticsStatus() : ""}'
        \ . '%{&ft=="help"?"\ \ ":""}'
        \ . '%{&modified?"":""}'
        \ . '%{&readonly?"":""}'
        \ . '%='
        \ . "%-14.(%l,%c%V%)"
        \ .' %P'
endfunction

" augroup StatusLine
"   autocmd!
"   autocmd VimEnter,WinEnter,BufEnter *
"         \ setlocal statusline& |
"         \ setlocal statusline=%!StatusLineRenderer()
"   autocmd VimLeave,WinLeave,BufLeave *
"         \ setlocal statusline&
" augroup END

" --- PLUGINS ---

lua require('plugins')

" --- TEMPORARY CONFIGS ---

if filereadable(expand('~/.vimrc.local.vim'))
  source ~/.vimrc.local.vim
endif

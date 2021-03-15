local cmd = vim.cmd
local exec = vim.api.nvim_exec
local fn = vim.fn
local scopes = {o = vim.o, b = vim.bo, g = vim.g, w = vim.wo}

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function opt(scope, key, value)
  scopes[scope][key] = value
end

local install_path = fn.stdpath('data')..'/site/pack/packer/opt/paq-nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  cmd('!git clone https://github.com/savq/paq-nvim.git '..install_path)
  cmd 'packadd paq-nvim'
end

cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq
paq { 'savq/paq-nvim', opt = true } -- Let Paq manage itself

-- Colors
paq 'sjl/badwolf'
cmd 'colorscheme badwolf'
exec([[
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
]], false)

-- Tabs
paq 'ap/vim-buftabline'
opt('g', 'buftabline_show', true)
opt('g', 'buftabline_indicators', true)
opt('g', 'buftabline_numbers', 2)
map('n', '<leader>1', '<Plug>BufTabLine.Go(1)', {noremap = false})
map('n', '<leader>2', '<Plug>BufTabLine.Go(2)', {noremap = false})
map('n', '<leader>3', '<Plug>BufTabLine.Go(3)', {noremap = false})
map('n', '<leader>4', '<Plug>BufTabLine.Go(4)', {noremap = false})
map('n', '<leader>5', '<Plug>BufTabLine.Go(5)', {noremap = false})
map('n', '<leader>6', '<Plug>BufTabLine.Go(6)', {noremap = false})
map('n', '<leader>7', '<Plug>BufTabLine.Go(7)', {noremap = false})
map('n', '<leader>8', '<Plug>BufTabLine.Go(8)', {noremap = false})
map('n', '<leader>9', '<Plug>BufTabLine.Go(9)', {noremap = false})
map('n', '<leader>0', '<Plug>BufTabLine.Go(10)', {noremap = false})
exec([[
  hi BufTabLineCurrent gui=bold guibg=#ff5f5f guifg=#080808
  hi BufTabLineActive  gui=bold guibg=#3a3a3a guifg=#ff5f5f
  hi BufTabLineHidden  gui=bold guibg=#3a3a3a guifg=#D5C4A1
  hi BufTabLineFill    gui=bold guibg=#3a3a3a guifg=#D5C4A1
]], false)

-- Language Pack
paq 'sheerun/vim-polyglot'
opt('g', 'vim_markdown_conceal', false)
opt('g', 'vim_markdown_conceal_code_blocks', false)

-- Git Gutter
paq 'mhinz/vim-signify'
opt('g', 'signify_sign_show_count', false)
opt('g', 'signify_priority', 5)
opt('g', 'signify_sign_add', '│')
opt('g', 'signify_sign_delete', '│')
opt('g', 'signify_sign_delete_first_line', '│')
opt('g', 'signify_sign_change', '│')
opt('g', 'signify_sign_changedelete', '│')
exec([[
  hi SignifySignAdd    guifg=#9BB76D guibg=NONE
  hi SignifySignChange guifg=#00AFFF guibg=NONE
  hi SignifySignDelete guifg=#FF5F5F guibg=NONE
]], false)

-- Indentation Guides
paq 'yggdroot/indentLine'
opt('g', 'indentLine_faster', 1)
opt('g', 'indentLine_char', '┊')

-- Auto Pairs
paq 'tmsvg/pear-tree'
opt('g', 'pear_tree_repeatable_expand', false)
opt('g', 'pear_tree_ft_disabled', {''}) -- Disable when no filetype: workaround for new coc input prompt

-- Tmux Integration
paq 'christoomey/vim-tmux-navigator'
opt('g', 'tmux_navigator_no_mappings', true)
map('n', '<m-h>', ':TmuxNavigateLeft<CR>')
map('n', '<m-j>', ':TmuxNavigateDown<CR>')
map('n', '<m-k>', ':TmuxNavigateUp<CR>')
map('n', '<m-l>', ':TmuxNavigateRight<CR>')

-- File Explorer
paq 'kyazdani42/nvim-web-devicons'
paq 'kyazdani42/nvim-tree.lua'
local tree_cb = require('nvim-tree.config').nvim_tree_callback
opt('g', 'nvim_tree_bindings', {
  ['C'] = tree_cb('cd'),
  ['u'] = tree_cb('dir_up'),
  ['x'] = tree_cb('close_node'),
})
opt('g', 'nvim_tree_follow', 1)
opt('g', 'nvim_tree_git_hl', 0)
opt('g', 'nvim_tree_icons', { default='', symlink='' })
opt('g', 'nvim_tree_ignore', { '.git' })
opt('g', 'nvim_tree_indent_markers', 1)
opt('g', 'nvim_tree_show_icons', { git=0, folders=1, files=1 })
opt('g', 'nvim_tree_width_allow_resize', 1)
map('n', '<leader>nf', ':NvimTreeFindFile<CR>')
map('n', '<leader>nt', ':NvimTreeToggle<CR>')

-- Toggle Comments
paq 'tpope/vim-commentary'

-- Misc
paq 'itchyny/vim-qfedit' -- Turn quickfix buffer editable
paq 'tpope/vim-rsi' -- Readline keymaps for command bar
paq 'tpope/vim-surround'

paq { 'iamcco/markdown-preview.nvim', run = vim.fn['mkdp#util#install'] } -- Markdown previewer

paq 'tpope/vim-projectionist'
map('n', '<leader>aa', ':A<CR>')
map('n', '<leader>as', ':AS<CR>')
map('n', '<leader>av', ':AV<CR>')

paq('obxhdx/vim-action-mapper')
exec([[
function! FindAndReplace(text, type)
 let l:use_word_boundary = index(['v', '^V'], a:type) < 0
 let l:pattern = l:use_word_boundary ? '<'.a:text.'>' : a:text
 let l:new_text = input('Replace '.l:pattern.' with: ', a:text)

 if len(l:new_text)
   call SaveCursorPos(',$s/\v'.l:pattern.'/'.l:new_text.'/gc')
 endif
endfunction

autocmd User MapActions call MapAction('FindAndReplace', '<Leader>r')

function! DebugLog(text, ...)
 let javascript_template = "console.log('==> %s:', %s);"
 let supported_languages = { 'java': 'System.out.println("==> %s: " + %s);', 'javascript': javascript_template, 'javascript.jsx': javascript_template, 'javascriptreact': javascript_template, 'python': "print('==> %s:', %s)", 'ruby': 'puts ("==> %s: #{%s}")', 'typescript': javascript_template, 'typescript.jsx': javascript_template, 'typescriptreact': javascript_template }
 let log_expression = get(supported_languages, &ft, '')

 if empty(log_expression)
   echohl ErrorMsg | echo 'DebugLog: filetype "'.&ft.'" not suppported.' | echohl None
   return
 endif

 execute "normal o".printf(log_expression, a:text, a:text)
endfunction

autocmd User MapActions call MapAction('DebugLog', '<leader>l')

function! GrepWithMotion(text, type) "{{{
 execute('Grep '.a:text)
endfunction

autocmd User MapActions call MapAction('GrepWithMotion', '<Leader>g')
]], false)

-- FZF
paq {'junegunn/fzf', hook='fzf#install()'}
paq 'junegunn/fzf.vim'
opt('g', 'fzf_layout', { window = { width = 0.7, height = 0.4 } })
opt('g', 'projectionist_ignore_term', 1)
map('n', '<leader>fb', ':Buffers<CR>')
map('n', '<leader>fc', ':Commands<CR>')
map('n', '<leader>ff', ':Files<CR>')
map('n', '<leader>fh', ':History:<CR>')
map('n', '<leader>fl', ':BLines<CR>')
map('n', '<leader>fr', ':History<CR>')

-- Treesitter
paq {'nvim-treesitter/nvim-treesitter', hook=':TSUpdate'}
paq 'nvim-treesitter/nvim-treesitter-textobjects'
paq 'nvim-treesitter/nvim-treesitter-refactor'

opt('w', 'foldmethod', 'expr')
opt('w', 'foldexpr', 'nvim_treesitter#foldexpr()')

require('nvim-treesitter.configs').setup {
  ensure_installed = "all",

  refactor = {
    highlight_definitions = { enable = true },
    navigation = {
      enable = true,
      keymaps = {
        goto_definition = "gd",
        goto_next_usage = "]u",
        goto_previous_usage = "[u",
      },
    },
    --[[ smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "<leader>cr",
      },
    }, ]] -- FIXME doesn't work very well
  },

  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ib"] = "@block.inner",
        ["ab"] = "@block.outer",
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
}

-- CoC
paq 'neoclide/coc.nvim'
paq 'antoinemadec/coc-fzf'
-- options
opt('g', 'coc_node_path', fn.expand("$LATEST_NODE_PATH"))
opt('w', 'signcolumn', 'yes')
-- mappings
map('n', 'K', ':call ShowDocumentation()<CR>')
map('i', '<C-n>', 'coc#refresh()', {expr = true}) -- Use <C-n> to trigger completion menu

exec([[
  " Echo method signatures
  function! ShowCodeSignature()
    if exists('*CocActionAsync') && &ft =~ '\(java\|type\)script\(react\)\?'
      call CocActionAsync('showSignatureHelp')
    endif
  endfunction

  augroup ShowCodeSignature
    autocmd!
    autocmd User CocJumpPlaceholder call ShowCodeSignature()
    autocmd CursorHoldI * call ShowCodeSignature()
  augroup END

  " A shade of red that is easier on the eyes
  hi CocErrorFLoat guifg=#FF7276

  function! ShowDocumentation()
    if &filetype == 'vim'
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Go-to mappings
  nmap <silent> <leader>cd <Plug>(coc-definition)
  nmap <silent> <leader>ct <Plug>(coc-type-definition)
  nmap <silent> <leader>ci <Plug>(coc-implementation)
  nmap <silent> <leader>cf <Plug>(coc-references)
  nmap <silent> <leader>cr <Plug>(coc-rename)

  " Applying codeAction to the selected region
  " Example: `<leader>caap` for current paragraph
  xmap <silent> <leader>ca  <Plug>(coc-codeaction-selected)
  nmap <silent> <leader>ca  <Plug>(coc-codeaction-selected)

  " Applying codeAction to the current buffer
  nmap <silent> <leader>caa  <Plug>(coc-codeaction)

  " CocFzfList mappings
  nmap <silent> <leader>cc :CocFzfList commands<CR>
  nmap <silent> <leader>co :CocFzfList outline<CR>
  nmap <silent> <leader>cs :CocFzfList symbols<CR>

  " Use `[d` and `]d` to navigate diagnostics
  " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
  nmap <silent> [d <Plug>(coc-diagnostic-prev)
  nmap <silent> ]d <Plug>(coc-diagnostic-next)

  " UltiSnips compatibility
  let g:coc_snippet_next = '<TAB>'
  let g:coc_snippet_prev = '<S-TAB>'

  inoremap <silent><expr> <TAB> pumvisible() ? coc#_select_confirm() : coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : CheckBackSpace() ? "\<TAB>" : coc#refresh()

  function! CheckBackSpace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  function! NumberToSuperscript(number) abort
    if a:number > 9
      return '⁹⁺'
    endif
    return { 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹', }[a:number]
  endfunction

  function! RenderLintSign(count, sign) abort
    return a:count == 0 ? '' : printf('%s%s ', a:sign, NumberToSuperscript(a:count))
  endfunction

  function! DiagnosticsStatus() abort
    let diagnostics = get(b:, 'coc_diagnostic_info', {})
    if empty(diagnostics) | return '' | endif
    let msgs = []

    let info_and_hints = get(diagnostics, 'hint', 0) + get(diagnostics, 'information', 0)
    if info_and_hints
      call add(msgs, RenderLintSign(info_and_hints, '%#StatusLineDiagnosticsHintSign# '))
    endif

    if get(diagnostics, 'warning', 0)
      call add(msgs, RenderLintSign(diagnostics['warning'], '%#StatusLineDiagnosticsWarnSign# '))
    endif

    if get(diagnostics, 'error', 0)
      call add(msgs, RenderLintSign(diagnostics['error'], '%#StatusLineDiagnosticsErrorSign# '))
    endif

    if empty(msgs)
      call add(msgs, '%#StatusLineDiagnosticsClearSign#  ')
    endif

    return join(msgs, '')
  endfunction
]], false)

-- Status Line
paq { 'glepnir/galaxyline.nvim', branch = 'main' }

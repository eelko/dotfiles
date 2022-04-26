require 'utils'

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience
vim.o.updatetime = 300

-- Custom node path
vim.g.coc_node_path = vim.fn.expand '$LATEST_NODE_PATH'

-- Round border corners
vim.g.coc_borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }

-- Use K to show documentation in preview window
map('n', 'K', ':call ShowDocumentation()<CR>', { noremap = false })

vim.cmd [[
function! ShowDocumentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
]]

-- Code navigation mappings
map('n', '<leader>cd', ':Telescope coc definitions<CR>', { noremap = false })
map('n', '<leader>ct', ':Telescope coc declarations<CR>', { noremap = false })
map('n', '<leader>ci', ':Telescope coc implementations<CR>', { noremap = false })
map('n', '<leader>ct', ':Telescope coc type_definitions<CR>', { noremap = false })
map('n', '<leader>cr', ':Telescope coc references<CR>', { noremap = false })
map('n', '<leader>cns', '<Plug>(coc-rename)', { noremap = false })

-- Apply codeAction to the selected region
map('x', '<leader>ca', '<Plug>(coc-codeaction-selected)', { noremap = false })

-- Apply codeAction at curor position
map('n', '<leader>ca', '<Plug>(coc-codeaction-cursor)', { noremap = false })

-- Easily navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
map('n', '[d', '<Plug>(coc-diagnostic-prev)', { noremap = false })
map('n', ']d', '<Plug>(coc-diagnostic-next)', { noremap = false })

-- Show all diagnostics
map('n', '<leader>ce', ':Telescope coc workspace_diagnostics<CR>', { noremap = false })

-- Find any symbol
map('n', '<leader>fs', ':Telescope coc workspace_symbols<CR>', { noremap = false })

-- Find commands
map('n', '<leader>cc', ':Telescope coc commands<CR>', { noremap = false })

-- Remap <C-f> and <C-b> for scroll float windows
vim.cmd [[
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
]]

-- Use Tab to trigger completion, snippet expansion and placeholder navigation
vim.g.coc_snippet_next = '<TAB>'
vim.g.coc_snippet_prev = '<S-TAB>'

map(
  'i',
  '<TAB>',
  'pumvisible() ? coc#_select_confirm() : CheckBackSpace() ? "<TAB>" : coc#refresh()',
  { noremap = true, expr = true, silent = true }
)

vim.cmd [[
function! CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
]]

-- Signature Helper
vim.cmd [[
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
]]

-- Enable Telescope integration
require('telescope').load_extension 'coc'

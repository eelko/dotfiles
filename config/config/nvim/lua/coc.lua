require 'helpers'

for _, package in ipairs {
  'coc-fzf',
  'coc-lightbulb',
  'coc.nvim',
  'vim-efm-langserver-settings',
} do
  local present, _ = pcall(require, package)

  cmd('packadd ' .. package)

  if present then
    print('Missing package: ' .. package .. '. Running PackerInstall... Nvim will exit once this is completed.')

    cmd [[
       autocmd User PackerComplete quitall
       PackerInstall
     ]]
    return
  end
end

opt('g', 'coc_node_path', fn.expand '$LATEST_NODE_PATH') -- Custom node path

cmd 'hi CocErrorFLoat guifg=#FF7276' -- A shade of red that is easier on the eyes
cmd 'hi CocFloatBorder guifg=black guibg=none gui=bold' -- Make float windows blend better with other stuff
cmd 'hi link CocErrorHighlight Noise' -- Get rid of ugly and distracting underline
cmd 'hi link CocFadeOut Noise' -- Make unused vars easier to see
cmd 'hi link CocInfoHighlight Noise' -- Get rid of ugly and distracting underline
cmd 'hi link CocWarningHighlight Noise' -- Get rid of ugly and distracting underline

-- Enhanced keyword lookup
map('n', 'K', ':call CocActionAsync("doHover")<CR>')

-- Code navigation mappings
map('n', '<leader>cd', '<Plug>(coc-definition)', { noremap = false })
map('n', '<leader>ct', '<Plug>(coc-type-definition)', { noremap = false })
map('n', '<leader>ci', '<Plug>(coc-implementation)', { noremap = false })
map('n', '<leader>cf', '<Plug>(coc-references)', { noremap = false })
map('n', '<leader>cr', '<Plug>(coc-rename)', { noremap = false })

-- Display available code actions
map('n', '<leader>ca', '<plug>(coc-codeaction-cursor)', { noremap = false })
map('x', '<leader>ca', '<Plug>(coc-codeaction-selected)', { noremap = false })

-- Easily navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
map('n', '[d', '<Plug>(coc-diagnostic-prev)', { noremap = false })
map('n', ']d', '<Plug>(coc-diagnostic-next)', { noremap = false })

-- Use Tab to trigger completion, snippet expansion and placeholder navigation
opt('g', 'coc_snippet_next', '<TAB>')
opt('g', 'coc_snippet_prev', '<S-TAB>')

map(
  'i',
  '<TAB>',
  'pumvisible() ? coc#_select_confirm() : CheckBackSpace() ? "<TAB>" : coc#refresh()',
  { noremap = true, expr = true, silent = true }
)

cmd [[
function! CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
]]

-- Signature Helper
cmd [[
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

-- CoC + FZF integration
map('n', '<leader>cc', ':CocFzfList commands<CR>', { noremap = false })
map('n', '<leader>co', ':CocFzfList outline<CR>', { noremap = false })
map('n', '<leader>cs', ':CocFzfList symbols<CR>', { noremap = false })

-- Light Bulb
require('coc-lightbulb').setup {
  sign = {
    enabled = true,
    priority = 100,
  },
}

fn.sign_define('LightBulbSign', { text = '', texthl = 'LspDiagnosticsDefaultInformation' })

-- Disable pear-tree when filetype is not set (workaround for CoC prompts on float windows)
opt('g', 'pear_tree_ft_disabled', { '' })

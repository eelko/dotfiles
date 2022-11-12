local keyset = vim.keymap.set
-- Auto complete
function _G.check_back_space()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

-- Use tab for trigger completion with characters ahead and navigate.
-- NOTE: There's always complete item selected by default, you may want to enable
-- no select by `"suggest.noselect": true` in your configuration file.
-- NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
-- other plugin before putting this into your config.
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
-- keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
-- keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice.
keyset('i', '<cr>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
keyset('i', '<c-j>', '<Plug>(coc-snippets-expand-jump)')
-- Use <tab> to trigger completion.
-- keyset("i", "<tab>", "coc#refresh()", {silent = true, expr = true})
keyset('i', '<tab>', [[coc#pum#visible() ? coc#pum#confirm() : coc#refresh()]], opts)

-- Use `[d` and `]d` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
keyset('n', '[d', '<Plug>(coc-diagnostic-prev)', { silent = true })
keyset('n', ']d', '<Plug>(coc-diagnostic-next)', { silent = true })

-- GoTo code navigation.
keyset('n', '<leader>cd', '<Plug>(coc-definition)', { silent = true })
keyset('n', '<leader>ct', '<Plug>(coc-type-definition)', { silent = true })
keyset('n', '<leader>ci', '<Plug>(coc-implementation)', { silent = true })
keyset('n', '<leader>cr', '<Plug>(coc-references)', { silent = true })

-- Use K to show documentation in preview window.
function _G.show_docs()
  local cword = vim.fn.expand '<cword>'

  if vim.fn.index({ 'vim', 'help', 'lua' }, vim.bo.filetype) >= 0 then
    xpcall(vim.api.nvim_command, function(e)
      vim.cmd(string.format("echohl ErrorMsg | echom '%s' | echohl NONE", e))
    end, 'h ' .. cword)
  elseif vim.api.nvim_eval 'coc#rpc#ready()' then
    vim.fn.CocActionAsync 'doHover'
  else
    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cword)
  end
end

keyset('n', 'K', '<CMD>lua _G.show_docs()<CR>', { silent = true })

-- -- Highlight the symbol and its references when holding the cursor.
vim.api.nvim_create_augroup('CocGroup', {})
vim.api.nvim_create_autocmd('CursorHold', {
  group = 'CocGroup',
  command = "silent call CocActionAsync('highlight')",
  desc = 'Highlight symbol under cursor on CursorHold',
})

-- Symbol renaming.
keyset('n', '<leader>cns', '<Plug>(coc-rename)', { silent = true })

-- Formatting selected code.
keyset('x', '<leader>f', '<Plug>(coc-format-selected)', { silent = true })
keyset('n', '<leader>f', '<Plug>(coc-format-selected)', { silent = true })

-- Setup formatexpr specified filetype(s).
vim.api.nvim_create_autocmd('FileType', {
  group = 'CocGroup',
  pattern = 'typescript,json',
  command = "setl formatexpr=CocAction('formatSelected')",
  desc = 'Setup formatexpr specified filetype(s).',
})

-- Update signature help on jump placeholder.
vim.api.nvim_create_autocmd('User', {
  group = 'CocGroup',
  pattern = 'CocJumpPlaceholder',
  command = "call CocActionAsync('showSignatureHelp')",
  desc = 'Update signature help on jump placeholder',
})

-- Applying codeAction to the selected region.
-- Example: `<leader>aap` for current paragraph
local opts = { silent = true, nowait = true }
keyset('x', '<leader>a', '<Plug>(coc-codeaction-selected)', opts)
-- keyset('n', '<leader>a', '<Plug>(coc-codeaction-selected)', opts)

-- Remap keys for applying codeAction to the current buffer.
keyset('n', '<leader>ca', '<Plug>(coc-codeaction-cursor)', opts)

-- Apply AutoFix to problem on the current line.
keyset('n', '<leader>cf', '<Plug>(coc-fix-current)', opts)

-- Run the Code Lens action on the current line.
keyset('n', '<leader>cl', '<Plug>(coc-codelens-action)', opts)

-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server.
keyset('x', 'if', '<Plug>(coc-funcobj-i)', opts)
keyset('o', 'if', '<Plug>(coc-funcobj-i)', opts)
keyset('x', 'af', '<Plug>(coc-funcobj-a)', opts)
keyset('o', 'af', '<Plug>(coc-funcobj-a)', opts)
keyset('x', 'ic', '<Plug>(coc-classobj-i)', opts)
keyset('o', 'ic', '<Plug>(coc-classobj-i)', opts)
keyset('x', 'ac', '<Plug>(coc-classobj-a)', opts)
keyset('o', 'ac', '<Plug>(coc-classobj-a)', opts)

-- Remap <C-f> and <C-b> for scroll float windows/popups.
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
keyset('n', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset('n', '<C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
keyset('i', '<C-f>', 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset('i', '<C-b>', 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset('v', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset('v', '<C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

-- Use CTRL-S for selections ranges.
-- Requires 'textDocument/selectionRange' support of language server.
keyset('n', '<C-s>', '<Plug>(coc-range-select)', { silent = true })
keyset('x', '<C-s>', '<Plug>(coc-range-select)', { silent = true })

-- Add `:Format` command to format current buffer.
vim.api.nvim_create_user_command('Format', "call CocAction('format')", {})

-- " Add `:Fold` command to fold current buffer.
vim.api.nvim_create_user_command('Fold', "call CocAction('fold', <f-args>)", { nargs = '?' })

-- Add `:OR` command for organize imports of the current buffer.
vim.api.nvim_create_user_command('OR', "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

-- Mappings for CoCList
-- code actions and coc stuff
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true }
-- Show all diagnostics.
keyset('n', '<leader>ce', ':<C-u>CocList diagnostics<cr>', opts)
-- -- Manage extensions.
-- keyset("n", "<leader>e", ":<C-u>CocList extensions<cr>", opts)
-- Show commands.
keyset('n', '<leader>cc', ':<C-u>CocList commands<cr>', opts)
-- -- Find symbol of current document.
-- keyset('n', '<leader>co', ':<C-u>CocList outline<cr>', opts)
-- Search workspace symbols.
keyset('n', '<leader>fs', ':<C-u>CocList -I symbols<cr>', opts)
-- -- Do default action for next item.
-- keyset("n", "<leader>j", ":<C-u>CocNext<cr>", opts)
-- -- Do default action for previous item.
-- keyset("n", "<leader>k", ":<C-u>CocPrev<cr>", opts)
-- Resume latest coc list.
keyset('n', '<leader>p', ':<C-u>CocListResume<cr>', opts)

---

vim.o.tagfunc = 'CocTagFunc'

-- Additional mappings
function _G.toggle_outline()
  local winid = vim.api.nvim_eval 'coc#window#find("cocViewId", "OUTLINE")'
  if winid == -1 then
    vim.fn.CocActionAsync('showOutline', 1)
  else
    vim.api.nvim_eval('coc#window#close(' .. winid .. ')')
  end
end
keyset('n', '<leader>co', toggle_outline, opts)

keyset('n', '<leader>chi', ':<C-u>call CocAction("showIncomingCalls")<cr>', opts)
keyset('n', '<leader>cho', ':<C-u>call CocAction("showOutgoingCalls")<cr>', opts)

-- Navigate snippet placeholders with tab/s-tab
vim.g.coc_snippet_next = '<tab>'
vim.g.coc_snippet_prev = '<s-tab>'

-- outline
vim.api.nvim_create_autocmd('FileType', {
  group = 'CocGroup',
  pattern = 'coctree',
  desc = 'Use a more subtle window separator for coctree buffers',
  callback = function()
    for winnr = 1, vim.fn.winnr '$' do
      local winid = vim.fn.win_getid(winnr)
      local bufid = vim.api.nvim_win_get_buf(winid)
      local filetype = vim.api.nvim_buf_get_option(bufid, 'filetype')

      if filetype == 'coctree' then
        -- using a timer to make sure coctree will be visible when the option is set
        vim.fn.timer_start(1, function()
          vim.api.nvim_win_set_option(winid, 'winhighlight', 'WinSeparator:NvimTreeWinSeparator,Normal:NvimTreeNormal')
        end)
      end
    end
  end,
})

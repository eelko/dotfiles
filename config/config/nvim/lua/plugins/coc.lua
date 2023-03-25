return {
  'neoclide/coc.nvim',
  enabled = true,
  event = { 'BufNewFile', 'BufReadPre' },
  branch = 'release',
  config = function()
    vim.o.tagfunc = 'CocTagFunc'

    -- Navigate snippet placeholders with tab/s-tab
    vim.g.coc_snippet_next = '<tab>'
    vim.g.coc_snippet_prev = '<s-tab>'

    -- Mappings
    local map = require('utils').map

    -- Code navigation
    map('n', '[d', '<Plug>(coc-diagnostic-prev)', { desc = '[LSP] Go to previous diagnostic' })
    map('n', ']d', '<Plug>(coc-diagnostic-next)', { desc = '[LSP] Go to next diagnostic' })
    map('n', 'gD', '<Plug>(coc-declaration)', { desc = '[LSP] Go to Declaration' })
    map('n', 'gd', '<Plug>(coc-definition)', { desc = '[LSP] Go to Definition' })
    map('n', 'gi', '<Plug>(coc-implementation)', { desc = '[LSP] Go to Implementation' })
    map('n', 'gr', '<Plug>(coc-references)', { desc = '[LSP] Go to References' })
    map('n', 'gR', '<Plug>(coc-references-used)', { desc = '[LSP] Go to References (excluding declarations)' })
    map('n', 'td', '<Plug>(coc-type-definition)', { desc = '[LSP] Go to Type Definition' })

    map('n', 'K', function()
      local api = vim.api
      local fn = vim.fn
      local cword = fn.expand '<cword>'

      if fn.index({ 'vim', 'help', 'lua' }, vim.bo.filetype) >= 0 then
        xpcall(api.nvim_command, function(e)
          vim.cmd(string.format("echohl ErrorMsg | echom '%s' | echohl NONE", e))
        end, 'h ' .. cword)
      elseif api.nvim_eval 'coc#rpc#ready()' then
        fn.CocActionAsync 'doHover'
      else
        api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cword)
      end
    end, { desc = '[LSP] Show documentation for symbol under cursor' })

    -- Code actions
    map('n', '<leader>r', '<Plug>(coc-rename)', { desc = '[LSP] Rename symbol under cursor' })

    map(
      'x',
      '<leader>a',
      '<Plug>(coc-codeaction-selected)',
      { desc = '[LSP] Apply Code Action to the selected region', nowait = true }
    )
    map(
      'n',
      '<leader>ca',
      '<Plug>(coc-codeaction-cursor)',
      { desc = '[LSP] Apply Code Action to symbol under cursor', nowait = true }
    )
    map(
      'n',
      '<leader>cf',
      '<Plug>(coc-fix-current)',
      { desc = '[LSP] Apply the most preferred auto-fix action for diagnostic under cursor', nowait = true }
    )

    -- List commands
    map('n', '<leader>cc', ':<C-u>CocList commands<cr>', { desc = '[LSP] Show all available LSP commands', nowait = true })
    map('n', '<leader>d', ':<C-u>CocList -A diagnostics<cr>', { desc = '[LSP] Show all diagnostics', nowait = true })
    map('n', '<leader>p', ':<C-u>CocListResume<cr>', { desc = '[LSP] Resume previous CoC list', nowait = true })
    map('n', '<leader>s', ':<C-u>CocList -A -I symbols<cr>', { desc = '[LSP] Search workspace symbols', nowait = true })

    -- Auto complete
    function _G.check_back_space()
      local col = vim.fn.col '.' - 1
      return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
    end

    map('i', '<tab>', 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', {
      desc = '[LSP] Trigger completion with characters ahead and navigate completion menu forward',
      expr = true,
    })
    map('i', '<s-tab>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], {
      desc = '[LSP] Navigate completion menu (or delete tab) backwards',
      expr = true,
    })

    -- Commands
    vim.api.nvim_create_user_command(
      'Fold',
      "call CocAction('fold', <f-args>)",
      { desc = '[LSP] Fold current buffer', nargs = '?' }
    )
    vim.api.nvim_create_user_command('Format', "call CocAction('format')", { desc = '[LSP] Format current buffer' })

    -- Autocommands
    vim.api.nvim_create_augroup('CocGroup', { clear = true })

    vim.api.nvim_create_autocmd('CursorHold', {
      group = 'CocGroup',
      command = "silent call CocActionAsync('highlight')",
      desc = '[LSP] Highlight symbol under cursor on CursorHold',
    })

    vim.api.nvim_create_autocmd('FileType', {
      group = 'CocGroup',
      pattern = 'typescript,json',
      command = "setl formatexpr=CocAction('formatSelected')",
      desc = '[LSP] Setup formatexpr specified filetype(s).',
    })

    vim.api.nvim_create_autocmd('User', {
      group = 'CocGroup',
      pattern = 'CocJumpPlaceholder',
      command = "call CocActionAsync('showSignatureHelp')",
      desc = '[LSP] Update signature help on jump placeholder',
    })
  end,
}

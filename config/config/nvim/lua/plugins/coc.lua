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
    local nmap = function(keys, func, opts)
      if opts.desc then
        opts.desc = '[LSP] ' .. opts.desc
      end

      map('n', keys, func, { desc = opts.desc })
    end

    -- Code navigation
    nmap('[d', '<Plug>(coc-diagnostic-prev)', { desc = 'Go to previous diagnostic' })
    nmap(']d', '<Plug>(coc-diagnostic-next)', { desc = 'Go to next diagnostic' })
    nmap('gD', '<Plug>(coc-declaration)', { desc = 'Go to Declaration' })
    nmap('gd', '<Plug>(coc-definition)', { desc = 'Go to Definition' })
    nmap('gi', '<Plug>(coc-implementation)', { desc = 'Go to Implementation' })
    nmap('gr', '<Plug>(coc-references)', { desc = 'Go to References' })
    nmap('td', '<Plug>(coc-type-definition)', { desc = 'Go to Type Definition' })

    nmap('K', function()
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
    end, { desc = 'Show documentation for symbol under cursor' })

    -- Code actions
    nmap('<leader>r', '<Plug>(coc-rename)', { desc = 'Rename symbol under cursor' })

    map(
      'x',
      '<leader>a',
      '<Plug>(coc-codeaction-selected)',
      { desc = '[LSP] Apply Code Action to the selected region', nowait = true }
    )
    nmap(
      '<leader>ca',
      '<Plug>(coc-codeaction-cursor)',
      { desc = 'Apply Code Action to symbol under cursor', nowait = true }
    )
    nmap(
      '<leader>cf',
      '<Plug>(coc-fix-current)',
      { desc = 'Apply the most preferred auto-fix action for diagnostic under cursor', nowait = true }
    )

    -- List commands
    nmap('<leader>ce', ':<C-u>CocList -A diagnostics<cr>', { desc = 'Show all diagnostics', nowait = true })
    nmap('<leader>cc', ':<C-u>CocList commands<cr>', { desc = 'Show all available LSP commands', nowait = true })
    nmap('<leader>cs', ':<C-u>CocList -A -I symbols<cr>', { desc = 'Search workspace symbols', nowait = true })
    nmap('<leader>p', ':<C-u>CocListResume<cr>', { desc = 'Resume previous CoC list', nowait = true })

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

    map('i', '<cr>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], {
      desc = '[LSP] Accept selected completion item or notify CoC to format',
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

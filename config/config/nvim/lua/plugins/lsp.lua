return {
  'neovim/nvim-lspconfig',
  enabled = false,
  event = { 'BufNewFile', 'BufReadPre' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/nvim-cmp',
    'hrsh7th/vim-vsnip',
    'hrsh7th/vim-vsnip-integ',
    'nvim-tree/nvim-web-devicons',
    'williamboman/mason-lspconfig.nvim',
    'williamboman/mason.nvim',
    'windwp/nvim-autopairs',
  },
  config = function()
    -- LSP
    require('mason').setup()

    local mason_lspconfig = require 'mason-lspconfig'
    mason_lspconfig.setup {
      ensure_installed = { 'cssls', 'efm', 'eslint', 'html', 'jsonls', 'tsserver' },
    }
    mason_lspconfig.setup_handlers {
      -- The first entry (without a key) will be the default handler
      -- and will be called for each installed server that doesn't have
      -- a dedicated handler:
      function(server_name)
        require('lspconfig')[server_name].setup {
          capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
          on_attach = function(client, bufnr)
            -- Mappings
            local nmap = function(keys, func, desc)
              if desc then
                desc = '[LSP] ' .. desc
              end

              require('utils').map('n', keys, func, { buffer = bufnr, desc = desc })
            end

            -- Code navigation
            nmap('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic')
            nmap(']d', vim.diagnostic.goto_next, 'Go to next diagnostic')
            nmap('gD', vim.lsp.buf.declaration, 'Go to Declaration')
            nmap('gd', vim.lsp.buf.definition, 'Go to Definition')
            nmap('gi', vim.lsp.buf.implementation, 'Go to Implementation')
            nmap('gr', require('telescope.builtin').lsp_references, 'Go to References')
            nmap('td', vim.lsp.buf.type_definition, 'Go to Type Definition')

            nmap('K', vim.lsp.buf.hover, 'Show documentation for symbol under cursor')
            nmap('<C-k>', vim.lsp.buf.signature_help, 'Show signature documentation')

            -- Code actions
            nmap('gns', vim.lsp.buf.rename, 'Rename symbol under cursor')
            nmap('<leader>ca', vim.lsp.buf.code_action, 'Apply Code Action to symbol under cursor')

            -- List commands
            nmap('<leader>ce', require('telescope.builtin').diagnostics, 'Show all diagnostics')
            nmap('<leader>cs', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Search workspace symbols')

            -- Commands
            vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
              vim.lsp.buf.format()
            end, { desc = '[LSP] Format current buffer' })

            -- Autocommands
            vim.api.nvim_create_augroup('LspGroup', { clear = false })
            vim.api.nvim_clear_autocmds { buffer = bufnr, group = 'LspGroup' }

            if client.server_capabilities.documentHighlightProvider then
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                group = 'LspGroup',
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
                desc = '[LSP] Highlight symbol under cursor on CursorHold',
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
                desc = '[LSP] Clear highlighted symbol references on CursorMoved',
                group = 'LspGroup',
              })
            end

            vim.api.nvim_create_autocmd('BufWrite', {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format()
              end,
              desc = '[LSP] Format current buffer on save',
              group = 'LspGroup',
            })
          end,
        }
      end,
    }

    -- Snippets
    vim.g.vsnip_filetypes = {
      javascriptreact = { 'javascript' },
      typescript = { 'javascript' },
      typescriptreact = { 'javascript', 'javascriptreact' },
    }

    vim.g.vsnip_snippet_dir = vim.fn.stdpath 'config' .. '/snippets'

    -- Autocomplete
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
    end

    local feedkey = function(key, mode)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
    end

    local cmp = require 'cmp'
    cmp.setup {
      snippet = {
        expand = function(args)
          vim.fn['vsnip#anonymous'](args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert {
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<tab>'] = cmp.mapping.complete(),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<cr>'] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.fn['vsnip#available'](1) == 1 then
            feedkey('<Plug>(vsnip-expand-or-jump)', '')
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<s-tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.fn['vsnip#jumpable'](-1) == 1 then
            feedkey('<Plug>(vsnip-jump-prev)', '')
          else
            fallback()
          end
        end, { 'i', 's' }),
      },
      sources = cmp.config.sources {
        { name = 'vsnip' },
        { name = 'nvim_lsp' },
      },
    }

    -- Autopairs
    require('nvim-autopairs').setup {}
    cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done()) -- insert `(` after picking a function or method from the autocomplete menu
  end,
}

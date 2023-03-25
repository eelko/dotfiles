return {
  'neovim/nvim-lspconfig',
  enabled = false,
  event = { 'BufNewFile', 'BufReadPre' },
  dependencies = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/nvim-cmp',
    'hrsh7th/vim-vsnip',
    'hrsh7th/vim-vsnip-integ',
    'jose-elias-alvarez/null-ls.nvim',
    'kosayoda/nvim-lightbulb',
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'onsails/lspkind.nvim',
    'williamboman/mason-lspconfig.nvim',
    'williamboman/mason.nvim',
    'windwp/nvim-autopairs',
  },
  config = function()
    local map = require('utils').map
    local augroup = vim.api.nvim_create_augroup('LspGroup', { clear = true })

    -- LSP
    require('mason').setup()

    local mason_lspconfig = require 'mason-lspconfig'
    mason_lspconfig.setup {
      ensure_installed = { 'cssls', 'html', 'jsonls', 'tsserver' },
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

              map('n', keys, func, { buffer = bufnr, desc = desc })
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
            nmap('<leader>r', vim.lsp.buf.rename, 'Rename symbol under cursor')
            nmap('<leader>ca', vim.lsp.buf.code_action, 'Apply Code Action to symbol under cursor')

            -- List commands
            nmap('<leader>d', require('telescope.builtin').diagnostics, 'Show all diagnostics')
            nmap('<leader>s', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Search workspace symbols')

            -- Commands
            vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
              vim.lsp.buf.format()
            end, { desc = '[LSP] Format current buffer' })

            -- Autocommands
            if client.server_capabilities.documentHighlightProvider then
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
                desc = '[LSP] Highlight symbol under cursor on CursorHold',
                group = augroup,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
                desc = '[LSP] Clear highlighted symbol references on CursorMoved',
                group = augroup,
              })
            end

            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = bufnr,
              callback = function()
                vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor' })
              end,
              desc = '[LSP] Show diagnostics under cursor on CursorHold',
              group = augroup,
            })

            -- Light bulb
            require('nvim-lightbulb').setup {
              sign = {
                enabled = false,
              },
              virtual_text = {
                enabled = true,
                text = '',
                -- highlight mode to use for virtual text (replace, combine, blend), see :help nvim_buf_set_extmark() for reference
                hl_mode = 'combine',
              },
              autocmd = {
                enabled = true,
                pattern = { '*' },
                events = { 'CursorHold', 'CursorHoldI' },
              },
            }
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

    local lspkind = require 'lspkind' -- Icons for completion menu
    local cmp = require 'cmp'

    cmp.setup {
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      formatting = {
        format = lspkind.cmp_format(),
      },
      mapping = cmp.mapping.preset.insert {
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
      snippet = {
        expand = function(args)
          vim.fn['vsnip#anonymous'](args.body)
        end,
      },
      sources = cmp.config.sources {
        { name = 'vsnip' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    }

    -- `/` cmdline setup.
    cmp.setup.cmdline('/', {
      formatting = {
        fields = { 'abbr', 'menu' },
      },
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      },
    })

    -- `:` cmdline setup.
    cmp.setup.cmdline(':', {
      formatting = {
        fields = { 'abbr', 'menu' },
      },
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' },
      }, {
        {
          name = 'cmdline',
          option = {
            ignore_cmds = { 'Man', '!' },
          },
        },
      }),
    })

    -- Autopairs
    require('nvim-autopairs').setup {}
    cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done()) -- insert `(` after picking a function or method from the autocomplete menu

    -- Linters/Formatters
    local null_ls = require 'null-ls'
    local code_actions = null_ls.builtins.code_actions
    local diagnostics = null_ls.builtins.diagnostics
    local formatting = null_ls.builtins.formatting

    null_ls.setup {
      on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format { bufnr = bufnr }
          end,
          desc = '[LSP] Format current buffer on save',
          group = augroup,
        })
      end,
      sources = {
        -- Eslint
        code_actions.eslint_d,
        diagnostics.eslint_d.with {
          filter = function(diagnostic)
            return diagnostic.code ~= 'prettier/prettier' -- ignore prettier warnings from eslint-plugin-prettier
          end,
        },
        formatting.eslint_d,

        -- Fixjson
        formatting.fixjson,

        -- Hadolint
        diagnostics.hadolint,

        -- Jsonlint
        diagnostics.jsonlint,

        -- Prettier
        formatting.prettierd,

        -- Shellcheck
        code_actions.shellcheck,
        diagnostics.shellcheck,

        -- Shellharden
        formatting.shellharden,

        -- Shfmt
        formatting.shfmt,

        -- Stylua
        formatting.stylua,

        -- Vale
        diagnostics.vale,

        -- Yamllint
        diagnostics.yamllint,
      },
    }
  end,
}

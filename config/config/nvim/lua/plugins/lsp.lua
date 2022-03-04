require 'helpers'

-- Hover/Signature with borders
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})

-- Signature Helper
require('lsp_signature').setup {
  hint_enable = false,
}

-- Snippets
vim.g.vsnip_filetypes = {
  javascriptreact = { 'javascript', 'typescriptreact' },
  typescript = { 'javascript' },
  typescriptreact = { 'javascript', 'typescriptreact' },
}

vim.g.vsnip_snippet_dir = fn.stdpath 'config' .. '/snippets'

-- Completion
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require 'cmp'

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },

  documentation = {
    border = 'rounded',
    winhighlight = 'FloatBorder:FloatBorder,Normal:Normal',
  },

  experimental = {
    ghost_text = true,
  },

  formatting = {
    format = require('lspkind').cmp_format {
      with_text = true,
      menu = {
        nvim_lsp = '[LSP]',
        nvim_lua = '[Lua]',
      },
    },
  },

  mapping = {
    ['<C-e>'] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },

    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },

    ['<Tab>'] = cmp.mapping {
      c = function(fallback)
        if cmp.visible() then
          cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
        else
          fallback()
        end
      end,
      i = function(fallback)
        if vim.fn['vsnip#available']() == 1 then
          feedkey('<Plug>(vsnip-expand-or-jump)', '')
        elseif cmp.visible() then
          cmp.confirm()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback() -- The fallback function sends an already mapped key. In this case, it's probably `<Tab>`.
        end
      end,
      s = function(fallback)
        if vim.fn['vsnip#available']() == 1 then
          feedkey('<Plug>(vsnip-expand-or-jump)', '')
        else
          fallback() -- The fallback function sends an already mapped key. In this case, it's probably `<Tab>`.
        end
      end,
    },

    ['<S-Tab>'] = cmp.mapping(function()
      if vim.fn['vsnip#jumpable'](-1) == 1 then
        feedkey('<Plug>(vsnip-jump-prev)', '')
      end
    end, {
      'i',
      's',
    }),
  },

  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },

  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
}

-- Use buffer source for '/'
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' },
  },
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  sources = cmp.config.sources {
    { name = 'cmdline' },
    { name = 'path' },
  },
})

-- auto-pairs integration
cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done {}) -- inserts `()` after selecting a function or method item

-- null-ls
local on_attach_formatting = function(client)
  if client.resolved_capabilities.document_formatting then
    vim.cmd [[
      augroup LspFormatting
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
      augroup END
    ]]
  end
end

local null_ls = require 'null-ls'
null_ls.setup {
  on_attach = on_attach_formatting,
  sources = {
    -- Code Actions
    null_ls.builtins.code_actions.proselint,
    -- Diagnostics
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.diagnostics.proselint,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.vale,
    null_ls.builtins.diagnostics.write_good,
    -- Formatting
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.markdownlint,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.shfmt,
    null_ls.builtins.formatting.stylua,
  },
}

-- LSP progress bar
require('fidget').setup {
  text = {
    spinner = 'dots',
  },
}

-- LSP server registration
local on_attach = function(client)
  -- Format buffer on save
  on_attach_formatting(client)

  if client.name == 'tsserver' then
    -- Leave formatting for null-ls
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false

    -- Fix code action ranges and filter diagnostics
    local ts_utils = require 'nvim-lsp-ts-utils'
    ts_utils.setup {}
    ts_utils.setup_client(client)
  end

  -- Options
  vim.b.omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Diagnostic Config
  local format_diagnostic = function(diagnostic)
    return string.format('[%s] %s', diagnostic.source, diagnostic.message)
  end

  vim.diagnostic.config {
    float = {
      format = format_diagnostic,
    },
    underline = {
      severity = { max = vim.diagnostic.severity.INFO },
    },
    severity_sort = true,
    virtual_text = {
      format = format_diagnostic,
      severity = { min = vim.diagnostic.severity.WARN },
    },
  }

  -- Diagnostics Signs and Colors
  for _, type in pairs { 'Error', 'Warn', 'Hint', 'Info' } do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = '', texthl = hl, numhl = '', priority = 1 })
  end

  -- Mappings
  map('n', '<leader>cd', ':lua vim.lsp.buf.definition()<CR>')
  map('n', '<leader>cD', ':lua vim.lsp.buf.declaration()<CR>')
  map('n', '<leader>ci', ':lua vim.lsp.buf.implementation()<CR>')
  map('n', '<leader>ct', ':lua vim.lsp.buf.type_definition()<CR>')
  map('n', '<leader>cr', ':lua vim.lsp.buf.references()<CR>')
  map('n', '<leader>cns', ':lua vim.lsp.buf.rename()<CR>')

  -- diagnostics
  map('n', '[d', ':lua vim.diagnostic.goto_prev()<CR>')
  map('n', ']d', ':lua vim.diagnostic.goto_next()<CR>')
  map('n', '<leader>ce', ':lua vim.diagnostic.open_float()<CR>')
  map('n', '<leader>cE', ':Telescope diagnostics<CR>')

  -- signature helpers
  map('n', 'K', ':lua vim.lsp.buf.hover()<CR>:lua vim.lsp.buf.hover()<CR>') -- calling twice as a workaround for flickering caused by vimade
  map('n', '<c-k>', ':lua vim.lsp.buf.signature_help()<CR>')

  -- code actions
  map('n', '<leader>ca', ':lua vim.lsp.buf.code_action()<CR>')
  map('v', '<leader>ca', ':Telescope lsp_range_code_actions theme=cursor<CR>')

  -- typescript helpers
  map('n', '<leader>co', ':TSLspOrganize<CR>')
  map('n', '<leader>cnf', ':TSLspRenameFile<CR>')
  map('n', '<leader>cI', ':TSLspImportAll<CR>')

  -- Light Bulb
  fn.sign_define('LightBulbSign', { text = '', linehl = '', numhl = '' })
  cmd 'autocmd CursorHold,CursorHoldI <buffer> lua require("nvim-lightbulb").update_lightbulb()'
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local flags = {
  debounce_text_changes = 150,
}

local server_opts = {
  ['emmet_ls'] = function(opts)
    opts.filetypes = { 'html', 'css', 'typescriptreact', 'javascriptreact' }
  end,
}

for _, server_name in
  ipairs {
    'bashls',
    'cssls',
    'dockerls',
    'emmet_ls',
    'eslint',
    'html',
    'jsonls',
    'pyright',
    'tsserver',
    'yamlls',
  }
do
  local ok, lsp_server = require('nvim-lsp-installer.servers').get_server(server_name)

  if ok and not lsp_server:is_installed() then
    print('LSP server ' .. server_name .. ' not installed. Will attempt to install it.')

    lsp_server:install()
    cmd 'au VimEnter * LspInstallInfo'
  end

  require('nvim-lsp-installer').on_server_ready(function(server)
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities,
      flags = flags,
    }

    if server_opts[server.name] then
      server_opts[server.name](opts)
    end

    server:setup(opts)
    cmd 'do User LspAttachBuffers'
  end)
end

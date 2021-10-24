require 'helpers'

-- Hover/Signature with borders
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})

-- Light Bulb
-- fn.sign_define('LightBulbSign', { text = '', texthl = 'CmpItemKind', linehl = '', numhl = '' })
fn.sign_define('LightBulbSign', { text = '', linehl = '', numhl = '' })
cmd 'autocmd CursorHold,CursorHoldI * lua require("nvim-lightbulb").update_lightbulb()'

-- Signature Helper
require('lsp_signature').setup {
  hint_enable = false,
}

-- Snippets
vim.g.vsnip_filetypes = {
  javascriptreact = { 'javascript' },
  typescript = { 'javascript' },
  typescriptreact = { 'javascript' },
}

vim.g.vsnip_snippet_dir = fn.stdpath 'config' .. '/snippets'

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
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },

    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm()
      elseif vim.fn['vsnip#available']() == 1 then
        feedkey('<Plug>(vsnip-expand-or-jump)', '')
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, {
      'i',
      's',
    }),

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
    { name = 'buffer' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'vsnip' },
  },
}

-- auto-pairs integration
require('nvim-autopairs.completion.cmp').setup {
  map_cr = true, -- map <CR> on insert mode
  map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
  auto_select = true, -- automatically select the first item
  insert = false, -- use insert confirm behavior instead of replace
}

-- null-ls
local null_ls = require 'null-ls'
null_ls.config {
  sources = {
    -- Code Actions
    null_ls.builtins.code_actions.proselint,
    -- Diagnostics
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.diagnostics.prettier,
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

-- LSP server registration
local on_attach = function(client)
  if client.resolved_capabilities.document_formatting then
    -- Format buffer on save
    cmd 'autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()'
  end

  if client.name == 'tsserver' then
    -- Leave formatting for null-ls
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false

    -- Fix code action ranges and filter diagnostics
    require('nvim-lsp-ts-utils').setup_client(client)
  end

  -- Options
  vim.b.omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Diagnostics Signs and Colors
  for _, type in pairs { 'Error', 'Warning', 'Hint', 'Information' } do
    local hl = 'LspDiagnosticsSign' .. type
    vim.fn.sign_define(hl, { text = '', texthl = hl, numhl = '', priority = 1 })
  end

  -- Mappings
  map('n', '<leader>cd', ':lua vim.lsp.buf.definition()<CR>')
  map('n', '<leader>cD', ':lua vim.lsp.buf.declaration()<CR>')
  map('n', '<leader>ci', ':lua vim.lsp.buf.implementation()<CR>')
  map('n', '<leader>ct', ':lua vim.lsp.buf.type_definition()<CR>')
  map('n', '<leader>cr', ':lua vim.lsp.buf.references()<CR>')
  map('n', '<leader>cn', ':lua vim.lsp.buf.rename()<CR>')

  -- diagnostics
  map('n', '[d', ':lua vim.lsp.diagnostic.goto_prev()<CR>')
  map('n', ']d', ':lua vim.lsp.diagnostic.goto_next()<CR>')
  map('n', '<leader>ee', ':Telescope lsp_document_diagnostics<CR>')
  map('n', '<leader>ew', ':Telescope lsp_workspace_diagnostics<CR>')

  -- signature helpers
  map('n', 'K', ':lua vim.lsp.buf.hover()<CR>')
  map('n', '<c-k>', ':lua vim.lsp.buf.signature_help()<CR>')

  -- code actions
  map('n', '<leader>ca', ':lua vim.lsp.buf.code_action()<CR>')
  map('v', '<leader>ca', ':Telescope lsp_range_code_actions theme=cursor<CR>')
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

local flags = {
  debounce_text_changes = 150,
}

for _, server_name in ipairs {
  'bashls',
  'cssls',
  'dockerls',
  'emmet_ls',
  'eslint',
  'html',
  'jsonls',
  'null-ls',
  'pyright',
  'sumneko_lua',
  'tsserver',
  'yamlls',
} do
  local ok, lsp_server = require('nvim-lsp-installer.servers').get_server(server_name)

  if ok and not lsp_server:is_installed() then
    print('LSP server ' .. server_name .. ' not installed. Will attempt to install it.')

    lsp_server:install()
    cmd 'au VimEnter * LspInstallInfo'
  end

  local server_opts = {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = flags,
  }

  if server_name == 'null-ls' then
    require('lspconfig')[server_name].setup(server_opts)
  else
    require('nvim-lsp-installer').on_server_ready(function(server)
      server:setup(server_opts)
      cmd 'do User LspAttachBuffers'
    end)
  end
end

require 'helpers'

-- Diagnostic Config
local format_diagnostic = function(diagnostic)
  if diagnostic.code then
    return string.format('[%s:%s] %s', diagnostic.source, diagnostic.code, diagnostic.message)
  else
    return string.format('[%s] %s', diagnostic.source, diagnostic.message)
  end
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

-- Diagnostics Signs
for _, type in pairs { 'Error', 'Warn', 'Hint', 'Info' } do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = '', texthl = hl, numhl = '', priority = 1 })
end

-- Hover/Signature with borders
local border_opts = {
  border = 'single',
}
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, border_opts)
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, border_opts)

-- Mappings
map('n', '<leader>cd', vim.lsp.buf.definition)
map('n', '<leader>cD', vim.lsp.buf.declaration)
map('n', '<leader>ci', vim.lsp.buf.implementation)
map('n', '<leader>ct', vim.lsp.buf.type_definition)
map('n', '<leader>cr', vim.lsp.buf.references)
map('n', '<leader>cns', vim.lsp.buf.rename)
-- diagnostics
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)
map('n', '<leader>ce', vim.diagnostic.open_float)
-- signature helpers
map('n', 'K', function()
  -- calling twice as a workaround for flickering caused by vimade
  vim.lsp.buf.hover()
  vim.lsp.buf.hover()
end)
map('i', '<C-k>', vim.lsp.buf.signature_help)
-- code actions
map('n', '<leader>ca', vim.lsp.buf.code_action)
-- typescript helpers
map('n', '<leader>co', ':TSLspOrganize<CR>')
map('n', '<leader>cnf', ':TSLspRenameFile<CR>')
map('n', '<leader>cI', ':TSLspImportAll<CR>')
-- Telescope
map('n', '<leader>fs', ':Telescope lsp_dynamic_workspace_symbols<CR>', { noremap = true })
map('n', '<leader>cE', ':Telescope diagnostics<CR>')
map('v', '<leader>ca', ':Telescope lsp_range_code_actions theme=cursor<CR>')

-- LSP server registration
local format_on_save = function(client)
  if client.resolved_capabilities.document_formatting then
    vim.cmd [[
      augroup LspFormatting
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
      augroup END
    ]]
  end
end

local leave_formatting_for_null_ls = function(client)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false
end

local on_attach = function(client)
  -- Options
  vim.b.omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Format buffer on save
  if contains({ 'tsserver' }, client.name) then
    leave_formatting_for_null_ls(client)
  else
    format_on_save(client)
  end

  -- Fix code action ranges and filter diagnostics
  if client.name == 'tsserver' then
    local ts_utils = require 'nvim-lsp-ts-utils'
    ts_utils.setup {}
    ts_utils.setup_client(client)
  end
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
    -- 'bashls',
    -- 'cssls',
    -- 'dockerls',
    'efm',
    'emmet_ls',
    -- 'eslint',
    -- 'html',
    -- 'jsonls',
    -- 'pyright',
    'tsserver',
    -- 'yamlls',
  }
do
  local ok, lsp_server = require('nvim-lsp-installer.servers').get_server(server_name)

  if ok and not lsp_server:is_installed() then
    lsp_server:install()
    vim.cmd 'au VimEnter * LspInstallInfo'
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
    vim.cmd 'do User LspAttachBuffers'
  end)
end

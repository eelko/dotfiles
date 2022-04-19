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
    border = 'rounded',
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

-- Show all diagnostics on current line on CursorHold
function ShowAllDiagnostics(opts, bufnr, line_nr, client_id)
  bufnr = bufnr or 0
  line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)
  opts = opts or { ['lnum'] = line_nr }

  local line_diagnostics = vim.diagnostic.get(bufnr, opts)
  if #line_diagnostics > 1 then
    vim.diagnostic.open_float()
  end
end

vim.cmd [[ autocmd! CursorHold * lua ShowAllDiagnostics() ]]

-- Hover/Signature with borders
local border_opts = {
  border = 'rounded',
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
  if contains({ 'vim', 'help' }, vim.o.filetype) then
    vim.cmd('silent! h ' .. vim.fn.expand '<cword>')
  else
    -- calling twice as a workaround for flickering caused by vimade
    vim.lsp.buf.hover()
    vim.lsp.buf.hover()
  end
end)
map('i', '<C-k>', vim.lsp.buf.signature_help)
-- code actions
map('n', '<leader>ca', vim.lsp.buf.code_action)
-- typescript helpers
map('n', '<leader>co', ':TSLspOrganize<CR>')
map('n', '<leader>cnf', ':TSLspRenameFile<CR>')
map('n', '<leader>cI', ':TSLspImportAll<CR>')
-- Telescope
map('n', '<leader>cE', ':Telescope diagnostics<CR>')
map('n', '<leader>fs', ':Telescope lsp_dynamic_workspace_symbols<CR>', { noremap = true })
map('n', '<leader>ca', ':Telescope lsp_code_actions theme=cursor<CR>')
map('v', '<leader>ca', ':Telescope lsp_range_code_actions theme=cursor<CR>')

-- LSP server registration
local on_attach = function(client)
  vim.b.omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Fix code action ranges and filter diagnostics
  if client.name == 'tsserver' then
    local ts_utils = require 'nvim-lsp-ts-utils'
    ts_utils.setup {}
    ts_utils.setup_client(client)
  end

  -- Format on save
  vim.cmd [[
    augroup LspFormatting
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
    augroup END
  ]]

  if client.name ~= 'efm' then
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
  end

  -- Highlight current symbol
  if client.resolved_capabilities.document_highlight then
    vim.cmd [[
      augroup LspDocumentHighlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end
end

local special_opts = {
  ['emmet_ls'] = function(opts)
    opts.filetypes = { 'html', 'css', 'typescriptreact', 'javascriptreact' }
  end,
}

for _, server_name in ipairs {
  'efm',
  'emmet_ls',
  'tsserver',
} do
  local ok, lsp_server = require('nvim-lsp-installer.servers').get_server(server_name)

  if ok and not lsp_server:is_installed() then
    lsp_server:install()
    vim.cmd 'autocmd! VimEnter * LspInstallInfo'
  end

  require('nvim-lsp-installer').on_server_ready(function(server)
    local common_opts = {
      capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
      on_attach = on_attach,
    }

    if special_opts[server.name] then
      special_opts[server.name](common_opts)
    end

    server:setup(common_opts)
    vim.cmd 'do User LspAttachBuffers'
  end)
end

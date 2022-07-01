require 'utils'

-- Hover/Diagnostic borders
local open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or { { ' ', 'FloatBorder' } }
  return open_floating_preview(contents, syntax, opts, ...)
end

-- Diagnostic Config
local format_diagnostic = function(diagnostic)
  local icons = {
    [vim.diagnostic.severity.ERROR] = ' ',
    [vim.diagnostic.severity.WARN] = ' ',
    [vim.diagnostic.severity.INFO] = ' ',
    [vim.diagnostic.severity.HINT] = ' ',
  }
  local icon = icons[diagnostic.severity]

  if diagnostic.code then
    return string.format('%s [%s:%s] %s', icon, diagnostic.source, diagnostic.code, diagnostic.message)
  else
    return string.format('%s [%s] %s', icon, diagnostic.source, diagnostic.message)
  end
end

vim.diagnostic.config {
  float = {
    format = format_diagnostic,
  },
  severity_sort = true,
  signs = false,
  virtual_text = {
    format = format_diagnostic,
    prefix = '',
  },
}

-- Diagnostic Handlers

-- Create a custom namespace. This will aggregate signs from all other
-- namespaces and only show the one with the highest severity on a
-- given line
---@param original_handler A reference to a handler, e.g. `vim.diagnostic.handlers.signs`.
---@param namespace The return of `vim.api.nvim_create_namespace`.
---@return A modified version of the handler that only shows the diagnostic with highest severity.
function filter_diagnostics(original_handler, namespace)
  local new_handler = {
    show = function(_, bufnr, _, opts)
      -- Get all diagnostics from the whole buffer rather than just the
      -- diagnostics passed to the handler
      local diagnostics = vim.diagnostic.get(bufnr)

      -- For each line, find the diagnostic with highest severity
      local max_severity_per_line = {}
      for _, d in pairs(diagnostics) do
        local m = max_severity_per_line[d.lnum]
        if not m or d.severity < m.severity then
          max_severity_per_line[d.lnum] = d
        end
      end

      -- Pass the filtered diagnostics (with the custom namespace) to
      -- the original handler
      local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
      original_handler.show(namespace, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(_, bufnr)
      original_handler.hide(namespace, bufnr)
    end,
  }

  return new_handler
end

local namespace = vim.api.nvim_create_namespace 'my_namespace'
vim.diagnostic.handlers.signs = filter_diagnostics(vim.diagnostic.handlers.signs, namespace)
vim.diagnostic.handlers.virtual_text = filter_diagnostics(vim.diagnostic.handlers.virtual_text, namespace)

-- Diagnostics Signs
for _, type in pairs { 'Error', 'Warn', 'Hint', 'Info' } do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = '', texthl = hl, numhl = '', priority = 1 })
end

-- Show all diagnostics on current line on CursorHold
function show_all_diagnostics(opts, bufnr, line_nr, client_id)
  bufnr = bufnr or 0
  line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)
  opts = opts or { ['lnum'] = line_nr }

  local line_diagnostics = vim.diagnostic.get(bufnr, opts)
  if #line_diagnostics > 1 then
    vim.diagnostic.open_float()
  end
end

vim.cmd [[ autocmd! CursorHold * lua show_all_diagnostics() ]]

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
map('n', '<leader>fs', ':Telescope lsp_dynamic_workspace_symbols<CR>')

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
  ['jsonls'] = function(opts)
    opts.settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
      },
    }
  end,
}

for _, server_name in ipairs {
  'efm',
  'jsonls',
  'tsserver',
} do
  local common_opts = {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    on_attach = on_attach,
  }

  if special_opts[server_name] then
    special_opts[server_name](common_opts)
  end

  require('lspconfig')[server_name].setup(common_opts)
end

require 'utils'

-- Borderless floats for hover info and diagnostics
local open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or { { ' ', 'FloatBorder' } }
  return open_floating_preview(contents, syntax, opts, ...)
end

-- Custom diagnostic messages
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
  signs = false, -- disable signs on gutter
  virtual_text = {
    format = format_diagnostic,
    prefix = '',
  },
}

-- Diagnostic Handlers

-- Aggregate diagnostics from all other namespaces and only show the one with
-- the highest severity on a given line
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
    vim.lsp.buf.hover()
  end
end)
map('i', '<C-k>', vim.lsp.buf.signature_help)
-- Telescope
map('n', '<leader>cE', ':Telescope diagnostics<CR>')
map('n', '<leader>fs', ':Telescope lsp_dynamic_workspace_symbols<CR>')

-- LSP server registration
local on_attach = function(client, bufnr)
  -- Format on save
  if client.supports_method 'textDocument/formatting' then
    vim.cmd [[
      augroup LspFormatting
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format({name = 'efm'})
      augroup END
    ]]
  end

  -- Highlight current symbol
  if client.supports_method 'textDocument/documentHighlight' then
    vim.cmd [[
      augroup LspDocumentHighlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end

  -- Code context
  if client.supports_method 'textDocument/documentSymbol' then
    local navic = require 'nvim-navic'
    navic.setup {
      highlight = true,
      separator = '  ',
    }
    navic.attach(client, bufnr)

    -- show context on winbar
    vim.wo.winbar = " %{%v:lua.require'nvim-navic'.get_location()%}"
  end
end

local lspconfig = require 'lspconfig'

local servers = {
  efm = {},
  cssls = {},
  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
      },
    },
  },
}

local build_opts = function(opts)
  opts['on_attach'] = on_attach
  opts['capabilities'] = require('cmp_nvim_lsp').default_capabilities()
  return opts
end

for name, config in pairs(servers) do
  lspconfig[name].setup(build_opts(config))
end

-- tsserver
require('typescript').setup {
  server = build_opts {},
}

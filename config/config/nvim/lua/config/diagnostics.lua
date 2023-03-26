local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }

-- Redefine gutter signs
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Format diagnostic messages to include icon and error code, when available
local format_diagnostic = function(diagnostic)
  local icons = {
    [vim.diagnostic.severity.ERROR] = signs.Error,
    [vim.diagnostic.severity.WARN] = signs.Warn,
    [vim.diagnostic.severity.INFO] = signs.Hint,
    [vim.diagnostic.severity.HINT] = signs.Info,
  }
  local icon = icons[diagnostic.severity]

  if diagnostic.code then
    return string.format('%s [%s:%s] %s', icon, diagnostic.source, diagnostic.code, diagnostic.message)
  else
    return string.format('%s [%s] %s', icon, diagnostic.source, diagnostic.message)
  end
end

-- Diagnostic settings
vim.diagnostic.config {
  float = {
    format = format_diagnostic,
  },
  severity_sort = true,
  virtual_text = false,
}

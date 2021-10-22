local present, staline = pcall(require, 'staline')

if not present then
  return false
end

local icons = {
  branch = '',
  lsp = ' ',
  separator = '❘',
  diagnostics = {
    Error = ' ',
    Hint = '',
    Info = ' ',
    Information = ' ',
    Warning = ' ',
  },
}

function _G.coc_status()
  local has_status, status = pcall(vim.api.nvim_get_var, 'coc_status')
  return has_status and icons.separator .. ' ' .. icons.lsp .. ' ' .. string.gsub(status, '^%s+', '') or ''
end

function _G.coc_diagnostics()
  local has_diagnostics, diagnostics = pcall(vim.api.nvim_buf_get_var, 0, 'coc_diagnostic_info')

  if not has_diagnostics then
    return ''
  end

  local counts = {}

  for type, sign in pairs(icons.diagnostics) do
    local count = diagnostics[string.lower(type)] or 0

    if count > 0 then
      table.insert(counts, sign .. count)
    end
  end

  return '   ' .. table.concat(counts, ' ')
end

function _G.active_lsp_clients()
  local buffer_filetype = vim.api.nvim_buf_get_option(0, 'filetype')
  local active_clients = vim.lsp.get_active_clients()

  if #active_clients == 0 then
    return ''
  end

  local clients = {}

  for _, client in ipairs(active_clients) do
    local filetypes = client.config.filetypes

    if filetypes and vim.fn.index(filetypes, buffer_filetype) ~= -1 then
      if not contains(clients, client.name) then
        table.insert(clients, client.name)
      end
    end
  end

  if #clients == 0 then
    return ''
  end

  return icons.separator .. ' ' .. icons.lsp .. ' ' .. table.concat(clients, ' ')
end

function _G.lsp_messages()
  local messages = vim.lsp.util.get_progress_messages()

  if #messages == 0 then
    return ''
  end

  local result = {}
  local spinners = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
  local ms = vim.loop.hrtime() / 1000000
  local frame = math.floor(ms / 120) % #spinners
  local i = 1

  for _, msg in pairs(messages) do
    -- Only display at most 2 progress messages at a time to avoid clutter
    if i < 3 then
      table.insert(result, (msg.percentage or 0) .. '% ' .. (msg.title or ''))
      i = i + 1
    end
  end

  return ' ' .. spinners[frame + 1] .. ' ' .. table.concat(result, ' ')
end

function _G.branch_name()
  if not pcall(require, 'plenary') then
    return ''
  end

  local branch_name = require('plenary.job'):new({
    command = 'git',
    args = { 'branch', '--show-current' },
  }):sync()[1]

  return branch_name and icons.separator .. ' ' .. icons.branch .. ' ' .. branch_name .. ' ' or ''
end

local statusline_fg = '#444444'

staline.setup {
  defaults = {
    left_separator = icons.separator,
    right_separator = icons.separator,
    line_column = '%l,%c%V %P',
    fg = '#d5c4a1',
    bg = '#d5c4a1',
    branch_symbol = ' ',
    inactive_color = '#8a8a8a',
    inactive_bgcolor = '#4e4e4e',
  },
  lsp_symbols = icons.diagnostics,
  mode_colors = {
    ['n'] = statusline_fg,
    ['v'] = statusline_fg,
    ['V'] = statusline_fg,
    ['i'] = statusline_fg,
    ['ic'] = statusline_fg,
    ['s'] = statusline_fg,
    ['S'] = statusline_fg,
    ['c'] = statusline_fg,
    ['t'] = statusline_fg,
    ['r'] = statusline_fg,
    ['R'] = statusline_fg,
    [''] = statusline_fg,
  },
  mode_icons = {
    n = 'N ',
    R = ' ',
  },
  sections = {
    left = {
      '- ',
      '-mode',
      'file_name',
      "%{luaeval('branch_name()')}",
      -- Native LSP
      "%{luaeval('active_lsp_clients()')}",
      'lsp',
      -- CoC
      "%{luaeval('coc_status()')}",
      "%{luaeval('coc_diagnostics()')}",
    },
    mid = {},
    right = { 'line_column' },
  },
}

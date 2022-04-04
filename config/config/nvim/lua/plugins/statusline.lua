local config = require 'tokyonight.config'
local colors = require('tokyonight.colors').setup(config)
local custom_theme = require 'lualine.themes.tokyonight'
require 'helpers'

custom_theme.command = {
  a = { bg = colors.magenta, fg = colors.black },
  b = { bg = colors.fg_gutter, fg = colors.magenta },
}

custom_theme.visual = {
  a = { bg = colors.yellow, fg = colors.black },
  b = { bg = colors.fg_gutter, fg = colors.yellow },
}

local function active_lsp_clients()
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
  else
    local icon = ''
    return icon .. ' ' .. table.concat(clients, ' ')
  end
end

local function coc_status()
  if isempty(vim.g.coc_status) then
    return ''
  end
  return ' ' .. vim.g.coc_status
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = custom_theme,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { 'NvimTree', 'neo-tree' },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {
      {
        'mode',
        padding = 2,
        fmt = function()
          local mode_icons = {
            ['n'] = 'N',
            ['i'] = '',
            ['v'] = '',
            ['V'] = '',
            [''] = '',
            ['c'] = '',
            ['t'] = '',
            ['!'] = '',
            ['r'] = '﯒',
            ['r?'] = '',
            ['R'] = '',
          }
          return mode_icons[vim.fn.mode()]
        end,
      },
    },
    lualine_b = {
      { 'filename', symbols = { modified = '  ', readonly = '  ' } },
    },
    lualine_c = {
      { 'branch', icon = '' },
      { active_lsp_clients },
      { coc_status },
      { 'diagnostics', sources = { 'nvim_diagnostic', 'coc' } },
    },
    lualine_x = {},
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}

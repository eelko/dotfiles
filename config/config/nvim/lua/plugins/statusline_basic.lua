require 'utils'

local config = require 'tokyonight.config'
local colors = require('tokyonight.colors').setup(config)
local custom_theme = require 'lualine.themes.tokyonight'

require('lualine').setup {
  options = {
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    theme = {
      normal = {
        a = { bg = '#303650', fg = '#a9b1d6' },
        b = { bg = '#303650', fg = '#a9b1d6' },
        c = { bg = '#303650', fg = '#a9b1d6' },
      },
      inactive = {
        a = { bg = '#1f2335', fg = '#a9b1d6' },
        b = { bg = '#1f2335', fg = '#a9b1d6' },
        c = { bg = '#1f2335', fg = '#a9b1d6' },
      },
    },
  },
  sections = {
    lualine_a = { { 'mode', color = { gui = 'bold' } } },
    lualine_b = {
      { 'branch', icon = '', padding = { left = 2 } },
      {
        'diff',
        diff_color = {
          added = { fg = colors.git.add },
          modified = { fg = colors.git.change },
          removed = { fg = colors.git.delete },
        },
        symbols = { added = ' ', modified = '柳', removed = ' ' },
      },
    },
    lualine_c = {
      { 'filetype', colored = false, icon_only = true, padding = { left = 2 } },
      {
        'filename',
        symbols = { modified = '  ', readonly = '  ' },
        cond = function()
          return not contains({ 'NvimTree', 'neo-tree', 'TelescopePrompt' }, vim.o.filetype)
        end,
      },
      { 'diagnostics', sources = { 'nvim_diagnostic', 'coc' } },
    },
    lualine_x = {},
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

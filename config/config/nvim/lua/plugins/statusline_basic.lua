require 'utils'

local config = require 'tokyonight.config'
local colors = require('tokyonight.colors').setup(config)
local theme = require 'lualine.themes.tokyonight'

local bg = theme.normal.b.bg
local fg = theme.normal.c.fg

require('lualine').setup {
  options = {
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    theme = {
      normal = {
        a = { bg = bg, fg = fg },
        b = { bg = bg, fg = fg },
        c = { bg = bg, fg = fg },
      },
    },
  },
  sections = {
    lualine_a = { { 'mode', color = { gui = 'bold' } } },
    lualine_b = {
      { 'branch', icon = '', padding = { left = 3 } },
      { 'diff' },
    },
    lualine_c = {
      { 'filetype', colored = false, icon_only = true, padding = { left = 3 } },
      {
        'filename',
        symbols = { modified = ' ', readonly = ' ' },
        cond = function()
          return not contains({ 'NvimTree', 'TelescopePrompt' }, vim.o.filetype)
        end,
      },
      { 'diagnostics', icon = ' ', sources = { 'nvim_diagnostic' }, padding = { left = 3 } },
    },
    lualine_x = {},
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

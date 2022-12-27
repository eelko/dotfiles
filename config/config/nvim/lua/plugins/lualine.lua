local contains = require('utils').contains

local function split_name()
  if vim.bo.buftype == 'nofile' then
    return ''
  end

  local wininfo = vim.fn.getwininfo()
  local open_files = 0

  for id, win in pairs(wininfo) do
    if vim.fn.bufname(win.bufnr) ~= '' then
      open_files = open_files + 1
    end
  end

  return (open_files > 1) and '%f' or ''
end

return {
  'nvim-lualine/lualine.nvim',
  event = 'UIEnter',
  config = function()
    local config = require 'tokyonight.config'
    local colors = require('tokyonight.colors').setup(config)
    local theme = require 'lualine.themes.tokyonight'

    local bg = theme.normal.b.bg
    local fg = theme.normal.c.fg

    require('lualine').setup {
      options = {
        component_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = { 'list' },
        },
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
          { 'g:coc_status', icon = '', padding = { left = 3 } },
          { 'diagnostics', icon = ' ', sources = { 'coc', 'nvim_lsp' }, padding = { left = 3 } },
        },
        lualine_x = {
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
            color = { fg = colors.orange },
          },
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      winbar = {
        lualine_a = { { split_name, color = 'WinBar' } },
      },
      inactive_winbar = {
        lualine_a = { { split_name, color = 'WinBarNC' } },
      },
    }
  end,
}

return {
  'nvim-lualine/lualine.nvim',
  event = 'UIEnter',
  config = function()
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

    require('lualine').setup {
      options = {
        component_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = { 'list' },
        },
        section_separators = { left = '', right = '' },
        theme = 'monotone',
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
            symbols = { modified = '󰆓 ', readonly = ' ' },
            cond = function()
              local contains = require('utils').contains
              return not contains({ 'NvimTree', 'TelescopePrompt' }, vim.o.filetype)
            end,
          },
          { 'g:coc_status', icon = '', padding = { left = 3 } },
          { 'diagnostics', icon = ' ', sources = { 'coc', 'nvim_workspace_diagnostic' }, padding = { left = 3 } },
        },
        lualine_x = {
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
            color = { fg = 'orange' },
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
      extensions = { 'quickfix', 'nvim-tree' },
    }
  end,
}

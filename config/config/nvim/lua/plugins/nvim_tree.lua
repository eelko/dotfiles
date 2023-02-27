return {
  'nvim-tree/nvim-tree.lua',
  keys = {
    { '\\', ':NvimTreeToggle<CR>', silent = true },
  },
  config = function()
    local utils = require 'utils'
    local map = utils.map
    local highlight = utils.highlight

    local config = require 'tokyonight.config'
    local colors = require('tokyonight.colors').setup(config)

    highlight('NvimTreeCursorLine', { bg = colors.bg_highlight })
    highlight('NvimTreeFolderIcon', { bg = colors.none, fg = '#8094b4' }) -- classic folder color
    highlight('NvimTreeGitIgnored', { fg = colors.comment, italic = false })
    highlight('NvimTreeWinSeparator', { bg = colors.bg, fg = colors.bg })

    require('nvim-tree').setup {
      hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
      filters = {
        custom = { '.DS_Store', '.git' },
      },
      git = {
        ignore = false,
      },
      renderer = {
        highlight_git = true,
        icons = {
          glyphs = {
            default = '',
            git = {
              unstaged = '',
              staged = '',
              unmerged = '',
              renamed = '➜',
              untracked = '',
              deleted = '',
              ignored = '',
            },
            symlink = '',
          },
        },
        indent_markers = {
          enable = true,
        },
        root_folder_modifier = ':t',
      },
      update_focused_file = {
        enable = true, -- highlight current file
      },
      view = {
        hide_root_folder = true,
        width = 40,
      },
    }
  end,
}

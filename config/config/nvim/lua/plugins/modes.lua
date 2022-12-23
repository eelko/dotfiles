local highlight = require('utils').highlight

return {
  'mvllow/modes.nvim',
  event = 'VeryLazy',
  config = function()
    require('modes').setup {
      set_cursorline = false,
    }

    -- Highlight numbers fg only
    highlight('ModesCopyCursorLineNr', { fg = '#f5c359', bold = true })
    highlight('ModesInsertCursorLineNr', { fg = '#78ccc5', bold = true })
    highlight('ModesDeleteCursorLineNr', { fg = '#c75c6a', bold = true })
    highlight('ModesVisualCursorLineNr', { fg = '#9745be', bold = true })

    -- Don't highlight sign column
    highlight('ModesCopyCursorLineSign', { bg = 'none' })
    highlight('ModesInsertCursorLineSign', { bg = 'none' })
    highlight('ModesDeleteCursorLineSign', { bg = 'none' })
    highlight('ModesVisualCursorLineSign', { bg = 'none' })
  end,
}

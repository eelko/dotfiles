return {
  'mvllow/modes.nvim',
  enabled = false,
  event = 'VeryLazy',
  config = function()
    require('modes').setup {
      set_cursorline = false,
    }

    local highlight = require('utils').highlight

    -- Highlight numbers fg only
    highlight('ModesCopyCursorLineNr', { fg = '#f5c359', bold = true })
    highlight('ModesInsertCursorLineNr', { fg = '#78ccc5', bold = true })
    highlight('ModesDeleteCursorLineNr', { fg = '#c75c6a', bold = true })
    highlight('ModesVisualCursorLineNr', { fg = '#9745be', bold = true })

    -- Don't highlight fold and sign columns
    for _, mode in pairs { 'Copy', 'Insert', 'Delete', 'Visual' } do
      highlight('Modes' .. mode .. 'CursorLineFold', { bg = 'none' })
      highlight('Modes' .. mode .. 'CursorLineSign', { bg = 'none' })
    end
  end,
}

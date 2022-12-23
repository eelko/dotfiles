return {
  'akinsho/bufferline.nvim',
  event = 'UIEnter',
  config = function()
    vim.o.mousemoveevent = true

    local config = require 'tokyonight.config'
    local colors = require('tokyonight.colors').setup(config)

    require('bufferline').setup {
      highlights = {
        buffer_selected = {
          fg = colors.fg_dark,
          bold = false,
          italic = false,
        },
        close_button_selected = {
          fg = colors.comment,
        },
      },
      options = {
        buffer_close_icon = '',
        diagnostics = false,
        hover = {
          enabled = true,
          delay = 100,
          reveal = { 'close' },
        },
        max_name_length = 50,
        modified_icon = '',
        offsets = {
          {
            filetype = 'NvimTree',
            text = function()
              return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            end,
            text_align = 'center',
          },
        },
      },
    }
  end,
}

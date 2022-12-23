return {
  'lukas-reineke/indent-blankline.nvim',
  event = 'UIEnter',
  config = function()
    require('indent_blankline').setup {
      show_current_context = true,
      show_first_indent_level = false,
      show_trailing_blankline_indent = false,
    }
  end,
}
